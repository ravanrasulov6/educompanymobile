import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../../providers/schedule_provider.dart';
import '../../../models/schedule_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/entrance_animation.dart';

/// Apple-quality Schedule screen with timeline layout
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
      if (mounted) context.read<ScheduleProvider>().loadSchedule();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<ScheduleProvider>(
      builder: (context, provider, _) {
        return Column(
          children: [
            // ── Premium Calendar ──
            _PremiumCalendar(
              isDark: isDark,
              focusedDay: provider.selectedDay,
              selectedDay: provider.selectedDay,
              calendarFormat: _calendarFormat,
              events: provider.events,
              onDaySelected: (day) => provider.selectDay(day),
              onFormatChanged: (f) => setState(() => _calendarFormat = f),
            ),
            // ── Section Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 18,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    AppStrings.todayEvents,
                    style: AppTextStyles.titleLarge.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary
                          .withValues(alpha: isDark ? 0.12 : 0.07),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${provider.selectedDayEvents.length} ${AppStrings.eventsCount}',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // ── Timeline Events ──
            Expanded(
              child: provider.selectedDayEvents.isEmpty
                  ? _EmptySchedule(isDark: isDark)
                  : _TimelineEventList(
                      events: provider.selectedDayEvents,
                      isDark: isDark,
                    ),
            ),
          ],
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  PREMIUM CALENDAR
// ═══════════════════════════════════════════════════════════════════

class _PremiumCalendar extends StatelessWidget {
  final bool isDark;
  final DateTime focusedDay;
  final DateTime selectedDay;
  final CalendarFormat calendarFormat;
  final List<ScheduleModel> events;
  final ValueChanged<DateTime> onDaySelected;
  final ValueChanged<CalendarFormat> onFormatChanged;

  const _PremiumCalendar({
    required this.isDark,
    required this.focusedDay,
    required this.selectedDay,
    required this.calendarFormat,
    required this.events,
    required this.onDaySelected,
    required this.onFormatChanged,
  });

  List<ScheduleModel> _getEventsForDay(DateTime day) {
    return events
        .where((e) =>
            e.dateTime.year == day.year &&
            e.dateTime.month == day.month &&
            e.dateTime.day == day.day)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
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
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: TableCalendar(
          locale: 'az_AZ',
          firstDay: DateTime.now().subtract(const Duration(days: 365)),
          lastDay: DateTime.now().add(const Duration(days: 365)),
          focusedDay: focusedDay,
          selectedDayPredicate: (day) => isSameDay(day, selectedDay),
          calendarFormat: calendarFormat,
          onFormatChanged: onFormatChanged,
          onDaySelected: (selected, _) => onDaySelected(selected),
          eventLoader: _getEventsForDay,
          startingDayOfWeek: StartingDayOfWeek.monday,
          calendarStyle: CalendarStyle(
            // Selected day - gradient effect via decoration
            selectedDecoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            selectedTextStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
            todayDecoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.1),
              shape: BoxShape.circle,
            ),
            todayTextStyle: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
            defaultTextStyle: TextStyle(
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              fontWeight: FontWeight.w500,
            ),
            weekendTextStyle: TextStyle(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
              fontWeight: FontWeight.w500,
            ),
            outsideTextStyle: TextStyle(
              color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.2),
            ),
            cellMargin: const EdgeInsets.all(4),
            markerDecoration: BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
            ),
            markersMaxCount: 3,
            markerSize: 5,
            markerMargin: const EdgeInsets.only(top: 1),
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: AppTextStyles.labelSmall.copyWith(
              color: isDark
                  ? AppColors.darkTextHint
                  : AppColors.lightTextHint,
              fontWeight: FontWeight.w600,
            ),
            weekendStyle: AppTextStyles.labelSmall.copyWith(
              color: isDark
                  ? AppColors.darkTextHint
                  : AppColors.lightTextHint,
              fontWeight: FontWeight.w600,
            ),
          ),
          headerStyle: HeaderStyle(
            formatButtonVisible: true,
            titleCentered: true,
            titleTextStyle: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.w700,
            ),
            leftChevronIcon: Icon(
              Icons.chevron_left_rounded,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
            rightChevronIcon: Icon(
              Icons.chevron_right_rounded,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
            formatButtonDecoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: isDark ? 0.12 : 0.07),
              borderRadius: BorderRadius.circular(10),
            ),
            formatButtonTextStyle: AppTextStyles.labelSmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
            formatButtonPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            headerPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  TIMELINE EVENT LIST
// ═══════════════════════════════════════════════════════════════════

class _TimelineEventList extends StatelessWidget {
  final List<ScheduleModel> events;
  final bool isDark;

  const _TimelineEventList({required this.events, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        final isLast = index == events.length - 1;

        return EntranceAnimation(
          delay: Duration(milliseconds: 80 * index),
          child: _TimelineRow(
            event: event,
            isDark: isDark,
            isLast: isLast,
          ),
        );
      },
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final ScheduleModel event;
  final bool isDark;
  final bool isLast;

  const _TimelineRow({
    required this.event,
    required this.isDark,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm');
    final typeColor = _typeColor;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Time Column ──
          SizedBox(
            width: 50,
            child: Padding(
              padding: const EdgeInsets.only(top: 18),
              child: Text(
                timeFormat.format(event.dateTime),
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ),
          ),
          // ── Timeline connector ──
          SizedBox(
            width: 28,
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Dot
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: typeColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: typeColor.withValues(alpha: 0.4),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
                // Line
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: typeColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // ── Event Card ──
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _TimelineEventCard(
                event: event,
                isDark: isDark,
                typeColor: typeColor,
              ),
            ),
          ),
        ],
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
}

// ═══════════════════════════════════════════════════════════════════
//  TIMELINE EVENT CARD
// ═══════════════════════════════════════════════════════════════════

class _TimelineEventCard extends StatelessWidget {
  final ScheduleModel event;
  final bool isDark;
  final Color typeColor;

  const _TimelineEventCard({
    required this.event,
    required this.isDark,
    required this.typeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.04),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Gradient accent strip ──
          Container(
            height: 4,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  typeColor,
                  typeColor.withValues(alpha: 0.4),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Type icon badge
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            typeColor.withValues(alpha: 0.15),
                            typeColor.withValues(alpha: 0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(_typeIcon, color: typeColor, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.title,
                            style: AppTextStyles.titleLarge.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            event.courseName,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (event.hasReminder)
                      _AnimatedReminderBell(typeColor: typeColor),
                  ],
                ),
                const SizedBox(height: 12),
                // ── Pills row ──
                Row(
                  children: [
                    _InfoPill(
                      icon: Icons.timer_outlined,
                      label:
                          '${event.durationMinutes} ${AppStrings.minutesShort}',
                      color: typeColor,
                      isDark: isDark,
                    ),
                    const SizedBox(width: 8),
                    _InfoPill(
                      icon: _typeIcon,
                      label: _typeLabel,
                      color: typeColor,
                      isDark: isDark,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
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

  String get _typeLabel {
    switch (event.type) {
      case ScheduleType.liveClass:
        return AppStrings.liveClasses;
      case ScheduleType.assignment:
        return AppStrings.assignments;
      case ScheduleType.exam:
        return AppStrings.exams;
    }
  }
}

// ═══════════════════════════════════════════════════════════════════
//  INFO PILL
// ═══════════════════════════════════════════════════════════════════

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;

  const _InfoPill({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
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
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: color,
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
//  ANIMATED REMINDER BELL
// ═══════════════════════════════════════════════════════════════════

class _AnimatedReminderBell extends StatefulWidget {
  final Color typeColor;
  const _AnimatedReminderBell({required this.typeColor});

  @override
  State<_AnimatedReminderBell> createState() => _AnimatedReminderBellState();
}

class _AnimatedReminderBellState extends State<_AnimatedReminderBell>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _rotation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.15), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 0.15, end: -0.12), weight: 25),
      TweenSequenceItem(tween: Tween(begin: -0.12, end: 0.08), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 0.08, end: 0.0), weight: 25),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    // Play once on mount, then repeat every few seconds
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _rotation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotation.value,
          child: child,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          Icons.notifications_active_rounded,
          size: 16,
          color: AppColors.accent,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  EMPTY STATE
// ═══════════════════════════════════════════════════════════════════

class _EmptySchedule extends StatelessWidget {
  final bool isDark;
  const _EmptySchedule({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.secondary
                    .withValues(alpha: isDark ? 0.08 : 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.event_available_rounded,
                size: 48,
                color: AppColors.secondary.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              AppStrings.noEventsToday,
              style: AppTextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.noEventsSub,
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
