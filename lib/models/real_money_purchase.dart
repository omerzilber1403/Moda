class RealMoneyPurchase {
  final String id;
  final String userId;
  final double amountIls;
  final int coinsPurchased;
  final String? paymentMethod;
  final String status; // pending, completed, failed, refunded
  final String? paymentReference;
  final String? transactionId;
  final DateTime createdAt;
  final DateTime? completedAt;

  const RealMoneyPurchase({
    required this.id,
    required this.userId,
    required this.amountIls,
    required this.coinsPurchased,
    this.paymentMethod,
    required this.status,
    this.paymentReference,
    this.transactionId,
    required this.createdAt,
    this.completedAt,
  });

  factory RealMoneyPurchase.fromJson(Map<String, dynamic> json) =>
      RealMoneyPurchase(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        amountIls: (json['amount_ils'] as num).toDouble(),
        coinsPurchased: json['coins_purchased'] as int,
        paymentMethod: json['payment_method'] as String?,
        status: json['status'] as String,
        paymentReference: json['payment_reference'] as String?,
        transactionId: json['transaction_id'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
        completedAt: json['completed_at'] != null
            ? DateTime.parse(json['completed_at'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'amount_ils': amountIls,
        'coins_purchased': coinsPurchased,
        if (paymentMethod != null) 'payment_method': paymentMethod,
        'status': status,
        if (paymentReference != null) 'payment_reference': paymentReference,
        if (transactionId != null) 'transaction_id': transactionId,
      };
}
