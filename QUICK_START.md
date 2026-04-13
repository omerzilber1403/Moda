# Chat Inbox Fix - Quick Start Guide

## ✅ What Was Fixed

**Problem:** After purchasing an item, the chat didn't appear in the Inbox tab.

**Root Causes:**
1. ❌ No message was created when order was placed → inbox empty
2. ❌ Orders provider didn't fetch last messages → couldn't display preview

**Solution:**
1. ✅ RPC now creates system message on purchase
2. ✅ Orders provider fetches last messages efficiently
3. ✅ Chat appears immediately after purchase

---

## 🚀 Quick Apply (Choose One Method)

### Method 1: Double-click the batch file ⭐ EASIEST
```
Double-click: apply-chat-fix.bat
```

### Method 2: Command line
```bash
node apply_chat_fix_migrations.js
```

### Method 3: Supabase Dashboard (Manual)
1. Open https://supabase.com → your project → SQL Editor
2. Copy/paste contents of `supabase/migrations/20260402000001_add_system_message_to_order_creation.sql`
3. Click RUN
4. Copy/paste contents of `supabase/migrations/20260402000002_chat_helper_rpcs.sql`
5. Click RUN
6. Done!

---

## 🧪 Test It

1. **In the app:**
   ```
   Shop tab → Buy an item → Checkout → Purchase
   ```

2. **Check Inbox tab:**
   - Should see the conversation immediately
   - Should show: "Order created — chat with the seller to arrange pickup!"
   - Should show item image and title

3. **Switch users:**
   - Log in as the seller
   - Inbox should also show the conversation
   - Both sides see the same initial message

---

## 📁 Files Changed

### New Migrations (need to be applied):
- ✅ `supabase/migrations/20260402000001_add_system_message_to_order_creation.sql`
- ✅ `supabase/migrations/20260402000002_chat_helper_rpcs.sql`

### Code Updated (already done):
- ✅ `lib/providers/orders_provider.dart` - fetches last messages

### Helper Scripts Created:
- `apply-chat-fix.bat` - Windows batch file to apply migrations
- `apply_chat_fix_migrations.js` - Node.js migration script
- `CHAT_FIX_SUMMARY.md` - Detailed technical documentation
- `QUICK_START.md` - This file

---

## ❓ Troubleshooting

### "Cannot find module '@supabase/supabase-js'"
```bash
cd server
npm install
cd ..
node apply_chat_fix_migrations.js
```

### "Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY"
1. Check `server/.env` exists
2. Make sure it has:
   ```
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
   ```

### Migration fails
- Use Method 3 (Manual via Dashboard) instead
- See `CHAT_FIX_SUMMARY.md` for SQL to paste

### Still not working after migration
1. Restart Flutter app: `Ctrl+C` then `flutter run`
2. Check Supabase logs for errors
3. Verify migration ran: Check SQL Editor history in dashboard

---

## 🎯 Expected Behavior After Fix

| Action | Before Fix | After Fix |
|--------|-----------|-----------|
| Buy item | No inbox entry | ✅ Chat appears in inbox |
| Open inbox | Empty/missing | ✅ Shows all order chats |
| Check seller inbox | No notification | ✅ Seller sees new chat |
| Initial message | None | ✅ "Order created — chat..." |
| Unread badge | Not shown | ✅ Shows unread count |

---

## 🔄 Rollback (If Needed)

If something breaks:

1. **Restore old RPC via Dashboard:**
   - Find the previous `lock_coins_for_order` in migration history
   - Copy and run it again

2. **Remove new RPCs:**
   ```sql
   DROP FUNCTION IF EXISTS get_last_messages(UUID[]);
   DROP FUNCTION IF EXISTS get_unread_counts(UUID[], UUID);
   ```

3. **Revert code:**
   ```bash
   git checkout lib/providers/orders_provider.dart
   ```

---

## 💡 Need More Details?

- **Technical deep-dive:** See `CHAT_FIX_SUMMARY.md`
- **Migration SQL:** See `supabase/migrations/20260402000001_*.sql` and `20260402000002_*.sql`
- **Code changes:** Check `lib/providers/orders_provider.dart`

---

**Ready? Run `apply-chat-fix.bat` now!** 🚀
