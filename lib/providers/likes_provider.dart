import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/mock_api.dart';

class LikesNotifier extends StateNotifier<List<ClothingItem>> {
  LikesNotifier() : super([]);

  void likeItem(String itemId) {
    final item = MockApi.getItemById(itemId);
    if (item == null) return;
    // Don't add duplicates
    if (state.any((i) => i.id == itemId)) return;
    state = [...state, item];
  }

  void removeItem(String itemId) {
    state = state.where((i) => i.id != itemId).toList();
  }
}

final likesProvider =
    StateNotifierProvider<LikesNotifier, List<ClothingItem>>((ref) {
  return LikesNotifier();
});
