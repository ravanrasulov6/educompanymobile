import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../providers/exam_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/premium_button.dart';

/// Exam taking screen with questions and timer
class ExamTakingScreen extends StatelessWidget {
  const ExamTakingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ExamProvider>(
      builder: (context, provider, _) {
        final exam = provider.currentExam;
        if (exam == null || exam.questions.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Exam')),
            body: const Center(child: Text('No exam loaded')),
          );
        }

        final question = exam.questions[provider.currentQuestionIndex];
        final selectedAnswer = provider.answers[question.id];
        final totalQuestions = exam.questions.length;

        return Scaffold(
          appBar: AppBar(
            title: Text(exam.title),
            actions: [
              // Timer badge
              Container(
                margin: const EdgeInsets.only(right: 16),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.timer, size: 16, color: AppColors.warning),
                    const SizedBox(width: 4),
                    Text('${exam.durationMinutes}:00',
                        style: AppTextStyles.labelLarge
                            .copyWith(color: AppColors.warning)),
                  ],
                ),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress
                Row(
                  children: [
                    Text(
                      'Question ${provider.currentQuestionIndex + 1} of $totalQuestions',
                      style: AppTextStyles.titleMedium,
                    ),
                    const Spacer(),
                    Text(
                      '${provider.answers.length} answered',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.success),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (provider.currentQuestionIndex + 1) / totalQuestions,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  valueColor:
                      const AlwaysStoppedAnimation(AppColors.primary),
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 28),

                // Question
                Text(question.question, style: AppTextStyles.headlineMedium),
                const SizedBox(height: 24),

                // Options
                ...List.generate(question.options.length, (i) {
                  final isSelected = selectedAnswer == i;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () =>
                          provider.answerQuestion(question.id, i),
                      borderRadius: BorderRadius.circular(14),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.1)
                              : Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : Theme.of(context).dividerColor,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : Theme.of(context)
                                        .colorScheme
                                        .surface,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : Theme.of(context).dividerColor,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  String.fromCharCode(65 + i),
                                  style: AppTextStyles.titleMedium.copyWith(
                                    color: isSelected
                                        ? Colors.white
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(question.options[i],
                                  style: AppTextStyles.bodyLarge),
                            ),
                            if (isSelected)
                              const Icon(Icons.check_circle,
                                  color: AppColors.primary, size: 22),
                          ],
                        ),
                      ),
                    ),
                  );
                }),

                const Spacer(),

                // Navigation buttons
                Row(
                  children: [
                    if (provider.currentQuestionIndex > 0)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => provider.previousQuestion(),
                          icon: const Icon(Icons.arrow_back, size: 18),
                          label: const Text('Previous'),
                        ),
                      ),
                    if (provider.currentQuestionIndex > 0)
                      const SizedBox(width: 12),
                    Expanded(
                      child: provider.currentQuestionIndex <
                              totalQuestions - 1
                          ? ElevatedButton.icon(
                              onPressed: () => provider.nextQuestion(),
                              icon:
                                  const Icon(Icons.arrow_forward, size: 18),
                              label: const Text('Next'),
                            )
                          : PremiumButton(
                              label: 'Finish Exam',
                              onPressed: () {
                                provider.finishExam();
                                context.go('/student/exams/result');
                              },
                              isGradient: true,
                              icon: Icons.check_circle,
                            ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}
