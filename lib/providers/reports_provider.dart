import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/supabase_service.dart';

class ReportsNotifier extends StateNotifier<List<Report>> {
  ReportsNotifier() : super([]);

  String? get _userId => supabase.auth.currentUser?.id;

  Future<void> submitReport({
    String? reportedUserId,
    String? reportedItemId,
    required String reason,
    String? description,
  }) async {
    final userId = _userId;
    if (userId == null) return;

    await supabase.from('reports').insert({
      'reporter_id': userId,
      if (reportedUserId != null) 'reported_user_id': reportedUserId,
      if (reportedItemId != null) 'reported_item_id': reportedItemId,
      'reason': reason,
      if (description != null) 'description': description,
    });
  }

  Future<void> blockUser(String blockedUserId) async {
    final userId = _userId;
    if (userId == null) return;

    await supabase.from('user_blocks').upsert({
      'blocker_id': userId,
      'blocked_id': blockedUserId,
    });
  }

  Future<void> unblockUser(String blockedUserId) async {
    final userId = _userId;
    if (userId == null) return;

    await supabase
        .from('user_blocks')
        .delete()
        .eq('blocker_id', userId)
        .eq('blocked_id', blockedUserId);
  }

  Future<bool> isBlocked(String userId) async {
    final currentUser = _userId;
    if (currentUser == null) return false;

    final data = await supabase
        .from('user_blocks')
        .select()
        .eq('blocker_id', currentUser)
        .eq('blocked_id', userId)
        .maybeSingle();
    return data != null;
  }
}

final reportsProvider =
    StateNotifierProvider<ReportsNotifier, List<Report>>((ref) {
  return ReportsNotifier();
});
