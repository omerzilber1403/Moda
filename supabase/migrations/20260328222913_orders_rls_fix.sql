-- Remove the client-side insert policy (purchase_item function bypasses RLS anyway)
DROP POLICY IF EXISTS "order_participants_insert" ON orders;
