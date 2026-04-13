-- Helper: insert a notification row
CREATE OR REPLACE FUNCTION create_notification(
  p_user_id UUID,
  p_type TEXT,
  p_title TEXT,
  p_body TEXT,
  p_data JSONB DEFAULT '{}'
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO notifications (user_id, type, title, body, data)
  VALUES (p_user_id, p_type::notification_type, p_title, p_body, p_data);
END;
$$;

-- Trigger: new message -> notify recipient
CREATE OR REPLACE FUNCTION trigger_message_notification()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_order orders%ROWTYPE;
  v_recipient_id UUID;
  v_sender_name TEXT;
BEGIN
  SELECT * INTO v_order FROM orders WHERE id = NEW.order_id;
  IF NOT FOUND THEN RETURN NEW; END IF;

  -- Recipient is the other participant
  v_recipient_id := CASE
    WHEN NEW.sender_id = v_order.buyer_id THEN v_order.seller_id
    ELSE v_order.buyer_id
  END;

  SELECT display_name INTO v_sender_name FROM profiles WHERE id = NEW.sender_id;

  PERFORM create_notification(
    v_recipient_id,
    'new_message',
    'New message from ' || coalesce(v_sender_name, 'someone'),
    left(NEW.content, 80),
    jsonb_build_object('order_id', NEW.order_id, 'sender_id', NEW.sender_id)
  );

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS notify_new_message ON messages;
CREATE TRIGGER notify_new_message
  AFTER INSERT ON messages
  FOR EACH ROW EXECUTE FUNCTION trigger_message_notification();

-- Trigger: order status change -> notify buyer
CREATE OR REPLACE FUNCTION trigger_order_notification()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_item_title TEXT;
BEGIN
  IF NEW.status = OLD.status THEN RETURN NEW; END IF;

  SELECT title INTO v_item_title FROM clothing_items WHERE id = NEW.item_id;

  IF NEW.status = 'ready_for_pickup' THEN
    PERFORM create_notification(
      NEW.buyer_id,
      'order_ready',
      'Ready for pickup!',
      coalesce(v_item_title, 'Your item') || ' is ready to collect.',
      jsonb_build_object('order_id', NEW.id)
    );
  ELSIF NEW.status = 'completed' THEN
    PERFORM create_notification(
      NEW.seller_id,
      'order_completed',
      'Order completed',
      'Your sale of ' || coalesce(v_item_title, 'an item') || ' is complete.',
      jsonb_build_object('order_id', NEW.id)
    );
  ELSIF NEW.status = 'cancelled' THEN
    -- Notify both parties
    PERFORM create_notification(
      NEW.buyer_id,
      'order_cancelled',
      'Order cancelled',
      coalesce(v_item_title, 'An order') || ' has been cancelled.',
      jsonb_build_object('order_id', NEW.id)
    );
    PERFORM create_notification(
      NEW.seller_id,
      'order_cancelled',
      'Order cancelled',
      coalesce(v_item_title, 'An order') || ' has been cancelled.',
      jsonb_build_object('order_id', NEW.id)
    );
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS notify_order_update ON orders;
CREATE TRIGGER notify_order_update
  AFTER UPDATE OF status ON orders
  FOR EACH ROW EXECUTE FUNCTION trigger_order_notification();

-- Trigger: item liked -> notify owner
CREATE OR REPLACE FUNCTION trigger_like_notification()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_item clothing_items%ROWTYPE;
  v_liker_name TEXT;
BEGIN
  SELECT * INTO v_item FROM clothing_items WHERE id = NEW.item_id;
  IF NOT FOUND OR v_item.owner_id = NEW.user_id THEN RETURN NEW; END IF;

  SELECT display_name INTO v_liker_name FROM profiles WHERE id = NEW.user_id;

  PERFORM create_notification(
    v_item.owner_id,
    'item_liked',
    'Someone liked your item',
    coalesce(v_liker_name, 'Someone') || ' liked "' || v_item.title || '"',
    jsonb_build_object('item_id', NEW.item_id, 'liker_id', NEW.user_id)
  );

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS notify_item_liked ON likes;
CREATE TRIGGER notify_item_liked
  AFTER INSERT ON likes
  FOR EACH ROW EXECUTE FUNCTION trigger_like_notification();
