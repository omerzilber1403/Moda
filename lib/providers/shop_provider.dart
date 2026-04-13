import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/supabase_service.dart';

class ShopFilterState {
  final String searchQuery;
  final int? categoryFilter;
  final String? sizeFilter;
  final String? conditionFilter;
  final int priceMin;
  final int priceMax;
  final String? genderFilter;

  const ShopFilterState({
    this.searchQuery = '',
    this.categoryFilter,
    this.sizeFilter,
    this.conditionFilter,
    this.priceMin = 0,
    this.priceMax = 500,
    this.genderFilter,
  });

  int get activeFilterCount {
    int count = 0;
    if (categoryFilter != null) count++;
    if (sizeFilter != null) count++;
    if (conditionFilter != null) count++;
    if (priceMin != 0 || priceMax != 500) count++;
    if (genderFilter != null) count++;
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
    String? genderFilter,
    bool clearGender = false,
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
      genderFilter: clearGender ? null : (genderFilter ?? this.genderFilter),
    );
  }
}

class ShopState {
  final List<ClothingItem> items;
  final List<ClothingItem> allItems;
  final bool isLoading;
  final ShopFilterState filters;
  final List<Category> categories;

  const ShopState({
    this.items = const [],
    this.allItems = const [],
    this.isLoading = false,
    this.filters = const ShopFilterState(),
    this.categories = const [],
  });

  ShopState copyWith({
    List<ClothingItem>? items,
    List<ClothingItem>? allItems,
    bool? isLoading,
    ShopFilterState? filters,
    List<Category>? categories,
  }) {
    return ShopState(
      items: items ?? this.items,
      allItems: allItems ?? this.allItems,
      isLoading: isLoading ?? this.isLoading,
      filters: filters ?? this.filters,
      categories: categories ?? this.categories,
    );
  }
}

class ShopNotifier extends StateNotifier<ShopState> {
  ShopNotifier() : super(const ShopState(isLoading: true)) {
    _init();
  }

  Future<void> _init() async {
    await loadCategories();
    await _loadPreferences();
    await loadItems();
  }

  Future<void> loadCategories() async {
    try {
      final data = await supabase
          .from('categories')
          .select()
          .order('id', ascending: true);
      final categories =
          (data as List).map((e) => Category.fromJson(e)).toList();
      state = state.copyWith(categories: categories);
    } catch (_) {
      // Categories are non-critical, keep empty list
    }
  }

  Future<void> _loadPreferences() async {
    // Preferences are stored for future recommendation algorithms,
    // but not auto-applied as active filters.
  }

  Future<void> loadItems() async {
    state = state.copyWith(isLoading: true);
    try {
      final uid = supabase.auth.currentUser?.id;
      var query = supabase
          .from('clothing_items')
          .select('*, owner:profiles!clothing_items_owner_id_fkey(*)')
          .eq('is_active', true);
      if (uid != null) {
        query = query.neq('owner_id', uid);
      }
      // Server-side full-text search when query is set
      if (state.filters.searchQuery.isNotEmpty) {
        query = query.textSearch(
          'search_vector',
          state.filters.searchQuery,
          config: 'english',
        );
      }
      final data = await query;
      final items =
          (data as List).map((e) => ClothingItem.fromJson(e)).toList();
      // Apply non-search filters client-side (category, size, condition, price, gender)
      final filtered = _applyFilters(items, state.filters);
      state = state.copyWith(
          items: filtered, allItems: items, isLoading: false);
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  List<ClothingItem> _applyFilters(
    List<ClothingItem> items,
    ShopFilterState filters,
  ) {
    var result = items;

    // Note: searchQuery filtering is handled server-side via textSearch

    if (filters.categoryFilter != null) {
      result = result
          .where((item) => item.categoryId == filters.categoryFilter)
          .toList();
    }

    if (filters.sizeFilter != null) {
      result =
          result.where((item) => item.size == filters.sizeFilter).toList();
    }

    if (filters.conditionFilter != null) {
      result = result
          .where((item) => item.condition == filters.conditionFilter)
          .toList();
    }

    if (filters.genderFilter != null) {
      result = result
          .where((item) =>
              item.gender == filters.genderFilter || item.gender == 'unisex')
          .toList();
    }

    result = result
        .where((item) =>
            item.priceInCoins >= filters.priceMin &&
            item.priceInCoins <= filters.priceMax)
        .toList();

    return result;
  }

  void setSearchQuery(String query) {
    final newFilters = state.filters.copyWith(searchQuery: query);
    state = state.copyWith(filters: newFilters);
    loadItems(); // triggers server-side search
  }

  void setCategory(int? categoryId) {
    final newFilters = categoryId != null
        ? state.filters.copyWith(categoryFilter: categoryId)
        : state.filters.copyWith(clearCategory: true);
    final filtered = _applyFilters(state.allItems, newFilters);
    state = state.copyWith(filters: newFilters, items: filtered);
  }

  void setSize(String? size) {
    final newFilters = size != null
        ? state.filters.copyWith(sizeFilter: size)
        : state.filters.copyWith(clearSize: true);
    final filtered = _applyFilters(state.allItems, newFilters);
    state = state.copyWith(filters: newFilters, items: filtered);

    // Persist preference
    final uid = supabase.auth.currentUser?.id;
    if (uid != null && size != null) {
      supabase
          .from('profiles')
          .update({'preferred_sizes': [size]}).eq('id', uid);
    }
  }

  void setCondition(String? condition) {
    final newFilters = condition != null
        ? state.filters.copyWith(conditionFilter: condition)
        : state.filters.copyWith(clearCondition: true);
    final filtered = _applyFilters(state.allItems, newFilters);
    state = state.copyWith(filters: newFilters, items: filtered);
  }

  void setGender(String? gender) {
    final newFilters = gender != null
        ? state.filters.copyWith(genderFilter: gender)
        : state.filters.copyWith(clearGender: true);
    final filtered = _applyFilters(state.allItems, newFilters);
    state = state.copyWith(filters: newFilters, items: filtered);

    // Persist preference
    final uid = supabase.auth.currentUser?.id;
    if (uid != null) {
      supabase
          .from('profiles')
          .update({'preferred_gender': gender}).eq('id', uid);
    }
  }

  void setPriceRange(int min, int max) {
    final newFilters = state.filters.copyWith(priceMin: min, priceMax: max);
    final filtered = _applyFilters(state.allItems, newFilters);
    state = state.copyWith(filters: newFilters, items: filtered);
  }

  void clearFilters() {
    const newFilters = ShopFilterState();
    final filtered = _applyFilters(state.allItems, newFilters);
    state = state.copyWith(filters: newFilters, items: filtered);
  }
}

final shopProvider = StateNotifierProvider<ShopNotifier, ShopState>((ref) {
  return ShopNotifier();
});
