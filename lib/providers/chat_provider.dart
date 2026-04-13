import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../models/models.dart';
import '../services/supabase_service.dart';

class ChatState {
  final List<Message> messages;
  final bool isLoading;

  const ChatState({this.messages = const [], this.isLoading = false});
}

class ChatNotifier extends StateNotifier<ChatState> {
  final String orderId;
  RealtimeChannel? _channel;

  ChatNotifier(this.orderId) : super(const ChatState()) {
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    state = const ChatState(isLoading: true);
    try {
      final data = await supabase
          .from('messages')
          .select()
          .eq('order_id', orderId)
          .order('created_at', ascending: true);
      final messages =
          (data as List).map((e) => Message.fromJson(e)).toList();
      state = ChatState(messages: messages);

      // Subscribe to realtime inserts
      _channel = supabase
          .channel('order-chat-$orderId')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'messages',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'order_id',
              value: orderId,
            ),
            callback: (payload) {
              if (!mounted) return;
              final newMsg = Message.fromJson(payload.newRecord);
              // Avoid duplicates
              if (state.messages.any((m) => m.id == newMsg.id)) return;
              state = ChatState(messages: [...state.messages, newMsg]);
            },
          )
          .subscribe();
    } catch (_) {
      state = const ChatState();
    }
  }

  Future<void> sendMessage(String content, String senderId) async {
    try {
      await supabase.from('messages').insert({
        'order_id': orderId,
        'sender_id': senderId,
        'content': content,
        'type': 'text',
        'sent_at': DateTime.now().toIso8601String(),
      });
      // Realtime channel will auto-add the message to state
    } catch (_) {
      // ignore
    }
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    super.dispose();
  }
}

final chatProvider =
    StateNotifierProvider.family<ChatNotifier, ChatState, String>(
  (ref, orderId) => ChatNotifier(orderId),
);
