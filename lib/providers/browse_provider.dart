import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/supabase_service.dart';

class BrowseState {
  final List<ClothingItem> items;
  final bool isLoading;
  final int? categoryFilter;
  final String? genderFilter;

  const BrowseState({
    this.items = const [],
    this.isLoading = false,
    this.categoryFilter,
    this.genderFilter,
  });

  BrowseState copyWith({
    List<ClothingItem>? items,
    bool? isLoading,
    int? categoryFilter,
    bool clearCategory = false,
    String? genderFilter,
    bool clearGender = false,
  }) {
    return BrowseState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      categoryFilter:
          clearCategory ? null : (categoryFilter ?? this.categoryFilter),
      genderFilter:
          clearGender ? null : (genderFilter ?? this.genderFilter),
    );
  }
}

class BrowseNotifier extends StateNotifier<BrowseState> {
  BrowseNotifier() : super(const BrowseState(isLoading: true)) {
    _init();
  }

  Future<void> _init() async {
    // Preferred gender is stored in the DB for future recommendation
    // algorithms, but not auto-applied as an active filter.
    await loadItems();
  }

  Future<void> loadItems() async {
    state = state.copyWith(isLoading: true);
    try {
      final uid = supabase.auth.currentUser?.id;

      // Get already-liked item IDs to exclude
      List<String> likedIds = [];
      if (uid != null) {
        final likes = await supabase
            .from('likes')
            .select('item_id')
            .eq('user_id', uid);
        likedIds =
            (likes as List).map((e) => e['item_id'] as String).toList();
      }

      final data = uid != null
          ? await supabase
              .from('clothing_items')
              .select('*, owner:profiles!clothing_items_owner_id_fkey(*)')
              .eq('is_active', true)
              .neq('owner_id', uid)
              .order('created_at', ascending: false)
          : await supabase
              .from('clothing_items')
              .select('*, owner:profiles!clothing_items_owner_id_fkey(*)')
              .eq('is_active', true)
              .order('created_at', ascending: false);
      var items =
          (data as List).map((e) => ClothingItem.fromJson(e)).toList();

      // Exclude already-liked items
      if (likedIds.isNotEmpty) {
        items = items.where((i) => !likedIds.contains(i.id)).toList();
      }

      // Apply category filter
      if (state.categoryFilter != null) {
        items =
            items.where((i) => i.categoryId == state.categoryFilter).toList();
      }

      // Apply gender filter (include unisex items alongside the selected gender)
      if (state.genderFilter != null) {
        items = items
            .where((i) =>
                i.gender == state.genderFilter || i.gender == 'unisex')
            .toList();
      }

      state = state.copyWith(items: items, isLoading: false);
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  void filterByCategory(int? categoryId) {
    if (categoryId == state.categoryFilter) return;
    state = state.copyWith(
      categoryFilter: categoryId,
      clearCategory: categoryId == null,
    );
    loadItems();
  }
}

final browseProvider =
    StateNotifierProvider<BrowseNotifier, BrowseState>((ref) {
  return BrowseNotifier();
});
