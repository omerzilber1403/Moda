import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../services/mock_api.dart';

class ChatState {
  final List<Message> messages;
  final bool isLoading;

  const ChatState({this.messages = const [], this.isLoading = false});
}

class ChatNotifier extends StateNotifier<ChatState> {
  final String orderId;

  ChatNotifier(this.orderId) : super(const ChatState()) {
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    state = const ChatState(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 300));
    final messages = MockApi.getMessagesForOrder(orderId);
    state = ChatState(messages: messages);
  }

  void sendMessage(String content, String senderId) {
    final msg = Message(
      id: const Uuid().v4(),
      orderId: orderId,
      senderId: senderId,
      content: content,
      createdAt: DateTime.now(),
    );
    MockApi.messages.add(msg);
    state = ChatState(messages: [...state.messages, msg]);

    // Simulate reply after 1-2 seconds
    _simulateReply();
  }

  Future<void> _simulateReply() async {
    await Future.delayed(const Duration(seconds: 2));
    final replies = [
      'Sounds great!',
      'Perfect, see you there!',
      'I love it!',
      'That works for me!',
      'Looking forward to it!',
    ];
    final reply = replies[DateTime.now().second % replies.length];

    // Find the other user in this order
    final order = MockApi.orders.firstWhere((o) => o.id == orderId);
    final otherUserId =
        order.buyerId == 'user-me' ? order.sellerId : order.buyerId;

    final msg = Message(
      id: const Uuid().v4(),
      orderId: orderId,
      senderId: otherUserId,
      content: reply,
      createdAt: DateTime.now(),
    );
    MockApi.messages.add(msg);
    if (mounted) {
      state = ChatState(messages: [...state.messages, msg]);
    }
  }
}

final chatProvider =
    StateNotifierProvider.family<ChatNotifier, ChatState, String>(
  (ref, orderId) => ChatNotifier(orderId),
);
