class Review {
  final String id;
  final String orderId;
  final String reviewerId;
  final String revieweeId;
  final String itemId;
  final int rating;
  final String comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.orderId,
    required this.reviewerId,
    required this.revieweeId,
    required this.itemId,
    required this.rating,
    required this.comment,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Review copyWith({
    String? id,
    String? orderId,
    String? reviewerId,
    String? revieweeId,
    String? itemId,
    int? rating,
    String? comment,
    DateTime? createdAt,
  }) {
    return Review(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      reviewerId: reviewerId ?? this.reviewerId,
      revieweeId: revieweeId ?? this.revieweeId,
      itemId: itemId ?? this.itemId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
