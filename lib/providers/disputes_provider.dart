import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/supabase_service.dart';

class DisputesNotifier extends StateNotifier<List<Dispute>> {
  DisputesNotifier() : super([]);

  String? get _userId => supabase.auth.currentUser?.id;

  Future<void> openDispute({
    required String orderId,
    required String reason,
    String? description,
  }) async {
    final userId = _userId;
    if (userId == null) return;

    final data = await supabase.from('disputes').insert({
      'order_id': orderId,
      'opened_by': userId,
      'reason': reason,
      if (description != null) 'description': description,
    }).select().single();

    state = [...state, Dispute.fromJson(data)];
  }

  Future<void> loadDisputesForOrder(String orderId) async {
    final data = await supabase
        .from('disputes')
        .select()
        .eq('order_id', orderId)
        .order('created_at', ascending: false);
    state = (data as List).map((e) => Dispute.fromJson(e)).toList();
  }
}

final disputesProvider =
    StateNotifierProvider<DisputesNotifier, List<Dispute>>((ref) {
  return DisputesNotifier();
});
