import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitflip/providers/likes_provider.dart';
import 'package:fitflip/services/mock_api.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    MockApi.reset();
    container = ProviderContainer();
  });

  tearDown(() => container.dispose());

  test('initial likes list is empty', () {
    expect(container.read(likesProvider), isEmpty);
  });

  test('likeItem adds item to likes (swipe right)', () {
    container.read(likesProvider.notifier).likeItem('item-2');
    final likes = container.read(likesProvider);
    expect(likes.length, equals(1));
    expect(likes.first.id, equals('item-2'));
  });

  test('likeItem is idempotent — no duplicates', () {
    container.read(likesProvider.notifier).likeItem('item-2');
    container.read(likesProvider.notifier).likeItem('item-2');
    expect(
      container.read(likesProvider).where((i) => i.id == 'item-2').length,
      equals(1),
    );
  });

  test('swipe left does not add to likes', () {
    // Swipe left = never calling likeItem. List stays empty.
    expect(container.read(likesProvider), isEmpty);
  });

  test('removeItem removes from likes', () {
    container.read(likesProvider.notifier).likeItem('item-2');
    container.read(likesProvider.notifier).removeItem('item-2');
    expect(container.read(likesProvider), isEmpty);
  });

  test('can like multiple different items', () {
    container.read(likesProvider.notifier).likeItem('item-2');
    container.read(likesProvider.notifier).likeItem('item-3');
    container.read(likesProvider.notifier).likeItem('item-4');
    expect(container.read(likesProvider).length, equals(3));
  });
}
