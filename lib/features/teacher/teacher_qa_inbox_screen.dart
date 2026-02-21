import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/student_question_model.dart';
import '../../providers/qa_provider.dart';

/// Teacher Q&A inbox — view and answer student questions
class TeacherQAInboxScreen extends StatefulWidget {
  const TeacherQAInboxScreen({super.key});

  @override
  State<TeacherQAInboxScreen> createState() => _TeacherQAInboxScreenState();
}

class _TeacherQAInboxScreenState extends State<TeacherQAInboxScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<StudentQuestionModel> _allQuestions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadQuestions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    setState(() => _isLoading = true);
    final provider = Provider.of<QAProvider>(context, listen: false);
    _allQuestions = await provider.loadTeacherInbox();
    setState(() => _isLoading = false);
  }

  List<StudentQuestionModel> get _unanswered =>
      _allQuestions.where((q) => !q.isAnswered).toList();

  List<StudentQuestionModel> get _answered =>
      _allQuestions.where((q) => q.isAnswered).toList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Stats row
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildStatChip(
                '${_unanswered.length}',
                'Gözləyən',
                AppColors.warning,
              ),
              const SizedBox(width: 12),
              _buildStatChip(
                '${_answered.length}',
                'Cavablanmış',
                AppColors.success,
              ),
              const SizedBox(width: 12),
              _buildStatChip(
                '${_allQuestions.length}',
                'Ümumi',
                AppColors.primary,
              ),
            ],
          ),
        ),

        // Tabs
        TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Gözləyən'),
                  if (_unanswered.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${_unanswered.length}',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 11),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Tab(text: 'Cavablanmış'),
          ],
        ),

        // Content
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildQuestionList(_unanswered, canAnswer: true),
                    _buildQuestionList(_answered, canAnswer: false),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildStatChip(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(value,
                style: AppTextStyles.headlineSmall
                    .copyWith(color: color)),
            Text(label, style: AppTextStyles.labelSmall),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionList(List<StudentQuestionModel> questions,
      {required bool canAnswer}) {
    if (questions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined,
                size: 64,
                color: AppColors.textSecondary.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text(
              canAnswer ? 'Gözləyən sual yoxdur' : 'Cavablanmış sual yoxdur',
              style: AppTextStyles.bodyLarge,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadQuestions,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: questions.length,
        itemBuilder: (context, index) =>
            _buildQuestionCard(questions[index], canAnswer: canAnswer),
      ),
    );
  }

  Widget _buildQuestionCard(StudentQuestionModel question,
      {required bool canAnswer}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Student info
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Text(
                    (question.studentName ?? 'T')[0].toUpperCase(),
                    style: const TextStyle(
                        color: AppColors.primary, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(question.studentName ?? 'Tələbə',
                          style: AppTextStyles.titleSmall),
                      Text(
                        _formatDate(question.createdAt),
                        style: AppTextStyles.labelSmall,
                      ),
                    ],
                  ),
                ),
                if (!question.isAnswered)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('Gözləyir',
                        style: TextStyle(
                            color: AppColors.warning,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Question
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.help_outline, size: 18, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(question.question,
                        style: AppTextStyles.bodyMedium),
                  ),
                ],
              ),
            ),

            // Answer
            if (question.isAnswered && question.answer != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle_outline,
                        size: 18, color: AppColors.success),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(question.answer!,
                          style: AppTextStyles.bodyMedium),
                    ),
                  ],
                ),
              ),
            ],

            // Answer button
            if (canAnswer) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _answerDialog(question),
                  icon: const Icon(Icons.reply, size: 18),
                  label: const Text('Cavabla'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _answerDialog(StudentQuestionModel question) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cavab Yaz', style: AppTextStyles.headlineSmall),
            const SizedBox(height: 8),
            Text(question.question,
                style: AppTextStyles.bodySmall.copyWith(
                    fontStyle: FontStyle.italic)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 4,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Cavabınızı yazın...',
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  if (controller.text.isNotEmpty) {
                    final provider =
                        Provider.of<QAProvider>(context, listen: false);
                    await provider.answerQuestion(
                      questionId: question.id,
                      answer: controller.text,
                    );
                    if (mounted) {
                      Navigator.pop(ctx);
                      _loadQuestions();
                    }
                  }
                },
                child: const Text('Göndər'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes} dəqiqə əvvəl';
    if (diff.inHours < 24) return '${diff.inHours} saat əvvəl';
    if (diff.inDays < 7) return '${diff.inDays} gün əvvəl';
    return '${date.day}.${date.month}.${date.year}';
  }
}
