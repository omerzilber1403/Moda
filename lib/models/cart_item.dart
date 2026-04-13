import 'clothing_item.dart';

class CartItem {
  final String id;
  final String itemId;
  final String userId;
  final DateTime addedAt;
  final ClothingItem? item;

  CartItem({
    required this.id,
    required this.itemId,
    required this.userId,
    DateTime? addedAt,
    this.item,
  }) : addedAt = addedAt ?? DateTime.now();

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as String,
      itemId: json['item_id'] as String,
      userId: json['user_id'] as String,
      addedAt: json['added_at'] != null
          ? DateTime.parse(json['added_at'] as String)
          : DateTime.now(),
      item: json['item'] is Map<String, dynamic>
          ? ClothingItem.fromJson(json['item'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'item_id': itemId,
      };

  CartItem copyWith({
    String? id,
    String? itemId,
    String? userId,
    DateTime? addedAt,
    ClothingItem? item,
  }) {
    return CartItem(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      userId: userId ?? this.userId,
      addedAt: addedAt ?? this.addedAt,
      item: item ?? this.item,
    );
  }
}
