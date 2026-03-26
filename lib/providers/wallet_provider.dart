import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/mock_api.dart';
import 'auth_provider.dart';

class WalletState {
  final int balance;
  final List<Transaction> transactions;
  final bool isLoading;

  const WalletState({
    this.balance = 0,
    this.transactions = const [],
    this.isLoading = false,
  });

  WalletState copyWith({
    int? balance,
    List<Transaction>? transactions,
    bool? isLoading,
  }) {
    return WalletState(
      balance: balance ?? this.balance,
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class WalletNotifier extends StateNotifier<WalletState> {
  final Ref ref;

  WalletNotifier(this.ref) : super(const WalletState()) {
    loadWallet();
  }

  String? get _userId => ref.read(authProvider).user?.id;

  Future<void> loadWallet() async {
    final userId = _userId;
    if (userId == null) return;

    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 200));

    final user = MockApi.getUserById(userId);
    final txns = MockApi.getTransactionsForUser(userId);

    state = WalletState(
      balance: user?.styleCoinBalance ?? 0,
      transactions: txns,
    );
  }

  /// Purchase an item. Returns the created Order on success, null on failure.
  Future<Order?> purchaseItem(String itemId) async {
    final userId = _userId;
    if (userId == null) return null;

    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 400));

    final order = MockApi.purchaseItem(itemId, userId);
    if (order != null) {
      await loadWallet();
    } else {
      state = state.copyWith(isLoading: false);
    }
    return order;
  }

  /// Top up coins.
  Future<void> topUp(int amount) async {
    final userId = _userId;
    if (userId == null) return;

    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 300));

    MockApi.topUp(userId, amount);
    await loadWallet();
  }
}

final walletProvider =
    StateNotifierProvider<WalletNotifier, WalletState>((ref) {
  return WalletNotifier(ref);
});
