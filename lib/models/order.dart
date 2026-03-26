import 'user.dart';
import 'clothing_item.dart';
import 'message.dart';

enum OrderStatus { pending, confirmed, completed, cancelled }

class Order {
  final String id;
  final String buyerId;
  final String sellerId;
  final String itemId;
  final int priceInCoins;
  final OrderStatus status;
  final DateTime createdAt;

  const Order({
    required this.id,
    required this.buyerId,
    required this.sellerId,
    required this.itemId,
    required this.priceInCoins,
    this.status = OrderStatus.pending,
    required this.createdAt,
  });

  Order copyWith({
    String? id,
    String? buyerId,
    String? sellerId,
    String? itemId,
    int? priceInCoins,
    OrderStatus? status,
    DateTime? createdAt,
  }) {
    return Order(
      id: id ?? this.id,
      buyerId: buyerId ?? this.buyerId,
      sellerId: sellerId ?? this.sellerId,
      itemId: itemId ?? this.itemId,
      priceInCoins: priceInCoins ?? this.priceInCoins,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class OrderDetail {
  final Order order;
  final User otherUser;
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
