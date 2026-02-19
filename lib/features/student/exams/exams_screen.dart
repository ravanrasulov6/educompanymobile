import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../providers/exam_provider.dart';
import '../../../models/exam_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Exams screen
class ExamsScreen extends StatefulWidget {
  const ExamsScreen({super.key});

  @override
  State<ExamsScreen> createState() => _ExamsScreenState();
}

class _ExamsScreenState extends State<ExamsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(() {
      if (mounted) {
        context.read<ExamProvider>().loadExams();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Mövcud'),
            Tab(text: 'Bitmiş'),
          ],
        ),
        Expanded(
          child: Consumer<ExamProvider>(
            builder: (context, provider, _) {
              return TabBarView(
                controller: _tabController,
                children: [
                  _ExamList(
                    exams: provider.availableExams,
                    onTake: (exam) {
                      provider.startExam(exam);
                      context.go('/student/exams/${exam.id}/take');
                    },
                  ),
                  _ExamList(exams: provider.completedExams),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ExamList extends StatelessWidget {
  final List<ExamModel> exams;
  final Function(ExamModel)? onTake;

  const _ExamList({required this.exams, this.onTake});

  @override
  Widget build(BuildContext context) {
    if (exams.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.quiz_outlined,
                size: 56,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.2)),
            const SizedBox(height: 12),
            Text('İmtahan yoxdur', style: AppTextStyles.bodyMedium),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: exams.length,
      itemBuilder: (context, index) {
        final exam = exams[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.quiz,
                          color: AppColors.primary, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(exam.title, style: AppTextStyles.titleLarge),
                          const SizedBox(height: 2),
                          Text(exam.courseName,
                              style: AppTextStyles.bodySmall),
                        ],
                      ),
                    ),
                    if (exam.score != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: _getScoreColor(exam.score!)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${exam.score!.round()}%',
                          style: AppTextStyles.titleMedium
                              .copyWith(color: _getScoreColor(exam.score!)),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.help_outline, size: 16),
                    const SizedBox(width: 6),
                    Text('${exam.totalQuestions} sual',
                        style: AppTextStyles.bodySmall),
                    const SizedBox(width: 16),
                    const Icon(Icons.timer_outlined, size: 16),
                    const SizedBox(width: 6),
                    Text('${exam.durationMinutes} dəq',
                        style: AppTextStyles.bodySmall),
                  ],
                ),
                if (onTake != null) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => onTake!(exam),
                      icon: const Icon(Icons.play_arrow, size: 18),
                      label: const Text('İmtahana başla'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return AppColors.success;
    if (score >= 60) return AppColors.warning;
    return AppColors.error;
  }
}
