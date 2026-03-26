class CartItem {
  final String id;
  final String itemId;
  final String userId;
  final int quantity;
  final DateTime addedAt;

  CartItem({
    required this.id,
    required this.itemId,
    required this.userId,
    this.quantity = 1,
    DateTime? addedAt,
  }) : addedAt = addedAt ?? DateTime.now();

  CartItem copyWith({
    String? id,
    String? itemId,
    String? userId,
    int? quantity,
    DateTime? addedAt,
  }) {
    return CartItem(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      userId: userId ?? this.userId,
      quantity: quantity ?? this.quantity,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}
