import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitflip/providers/auth_provider.dart';
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

  test('wallet balance matches mock user initial balance (50 SC)', () {
    expect(container.read(walletProvider).balance, equals(50));
  });

  test('topUp increases balance by exact amount', () async {
    await container.read(walletProvider.notifier).topUp(100);
    expect(container.read(walletProvider).balance, equals(150));
  });

  test('purchaseItem deducts coins and creates order', () async {
    // item-2: Supreme Hoodie, owner: user-3, price: 45 SC
    final order =
        await container.read(walletProvider.notifier).purchaseItem('item-2');
    expect(order, isNotNull);
    expect(order!.buyerId, equals('user-me'));
    expect(order.priceInCoins, equals(45));
    expect(container.read(walletProvider).balance, equals(5));
  });

  test('purchaseItem returns null for inactive items', () async {
    // item-1 is isActive: false (already sold)
    final order =
        await container.read(walletProvider.notifier).purchaseItem('item-1');
    expect(order, isNull);
    expect(container.read(walletProvider).balance, equals(50)); // unchanged
  });

  test('purchaseItem returns null when balance is insufficient', () async {
    // Login as user-6 who has only 15 SC — cannot afford item-2 (45 SC)
    final user6 = MockApi.users.firstWhere((u) => u.id == 'user-6');
    await container.read(authProvider.notifier).loginAs(user6);
    await container.read(walletProvider.notifier).loadWallet();
    expect(container.read(walletProvider).balance, equals(15));

    final order =
        await container.read(walletProvider.notifier).purchaseItem('item-2');
    expect(order, isNull);
    expect(container.read(walletProvider).balance, equals(15));
  });
}
