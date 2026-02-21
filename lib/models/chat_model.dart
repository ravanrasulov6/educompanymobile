import 'package:supabase_flutter/supabase_flutter.dart';

enum MessageSenderType { student, teacher, assistant }
enum ConversationType { ai, teacher }

class MessageModel {
  final String id;
  final String conversationId;
  final String? senderId;
  final String content;
  final MessageSenderType senderType;
  final List<Map<String, dynamic>> citations;
  final List<String> attachments;
  final bool isRead;
  final DateTime createdAt;

  MessageModel({
    required this.id,
    required this.conversationId,
    this.senderId,
    required this.content,
    required this.senderType,
    this.citations = const [],
    this.attachments = const [],
    this.isRead = false,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      conversationId: json['conversation_id'],
      senderId: json['sender_id'],
      content: json['content'],
      senderType: _parseSenderType(json['sender_type']),
      citations: List<Map<String, dynamic>>.from(json['citations'] ?? []),
      attachments: List<String>.from(json['attachments'] ?? []),
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  static MessageSenderType _parseSenderType(String? type) {
    switch (type) {
      case 'teacher': return MessageSenderType.teacher;
      case 'assistant': return MessageSenderType.assistant;
      default: return MessageSenderType.student;
    }
  }

  bool get isFromMe => senderType == MessageSenderType.student;
}

class ConversationModel {
  final String id;
  final String studentId;
  final String? participantId;
  final ConversationType type;
  final DateTime lastMessageAt;
  final Map<String, dynamic> metadata;
  final int unreadCount;
  final String? participantName;
  final String? participantAvatar;

  ConversationModel({
    required this.id,
    required this.studentId,
    this.participantId,
    required this.type,
    required this.lastMessageAt,
    this.metadata = const {},
    this.unreadCount = 0,
    this.participantName,
    this.participantAvatar,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'],
      studentId: json['student_id'],
      participantId: json['participant_id'],
      type: json['type'] == 'ai' ? ConversationType.ai : ConversationType.teacher,
      lastMessageAt: DateTime.parse(json['last_message_at']),
      metadata: json['metadata'] ?? {},
      unreadCount: json['unread_count'] ?? 0,
      participantName: json['participant']?['full_name'],
      participantAvatar: json['participant']?['avatar_url'],
    );
  }
}
