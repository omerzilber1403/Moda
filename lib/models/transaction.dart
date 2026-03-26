enum TransactionType { welcomeBonus, purchase, sale, topup }

class Transaction {
  final String id;
  final String userId;
  final TransactionType type;
  final int amount;
  final String description;
  final int balanceAfter;
  final DateTime createdAt;

  const Transaction({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.description,
    required this.balanceAfter,
    required this.createdAt,
  });
}
