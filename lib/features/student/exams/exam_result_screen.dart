import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../providers/exam_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/premium_button.dart';

/// Exam result screen
class ExamResultScreen extends StatelessWidget {
  const ExamResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ExamProvider>(
      builder: (context, provider, _) {
        final score = provider.lastScore ?? 0;
        final exam = provider.currentExam;

        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Score circle
                  Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          _getScoreColor(score),
                          _getScoreColor(score).withValues(alpha: 0.6),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _getScoreColor(score).withValues(alpha: 0.3),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${score.round()}%',
                          style: AppTextStyles.displayLarge
                              .copyWith(color: Colors.white, fontSize: 48),
                        ),
                        Text(
                          _getScoreLabel(score),
                          style: AppTextStyles.titleMedium
                              .copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  Text(
                    exam?.title ?? 'Exam',
                    style: AppTextStyles.headlineLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getMotivationalMessage(score),
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Stats
                  if (exam != null && provider.answers.isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _StatItem(
                          label: 'Questions',
                          value: '${exam.questions.length}',
                          icon: Icons.help_outline,
                        ),
                        _StatItem(
                          label: 'Correct',
                          value: '${_getCorrectCount(provider)}',
                          icon: Icons.check_circle_outline,
                          color: AppColors.success,
                        ),
                        _StatItem(
                          label: 'Wrong',
                          value:
                              '${exam.questions.length - _getCorrectCount(provider)}',
                          icon: Icons.cancel_outlined,
                          color: AppColors.error,
                        ),
                      ],
                    ),
                  const SizedBox(height: 40),

                  PremiumButton(
                    label: 'Back to Exams',
                    onPressed: () {
                      provider.resetExam();
                      context.go('/student/exams');
                    },
                    isGradient: true,
                    width: double.infinity,
                    icon: Icons.arrow_back,
                  ),
                  const SizedBox(height: 12),
                  PremiumButton(
                    label: 'Review Answers',
                    onPressed: () {},
                    isOutlined: true,
                    width: double.infinity,
                    icon: Icons.visibility,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  int _getCorrectCount(ExamProvider provider) {
    int correct = 0;
    for (final q in provider.currentExam!.questions) {
      if (provider.answers[q.id] == q.correctIndex) correct++;
    }
    return correct;
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return AppColors.success;
    if (score >= 60) return AppColors.warning;
    return AppColors.error;
  }

  String _getScoreLabel(double score) {
    if (score >= 90) return 'Excellent!';
    if (score >= 80) return 'Great Job!';
    if (score >= 60) return 'Good';
    if (score >= 40) return 'Fair';
    return 'Needs Work';
  }

  String _getMotivationalMessage(double score) {
    if (score >= 80) return 'Outstanding performance! Keep up the great work.';
    if (score >= 60) return 'Good effort! Review the topics you missed.';
    return 'Don\'t give up! Practice more and try again.';
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: c.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: c, size: 24),
        ),
        const SizedBox(height: 8),
        Text(value, style: AppTextStyles.headlineMedium),
        Text(label, style: AppTextStyles.bodySmall),
      ],
    );
  }
}
