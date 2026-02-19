import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../providers/schedule_provider.dart';
import '../../../models/schedule_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'package:intl/intl.dart';

/// Weekly schedule screen with calendar
class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.week;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<ScheduleProvider>().loadSchedule();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ScheduleProvider>(
      builder: (context, provider, _) {
        return Column(
          children: [
            // Calendar
            TableCalendar(
              firstDay: DateTime.now().subtract(const Duration(days: 365)),
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: provider.selectedDay,
              selectedDayPredicate: (day) =>
                  isSameDay(day, provider.selectedDay),
              calendarFormat: _calendarFormat,
              onFormatChanged: (format) =>
                  setState(() => _calendarFormat = format),
              onDaySelected: (selectedDay, _) =>
                  provider.selectDay(selectedDay),
              calendarStyle: CalendarStyle(
                selectedDecoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                todayTextStyle: const TextStyle(color: AppColors.primary),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: true,
                titleCentered: true,
              ),
            ),

            const Divider(),

            // Events for selected day
            Expanded(
              child: provider.selectedDayEvents.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.event_available,
                              size: 56,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.2)),
                          const SizedBox(height: 12),
                          Text('No events today',
                              style: AppTextStyles.bodyMedium),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: provider.selectedDayEvents.length,
                      itemBuilder: (context, index) {
                        return _EventCard(
                            event: provider.selectedDayEvents[index]);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _EventCard extends StatelessWidget {
  final ScheduleModel event;
  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('h:mm a');

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 52,
              decoration: BoxDecoration(
                color: _typeColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 14),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _typeColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_typeIcon, color: _typeColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.title, style: AppTextStyles.titleLarge),
                  const SizedBox(height: 2),
                  Text(event.courseName, style: AppTextStyles.bodySmall),
                  const SizedBox(height: 4),
                  Text(
                    '${timeFormat.format(event.dateTime)} • ${event.durationMinutes} min',
                    style: AppTextStyles.labelSmall
                        .copyWith(color: _typeColor),
                  ),
                ],
              ),
            ),
            if (event.hasReminder)
              Icon(Icons.notifications_active,
                  size: 18, color: AppColors.accent),
          ],
        ),
      ),
    );
  }

  Color get _typeColor {
    switch (event.type) {
      case ScheduleType.liveClass:
        return AppColors.secondary;
      case ScheduleType.assignment:
        return AppColors.warning;
      case ScheduleType.exam:
        return AppColors.error;
    }
  }

  IconData get _typeIcon {
    switch (event.type) {
      case ScheduleType.liveClass:
        return Icons.videocam_outlined;
      case ScheduleType.assignment:
        return Icons.assignment_outlined;
      case ScheduleType.exam:
        return Icons.quiz_outlined;
    }
  }
}
