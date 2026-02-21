import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../providers/qa_provider.dart';

/// Student lesson Q&A screen — AI + Teacher tabs
class LessonQAScreen extends StatefulWidget {
  final String lessonId;
  final String lessonTitle;
  final String sectionTitle;
  final String? courseTitle;

  const LessonQAScreen({
    super.key,
    required this.lessonId,
    required this.lessonTitle,
    required this.sectionTitle,
    this.courseTitle,
  });

  @override
  State<LessonQAScreen> createState() => _LessonQAScreenState();
}

class _LessonQAScreenState extends State<LessonQAScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _aiInputController = TextEditingController();
  final _teacherInputController = TextEditingController();
  final _aiScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<QAProvider>(context, listen: false)
          .loadLessonQA(widget.lessonId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _aiInputController.dispose();
    _teacherInputController.dispose();
    _aiScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lessonTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.smart_toy_outlined), text: 'AI Köməkçi'),
            Tab(icon: Icon(Icons.person_outline), text: 'Müəllimə Sual'),
          ],
        ),
      ),
      body: Consumer<QAProvider>(
        builder: (_, provider, __) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildAITab(provider),
              _buildTeacherTab(provider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAITab(QAProvider provider) {
    return Column(
      children: [
        // Limit indicator
        _buildLimitBar(
          remaining: provider.aiQuestionsRemaining,
          total: provider.config?.aiQuestionLimit ?? 30,
          color: AppColors.info,
          label: 'AI sual',
        ),

        // Chat history
        Expanded(
          child: provider.aiHistory.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(Icons.smart_toy,
                            size: 40, color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      Text('AI Köməkçi', style: AppTextStyles.headlineSmall),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          'Bu dərs haqqında suallarınızı soruşun. AI sizə kömək edəcək!',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodySmall,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  controller: _aiScrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.aiHistory.length +
                      (provider.isAiThinking ? 1 : 0),
                  itemBuilder: (_, i) {
                    if (i == provider.aiHistory.length) {
                      return _buildThinkingBubble();
                    }
                    final chat = provider.aiHistory[i];
                    return Column(
                      children: [
                        _buildChatBubble(chat.question, isUser: true),
                        _buildChatBubble(chat.aiAnswer, isUser: false),
                      ],
                    );
                  },
                ),
        ),

        // Input
        _buildInputBar(
          controller: _aiInputController,
          enabled: provider.canAskAI && !provider.isAiThinking,
          hintText: provider.canAskAI
              ? 'AI-yə sual verin...'
              : 'Sual limitiniz bitdi',
          onSend: () => _sendAIQuestion(provider),
          isThinking: provider.isAiThinking,
        ),
      ],
    );
  }

  Widget _buildTeacherTab(QAProvider provider) {
    return Column(
      children: [
        // Limit indicator
        _buildLimitBar(
          remaining: provider.teacherQuestionsRemaining,
          total: provider.config?.teacherQuestionLimit ?? 3,
          color: AppColors.accent,
          label: 'Müəllim sualı',
        ),

        // Questions list
        Expanded(
          child: provider.teacherQuestions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.school_outlined,
                          size: 64,
                          color:
                              AppColors.textSecondary.withValues(alpha: 0.3)),
                      const SizedBox(height: 16),
                      Text('Müəllimə sual göndərin',
                          style: AppTextStyles.bodyLarge),
                      const SizedBox(height: 8),
                      Text(
                        '${provider.teacherQuestionsRemaining} sual hüququnuz var',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.teacherQuestions.length,
                  itemBuilder: (_, i) {
                    final q = provider.teacherQuestions[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.help_outline,
                                    size: 16, color: AppColors.primary),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(q.question,
                                      style: AppTextStyles.bodyMedium),
                                ),
                              ],
                            ),
                            if (q.isAnswered && q.answer != null) ...[
                              const Divider(height: 20),
                              Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.check_circle,
                                      size: 16, color: AppColors.success),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(q.answer!,
                                        style: AppTextStyles.bodyMedium
                                            .copyWith(
                                                color: AppColors.success)),
                                  ),
                                ],
                              ),
                            ] else
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.warning
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text('Cavab gözlənilir...',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: AppColors.warning)),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),

        // Input
        _buildInputBar(
          controller: _teacherInputController,
          enabled: provider.canAskTeacher,
          hintText: provider.canAskTeacher
              ? 'Müəllimə sual göndərin...'
              : 'Sual limitiniz bitdi',
          onSend: () => _sendTeacherQuestion(provider),
        ),
      ],
    );
  }

  Widget _buildLimitBar({
    required int remaining,
    required int total,
    required Color color,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        border: Border(bottom: BorderSide(color: color.withValues(alpha: 0.1))),
      ),
      child: Row(
        children: [
          Text(label, style: AppTextStyles.labelSmall),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: remaining > 0
                  ? color.withValues(alpha: 0.1)
                  : AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$remaining / $total qaldı',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: remaining > 0 ? color : AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(String text, {required bool isUser}) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        margin: EdgeInsets.only(
          bottom: 8,
          left: isUser ? 48 : 0,
          right: isUser ? 0 : 48,
        ),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUser
              ? AppColors.primary
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isUser
                ? const Radius.circular(16)
                : const Radius.circular(4),
            bottomRight: isUser
                ? const Radius.circular(4)
                : const Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isUser ? Colors.white : null,
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildThinkingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(right: 48, bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(width: 10),
            Text('AI düşünür...',
                style: AppTextStyles.bodySmall
                    .copyWith(fontStyle: FontStyle.italic)),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar({
    required TextEditingController controller,
    required bool enabled,
    required String hintText,
    required VoidCallback onSend,
    bool isThinking = false,
  }) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border:
            Border(top: BorderSide(color: Colors.grey.withValues(alpha: 0.15))),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled && !isThinking,
              maxLines: 3,
              minLines: 1,
              decoration: InputDecoration(
                hintText: hintText,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).cardColor,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: IconButton.filled(
              onPressed: enabled && !isThinking ? onSend : null,
              icon: const Icon(Icons.send_rounded, size: 20),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendAIQuestion(QAProvider provider) async {
    final question = _aiInputController.text.trim();
    if (question.isEmpty) return;

    _aiInputController.clear();

    await provider.askAI(
      lessonId: widget.lessonId,
      question: question,
      lessonTitle: widget.lessonTitle,
      sectionTitle: widget.sectionTitle,
      courseTitle: widget.courseTitle,
    );

    // Scroll to bottom
    if (_aiScrollController.hasClients) {
      _aiScrollController.animateTo(
        _aiScrollController.position.maxScrollExtent + 200,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendTeacherQuestion(QAProvider provider) {
    final question = _teacherInputController.text.trim();
    if (question.isEmpty) return;

    _teacherInputController.clear();

    provider.askTeacher(
      lessonId: widget.lessonId,
      question: question,
    );
  }
}
