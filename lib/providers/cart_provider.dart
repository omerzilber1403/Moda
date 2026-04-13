import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/supabase_service.dart';

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
      if (cartItem.item != null) {
        total += cartItem.item!.priceInCoins;
      }
    }
    return total;
  }

  int get itemCount => items.length;
}

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(const CartState()) {
    loadCart();
  }

  Future<void> loadCart() async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) return;
    state = state.copyWith(isLoading: true);
    try {
      final data = await supabase
          .from('cart_items')
          .select('*, item:clothing_items(*)')
          .eq('user_id', uid);
      final items =
          (data as List).map((e) => CartItem.fromJson(e)).toList();
      state = CartState(items: items);
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> addItem(String itemId) async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) return;
    if (isInCart(itemId)) return;
    try {
      await supabase
          .from('cart_items')
          .insert({'user_id': uid, 'item_id': itemId});
      await loadCart();
    } catch (_) {
      // Silently fail — item may already be in cart
    }
  }

  Future<void> removeItem(String itemId) async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) return;
    try {
      await supabase
          .from('cart_items')
          .delete()
          .eq('user_id', uid)
          .eq('item_id', itemId);
      state = state.copyWith(
        items: state.items.where((c) => c.itemId != itemId).toList(),
      );
    } catch (_) {
      // ignore
    }
  }

  bool isInCart(String itemId) {
    return state.items.any((c) => c.itemId == itemId);
  }

  void clear() {
    state = const CartState();
  }

  List<ClothingItem> getCartClothingItems() {
    return state.items
        .where((c) => c.item != null)
        .map((c) => c.item!)
        .toList();
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});
