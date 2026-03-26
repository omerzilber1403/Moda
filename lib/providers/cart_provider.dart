import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/mock_api.dart';
import 'auth_provider.dart';

class CartState {
  final List<CartItem> items;
  final bool isLoading;

  const CartState({
    this.items = const [],
    this.isLoading = false,
  });

  CartState copyWith({
    List<CartItem>? items,
    bool? isLoading,
  }) {
    return CartState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  int get totalCoins {
    int total = 0;
    for (final cartItem in items) {
      final item = MockApi.getItemById(cartItem.itemId);
      if (item != null) total += item.priceInCoins * cartItem.quantity;
    }
    return total;
  }

  int get itemCount => items.length;
}

class CartNotifier extends StateNotifier<CartState> {
  final Ref ref;

  CartNotifier(this.ref) : super(const CartState());

  String? get _userId => ref.read(authProvider).user?.id;

  void addItem(String itemId) {
    final userId = _userId;
    if (userId == null) return;

    final exists = state.items.any((c) => c.itemId == itemId);
    if (exists) return;

    final newItem = CartItem(
      id: 'cart-${DateTime.now().millisecondsSinceEpoch}',
      itemId: itemId,
      userId: userId,
    );
    state = state.copyWith(items: [...state.items, newItem]);
  }

  void removeItem(String itemId) {
    state = state.copyWith(
      items: state.items.where((c) => c.itemId != itemId).toList(),
    );
  }

  bool isInCart(String itemId) {
    return state.items.any((c) => c.itemId == itemId);
  }

  void clear() {
    state = const CartState();
  }

  List<ClothingItem> getCartClothingItems() {
    return state.items
        .map((c) => MockApi.getItemById(c.itemId))
        .where((i) => i != null)
        .cast<ClothingItem>()
        .toList();
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier(ref);
});
