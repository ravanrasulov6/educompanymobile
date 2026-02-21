import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../providers/lesson_schedule_provider.dart';

/// Course schedule screen — timeline with locked/unlocked/completed lessons
class CourseScheduleScreen extends StatefulWidget {
  final String courseId;
  const CourseScheduleScreen({super.key, required this.courseId});

  @override
  State<CourseScheduleScreen> createState() => _CourseScheduleScreenState();
}

class _CourseScheduleScreenState extends State<CourseScheduleScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LessonScheduleProvider>(context, listen: false)
          .loadSchedule(widget.courseId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dərs Cədvəli'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<LessonScheduleProvider>(
        builder: (_, provider, __) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.schedule.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today_outlined,
                      size: 64,
                      color: AppColors.textSecondary.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  Text('Cədvəl hələ hazır deyil',
                      style: AppTextStyles.headlineSmall),
                  const SizedBox(height: 8),
                  Text('Müəllim dərs cədvəlini tezliklə əlavə edəcək',
                      style: AppTextStyles.bodySmall),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Stats bar
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _buildStat(
                      '${provider.unlockedLessons.length}',
                      'Açıq',
                      AppColors.success,
                      Icons.lock_open,
                    ),
                    _buildStat(
                      '${provider.lockedLessons.length}',
                      'Kilidli',
                      AppColors.textSecondary,
                      Icons.lock_outline,
                    ),
                    _buildStat(
                      '${provider.todayLessons.length}',
                      'Bu gün',
                      AppColors.primary,
                      Icons.today,
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Timeline
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.schedule.length,
                  itemBuilder: (_, i) =>
                      _buildTimelineItem(provider.schedule[i], i,
                          isLast: i == provider.schedule.length - 1),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStat(String value, String label, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 4),
            Text(value,
                style: AppTextStyles.headlineSmall.copyWith(color: color)),
            Text(label, style: AppTextStyles.labelSmall),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(LessonScheduleItem item, int index,
      {bool isLast = false}) {
    final Color statusColor;
    final IconData statusIcon;
    final String statusText;

    if (item.isCompleted) {
      statusColor = AppColors.success;
      statusIcon = Icons.check_circle;
      statusText = 'Tamamlanıb';
    } else if (item.isToday) {
      statusColor = AppColors.primary;
      statusIcon = Icons.play_circle_filled;
      statusText = 'Bu gün';
    } else if (item.isUnlocked) {
      statusColor = AppColors.info;
      statusIcon = Icons.lock_open;
      statusText = 'Açıqdır';
    } else {
      statusColor = AppColors.textSecondary;
      statusIcon = Icons.lock;
      statusText = _formatDate(item.unlockDate);
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline line + dot
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: statusColor, width: 2),
                  ),
                  child: Icon(statusIcon, size: 14, color: statusColor),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: statusColor.withValues(alpha: 0.2),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Content card
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: item.isToday
                    ? AppColors.primary.withValues(alpha: 0.05)
                    : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: item.isToday
                    ? Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2))
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('Gün ${item.dayNumber}',
                                style: AppTextStyles.labelSmall
                                    .copyWith(color: statusColor)),
                            if (item.isToday) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'BU GÜN',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.lessonTitle ?? 'Dərs ${item.dayNumber}',
                          style: AppTextStyles.titleSmall.copyWith(
                            color: item.isUnlocked ? null : AppColors.textSecondary,
                          ),
                        ),
                        if (item.lessonDuration != null)
                          Text(item.lessonDuration!,
                              style: AppTextStyles.labelSmall),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                          fontSize: 11,
                          color: statusColor,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final monthNames = [
      'Yan', 'Fev', 'Mar', 'Apr', 'May', 'İyn',
      'İyl', 'Avq', 'Sen', 'Okt', 'Noy', 'Dek'
    ];
    return '${date.day} ${monthNames[date.month - 1]}';
  }
}
