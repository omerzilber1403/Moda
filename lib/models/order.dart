import 'user.dart';
import 'clothing_item.dart';
import 'message.dart';

enum OrderStatus { pending, confirmed, readyForPickup, completed, cancelled }

class Order {
  final String id;
  final String buyerId;
  final String sellerId;
  final String itemId;
  final int priceInCoins;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? orderedAt;
  final DateTime? readyAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final String? cancelledBy;
  final bool buyerConfirmedPickup;
  final bool sellerConfirmedPickup;

  const Order({
    required this.id,
    required this.buyerId,
    required this.sellerId,
    required this.itemId,
    required this.priceInCoins,
    this.status = OrderStatus.pending,
    required this.createdAt,
    this.orderedAt,
    this.readyAt,
    this.completedAt,
    this.cancelledAt,
    this.cancellationReason,
    this.cancelledBy,
    this.buyerConfirmedPickup = false,
    this.sellerConfirmedPickup = false,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      buyerId: json['buyer_id'] as String,
      sellerId: json['seller_id'] as String,
      itemId: json['item_id'] as String,
      priceInCoins: json['price_in_coins'] as int? ?? 0,
      status: _parseStatus(json['status'] as String? ?? 'pending'),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      orderedAt: json['ordered_at'] != null
          ? DateTime.parse(json['ordered_at'] as String)
          : null,
      readyAt: json['ready_at'] != null
          ? DateTime.parse(json['ready_at'] as String)
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.parse(json['cancelled_at'] as String)
          : null,
      cancellationReason: json['cancellation_reason'] as String?,
      cancelledBy: json['cancelled_by'] as String?,
      buyerConfirmedPickup: json['buyer_confirmed_pickup'] as bool? ?? false,
      sellerConfirmedPickup: json['seller_confirmed_pickup'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'buyer_id': buyerId,
        'seller_id': sellerId,
        'item_id': itemId,
        'price_in_coins': priceInCoins,
        'status': _statusToString(status),
        if (orderedAt != null) 'ordered_at': orderedAt!.toIso8601String(),
      };

  static OrderStatus _parseStatus(String value) {
    switch (value) {
      case 'ready_for_pickup':
        return OrderStatus.readyForPickup;
      default:
        return OrderStatus.values.firstWhere(
          (e) => e.name == value,
          orElse: () => OrderStatus.pending,
        );
    }
  }

  static String _statusToString(OrderStatus status) {
    if (status == OrderStatus.readyForPickup) return 'ready_for_pickup';
    return status.name;
  }

  /// Whether this user has already confirmed pickup.
  bool hasConfirmed(String userId) {
    if (userId == buyerId) return buyerConfirmedPickup;
    if (userId == sellerId) return sellerConfirmedPickup;
    return false;
  }

  /// Whether the other party has confirmed pickup.
  bool otherPartyConfirmed(String userId) {
    if (userId == buyerId) return sellerConfirmedPickup;
    if (userId == sellerId) return buyerConfirmedPickup;
    return false;
  }

  Order copyWith({
    String? id,
    String? buyerId,
    String? sellerId,
    String? itemId,
    int? priceInCoins,
    OrderStatus? status,
    DateTime? createdAt,
    DateTime? orderedAt,
    DateTime? readyAt,
    DateTime? completedAt,
    DateTime? cancelledAt,
    String? cancellationReason,
    String? cancelledBy,
    bool? buyerConfirmedPickup,
    bool? sellerConfirmedPickup,
  }) {
    return Order(
      id: id ?? this.id,
      buyerId: buyerId ?? this.buyerId,
      sellerId: sellerId ?? this.sellerId,
      itemId: itemId ?? this.itemId,
      priceInCoins: priceInCoins ?? this.priceInCoins,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      orderedAt: orderedAt ?? this.orderedAt,
      readyAt: readyAt ?? this.readyAt,
      completedAt: completedAt ?? this.completedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      cancelledBy: cancelledBy ?? this.cancelledBy,
      buyerConfirmedPickup: buyerConfirmedPickup ?? this.buyerConfirmedPickup,
      sellerConfirmedPickup: sellerConfirmedPickup ?? this.sellerConfirmedPickup,
    );
  }
}

class OrderDetail {
  final Order order;
  final AppUser otherUser;
  final ClothingItem item;
  final Message? lastMessage;
  final int unreadCount;
  final bool isBuyer;

  const OrderDetail({
    required this.order,
    required this.otherUser,
    required this.item,
    this.lastMessage,
    this.unreadCount = 0,
    required this.isBuyer,
  });
}
