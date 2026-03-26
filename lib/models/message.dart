enum MessageType { text, image, system }

class Message {
  final String id;
  final String orderId;
  final String senderId;
  final String content;
  final MessageType type;
  final DateTime? readAt;
  final DateTime createdAt;

  const Message({
    required this.id,
    required this.orderId,
    required this.senderId,
    required this.content,
    this.type = MessageType.text,
    this.readAt,
    required this.createdAt,
  });
}
