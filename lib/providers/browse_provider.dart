import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/mock_api.dart';
import 'auth_provider.dart';

class BrowseState {
  final List<ClothingItem> items;
  final bool isLoading;
  final int? categoryFilter;

  const BrowseState({
    this.items = const [],
    this.isLoading = false,
    this.categoryFilter,
  });

  BrowseState copyWith({
    List<ClothingItem>? items,
    bool? isLoading,
    int? categoryFilter,
    bool clearCategory = false,
  }) {
    return BrowseState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      categoryFilter: clearCategory ? null : (categoryFilter ?? this.categoryFilter),
    );
  }
}

class BrowseNotifier extends StateNotifier<BrowseState> {
  final Ref ref;

  BrowseNotifier(this.ref) : super(const BrowseState()) {
    loadItems();
  }

  String get _userId => ref.read(authProvider).user?.id ?? 'user-me';

  Future<void> loadItems() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 200));

    final allItems = MockApi.getShopItems(_userId);
    final filtered = state.categoryFilter != null
        ? allItems.where((i) => i.categoryId == state.categoryFilter).toList()
        : allItems;

    state = state.copyWith(items: filtered, isLoading: false);
  }

  void filterByCategory(int? categoryId) {
    if (categoryId == state.categoryFilter) return;

    final allItems = MockApi.getShopItems(_userId);
    final filtered = categoryId != null
        ? allItems.where((i) => i.categoryId == categoryId).toList()
        : allItems;

    state = BrowseState(
      items: filtered,
      categoryFilter: categoryId,
    );
  }
}

final browseProvider =
    StateNotifierProvider<BrowseNotifier, BrowseState>((ref) {
  return BrowseNotifier(ref);
});
