class Report {
  final String id;
  final String reporterId;
  final String? reportedUserId;
  final String? reportedItemId;
  final String reason;
  final String? description;
  final String status;
  final DateTime createdAt;

  const Report({
    required this.id,
    required this.reporterId,
    this.reportedUserId,
    this.reportedItemId,
    required this.reason,
    this.description,
    this.status = 'pending',
    required this.createdAt,
  });

  factory Report.fromJson(Map<String, dynamic> json) => Report(
        id: json['id'] as String,
        reporterId: json['reporter_id'] as String,
        reportedUserId: json['reported_user_id'] as String?,
        reportedItemId: json['reported_item_id'] as String?,
        reason: json['reason'] as String,
        description: json['description'] as String?,
        status: json['status'] as String? ?? 'pending',
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'reporter_id': reporterId,
        if (reportedUserId != null) 'reported_user_id': reportedUserId,
        if (reportedItemId != null) 'reported_item_id': reportedItemId,
        'reason': reason,
        if (description != null) 'description': description,
      };
}
