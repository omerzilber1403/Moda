enum MessageType { text, image, system }

class Message {
  final String id;
  final String orderId;
  final String senderId;
  final String content;
  final MessageType type;
  final DateTime? readAt;
  final DateTime createdAt;
  final DateTime? sentAt;

  const Message({
    required this.id,
    required this.orderId,
    required this.senderId,
    required this.content,
    this.type = MessageType.text,
    this.readAt,
    required this.createdAt,
    this.sentAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      senderId: json['sender_id'] as String,
      content: json['content'] as String? ?? '',
      type: _parseType(json['type'] as String? ?? 'text'),
      readAt: json['read_at'] != null
          ? DateTime.parse(json['read_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      sentAt: json['sent_at'] != null
          ? DateTime.parse(json['sent_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'order_id': orderId,
        'sender_id': senderId,
        'content': content,
        'type': type.name,
        if (sentAt != null) 'sent_at': sentAt!.toIso8601String(),
      };

  static MessageType _parseType(String value) {
    return MessageType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => MessageType.text,
    );
  }
}
