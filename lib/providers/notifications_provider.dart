import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../models/models.dart';
import '../services/supabase_service.dart';
import 'orders_provider.dart';

class NotificationsState {
  final List<AppNotification> notifications;
  final bool isLoading;

  const NotificationsState({
    this.notifications = const [],
    this.isLoading = false,
  });

  NotificationsState copyWith({
    List<AppNotification>? notifications,
    bool? isLoading,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  int get unreadCount => notifications.where((n) => !n.isRead).length;
}

class NotificationsNotifier extends StateNotifier<NotificationsState> {
  final Ref ref;
  RealtimeChannel? _channel;

  NotificationsNotifier(this.ref) : super(const NotificationsState()) {
    loadNotifications();
  }

  String? get _userId => supabase.auth.currentUser?.id;

  static const _orderRelatedTypes = {
    'new_message',
    'order_update',
    'order_ready',
    'order_completed',
    'order_cancelled',
  };

  Future<void> loadNotifications() async {
    final userId = _userId;
    if (userId == null) return;
    state = state.copyWith(isLoading: true);
    try {
      final data = await supabase
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      final notifications =
          (data as List).map((e) => AppNotification.fromJson(e)).toList();
      state = NotificationsState(notifications: notifications);
      _subscribeToRealtime();
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  void _subscribeToRealtime() {
    final userId = _userId;
    if (userId == null) return;
    _channel?.unsubscribe();
    _channel = supabase
        .channel('notifications-$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            if (!mounted) return;
            final newNotif = AppNotification.fromJson(payload.newRecord);
            // Avoid duplicates
            if (state.notifications.any((n) => n.id == newNotif.id)) return;
            state = state.copyWith(
              notifications: [newNotif, ...state.notifications],
            );
            // Refresh orders when an order-related notification arrives
            final type = payload.newRecord['type'] as String?;
            if (type != null && _orderRelatedTypes.contains(type)) {
              ref.read(ordersProvider.notifier).refresh();
            }
          },
        )
        .subscribe();
  }

  Future<void> markAsRead(String notifId) async {
    try {
      await supabase
          .from('notifications')
          .update({'is_read': true}).eq('id', notifId);
      state = state.copyWith(
        notifications: state.notifications.map((n) {
          return n.id == notifId ? n.copyWith(isRead: true) : n;
        }).toList(),
      );
    } catch (_) {
      // ignore
    }
  }

  Future<void> markAllAsRead() async {
    final userId = _userId;
    if (userId == null) return;
    try {
      await supabase
          .from('notifications')
          .update({'is_read': true}).eq('user_id', userId);
      state = state.copyWith(
        notifications: state.notifications.map((n) {
          return n.copyWith(isRead: true);
        }).toList(),
      );
    } catch (_) {
      // ignore
    }
  }

  Future<void> removeNotification(String notifId) async {
    try {
      await supabase.from('notifications').delete().eq('id', notifId);
      state = state.copyWith(
        notifications:
            state.notifications.where((n) => n.id != notifId).toList(),
      );
    } catch (_) {
      // ignore
    }
  }

  void reset() {
    _channel?.unsubscribe();
    _channel = null;
    state = const NotificationsState();
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    super.dispose();
  }
}

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, NotificationsState>((ref) {
  return NotificationsNotifier(ref);
});
