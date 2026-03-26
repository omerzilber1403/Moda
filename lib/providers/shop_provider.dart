import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/mock_api.dart';
import 'auth_provider.dart';

class ShopFilterState {
  final String searchQuery;
  final int? categoryFilter;
  final String? sizeFilter;
  final String? conditionFilter;
  final int priceMin;
  final int priceMax;

  const ShopFilterState({
    this.searchQuery = '',
    this.categoryFilter,
    this.sizeFilter,
    this.conditionFilter,
    this.priceMin = 0,
    this.priceMax = 100,
  });

  int get activeFilterCount {
    int count = 0;
    if (categoryFilter != null) count++;
    if (sizeFilter != null) count++;
    if (conditionFilter != null) count++;
    if (priceMin != 0 || priceMax != 100) count++;
    return count;
  }

  ShopFilterState copyWith({
    String? searchQuery,
    int? categoryFilter,
    bool clearCategory = false,
    String? sizeFilter,
    bool clearSize = false,
    String? conditionFilter,
    bool clearCondition = false,
    int? priceMin,
    int? priceMax,
  }) {
    return ShopFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      categoryFilter:
          clearCategory ? null : (categoryFilter ?? this.categoryFilter),
      sizeFilter: clearSize ? null : (sizeFilter ?? this.sizeFilter),
      conditionFilter:
          clearCondition ? null : (conditionFilter ?? this.conditionFilter),
      priceMin: priceMin ?? this.priceMin,
      priceMax: priceMax ?? this.priceMax,
    );
  }
}

class ShopState {
  final List<ClothingItem> items;
  final bool isLoading;
  final ShopFilterState filters;

  const ShopState({
    this.items = const [],
    this.isLoading = false,
    this.filters = const ShopFilterState(),
  });

  ShopState copyWith({
    List<ClothingItem>? items,
    bool? isLoading,
    ShopFilterState? filters,
  }) {
    return ShopState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      filters: filters ?? this.filters,
    );
  }
}

class ShopNotifier extends StateNotifier<ShopState> {
  final Ref ref;

  ShopNotifier(this.ref) : super(const ShopState()) {
    loadItems();
  }

  String get _userId => ref.read(authProvider).user?.id ?? 'user-me';

  Future<void> loadItems() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 200));

    final allItems = MockApi.getShopItems(_userId);
    final filtered = _applyFilters(allItems, state.filters);

    state = state.copyWith(items: filtered, isLoading: false);
  }

  List<ClothingItem> _applyFilters(
    List<ClothingItem> items,
    ShopFilterState filters,
  ) {
    var result = items;

    // Search query — match against title or brand (case-insensitive)
    if (filters.searchQuery.isNotEmpty) {
      final query = filters.searchQuery.toLowerCase();
      result = result.where((item) {
        final titleMatch = item.title.toLowerCase().contains(query);
        final brandMatch =
            item.brand?.toLowerCase().contains(query) ?? false;
        return titleMatch || brandMatch;
      }).toList();
    }

    // Category filter
    if (filters.categoryFilter != null) {
      result = result
          .where((item) => item.categoryId == filters.categoryFilter)
          .toList();
    }

    // Size filter
    if (filters.sizeFilter != null) {
      result =
          result.where((item) => item.size == filters.sizeFilter).toList();
    }

    // Condition filter
    if (filters.conditionFilter != null) {
      result = result
          .where((item) => item.condition == filters.conditionFilter)
          .toList();
    }

    // Price range filter
    result = result
        .where((item) =>
            item.priceInCoins >= filters.priceMin &&
            item.priceInCoins <= filters.priceMax)
        .toList();

    return result;
  }

  void setSearchQuery(String query) {
    final newFilters = state.filters.copyWith(searchQuery: query);
    final allItems = MockApi.getShopItems(_userId);
    final filtered = _applyFilters(allItems, newFilters);

    state = state.copyWith(filters: newFilters, items: filtered);
  }

  void setCategory(int? categoryId) {
    final newFilters = categoryId != null
        ? state.filters.copyWith(categoryFilter: categoryId)
        : state.filters.copyWith(clearCategory: true);
    final allItems = MockApi.getShopItems(_userId);
    final filtered = _applyFilters(allItems, newFilters);

    state = state.copyWith(filters: newFilters, items: filtered);
  }

  void setSize(String? size) {
    final newFilters = size != null
        ? state.filters.copyWith(sizeFilter: size)
        : state.filters.copyWith(clearSize: true);
    final allItems = MockApi.getShopItems(_userId);
    final filtered = _applyFilters(allItems, newFilters);

    state = state.copyWith(filters: newFilters, items: filtered);
  }

  void setCondition(String? condition) {
    final newFilters = condition != null
        ? state.filters.copyWith(conditionFilter: condition)
        : state.filters.copyWith(clearCondition: true);
    final allItems = MockApi.getShopItems(_userId);
    final filtered = _applyFilters(allItems, newFilters);

    state = state.copyWith(filters: newFilters, items: filtered);
  }

  void setPriceRange(int min, int max) {
    final newFilters = state.filters.copyWith(priceMin: min, priceMax: max);
    final allItems = MockApi.getShopItems(_userId);
    final filtered = _applyFilters(allItems, newFilters);

    state = state.copyWith(filters: newFilters, items: filtered);
  }

  void clearFilters() {
    const newFilters = ShopFilterState();
    final allItems = MockApi.getShopItems(_userId);
    final filtered = _applyFilters(allItems, newFilters);

    state = state.copyWith(filters: newFilters, items: filtered);
  }

}

final shopProvider = StateNotifierProvider<ShopNotifier, ShopState>((ref) {
  return ShopNotifier(ref);
});
