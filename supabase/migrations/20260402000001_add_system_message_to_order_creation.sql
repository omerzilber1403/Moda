-- Update lock_coins_for_order to create an initial system message
-- This ensures the chat appears in the inbox immediately after purchase

CREATE OR REPLACE FUNCTION lock_coins_for_order(p_buyer_id UUID, p_item_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
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

  -- Create initial system message so the chat appears in inbox
  INSERT INTO messages (order_id, sender_id, content, type, sent_at)
  VALUES (
    v_order_id,
    p_buyer_id,
    'Order created — chat with the seller to arrange pickup!',
    'system',
    now()
  );

  RETURN jsonb_build_object('success', true, 'order_id', v_order_id);
END;
$$;
