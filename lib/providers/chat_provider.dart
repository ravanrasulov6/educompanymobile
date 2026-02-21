import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/chat_model.dart';

class ChatProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  List<ConversationModel> _conversations = [];
  List<MessageModel> _messages = [];
  bool _isMessagesLoading = false;
  bool _isConversationsLoading = false;
  RealtimeChannel? _messageChannel;

  List<ConversationModel> get conversations => _conversations;
  List<MessageModel> get messages => _messages;
  bool get isMessagesLoading => _isMessagesLoading;
  bool get isConversationsLoading => _isConversationsLoading;

  int get totalUnreadCount => _conversations.fold(0, (sum, item) => sum + item.unreadCount);

  Future<void> loadConversations() async {
    _isConversationsLoading = true;
    notifyListeners();

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      // In a real app, we'd use a dedicated RPC or view to get unread counts
      final response = await _supabase
          .from('conversations')
          .select('*, participant:profiles!participant_id(*)')
          .or('student_id.eq.$userId,participant_id.eq.$userId')
          .order('last_message_at', ascending: false);

      _conversations = (response as List)
          .map((json) => ConversationModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error loading conversations: $e');
    } finally {
      _isConversationsLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMessages(String conversationId) async {
    _isMessagesLoading = true;
    _messages = [];
    notifyListeners();

    try {
      // 1. Initial Load
      final response = await _supabase
          .from('messages')
          .select()
          .eq('conversation_id', conversationId)
          .order('created_at', ascending: true);

      _messages = (response as List)
          .map((json) => MessageModel.fromJson(json))
          .toList();

      // 2. Mark as read
      await _supabase
          .from('messages')
          .update({'is_read': true})
          .eq('conversation_id', conversationId)
          .eq('is_read', false)
          .neq('sender_type', 'student'); // Don't mark own as unread

      // 3. Subscribe to Realtime
      _subscribeToMessages(conversationId);
    } catch (e) {
      debugPrint('Error loading messages: $e');
    } finally {
      _isMessagesLoading = false;
      notifyListeners();
    }
  }

  void _subscribeToMessages(String conversationId) {
    _messageChannel?.unsubscribe();
    _messageChannel = _supabase
        .channel('public:messages:conversation=$conversationId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'conversation_id',
            value: conversationId,
          ),
          callback: (payload) {
            final newMessage = MessageModel.fromJson(payload.newRecord);
            if (!_messages.any((m) => m.id == newMessage.id)) {
              _messages.add(newMessage);
              notifyListeners();
            }
          },
        )
        .subscribe();
  }

  Future<void> sendMessage(String conversationId, String content) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await _supabase.from('messages').insert({
        'conversation_id': conversationId,
        'sender_id': userId,
        'content': content,
        'sender_type': 'student',
      });

      // Update last_message_at in conversation
      await _supabase
          .from('conversations')
          .update({'last_message_at': DateTime.now().toIso8601String()})
          .eq('id', conversationId);
    } catch (e) {
      debugPrint('Error sending message: $e');
    }
  }

  @override
  void dispose() {
    _messageChannel?.unsubscribe();
    super.dispose();
  }
}
