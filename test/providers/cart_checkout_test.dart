import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitflip/providers/auth_provider.dart';
import 'package:fitflip/providers/cart_provider.dart';
import 'package:fitflip/providers/wallet_provider.dart';
import 'package:fitflip/services/mock_api.dart';

void main() {
  late ProviderContainer container;

  setUp(() async {
    MockApi.reset();
    container = ProviderContainer();
    await container.read(authProvider.notifier).login('me@fitflip.com', 'any');
    await container.read(walletProvider.notifier).loadWallet();
  });

  tearDown(() => container.dispose());

  test('cart starts empty', () {
    expect(container.read(cartProvider).itemCount, equals(0));
  });

  test('addItem adds to cart', () {
    container.read(cartProvider.notifier).addItem('item-2');
    expect(container.read(cartProvider).itemCount, equals(1));
  });

  test('addItem is idempotent — no duplicates', () {
    container.read(cartProvider.notifier).addItem('item-2');
    container.read(cartProvider.notifier).addItem('item-2');
    expect(container.read(cartProvider).itemCount, equals(1));
  });

  test('totalCoins sums prices correctly', () {
    // item-2: Supreme Hoodie (45 SC) + item-4: Cropped Baby Tee (20 SC)
    container.read(cartProvider.notifier).addItem('item-2');
    container.read(cartProvider.notifier).addItem('item-4');
    expect(container.read(cartProvider).totalCoins, equals(65));
  });

  test('removeItem removes from cart', () {
    container.read(cartProvider.notifier).addItem('item-2');
    container.read(cartProvider.notifier).removeItem('item-2');
    expect(container.read(cartProvider).itemCount, equals(0));
  });

  test('clear empties the cart', () {
    container.read(cartProvider.notifier).addItem('item-2');
    container.read(cartProvider.notifier).addItem('item-4');
    container.read(cartProvider.notifier).clear();
    expect(container.read(cartProvider).itemCount, equals(0));
  });

  test('full checkout flow: purchase deducts coins, then clear cart', () async {
    // Add item-3 (Silk Blouse, 40 SC, owned by user-4) to cart
    container.read(cartProvider.notifier).addItem('item-3');
    expect(container.read(cartProvider).totalCoins, equals(40));

    // Purchase via walletProvider (simulates checkout)
    final order =
        await container.read(walletProvider.notifier).purchaseItem('item-3');
    expect(order, isNotNull);
    expect(container.read(walletProvider).balance, equals(10)); // 50 - 40

    // Clear cart after successful purchase
    container.read(cartProvider.notifier).clear();
    expect(container.read(cartProvider).itemCount, equals(0));
  });
}
