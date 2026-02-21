import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/premium_kit.dart';
import '../../../providers/chat_provider.dart';
import '../../../models/chat_model.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  int _selectedTab = 0; // 0: AI, 1: Müəllim

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ChatProvider>().loadConversations());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Mesajlar'),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: PremiumSegmentedControl(
              items: const ['AI Köməkçi', 'Müəllimlər'],
              selectedIndex: _selectedTab,
              onValueChanged: (v) => setState(() => _selectedTab = v),
            ),
          ),
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, provider, _) {
                final type = _selectedTab == 0 ? ConversationType.ai : ConversationType.teacher;
                final filtered = provider.conversations.where((c) => c.type == type).toList();

                if (provider.isConversationsLoading && filtered.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (filtered.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final conv = filtered[index];
                    return _buildConversationTile(conv);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationTile(ConversationModel conv) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => context.push('/student/chat/${conv.id}'),
        child: GlassCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildAvatar(conv),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          conv.type == ConversationType.ai ? 'AI Tutor' : (conv.participantName ?? 'Müəllim'),
                          style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
                        ),
                        Text(
                          _formatDate(conv.lastMessageAt),
                          style: AppTextStyles.labelSmall.copyWith(color: Colors.white54),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      conv.metadata['last_message'] ?? 'Mesaj yoxdur',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMedium.copyWith(color: Colors.white.withValues(alpha: 0.74)),
                    ),
                  ],
                ),
              ),
              if (conv.unreadCount > 0)
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  child: Text(
                    conv.unreadCount.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(ConversationModel conv) {
    if (conv.type == ConversationType.ai) {
      return Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [AppColors.primary, AppColors.accent]),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.psychology_rounded, color: Colors.white, size: 28),
      );
    }
    return CircleAvatar(
      radius: 25,
      backgroundImage: conv.participantAvatar != null ? NetworkImage(conv.participantAvatar!) : null,
      child: conv.participantAvatar == null ? const Icon(Icons.person) : null,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.chat_bubble_outline_rounded, size: 64, color: Colors.white24),
          const SizedBox(height: 16),
          Text('Hələ ki mesaj yoxdur', style: AppTextStyles.bodyLarge.copyWith(color: Colors.white54)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
    return '${date.day}.${date.month}';
  }
}
