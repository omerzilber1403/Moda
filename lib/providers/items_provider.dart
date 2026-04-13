import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/supabase_service.dart';

class ItemsNotifier extends StateNotifier<List<ClothingItem>> {
  ItemsNotifier() : super([]) {
    loadMyItems();
  }

  Future<void> loadMyItems() async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) return;
    try {
      final data = await supabase
          .from('clothing_items')
          .select()
          .eq('owner_id', uid)
          .order('created_at', ascending: false);
      state =
          (data as List).map((e) => ClothingItem.fromJson(e)).toList();
    } catch (_) {
      // Keep current state on error
    }
  }

  Future<void> addItem({
    required String title,
    String? description,
    String? brand,
    String? size,
    ClothingType clothingType = ClothingType.top,
    required int categoryId,
    required String condition,
    String? color,
    required List<String> images,
    required int priceInCoins,
    Map<String, dynamic> attributes = const {},
    String? gender,
    String? pickupAddress,
  }) async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) return;
    try {
      await supabase.from('clothing_items').insert({
        'owner_id': uid,
        'title': title,
        if (description != null) 'description': description,
        if (brand != null) 'brand': brand,
        if (size != null) 'size': size,
        'clothing_type': clothingType.value,
        'category_id': categoryId,
        'condition': condition,
        if (color != null) 'color': color,
        'images': images,
        'price_in_coins': priceInCoins,
        'attributes': attributes,
        'upload_date': DateTime.now().toIso8601String(),
        if (gender != null) 'gender': gender,
        if (pickupAddress != null) 'pickup_address': pickupAddress,
      });
      await loadMyItems();
    } catch (_) {
      // ignore
    }
  }
}

final myItemsProvider =
    StateNotifierProvider<ItemsNotifier, List<ClothingItem>>((ref) {
  return ItemsNotifier();
});
