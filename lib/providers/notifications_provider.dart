import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import 'auth_provider.dart';

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

  NotificationsNotifier(this.ref) : super(const NotificationsState()) {
    _loadMockNotifications();
  }

  String? get _userId => ref.read(authProvider).user?.id;

  void _loadMockNotifications() {
    final userId = _userId;
    if (userId == null) return;

    state = NotificationsState(notifications: [
      AppNotification(
        id: 'notif-1',
        userId: userId,
        type: NotificationType.welcome,
        title: 'Welcome to Moda!',
        body: 'You received 50 Style Coins to start shopping second-hand fashion.',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        isRead: true,
      ),
      AppNotification(
        id: 'notif-2',
        userId: userId,
        type: NotificationType.orderUpdate,
        title: 'Order Confirmed',
        body: 'Your purchase of "Vintage Denim Jacket" has been confirmed. Chat with the seller to arrange pickup.',
        routeTo: '/orders',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      AppNotification(
        id: 'notif-3',
        userId: userId,
        type: NotificationType.newMessage,
        title: 'New Message from Maya',
        body: 'Hey! When would you like to pick up the jacket?',
        imageUrl: 'https://picsum.photos/seed/avatar-maya/300/300',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      AppNotification(
        id: 'notif-4',
        userId: userId,
        type: NotificationType.priceDropAlert,
        title: 'Price Drop!',
        body: 'An item in your wishlist "Oversized Blazer" dropped from 35 SC to 25 SC.',
        routeTo: '/saved',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      AppNotification(
        id: 'notif-5',
        userId: userId,
        type: NotificationType.promotion,
        title: 'Weekend Sale!',
        body: 'Top up Style Coins this weekend and get 10% bonus coins on every purchase.',
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
    ]);
  }

  void markAsRead(String notifId) {
    state = state.copyWith(
      notifications: state.notifications.map((n) {
        return n.id == notifId ? n.copyWith(isRead: true) : n;
      }).toList(),
    );
  }

  void markAllAsRead() {
    state = state.copyWith(
      notifications: state.notifications.map((n) {
        return n.copyWith(isRead: true);
      }).toList(),
    );
  }

  void removeNotification(String notifId) {
    state = state.copyWith(
      notifications: state.notifications.where((n) => n.id != notifId).toList(),
    );
  }
}

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, NotificationsState>((ref) {
  return NotificationsNotifier(ref);
});
