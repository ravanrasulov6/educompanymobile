import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/premium_kit.dart';
import '../../../core/services/haptic_service.dart';
import '../../../providers/student_provider.dart';
import 'widgets/recent_activity_timeline.dart';

class ActivityHistoryScreen extends StatefulWidget {
  const ActivityHistoryScreen({super.key});

  @override
  State<ActivityHistoryScreen> createState() => _ActivityHistoryScreenState();
}

class _ActivityHistoryScreenState extends State<ActivityHistoryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<StudentProvider>().loadDashboardData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Bütün Aktivliklər', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w800)),
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<StudentProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.activities.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.activities.isEmpty) {
            return const Center(child: Text('Hələ ki aktivlik yoxdur'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: provider.activities.length,
            itemBuilder: (context, index) {
              final a = provider.activities[index];
              return _buildActivityItem(a);
            },
          );
        },
      ),
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> a) {
    IconData icon;
    Color color;
    switch (a['activity_type']) {
      case 'lesson_view':
        icon = Icons.play_circle_fill_rounded;
        color = AppColors.primary;
        break;
      case 'assignment_submit':
        icon = Icons.assignment_turned_in_rounded;
        color = AppColors.success;
        break;
      default:
        icon = Icons.star_rounded;
        color = AppColors.accent;
    }

    return InkWell(
      onTap: () {
        HapticService.light();
        if (a['activity_type'] == 'lesson_view') {
          context.push('/student/courses/${a['course_id']}/workspace/${a['lesson_id'] ?? 'initial'}');
        } else if (a['activity_type'] == 'assignment_submit' || a['activity_type'] == 'assignment_submission') {
          context.push('/student/assignments/${a['assignment_id'] ?? 'mock-id'}/submit');
        }
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    a['description'] ?? a['activity_type'], 
                    style: AppTextStyles.titleSmall.copyWith(color: const Color(0xFF0F172A), fontWeight: FontWeight.bold)
                  ),
                  const SizedBox(height: 4),
                  Text(_formatDateTime(a['created_at']), style: AppTextStyles.labelSmall.copyWith(color: const Color(0xFF64748B))),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFFCBD5E1)),
          ],
        ),
      ),
    );
 seasonal_reward (context) {
    // ... logic
 }
  }

  String _formatDateTime(String dateStr) {
    final dt = DateTime.parse(dateStr);
    return '${dt.day}.${dt.month}.${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
