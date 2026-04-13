import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../models/models.dart';
import '../services/supabase_service.dart';

class OrdersNotifier extends StateNotifier<List<OrderDetail>> {
  final Ref ref;
  RealtimeChannel? _buyerChannel;
  RealtimeChannel? _sellerChannel;
  Timer? _debounce;

  OrdersNotifier(this.ref) : super([]) {
    loadOrders();
  }

  String? get _userId => supabase.auth.currentUser?.id;

  Future<void> loadOrders() async {
    final uid = _userId;
    // ignore: avoid_print
    print('loadOrders called, uid=$uid');
    if (uid == null) return;
    try {
      // Fetch orders with item join only (avoid multi-FK profile join ambiguity)
      final data = await supabase
          .from('orders')
          .select('*, item:clothing_items(*)')
          .or('buyer_id.eq.$uid,seller_id.eq.$uid')
          .order('created_at', ascending: false) as List;

      // ignore: avoid_print
      print('loadOrders raw count=${data.length}');

      if (data.isEmpty) {
        state = [];
        return;
      }

      // Collect all unique user IDs we need profiles for
      final userIds = <String>{};
      for (final e in data) {
        userIds.add(e['buyer_id'] as String);
        userIds.add(e['seller_id'] as String);
      }

      // Fetch all needed profiles in one query
      final profilesData = await supabase
          .from('profiles')
          .select()
          .inFilter('id', userIds.toList()) as List;
      final profilesMap = {
        for (final p in profilesData) p['id'] as String: AppUser.fromJson(p as Map<String, dynamic>)
      };

      // Collect all order IDs to fetch last messages
      final orderIds = data.map((e) => e['id'] as String).toList();

      // Fetch last message per order + unread count in two parallel queries
      final msgResults = await Future.wait([
        // Last message per order (using distinct on)
        supabase.rpc('get_last_messages', params: {'p_order_ids': orderIds}),
        // Unread counts per order
        supabase.rpc('get_unread_counts', params: {
          'p_order_ids': orderIds,
          'p_user_id': uid,
        }),
      ]);

      final lastMessages = <String, Message>{};
      for (final m in (msgResults[0] as List)) {
        final msg = Message.fromJson(m as Map<String, dynamic>);
        lastMessages[msg.orderId] = msg;
      }

      final unreadCounts = <String, int>{};
      for (final u in (msgResults[1] as List)) {
        final row = u as Map<String, dynamic>;
        unreadCounts[row['order_id'] as String] = row['count'] as int;
      }

      final details = data.map((e) {
        final row = e as Map<String, dynamic>;
        final order = Order.fromJson(row);
        final isBuyer = order.buyerId == uid;
        final otherUserId = isBuyer ? order.sellerId : order.buyerId;
        final otherUser = profilesMap[otherUserId];
        if (otherUser == null) return null;
        final item = ClothingItem.fromJson(row['item'] as Map<String, dynamic>);

        return OrderDetail(
          order: order,
          otherUser: otherUser,
          item: item,
          isBuyer: isBuyer,
          lastMessage: lastMessages[order.id],
          unreadCount: unreadCounts[order.id] ?? 0,
        );
      }).whereType<OrderDetail>().toList();

      state = details;
      _subscribeToRealtime();
    } catch (e, st) {
      // ignore: avoid_print
      print('loadOrders error: $e\n$st');
    }
  }

  void _subscribeToRealtime() {
    final uid = _userId;
    if (uid == null) return;
    // Only subscribe once
    if (_buyerChannel != null) return;

    void onOrderChange(PostgresChangePayload payload) {
      if (!mounted) return;
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), () {
        if (mounted) loadOrders();
      });
    }

    _buyerChannel = supabase
        .channel('orders-buyer-$uid')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'orders',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'buyer_id',
            value: uid,
          ),
          callback: onOrderChange,
        )
        .subscribe();

    _sellerChannel = supabase
        .channel('orders-seller-$uid')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'orders',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'seller_id',
            value: uid,
          ),
          callback: onOrderChange,
        )
        .subscribe();
  }

  Future<void> refresh() async {
    await loadOrders();
  }

  /// Transition an order's status via the server-side function.
  /// Seller calls with [readyForPickup]; buyer calls with [completed] or [cancelled].
  Future<bool> updateOrderStatus(
    String orderId,
    OrderStatus newStatus, {
    String? cancellationReason,
  }) async {
    final uid = _userId;
    if (uid == null) return false;

    final statusString = newStatus == OrderStatus.readyForPickup
        ? 'ready_for_pickup'
        : newStatus.name;

    try {
      final result = await supabase.rpc('update_order_status', params: {
        'p_order_id': orderId,
        'p_new_status': statusString,
        'p_user_id': uid,
        if (cancellationReason != null)
          'p_cancellation_reason': cancellationReason,
      }) as Map<String, dynamic>;

      if (result['success'] == true) {
        await loadOrders();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  void reset() {
    _debounce?.cancel();
    _buyerChannel?.unsubscribe();
    _sellerChannel?.unsubscribe();
    _buyerChannel = null;
    _sellerChannel = null;
    state = [];
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _buyerChannel?.unsubscribe();
    _sellerChannel?.unsubscribe();
    super.dispose();
  }
}

final ordersProvider =
    StateNotifierProvider<OrdersNotifier, List<OrderDetail>>((ref) {
  return OrdersNotifier(ref);
});
