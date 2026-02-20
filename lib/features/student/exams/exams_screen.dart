import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../../providers/exam_provider.dart';
import '../../../models/exam_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/haptic_service.dart';
import '../../../core/widgets/entrance_animation.dart';

/// Apple-quality Exams screen
class ExamsScreen extends StatefulWidget {
  const ExamsScreen({super.key});

  @override
  State<ExamsScreen> createState() => _ExamsScreenState();
}

class _ExamsScreenState extends State<ExamsScreen> {
  int _selectedSegment = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) context.read<ExamProvider>().loadExams();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExamProvider>(
      builder: (context, provider, _) {
        final lists = [provider.availableExams, provider.completedExams];

        return Column(
          children: [
            const SizedBox(height: 8),
            // ── Stat Header ──
            _ExamStatHeader(
              totalExams: provider.exams.length,
              available: provider.availableExams.length,
              completed: provider.completedExams.length,
              avgScore: _avgScore(provider.completedExams),
            ),
            const SizedBox(height: 16),
            // ── Segmented Control ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _PillSegmentedControl(
                labels: [AppStrings.available, AppStrings.completed],
                selectedIndex: _selectedSegment,
                onChanged: (i) {
                  HapticService.light();
                  setState(() => _selectedSegment = i);
                },
              ),
            ),
            const SizedBox(height: 12),
            // ── List ──
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeIn,
                child: _ExamList(
                  key: ValueKey(_selectedSegment),
                  exams: lists[_selectedSegment],
                  showTakeButton: _selectedSegment == 0,
                  onTake: (exam) {
                    provider.startExam(exam);
                    context.go('/student/exams/${exam.id}/take');
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  double? _avgScore(List<ExamModel> completed) {
    if (completed.isEmpty) return null;
    final scores = completed.where((e) => e.score != null).map((e) => e.score!);
    if (scores.isEmpty) return null;
    return scores.reduce((a, b) => a + b) / scores.length;
  }
}

// ═══════════════════════════════════════════════════════════════════
//  PILL SEGMENTED CONTROL (shared design with Assignments)
// ═══════════════════════════════════════════════════════════════════

class _PillSegmentedControl extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const _PillSegmentedControl({
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : AppColors.lightBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.04),
        ),
      ),
      child: Row(
        children: List.generate(labels.length, (i) {
          final isSelected = i == selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? AppColors.primary : Colors.white)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(11),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: (isDark
                                    ? AppColors.primary
                                    : Colors.black)
                                .withValues(alpha: isDark ? 0.3 : 0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: AppTextStyles.titleMedium.copyWith(
                      color: isSelected
                          ? (isDark ? Colors.white : AppColors.primary)
                          : (isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary),
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                    child: Text(labels[i]),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  EXAM STAT HEADER
// ═══════════════════════════════════════════════════════════════════

class _ExamStatHeader extends StatelessWidget {
  final int totalExams;
  final int available;
  final int completed;
  final double? avgScore;

  const _ExamStatHeader({
    required this.totalExams,
    required this.available,
    required this.completed,
    this.avgScore,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _ExamStatChip(
            label: AppStrings.examsUpcoming,
            value: '$available',
            color: AppColors.info,
            isDark: isDark,
          ),
          const SizedBox(width: 10),
          _ExamStatChip(
            label: AppStrings.examsCompleted,
            value: '$completed',
            color: AppColors.success,
            isDark: isDark,
          ),
          const SizedBox(width: 10),
          _ExamStatChip(
            label: AppStrings.avgScore,
            value: avgScore != null ? '${avgScore!.round()}%' : '—',
            color: AppColors.accent,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _ExamStatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  const _ExamStatChip({
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: isDark
              ? color.withValues(alpha: 0.08)
              : color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: isDark ? 0.15 : 0.1),
          ),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: AppTextStyles.headlineMedium.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
                fontSize: 10,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  EXAM LIST
// ═══════════════════════════════════════════════════════════════════

class _ExamList extends StatelessWidget {
  final List<ExamModel> exams;
  final bool showTakeButton;
  final Function(ExamModel)? onTake;

  const _ExamList({
    super.key,
    required this.exams,
    this.showTakeButton = false,
    this.onTake,
  });

  @override
  Widget build(BuildContext context) {
    if (exams.isEmpty) {
      return const _EmptyExams();
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      itemCount: exams.length,
      itemBuilder: (context, index) {
        return EntranceAnimation(
          delay: Duration(milliseconds: 60 * index),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _ExamCard(
              exam: exams[index],
              showTakeButton: showTakeButton,
              onTake: onTake,
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  EXAM CARD
// ═══════════════════════════════════════════════════════════════════

class _ExamCard extends StatelessWidget {
  final ExamModel exam;
  final bool showTakeButton;
  final Function(ExamModel)? onTake;

  const _ExamCard({
    required this.exam,
    this.showTakeButton = false,
    this.onTake,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.04),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Gradient header strip ──
          Container(
            height: 4,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primaryLight.withValues(alpha: 0.6),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(22),
                topRight: Radius.circular(22),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Exam icon
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withValues(alpha: 0.15),
                            AppColors.primary.withValues(alpha: 0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.quiz_outlined,
                          color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exam.title,
                            style: AppTextStyles.titleLarge.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          // Course badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primary
                                  .withValues(alpha: isDark ? 0.12 : 0.07),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              exam.courseName,
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.primaryLight,
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Score ring for completed
                    if (exam.score != null)
                      _ScoreRing(score: exam.score!, isDark: isDark),
                  ],
                ),
                const SizedBox(height: 14),
                // ── Info pills ──
                Row(
                  children: [
                    _ExamInfoPill(
                      icon: Icons.help_outline_rounded,
                      label: '${exam.totalQuestions} ${AppStrings.questionsShort}',
                      isDark: isDark,
                    ),
                    const SizedBox(width: 8),
                    _ExamInfoPill(
                      icon: Icons.timer_outlined,
                      label: '${exam.durationMinutes} ${AppStrings.minutesShort}',
                      isDark: isDark,
                    ),
                    const SizedBox(width: 8),
                    _DifficultyPill(
                      difficulty: _getDifficulty(exam),
                      isDark: isDark,
                    ),
                  ],
                ),
                // ── Take button ──
                if (showTakeButton && onTake != null) ...[
                  const SizedBox(height: 16),
                  _GradientExamButton(
                    label: AppStrings.startExam,
                    onPressed: () {
                      HapticService.medium();
                      onTake!(exam);
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getDifficulty(ExamModel exam) {
    if (exam.totalQuestions >= 25) return AppStrings.difficultyHard;
    if (exam.totalQuestions >= 15) return AppStrings.difficultyMedium;
    return AppStrings.difficultyEasy;
  }
}

// ═══════════════════════════════════════════════════════════════════
//  SCORE RING
// ═══════════════════════════════════════════════════════════════════

class _ScoreRing extends StatelessWidget {
  final double score;
  final bool isDark;

  const _ScoreRing({required this.score, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final color = score >= 80
        ? AppColors.success
        : (score >= 60 ? AppColors.warning : AppColors.error);

    return CircularPercentIndicator(
      radius: 28,
      lineWidth: 4,
      percent: (score / 100).clamp(0.0, 1.0),
      center: Text(
        '${score.round()}',
        style: AppTextStyles.titleMedium.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 13,
        ),
      ),
      progressColor: color,
      backgroundColor:
          (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06),
      circularStrokeCap: CircularStrokeCap.round,
      animation: true,
      animationDuration: 800,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  EXAM INFO PILL
// ═══════════════════════════════════════════════════════════════════

class _ExamInfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;

  const _ExamInfoPill({
    required this.icon,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 13,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  DIFFICULTY PILL
// ═══════════════════════════════════════════════════════════════════

class _DifficultyPill extends StatelessWidget {
  final String difficulty;
  final bool isDark;

  const _DifficultyPill({required this.difficulty, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final Color color;
    if (difficulty == AppStrings.difficultyHard) {
      color = AppColors.error;
    } else if (difficulty == AppStrings.difficultyMedium) {
      color = AppColors.warning;
    } else {
      color = AppColors.success;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.1 : 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.15 : 0.08),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.signal_cellular_alt_rounded, size: 12, color: color),
          const SizedBox(width: 5),
          Text(
            difficulty,
            style: AppTextStyles.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  GRADIENT EXAM BUTTON
// ═══════════════════════════════════════════════════════════════════

class _GradientExamButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;

  const _GradientExamButton({
    required this.label,
    required this.onPressed,
  });

  @override
  State<_GradientExamButton> createState() => _GradientExamButtonState();
}

class _GradientExamButtonState extends State<_GradientExamButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedOpacity(
          opacity: _pressed ? 0.85 : 1.0,
          duration: const Duration(milliseconds: 120),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.play_circle_filled_rounded,
                    size: 18, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  widget.label,
                  style: AppTextStyles.button.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  EMPTY STATE
// ═══════════════════════════════════════════════════════════════════

class _EmptyExams extends StatelessWidget {
  const _EmptyExams();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: isDark ? 0.08 : 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.quiz_outlined,
                size: 48,
                color: AppColors.primary.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              AppStrings.noExams,
              style: AppTextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.noExamsSub,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
