import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitflip/providers/auth_provider.dart';
import 'package:fitflip/services/mock_api.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    MockApi.reset();
    container = ProviderContainer();
  });

  tearDown(() => container.dispose());

  test('initial state is unauthenticated', () {
    final state = container.read(authProvider);
    expect(state.isAuthenticated, isFalse);
    expect(state.user, isNull);
  });

  test('login sets authenticated state', () async {
    await container.read(authProvider.notifier).login('me@fitflip.com', 'any');
    final state = container.read(authProvider);
    expect(state.isAuthenticated, isTrue);
    expect(state.user, isNotNull);
  });

  test('logout clears user', () async {
    await container.read(authProvider.notifier).login('me@fitflip.com', 'any');
    container.read(authProvider.notifier).logout();
    expect(container.read(authProvider).isAuthenticated, isFalse);
    expect(container.read(authProvider).user, isNull);
  });

  test('loginAs sets the given user instantly', () async {
    final user = MockApi.users.last; // user-6, Yoav Ben-Ari
    await container.read(authProvider.notifier).loginAs(user);
    expect(container.read(authProvider).user?.id, equals(user.id));
  });
}
