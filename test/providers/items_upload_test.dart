import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitflip/providers/items_provider.dart';
import 'package:fitflip/services/mock_api.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    MockApi.reset();
    container = ProviderContainer();
  });

  tearDown(() => container.dispose());

  test('initial items list shows user-me owned active items', () {
    final items = container.read(myItemsProvider);
    expect(items.every((i) => i.ownerId == 'user-me'), isTrue);
    expect(items.every((i) => i.isActive), isTrue);
  });

  test('addItem increases the list count', () {
    final initialCount = container.read(myItemsProvider).length;
    container.read(myItemsProvider.notifier).addItem(
      title: 'Test Jacket',
      categoryId: 4,
      condition: 'good',
      images: ['https://example.com/img.jpg'],
      priceInCoins: 30,
    );
    expect(container.read(myItemsProvider).length, equals(initialCount + 1));
  });

  test('new item appears in global MockApi.items list', () {
    container.read(myItemsProvider.notifier).addItem(
      title: 'My Unique Item',
      categoryId: 1,
      condition: 'like_new',
      images: ['https://example.com/img.jpg'],
      priceInCoins: 20,
    );
    expect(MockApi.items.any((i) => i.title == 'My Unique Item'), isTrue);
  });

  test('new item has correct title, price, and owner', () {
    container.read(myItemsProvider.notifier).addItem(
      title: 'Vintage Denim Jacket',
      categoryId: 4,
      condition: 'good',
      images: ['https://example.com/denim.jpg'],
      priceInCoins: 55,
    );
    final newItem = container
        .read(myItemsProvider)
        .firstWhere((i) => i.title == 'Vintage Denim Jacket');
    expect(newItem.priceInCoins, equals(55));
    expect(newItem.ownerId, equals('user-me'));
    expect(newItem.categoryId, equals(4));
  });
}
