CREATE OR REPLACE FUNCTION topup_coins(
  p_user_id UUID,
  p_coins INTEGER,
  p_amount_ils NUMERIC,
  p_payment_method TEXT DEFAULT 'mock'
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_current_balance INTEGER;
  v_new_balance INTEGER;
BEGIN
  -- Lock and read current balance
  SELECT style_coin_balance INTO v_current_balance
  FROM profiles WHERE id = p_user_id FOR UPDATE;

  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'error', 'user_not_found');
  END IF;

  IF p_coins <= 0 THEN
    RETURN jsonb_build_object('success', false, 'error', 'invalid_coin_amount');
  END IF;

  v_new_balance := v_current_balance + p_coins;

  -- Insert real_money_purchase record
  INSERT INTO real_money_purchases (user_id, amount_ils, coins_purchased, payment_method, status, completed_at)
  VALUES (p_user_id, p_amount_ils, p_coins, p_payment_method, 'completed', now());

  -- Insert transaction record
  INSERT INTO transactions (user_id, type, amount, description, balance_after)
  VALUES (
    p_user_id, 'topup', p_coins,
    'Topped up ' || p_coins || ' Style Coins',
    v_new_balance
  );

  -- Update profile balance
  UPDATE profiles SET style_coin_balance = v_new_balance WHERE id = p_user_id;

  RETURN jsonb_build_object('success', true, 'new_balance', v_new_balance);
END;
$$;
