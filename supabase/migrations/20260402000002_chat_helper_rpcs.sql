-- Helper RPCs for efficient chat list queries

-- Get the last message for each order
CREATE OR REPLACE FUNCTION get_last_messages(p_order_ids UUID[])
RETURNS TABLE (
  id UUID,
  order_id UUID,
  sender_id UUID,
  content TEXT,
  type message_type,
  sent_at TIMESTAMPTZ,
  read_at TIMESTAMPTZ
)
LANGUAGE sql
STABLE
AS $$
  SELECT DISTINCT ON (order_id)
    id, order_id, sender_id, content, type, sent_at, read_at
  FROM messages
  WHERE order_id = ANY(p_order_ids)
  ORDER BY order_id, sent_at DESC;
$$;

-- Get unread message counts per order for a specific user
CREATE OR REPLACE FUNCTION get_unread_counts(p_order_ids UUID[], p_user_id UUID)
RETURNS TABLE (
  order_id UUID,
  count BIGINT
)
LANGUAGE sql
STABLE
AS $$
  SELECT 
    order_id,
    COUNT(*) as count
  FROM messages
  WHERE order_id = ANY(p_order_ids)
    AND sender_id != p_user_id
    AND read_at IS NULL
  GROUP BY order_id;
$$;
