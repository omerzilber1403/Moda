# Chat Inbox Fix - Summary

## Problem
After purchasing an item, the conversation wasn't appearing in the Inbox tab because:
1. No initial message was created when an order was placed
2. The orders provider wasn't fetching the last message for each order

## Solution Applied

### 1. Database Changes (2 migrations created)

#### Migration 1: `20260402000001_add_system_message_to_order_creation.sql`
- Updated `lock_coins_for_order()` RPC function
- Now inserts a system message when order is created:
  ```
  "Order created — chat with the seller to arrange pickup!"
  ```
- This ensures the chat appears in inbox immediately

#### Migration 2: `20260402000002_chat_helper_rpcs.sql`
- Added `get_last_messages(p_order_ids UUID[])` RPC
  - Efficiently fetches the most recent message for each order
  - Uses `DISTINCT ON` for optimal performance
  
- Added `get_unread_counts(p_order_ids UUID[], p_user_id UUID)` RPC
  - Counts unread messages per order
  - Only counts messages from other users

### 2. Code Changes

#### Updated: `lib/providers/orders_provider.dart`
- Modified `loadOrders()` to fetch last messages and unread counts
- Uses parallel queries for efficiency:
  ```dart
  final msgResults = await Future.wait([
    supabase.rpc('get_last_messages', params: {'p_order_ids': orderIds}),
    supabase.rpc('get_unread_counts', params: {
      'p_order_ids': orderIds,
      'p_user_id': uid,
    }),
  ]);
  ```
- Now populates `lastMessage` and `unreadCount` in `OrderDetail`

## How to Apply

### Option 1: Using the Node.js script (Recommended)
```bash
node apply_chat_fix_migrations.js
```

### Option 2: Manual application via Supabase Dashboard
1. Go to your Supabase project dashboard
2. Navigate to SQL Editor
3. Copy and paste the contents of:
   - `supabase/migrations/20260402000001_add_system_message_to_order_creation.sql`
   - Run it
4. Then copy and paste:
   - `supabase/migrations/20260402000002_chat_helper_rpcs.sql`
   - Run it

### Option 3: Using Supabase CLI
```bash
cd supabase
supabase db push
```

## Testing

1. **Create a test purchase:**
   - Log in as a buyer
   - Purchase an item
   
2. **Verify inbox appearance:**
   - Tap the Inbox tab
   - The conversation should appear immediately
   - Should show the system message: "Order created — chat with the seller to arrange pickup!"
   
3. **Check both sides:**
   - Switch to seller account
   - Inbox should show the same conversation
   - Both buyer and seller see the initial message

## Files Modified/Created

### New Files:
- `supabase/migrations/20260402000001_add_system_message_to_order_creation.sql`
- `supabase/migrations/20260402000002_chat_helper_rpcs.sql`
- `apply_chat_fix_migrations.js` (helper script)
- `CHAT_FIX_SUMMARY.md` (this file)

### Modified Files:
- `lib/providers/orders_provider.dart` (added last message fetching logic)

## Technical Details

### Why `DISTINCT ON` in `get_last_messages`?
- More efficient than `ROW_NUMBER()` or subqueries
- PostgreSQL optimizes `DISTINCT ON` + `ORDER BY` very well
- Returns exactly one row per order_id (the most recent)

### Why separate RPC for unread counts?
- Allows independent caching strategies
- Unread counts change frequently (every message)
- Last messages change less frequently
- Can be optimized separately in the future

### Performance Considerations
- Both RPCs use `STABLE` (can read database, won't modify)
- Batch queries prevent N+1 problem
- Parallel execution with `Future.wait`
- Indexed on `order_id` and `sent_at` (existing indexes)

## Rollback (if needed)

If issues arise, you can rollback by:

1. **Restore old RPC:**
   ```sql
   -- Remove the system message insertion line from lock_coins_for_order
   -- (Re-run the old version from previous migration)
   ```

2. **Remove helper RPCs:**
   ```sql
   DROP FUNCTION IF EXISTS get_last_messages(UUID[]);
   DROP FUNCTION IF EXISTS get_unread_counts(UUID[], UUID);
   ```

3. **Revert code:**
   ```bash
   git checkout lib/providers/orders_provider.dart
   ```

## Notes

- System messages use `type = 'system'` (existing enum value)
- `sender_id` is set to buyer_id for audit trail
- Messages are inserted AFTER cart cleanup (maintains data integrity)
- No changes needed to `Message` model (already supports system type)
- No changes needed to UI (chat screens already handle system messages)
