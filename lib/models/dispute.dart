class Dispute {
  final String id;
  final String orderId;
  final String openedBy;
  final String reason;
  final String? description;
  final String status;
  final String? resolution;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  const Dispute({
    required this.id,
    required this.orderId,
    required this.openedBy,
    required this.reason,
    this.description,
    this.status = 'open',
    this.resolution,
    required this.createdAt,
    this.resolvedAt,
  });

  factory Dispute.fromJson(Map<String, dynamic> json) => Dispute(
        id: json['id'] as String,
        orderId: json['order_id'] as String,
        openedBy: json['opened_by'] as String,
        reason: json['reason'] as String,
        description: json['description'] as String?,
        status: json['status'] as String? ?? 'open',
        resolution: json['resolution'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
        resolvedAt: json['resolved_at'] != null
            ? DateTime.parse(json['resolved_at'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'order_id': orderId,
        'opened_by': openedBy,
        'reason': reason,
        if (description != null) 'description': description,
      };
}
