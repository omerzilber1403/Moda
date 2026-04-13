-- Escrow purchase flow: lock coins on order creation, release only after dual pickup confirmation

-- Add pickup confirmation columns to orders
ALTER TABLE orders ADD COLUMN IF NOT EXISTS buyer_confirmed_pickup BOOLEAN NOT NULL DEFAULT false;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS seller_confirmed_pickup BOOLEAN NOT NULL DEFAULT false;

-- Add ready_for_pickup status to order_status enum
ALTER TYPE order_status ADD VALUE IF NOT EXISTS 'ready_for_pickup';

-- ---------------------------------------------------------------------------
-- lock_coins_for_order
-- Deducts coins from buyer, creates a pending order, deactivates the item.
-- Coins are NOT transferred to the seller yet — they are held in escrow.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.lock_coins_for_order(p_buyer_id uuid, p_item_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  v_item clothing_items%ROWTYPE;
  v_buyer_balance INTEGER;
  v_order_id UUID;
BEGIN
  -- Lock the item row
  SELECT * INTO v_item FROM clothing_items
  WHERE id = p_item_id AND is_active = true
  FOR UPDATE;

  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'error', 'item_not_available');
  END IF;

  IF v_item.owner_id = p_buyer_id THEN
    RETURN jsonb_build_object('success', false, 'error', 'cannot_buy_own_item');
  END IF;

  -- Check and lock buyer balance
  SELECT style_coin_balance INTO v_buyer_balance
  FROM profiles WHERE id = p_buyer_id FOR UPDATE;

  IF v_buyer_balance < v_item.price_in_coins THEN
    RETURN jsonb_build_object('success', false, 'error', 'insufficient_balance');
  END IF;

  -- Create order in PENDING status
  INSERT INTO orders (buyer_id, seller_id, item_id, price_in_coins, status)
  VALUES (p_buyer_id, v_item.owner_id, p_item_id, v_item.price_in_coins, 'pending')
  RETURNING id INTO v_order_id;

  -- Deduct from buyer (coins are locked, not transferred)
  UPDATE profiles SET style_coin_balance = style_coin_balance - v_item.price_in_coins
  WHERE id = p_buyer_id;

  -- Buyer transaction: locked
  INSERT INTO transactions (user_id, type, amount, description, balance_after)
  VALUES (
    p_buyer_id, 'purchase', -v_item.price_in_coins,
    'Locked: ' || v_item.title,
    v_buyer_balance - v_item.price_in_coins
  );

  -- Deactivate item so no one else can buy it
  UPDATE clothing_items SET is_active = false WHERE id = p_item_id;

  -- Clean up buyer's cart
  DELETE FROM cart_items WHERE user_id = p_buyer_id AND item_id = p_item_id;

  RETURN jsonb_build_object('success', true, 'order_id', v_order_id);
END;
$function$;

-- ---------------------------------------------------------------------------
-- confirm_pickup
-- Records that one party confirms the pickup occurred.
-- When BOTH buyer and seller have confirmed, coins are credited to the seller
-- and the order is marked completed.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.confirm_pickup(p_user_id uuid, p_order_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  v_order orders%ROWTYPE;
  v_seller_balance_after INTEGER;
  v_item_title TEXT;
BEGIN
  -- Lock the order row
  SELECT * INTO v_order FROM orders
  WHERE id = p_order_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'error', 'order_not_found');
  END IF;

  -- Order must be pending or confirmed
  IF v_order.status NOT IN ('pending', 'confirmed', 'ready_for_pickup') THEN
    RETURN jsonb_build_object('success', false, 'error', 'order_not_eligible');
  END IF;

  -- Determine which party is confirming
  IF p_user_id = v_order.buyer_id THEN
    UPDATE orders SET buyer_confirmed_pickup = true WHERE id = p_order_id;
    v_order.buyer_confirmed_pickup := true;
  ELSIF p_user_id = v_order.seller_id THEN
    UPDATE orders SET seller_confirmed_pickup = true WHERE id = p_order_id;
    v_order.seller_confirmed_pickup := true;
  ELSE
    RETURN jsonb_build_object('success', false, 'error', 'not_a_party');
  END IF;

  -- If both confirmed, complete the transaction
  IF v_order.buyer_confirmed_pickup AND v_order.seller_confirmed_pickup THEN
    -- Credit seller
    UPDATE profiles SET style_coin_balance = style_coin_balance + v_order.price_in_coins
    WHERE id = v_order.seller_id
    RETURNING style_coin_balance INTO v_seller_balance_after;

    -- Get item title for transaction record
    SELECT title INTO v_item_title FROM clothing_items WHERE id = v_order.item_id;

    -- Seller transaction record
    INSERT INTO transactions (user_id, type, amount, description, balance_after)
    VALUES (
      v_order.seller_id, 'sale', v_order.price_in_coins,
      'Sale: ' || coalesce(v_item_title, 'Item'),
      v_seller_balance_after
    );

    -- Mark order completed
    UPDATE orders SET status = 'completed', completed_at = now()
    WHERE id = p_order_id;

    RETURN jsonb_build_object('success', true, 'completed', true);
  END IF;

  RETURN jsonb_build_object('success', true, 'completed', false);
END;
$function$;

-- ---------------------------------------------------------------------------
-- cancel_order
-- Refunds the locked coins to the buyer, re-activates the item,
-- and marks the order as cancelled.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.cancel_order(p_user_id uuid, p_order_id uuid, p_reason text DEFAULT NULL)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  v_order orders%ROWTYPE;
  v_buyer_balance_after INTEGER;
  v_item_title TEXT;
BEGIN
  SELECT * INTO v_order FROM orders WHERE id = p_order_id FOR UPDATE;

  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'error', 'order_not_found');
  END IF;

  IF v_order.status IN ('completed', 'cancelled') THEN
    RETURN jsonb_build_object('success', false, 'error', 'order_already_finalized');
  END IF;

  IF p_user_id != v_order.buyer_id AND p_user_id != v_order.seller_id THEN
    RETURN jsonb_build_object('success', false, 'error', 'not_a_party');
  END IF;

  -- Refund buyer
  UPDATE profiles SET style_coin_balance = style_coin_balance + v_order.price_in_coins
  WHERE id = v_order.buyer_id
  RETURNING style_coin_balance INTO v_buyer_balance_after;

  SELECT title INTO v_item_title FROM clothing_items WHERE id = v_order.item_id;

  -- Refund transaction
  INSERT INTO transactions (user_id, type, amount, description, balance_after)
  VALUES (
    v_order.buyer_id, 'refund', v_order.price_in_coins,
    'Refund: ' || coalesce(v_item_title, 'Item'),
    v_buyer_balance_after
  );

  -- Re-activate item
  UPDATE clothing_items SET is_active = true WHERE id = v_order.item_id;

  -- Cancel order
  UPDATE orders SET
    status = 'cancelled',
    cancelled_at = now(),
    cancelled_by = p_user_id,
    cancellation_reason = p_reason
  WHERE id = p_order_id;

  RETURN jsonb_build_object('success', true);
END;
$function$;
