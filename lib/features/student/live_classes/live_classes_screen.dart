import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/haptic_service.dart';
import '../../../core/widgets/entrance_animation.dart';

/// Apple-quality Live Classes screen
class LiveClassesScreen extends StatelessWidget {
  const LiveClassesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      children: [
        // ── Active Session Banner ──
        EntranceAnimation(
          child: _ActiveSessionBanner(isDark: isDark),
        ),
        const SizedBox(height: 28),

        // ── Stats Row ──
        EntranceAnimation(
          delay: const Duration(milliseconds: 80),
          child: _LiveStatsRow(isDark: isDark),
        ),
        const SizedBox(height: 24),

        // ── Upcoming Section Header ──
        EntranceAnimation(
          delay: const Duration(milliseconds: 140),
          child: _SectionHeader(isDark: isDark),
        ),
        const SizedBox(height: 14),

        // ── Upcoming Classes ──
        ..._buildUpcomingClasses(isDark),
      ],
    );
  }

  List<Widget> _buildUpcomingClasses(bool isDark) {
    final classes = [
      _UpcomingClassData(
        title: 'Rəng Nəzəriyyəsi Seminarı',
        instructor: 'Sarah Müəllim',
        time: '${AppStrings.tomorrow}, 14:00',
        duration: '1 ${AppStrings.durationHours.replaceFirst('%s', '').trim()}',
        participants: 24,
        type: _ClassType.workshop,
      ),
      _UpcomingClassData(
        title: 'Təkmil Widget Nümunələri',
        instructor: 'Sarah Müəllim',
        time: '${AppStrings.wed}, 10:00',
        duration: '1.5 ${AppStrings.durationHours.replaceFirst('%s', '').trim()}',
        participants: 18,
        type: _ClassType.lecture,
      ),
      _UpcomingClassData(
        title: 'Responziv Dizayn Laboratoriyası',
        instructor: 'Sarah Müəllim',
        time: '${AppStrings.fri}, 15:00',
        duration: '1 ${AppStrings.durationHours.replaceFirst('%s', '').trim()}',
        participants: 31,
        type: _ClassType.lab,
      ),
    ];

    return List.generate(classes.length, (index) {
      return EntranceAnimation(
        delay: Duration(milliseconds: 200 + (index * 80)),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _UpcomingClassCard(
            data: classes[index],
            isDark: isDark,
          ),
        ),
      );
    });
  }
}

// ═══════════════════════════════════════════════════════════════════
//  ACTIVE SESSION BANNER
// ═══════════════════════════════════════════════════════════════════

class _ActiveSessionBanner extends StatelessWidget {
  final bool isDark;
  const _ActiveSessionBanner({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFFDC2626), Color(0xFFF97316)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEF4444).withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circle
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            right: 40,
            bottom: -30,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Live badge
                Row(
                  children: [
                    _LivePulseDot(),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        AppStrings.liveNow,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Participant count
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.people_alt_rounded,
                              size: 13, color: Colors.white70),
                          const SizedBox(width: 5),
                          Text(
                            '32 ${AppStrings.liveParticipants}',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: Colors.white70,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  'Flutter Vəziyyət İdarəetməsi',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.4)),
                      ),
                      child: const Icon(Icons.person_rounded,
                          size: 14, color: Colors.white70),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Sarah Müəllim',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.access_time_rounded,
                        size: 14,
                        color: Colors.white.withValues(alpha: 0.6)),
                    const SizedBox(width: 4),
                    Text(
                      AppStrings.startedTimeAgo.replaceFirst(
                          '%s', '15 ${AppStrings.minutesShort}'),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Join button
                _JoinSessionButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  LIVE PULSE DOT (animated)
// ═══════════════════════════════════════════════════════════════════

class _LivePulseDot extends StatefulWidget {
  @override
  State<_LivePulseDot> createState() => _LivePulseDotState();
}

class _LivePulseDotState extends State<_LivePulseDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _scaleAnimation = Tween(begin: 1.0, end: 2.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _opacityAnimation = Tween(begin: 0.6, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Opacity(
                  opacity: _opacityAnimation.value,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            },
          ),
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  JOIN SESSION BUTTON
// ═══════════════════════════════════════════════════════════════════

class _JoinSessionButton extends StatefulWidget {
  @override
  State<_JoinSessionButton> createState() => _JoinSessionButtonState();
}

class _JoinSessionButtonState extends State<_JoinSessionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        HapticService.medium();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedOpacity(
          opacity: _pressed ? 0.85 : 1.0,
          duration: const Duration(milliseconds: 120),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.videocam_rounded,
                    size: 20, color: Color(0xFFDC2626)),
                const SizedBox(width: 10),
                Text(
                  AppStrings.joinSession,
                  style: AppTextStyles.button.copyWith(
                    color: const Color(0xFFDC2626),
                    fontWeight: FontWeight.w700,
                  ),
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
//  STATS ROW
// ═══════════════════════════════════════════════════════════════════

class _LiveStatsRow extends StatelessWidget {
  final bool isDark;
  const _LiveStatsRow({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _LiveStatChip(
          icon: Icons.videocam_rounded,
          label: AppStrings.liveSessionsToday,
          value: '1',
          color: AppColors.error,
          isDark: isDark,
        ),
        const SizedBox(width: 10),
        _LiveStatChip(
          icon: Icons.event_rounded,
          label: AppStrings.liveUpcomingCount,
          value: '3',
          color: AppColors.secondary,
          isDark: isDark,
        ),
        const SizedBox(width: 10),
        _LiveStatChip(
          icon: Icons.access_time_rounded,
          label: AppStrings.liveTotalHours,
          value: '4.5',
          color: AppColors.accent,
          isDark: isDark,
        ),
      ],
    );
  }
}

class _LiveStatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  const _LiveStatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
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
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 6),
            Text(
              value,
              style: AppTextStyles.headlineMedium.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
                fontSize: 9,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  SECTION HEADER
// ═══════════════════════════════════════════════════════════════════

class _SectionHeader extends StatelessWidget {
  final bool isDark;
  const _SectionHeader({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.secondary, AppColors.secondaryLight],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          AppStrings.upcomingSessions,
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: isDark ? 0.12 : 0.07),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '3 ${AppStrings.liveSessionsLabel}',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.secondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  DATA MODEL
// ═══════════════════════════════════════════════════════════════════

enum _ClassType { lecture, workshop, lab }

class _UpcomingClassData {
  final String title;
  final String instructor;
  final String time;
  final String duration;
  final int participants;
  final _ClassType type;

  const _UpcomingClassData({
    required this.title,
    required this.instructor,
    required this.time,
    required this.duration,
    required this.participants,
    required this.type,
  });
}

// ═══════════════════════════════════════════════════════════════════
//  UPCOMING CLASS CARD
// ═══════════════════════════════════════════════════════════════════

class _UpcomingClassCard extends StatelessWidget {
  final _UpcomingClassData data;
  final bool isDark;

  const _UpcomingClassCard({required this.data, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final typeColor = _typeColor;

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
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Gradient accent strip ──
          Container(
            height: 3,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [typeColor, typeColor.withValues(alpha: 0.3)],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(22),
                topRight: Radius.circular(22),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Row(
              children: [
                // Type icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        typeColor.withValues(alpha: 0.15),
                        typeColor.withValues(alpha: 0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(_typeIcon, color: typeColor, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.title,
                        style: AppTextStyles.titleLarge.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      // Info row
                      Row(
                        children: [
                          Icon(Icons.person_outline_rounded,
                              size: 13,
                              color: isDark
                                  ? AppColors.darkTextHint
                                  : AppColors.lightTextHint),
                          const SizedBox(width: 4),
                          Text(
                            data.instructor,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Pill tags row
                      Row(
                        children: [
                          _SmallPill(
                            icon: Icons.access_time_rounded,
                            label: data.time,
                            color: typeColor,
                            isDark: isDark,
                          ),
                          const SizedBox(width: 6),
                          _SmallPill(
                            icon: Icons.timer_outlined,
                            label: data.duration,
                            color: typeColor,
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Notification toggle
                _ReminderToggle(typeColor: typeColor, isDark: isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color get _typeColor {
    switch (data.type) {
      case _ClassType.lecture:
        return AppColors.secondary;
      case _ClassType.workshop:
        return AppColors.accent;
      case _ClassType.lab:
        return AppColors.success;
    }
  }

  IconData get _typeIcon {
    switch (data.type) {
      case _ClassType.lecture:
        return Icons.school_outlined;
      case _ClassType.workshop:
        return Icons.brush_outlined;
      case _ClassType.lab:
        return Icons.science_outlined;
    }
  }
}

// ═══════════════════════════════════════════════════════════════════
//  SMALL PILL
// ═══════════════════════════════════════════════════════════════════

class _SmallPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;

  const _SmallPill({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.1 : 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.15 : 0.08),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  REMINDER TOGGLE
// ═══════════════════════════════════════════════════════════════════

class _ReminderToggle extends StatefulWidget {
  final Color typeColor;
  final bool isDark;

  const _ReminderToggle({required this.typeColor, required this.isDark});

  @override
  State<_ReminderToggle> createState() => _ReminderToggleState();
}

class _ReminderToggleState extends State<_ReminderToggle> {
  bool _enabled = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticService.light();
        setState(() => _enabled = !_enabled);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _enabled
              ? widget.typeColor.withValues(alpha: 0.12)
              : (widget.isDark ? Colors.white : Colors.black)
                  .withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _enabled
                ? widget.typeColor.withValues(alpha: 0.25)
                : (widget.isDark ? Colors.white : Colors.black)
                    .withValues(alpha: 0.06),
          ),
        ),
        child: Icon(
          _enabled
              ? Icons.notifications_active_rounded
              : Icons.notifications_none_rounded,
          size: 20,
          color: _enabled
              ? widget.typeColor
              : (widget.isDark
                  ? AppColors.darkTextHint
                  : AppColors.lightTextHint),
        ),
      ),
    );
  }
}
