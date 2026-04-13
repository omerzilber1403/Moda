enum TransactionType { welcomeBonus, purchase, sale, topup }

class Transaction {
  final String id;
  final String userId;
  final TransactionType type;
  final int amount;
  final String description;
  final int balanceAfter;
  final DateTime createdAt;
  final DateTime? transactionTime;
  final DateTime? confirmationTime;
  final String? notes;

  const Transaction({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.description,
    required this.balanceAfter,
    required this.createdAt,
    this.transactionTime,
    this.confirmationTime,
    this.notes,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: _parseType(json['type'] as String? ?? 'purchase'),
      amount: json['amount'] as int? ?? 0,
      description: json['description'] as String? ?? '',
      balanceAfter: json['balance_after'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      transactionTime: json['transaction_time'] != null
          ? DateTime.parse(json['transaction_time'] as String)
          : null,
      confirmationTime: json['confirmation_time'] != null
          ? DateTime.parse(json['confirmation_time'] as String)
          : null,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'type': _typeToDb(type),
        'amount': amount,
        'description': description,
        'balance_after': balanceAfter,
        if (transactionTime != null)
          'transaction_time': transactionTime!.toIso8601String(),
        if (confirmationTime != null)
          'confirmation_time': confirmationTime!.toIso8601String(),
        if (notes != null) 'notes': notes,
      };

  static TransactionType _parseType(String value) {
    switch (value) {
      case 'welcome_bonus':
        return TransactionType.welcomeBonus;
      case 'purchase':
        return TransactionType.purchase;
      case 'sale':
        return TransactionType.sale;
      case 'topup':
        return TransactionType.topup;
      default:
        return TransactionType.purchase;
    }
  }

  static String _typeToDb(TransactionType type) {
    switch (type) {
      case TransactionType.welcomeBonus:
        return 'welcome_bonus';
      case TransactionType.purchase:
        return 'purchase';
      case TransactionType.sale:
        return 'sale';
      case TransactionType.topup:
        return 'topup';
    }
  }
}
