import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitflip/providers/shop_provider.dart';
import 'package:fitflip/services/mock_api.dart';

void main() {
  late ProviderContainer container;

  setUp(() async {
    MockApi.reset();
    container = ProviderContainer();
    await container.read(shopProvider.notifier).loadItems();
  });

  tearDown(() => container.dispose());

  test('items load and exclude current user items', () {
    final items = container.read(shopProvider).items;
    expect(items, isNotEmpty);
    expect(items.every((i) => i.ownerId != 'user-me'), isTrue);
  });

  test('only active items are shown', () {
    final items = container.read(shopProvider).items;
    expect(items.every((i) => i.isActive), isTrue);
  });

  test('search query filters by title or brand', () {
    container.read(shopProvider.notifier).setSearchQuery('Supreme');
    final items = container.read(shopProvider).items;
    expect(items, isNotEmpty);
    expect(
      items.every((i) =>
          i.title.toLowerCase().contains('supreme') ||
          (i.brand?.toLowerCase().contains('supreme') ?? false)),
      isTrue,
    );
  });

  test('category filter returns only matching items', () {
    container.read(shopProvider.notifier).setCategory(5); // Shoes
    final items = container.read(shopProvider).items;
    expect(items, isNotEmpty);
    expect(items.every((i) => i.categoryId == 5), isTrue);
  });

  test('clearFilters restores full list', () {
    final fullCount = container.read(shopProvider).items.length;
    container.read(shopProvider.notifier).setCategory(5);
    expect(container.read(shopProvider).items.length, lessThan(fullCount));
    container.read(shopProvider.notifier).clearFilters();
    expect(container.read(shopProvider).items.length, equals(fullCount));
  });
}
