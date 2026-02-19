import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/assignment_provider.dart';
import '../../../models/assignment_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'package:intl/intl.dart';

/// Assignments screen with tabs
class AssignmentsScreen extends StatefulWidget {
  const AssignmentsScreen({super.key});

  @override
  State<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends State<AssignmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    Future.microtask(() {
      if (mounted) {
        context.read<AssignmentProvider>().loadAssignments();
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
            Tab(text: 'Aktiv'),
            Tab(text: 'Təhvil verildi'),
            Tab(text: 'Qiymətləndirildi'),
          ],
        ),
        Expanded(
          child: Consumer<AssignmentProvider>(
            builder: (context, provider, _) {
              return TabBarView(
                controller: _tabController,
                children: [
                  _AssignmentList(assignments: provider.activeAssignments),
                  _AssignmentList(assignments: provider.submittedAssignments),
                  _AssignmentList(assignments: provider.gradedAssignments),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AssignmentList extends StatelessWidget {
  final List<AssignmentModel> assignments;
  const _AssignmentList({required this.assignments});

  @override
  Widget build(BuildContext context) {
    if (assignments.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.assignment_outlined,
                size: 56,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2)),
            const SizedBox(height: 12),
            Text('Tapşırıq yoxdur', style: AppTextStyles.bodyMedium),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: assignments.length,
      itemBuilder: (context, index) {
        final a = assignments[index];
        return _AssignmentCard(assignment: a);
      },
    );
  }
}

class _AssignmentCard extends StatelessWidget {
  final AssignmentModel assignment;
  const _AssignmentCard({required this.assignment});

  @override
  Widget build(BuildContext context) {
    final isOverdue = assignment.isOverdue;
    final dateFormat = DateFormat('MMM dd, yyyy');

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
                    color: _statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_statusIcon, color: _statusColor, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(assignment.title, style: AppTextStyles.titleLarge),
                      const SizedBox(height: 2),
                      Text(assignment.courseName,
                          style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
                if (assignment.grade != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${assignment.grade!.round()}%',
                      style: AppTextStyles.titleMedium
                          .copyWith(color: AppColors.success),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            // Deadline
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 16,
                  color: isOverdue ? AppColors.error : AppColors.lightTextHint,
                ),
                const SizedBox(width: 6),
                Text(
                  'Son tarix: ${dateFormat.format(assignment.deadline)}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isOverdue ? AppColors.error : null,
                    fontWeight: isOverdue ? FontWeight.w600 : null,
                  ),
                ),
                if (isOverdue) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text('VAXTI KEÇİB',
                        style: AppTextStyles.labelSmall
                            .copyWith(color: AppColors.error)),
                  ),
                ],
              ],
            ),
            if (assignment.feedback != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.chat_bubble_outline,
                        size: 16, color: AppColors.success),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(assignment.feedback!,
                          style: AppTextStyles.bodySmall),
                    ),
                  ],
                ),
              ),
            ],
            if (assignment.status == AssignmentStatus.active) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.upload_file, size: 18),
                  label: const Text('Tapşırığı göndər'),
                ),
              ),
            ],
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
        return Icons.upload_file;
      case AssignmentStatus.graded:
        return Icons.grading;
    }
  }
}
