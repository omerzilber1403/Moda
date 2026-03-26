import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../services/mock_api.dart';

class ItemsNotifier extends StateNotifier<List<ClothingItem>> {
  ItemsNotifier() : super(MockApi.getItemsByOwner('user-me'));

  void addItem({
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
    Map<String, String> attributes = const {},
  }) {
    final item = ClothingItem(
      id: const Uuid().v4(),
      ownerId: 'user-me',
      title: title,
      description: description,
      brand: brand,
      size: size,
      clothingType: clothingType,
      categoryId: categoryId,
      condition: condition,
      color: color,
      images: images,
      priceInCoins: priceInCoins,
      attributes: attributes,
      createdAt: DateTime.now(),
    );
    MockApi.items.add(item);
    state = [...state, item];
  }
}

final myItemsProvider =
    StateNotifierProvider<ItemsNotifier, List<ClothingItem>>((ref) {
  return ItemsNotifier();
});
