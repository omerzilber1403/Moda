import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../models/models.dart';
import '../services/supabase_service.dart';
import 'auth_provider.dart';
import 'browse_provider.dart';
import 'orders_provider.dart';
import 'shop_provider.dart';

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
  RealtimeChannel? _balanceChannel;

  WalletNotifier(this.ref) : super(const WalletState()) {
    loadWallet();
  }

  String? get _userId => supabase.auth.currentUser?.id;

  Future<void> loadWallet() async {
    final userId = _userId;
    if (userId == null) return;

    state = state.copyWith(isLoading: true);
    try {
      await Future.wait([_loadBalance(userId), _loadTransactions(userId)]);
      _subscribeToRealtime();
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  void _subscribeToRealtime() {
    final uid = _userId;
    if (uid == null) return;
    // Only subscribe once
    if (_balanceChannel != null) return;

    _balanceChannel = supabase
        .channel('balance-$uid')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'profiles',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: uid,
          ),
          callback: (payload) {
            if (!mounted) return;
            final newBalance =
                payload.newRecord['style_coin_balance'] as int?;
            if (newBalance != null && newBalance != state.balance) {
              state = state.copyWith(balance: newBalance);
              _loadTransactions(uid);
            }
          },
        )
        .subscribe();
  }

  Future<void> _loadBalance(String userId) async {
    final profile = await supabase
        .from('profiles')
        .select('style_coin_balance')
        .eq('id', userId)
        .single();
    state = state.copyWith(
      balance: profile['style_coin_balance'] as int? ?? 0,
      isLoading: false,
    );
  }

  Future<void> _loadTransactions(String userId) async {
    final data = await supabase
        .from('transactions')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    final txns =
        (data as List).map((e) => Transaction.fromJson(e)).toList();
    state = state.copyWith(transactions: txns, isLoading: false);
  }

  /// Lock coins in escrow for an item. Coins are deducted from the buyer
  /// but NOT credited to the seller until both parties confirm pickup.
  /// Returns the created Order on success, null on failure.
  Future<Order?> lockCoinsForOrder(String itemId) async {
    final userId = _userId;
    if (userId == null) return null;

    state = state.copyWith(isLoading: true);
    try {
      final result = await supabase.rpc('lock_coins_for_order', params: {
        'p_buyer_id': userId,
        'p_item_id': itemId,
      }) as Map<String, dynamic>;

      if (result['success'] != true) {
        state = state.copyWith(isLoading: false);
        throw result['error'] as String? ?? 'lock_failed';
      }

      await loadWallet();
      ref.read(authProvider.notifier).refreshProfile();
      ref.read(ordersProvider.notifier).refresh();
      ref.read(shopProvider.notifier).loadItems();
      ref.read(browseProvider.notifier).loadItems();

      final orderId = result['order_id'] as String;
      final orderData = await supabase
          .from('orders')
          .select()
          .eq('id', orderId)
          .single();
      return Order.fromJson(orderData);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  /// Confirm pickup for the current user on a given order.
  /// Returns true if both parties have now confirmed (order completed).
  Future<bool> confirmPickup(String orderId) async {
    final userId = _userId;
    if (userId == null) return false;

    try {
      final result = await supabase.rpc('confirm_pickup', params: {
        'p_user_id': userId,
        'p_order_id': orderId,
      }) as Map<String, dynamic>;

      if (result['success'] != true) return false;

      final completed = result['completed'] as bool? ?? false;
      if (completed) {
        await loadWallet();
        ref.read(authProvider.notifier).refreshProfile();
      }
      return completed;
    } catch (_) {
      return false;
    }
  }

  /// Cancel an order and refund locked coins to buyer.
  Future<bool> cancelOrder(String orderId, {String? reason}) async {
    final userId = _userId;
    if (userId == null) return false;

    try {
      final result = await supabase.rpc('cancel_order', params: {
        'p_user_id': userId,
        'p_order_id': orderId,
        'p_reason': reason,
      }) as Map<String, dynamic>;

      if (result['success'] != true) return false;

      await loadWallet();
      ref.read(authProvider.notifier).refreshProfile();
      return true;
    } catch (_) {
      return false;
    }
  }

  void reset() {
    _balanceChannel?.unsubscribe();
    _balanceChannel = null;
    state = const WalletState();
  }

  @override
  void dispose() {
    _balanceChannel?.unsubscribe();
    super.dispose();
  }

  /// Top up coins via server-side RPC.
  Future<void> topUp(int coins, {double? amountIls}) async {
    final userId = _userId;
    if (userId == null) return;

    state = state.copyWith(isLoading: true);
    try {
      final ils = amountIls ?? coins.toDouble();
      final result = await supabase.rpc('topup_coins', params: {
        'p_user_id': userId,
        'p_coins': coins,
        'p_amount_ils': ils,
        'p_payment_method': 'mock',
      }) as Map<String, dynamic>;

      if (result['success'] != true) {
        state = state.copyWith(isLoading: false);
        return;
      }

      await loadWallet();
      ref.read(authProvider.notifier).refreshProfile();
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }
}

final walletProvider =
    StateNotifierProvider<WalletNotifier, WalletState>((ref) {
  return WalletNotifier(ref);
});
