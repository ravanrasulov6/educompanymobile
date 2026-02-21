import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/assignment_provider.dart';
import '../../../models/assignment_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/haptic_service.dart';
import '../../../core/widgets/entrance_animation.dart';

/// Apple-quality Assignments screen
class AssignmentsScreen extends StatefulWidget {
  const AssignmentsScreen({super.key});

  @override
  State<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends State<AssignmentsScreen> {
  int _selectedSegment = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) context.read<AssignmentProvider>().loadAssignments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AssignmentProvider>(
      builder: (context, provider, _) {
        final lists = [
          provider.activeAssignments,
          provider.submittedAssignments,
          provider.gradedAssignments,
        ];
        return Container(
          color: const Color(0xFFF8F9FA),
          child: Column(
            children: [
              const SizedBox(height: 8),
              _StatSummaryRow(
                activeCount: provider.activeAssignments.length,
                submittedCount: provider.submittedAssignments.length,
                gradedCount: provider.gradedAssignments.length,
              ),
            const SizedBox(height: 16),
            // ── Segmented Control ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _PillSegmentedControl(
                labels: [AppStrings.active, AppStrings.submitted, AppStrings.graded],
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
                child: _AssignmentList(
                  key: ValueKey(_selectedSegment),
                  assignments: lists[_selectedSegment],
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
}

// ═══════════════════════════════════════════════════════════════════
//  PILL SEGMENTED CONTROL
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
//  STAT SUMMARY ROW
// ═══════════════════════════════════════════════════════════════════

class _StatSummaryRow extends StatelessWidget {
  final int activeCount;
  final int submittedCount;
  final int gradedCount;

  const _StatSummaryRow({
    required this.activeCount,
    required this.submittedCount,
    required this.gradedCount,
  });

  @override
  Widget build(BuildContext context) {
    return EntranceAnimation(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            _StatChip(
              label: AppStrings.active,
              count: activeCount,
              color: AppColors.info,
              icon: Icons.pending_actions,
            ),
            const SizedBox(width: 10),
            _StatChip(
              label: AppStrings.submitted,
              count: submittedCount,
              color: AppColors.warning,
              icon: Icons.upload_file,
            ),
            const SizedBox(width: 10),
            _StatChip(
              label: AppStrings.graded,
              count: gradedCount,
              color: AppColors.success,
              icon: Icons.check_circle,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;

  const _StatChip({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: isDark
              ? color.withValues(alpha: 0.1)
              : color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: color.withValues(alpha: isDark ? 0.2 : 0.15),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(
              '$count',
              style: AppTextStyles.headlineMedium.copyWith(
                color: color,
                fontWeight: FontWeight.w900,
                fontSize: 20,
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
                fontWeight: FontWeight.w600,
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
//  ASSIGNMENT LIST
// ═══════════════════════════════════════════════════════════════════

class _AssignmentList extends StatelessWidget {
  final List<AssignmentModel> assignments;
  const _AssignmentList({super.key, required this.assignments});

  @override
  Widget build(BuildContext context) {
    if (assignments.isEmpty) {
      return const _EmptyAssignments();
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      itemCount: assignments.length,
      itemBuilder: (context, index) {
        return EntranceAnimation(
          delay: Duration(milliseconds: 60 * index),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _AssignmentCard(assignment: assignments[index]),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  ASSIGNMENT CARD
// ═══════════════════════════════════════════════════════════════════

class _AssignmentCard extends StatelessWidget {
  final AssignmentModel assignment;
  const _AssignmentCard({required this.assignment});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isOverdue = assignment.isOverdue;
    final dateFormat = DateFormat('dd MMM, yyyy');
    final statusColor = _statusColor;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // ── Left accent strip ──
            Container(
              width: 4,
              margin: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            // ── Card body ──
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 18, 18, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Header row ──
                    Row(
                      children: [
                        // Status icon
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(_statusIcon, color: statusColor, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                assignment.title,
                                style: const TextStyle(
                                  color: Color(0xFF0F172A),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                  height: 1.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 3),
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
                                  assignment.courseName,
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
                        // Grade badge or deadline ring
                        if (assignment.grade != null)
                          _GradeBadge(grade: assignment.grade!)
                        else
                          _DeadlineRing(
                            deadline: assignment.deadline,
                            statusColor: statusColor,
                            isOverdue: isOverdue,
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // ── Deadline row ──
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 14,
                          color: isOverdue
                              ? AppColors.error
                              : (isDark
                                  ? AppColors.darkTextHint
                                  : AppColors.lightTextHint),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${AppStrings.deadline}: ${dateFormat.format(assignment.deadline)}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: isOverdue
                                ? AppColors.error
                                : (isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary),
                            fontWeight:
                                isOverdue ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                        if (isOverdue) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              AppStrings.overdue,
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.error,
                                fontWeight: FontWeight.w700,
                                fontSize: 9,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    // ── Feedback ──
                    if (assignment.feedback != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.success
                              .withValues(alpha: isDark ? 0.08 : 0.04),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.success
                                .withValues(alpha: isDark ? 0.15 : 0.08),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.chat_bubble_outline_rounded,
                                size: 15, color: AppColors.success),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                assignment.feedback!,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    // ── Submit button ──
                    if (assignment.status == AssignmentStatus.active) ...[
                      const SizedBox(height: 14),
                      _GradientSubmitButton(
                        label: AppStrings.submitAssignment,
                        onPressed: () {
                          HapticService.medium();
                          context.push('/student/assignments/${assignment.id}/submit');
                        },
                      ),
                    ],
                    // Also allow viewing graded assignments
                    if (assignment.status == AssignmentStatus.graded || assignment.status == AssignmentStatus.submitted) ...[
                      const SizedBox(height: 14),
                      _GradientSubmitButton(
                        label: 'Nəticəyə Bax',
                        onPressed: () {
                          HapticService.medium();
                          context.push('/student/assignments/${assignment.id}/submit');
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color get _statusColor {
    switch (assignment.status) {
      case AssignmentStatus.active:
        return assignment.isOverdue ? AppColors.error : AppColors.info;
      case AssignmentStatus.submitted:
        return AppColors.warning;
      case AssignmentStatus.graded:
        return AppColors.success;
    }
  }

  IconData get _statusIcon {
    switch (assignment.status) {
      case AssignmentStatus.active:
        return Icons.assignment_outlined;
      case AssignmentStatus.submitted:
        return Icons.cloud_done_outlined;
      case AssignmentStatus.graded:
        return Icons.verified_outlined;
    }
  }
}

// ═══════════════════════════════════════════════════════════════════
//  GRADE BADGE
// ═══════════════════════════════════════════════════════════════════

class _GradeBadge extends StatelessWidget {
  final double grade;
  const _GradeBadge({required this.grade});

  @override
  Widget build(BuildContext context) {
    final color = grade >= 80
        ? AppColors.success
        : (grade >= 60 ? AppColors.warning : AppColors.error);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.15), color.withValues(alpha: 0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        '${grade.round()}%',
        style: AppTextStyles.titleMedium.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  DEADLINE RING
// ═══════════════════════════════════════════════════════════════════

class _DeadlineRing extends StatelessWidget {
  final DateTime deadline;
  final Color statusColor;
  final bool isOverdue;

  const _DeadlineRing({
    required this.deadline,
    required this.statusColor,
    required this.isOverdue,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final total = deadline.difference(now.subtract(const Duration(days: 14)));
    final remaining = deadline.difference(now);
    final progress =
        total.inMinutes > 0 ? (remaining.inMinutes / total.inMinutes).clamp(0.0, 1.0) : 0.0;
    final daysLeft = remaining.inDays;

    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 3.5,
              backgroundColor:
                  (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06),
              valueColor: AlwaysStoppedAnimation(
                  isOverdue ? AppColors.error : statusColor),
              strokeCap: StrokeCap.round,
            ),
          ),
          Text(
            isOverdue ? '!' : '${daysLeft}g',
            style: AppTextStyles.labelSmall.copyWith(
              color: isOverdue ? AppColors.error : statusColor,
              fontWeight: FontWeight.w800,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  GRADIENT SUBMIT BUTTON
// ═══════════════════════════════════════════════════════════════════

class _GradientSubmitButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;

  const _GradientSubmitButton({
    required this.label,
    required this.onPressed,
  });

  @override
  State<_GradientSubmitButton> createState() => _GradientSubmitButtonState();
}

class _GradientSubmitButtonState extends State<_GradientSubmitButton> {
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
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_upload_outlined,
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

class _EmptyAssignments extends StatelessWidget {
  const _EmptyAssignments();

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
                Icons.assignment_outlined,
                size: 48,
                color: AppColors.primary.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              AppStrings.noAssignments,
              style: AppTextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.noAssignmentsSub,
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
