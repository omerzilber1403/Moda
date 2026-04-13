import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/supabase_service.dart';

class LikesNotifier extends StateNotifier<List<ClothingItem>> {
  LikesNotifier() : super([]) {
    loadLikes();
  }

  Future<void> loadLikes() async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) return;
    try {
      final data = await supabase
          .from('likes')
          .select('*, item:clothing_items(*, owner:profiles!clothing_items_owner_id_fkey(*))')
          .eq('user_id', uid);
      final items = (data as List)
          .where((e) => e['item'] != null)
          .map((e) => ClothingItem.fromJson(e['item'] as Map<String, dynamic>))
          .toList();
      state = items;
    } catch (_) {
      // Keep current state on error
    }
  }

  Future<void> likeItem(String itemId) async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) return;
    if (state.any((i) => i.id == itemId)) return;
    try {
      await supabase.from('likes').upsert(
        {'user_id': uid, 'item_id': itemId},
        onConflict: 'user_id,item_id',
      );
      await loadLikes();
    } catch (e) {
      debugPrint('likeItem error: $e');
    }
  }

  Future<void> removeItem(String itemId) async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) return;
    try {
      await supabase
          .from('likes')
          .delete()
          .eq('user_id', uid)
          .eq('item_id', itemId);
      state = state.where((i) => i.id != itemId).toList();
    } catch (_) {
      // ignore
    }
  }

  bool isLiked(String itemId) {
    return state.any((i) => i.id == itemId);
  }
}

final likesProvider =
    StateNotifierProvider<LikesNotifier, List<ClothingItem>>((ref) {
  return LikesNotifier();
});
