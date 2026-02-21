import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../providers/chat_provider.dart';
import '../../../models/chat_model.dart';

class ChatViewScreen extends StatefulWidget {
  final String conversationId;

  const ChatViewScreen({super.key, required this.conversationId});

  @override
  State<ChatViewScreen> createState() => _ChatViewScreenState();
}

class _ChatViewScreenState extends State<ChatViewScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ChatProvider>().loadMessages(widget.conversationId));
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    HapticFeedback.lightImpact();
    context.read<ChatProvider>().sendMessage(widget.conversationId, text);
    _controller.clear();
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          _buildInputArea(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final provider = context.watch<ChatProvider>();
    final conv = provider.conversations.firstWhere((c) => c.id == widget.conversationId, 
      orElse: () => ConversationModel(id: '', studentId: '', type: ConversationType.ai, lastMessageAt: DateTime.now()));
    
    return AppBar(
      backgroundColor: Colors.black,
      title: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: conv.type == ConversationType.ai ? AppColors.primary : Colors.grey,
            child: Icon(conv.type == ConversationType.ai ? Icons.psychology : Icons.person, size: 18, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Text(conv.type == ConversationType.ai ? 'AI Tutor' : (conv.participantName ?? 'Müəllim'), style: AppTextStyles.titleMedium),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return Consumer<ChatProvider>(
      builder: (context, provider, _) {
        if (provider.isMessagesLoading && provider.messages.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(20),
          itemCount: provider.messages.length,
          itemBuilder: (context, index) {
            final msg = provider.messages[index];
            return _buildMessageBubble(msg);
          },
        );
      },
    );
  }

  Widget _buildMessageBubble(MessageModel msg) {
    final isMe = msg.isFromMe;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary : Colors.white10,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isMe ? 20 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 20),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(msg.content, style: AppTextStyles.bodyMedium.copyWith(color: Colors.white)),
            const SizedBox(height: 4),
            Text(
              '${msg.createdAt.hour}:${msg.createdAt.minute.toString().padLeft(2, '0')}',
              style: TextStyle(fontSize: 10, color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 8, 20, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
      ),
      child: Row(
        children: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.add_rounded, color: Colors.white54)),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _controller,
                maxLines: 4,
                minLines: 1,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Mesaj yazın...',
                  hintStyle: TextStyle(color: Colors.white24),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _sendMessage,
            icon: const Icon(Icons.send_rounded, color: AppColors.primary),
            style: IconButton.styleFrom(backgroundColor: AppColors.primary.withValues(alpha: 0.1)),
          ),
        ],
      ),
    );
  }
}
