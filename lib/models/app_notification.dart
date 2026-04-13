enum NotificationType {
  orderUpdate,
  priceDropAlert,
  newMessage,
  promotion,
  welcome,
  review,
  itemLiked,
  orderReady,
  orderCompleted,
  orderCancelled,
}

class AppNotification {
  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String body;
  final String? imageUrl;
  final String? routeTo;
  final bool isRead;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    this.imageUrl,
    this.routeTo,
    this.isRead = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: _parseType(json['type'] as String? ?? 'welcome'),
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
      routeTo: json['route_to'] as String?,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'type': _typeToDb(type),
        'title': title,
        'body': body,
        if (imageUrl != null) 'image_url': imageUrl,
        if (routeTo != null) 'route_to': routeTo,
        'is_read': isRead,
      };

  static NotificationType _parseType(String value) {
    switch (value) {
      case 'order_update':
        return NotificationType.orderUpdate;
      case 'price_drop_alert':
        return NotificationType.priceDropAlert;
      case 'new_message':
        return NotificationType.newMessage;
      case 'promotion':
        return NotificationType.promotion;
      case 'welcome':
        return NotificationType.welcome;
      case 'review':
        return NotificationType.review;
      case 'item_liked':
        return NotificationType.itemLiked;
      case 'order_ready':
        return NotificationType.orderReady;
      case 'order_completed':
        return NotificationType.orderCompleted;
      case 'order_cancelled':
        return NotificationType.orderCancelled;
      default:
        return NotificationType.welcome;
    }
  }

  static String _typeToDb(NotificationType type) {
    switch (type) {
      case NotificationType.orderUpdate:
        return 'order_update';
      case NotificationType.priceDropAlert:
        return 'price_drop_alert';
      case NotificationType.newMessage:
        return 'new_message';
      case NotificationType.promotion:
        return 'promotion';
      case NotificationType.welcome:
        return 'welcome';
      case NotificationType.review:
        return 'review';
      case NotificationType.itemLiked:
        return 'item_liked';
      case NotificationType.orderReady:
        return 'order_ready';
      case NotificationType.orderCompleted:
        return 'order_completed';
      case NotificationType.orderCancelled:
        return 'order_cancelled';
    }
  }

  AppNotification copyWith({
    String? id,
    String? userId,
    NotificationType? type,
    String? title,
    String? body,
    String? imageUrl,
    String? routeTo,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      imageUrl: imageUrl ?? this.imageUrl,
      routeTo: routeTo ?? this.routeTo,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
