import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../services/haptic_service.dart';

class StreakSection extends StatefulWidget {
  final int streakDays;
  const StreakSection({super.key, this.streakDays = 7});

  @override
  State<StreakSection> createState() => _StreakSectionState();
}

class _StreakSectionState extends State<StreakSection> with TickerProviderStateMixin {
  late AnimationController _fireController;
  late AnimationController _staggerController;
  late Animation<double> _fireAnimation;

  final List<Color> _progressionColors = [
    const Color(0xFF00B8D4), // Day 1: Cyan
    const Color(0xFF00BFA5), // Day 2: Teal
    const Color(0xFF00C853), // Day 3: Green
    const Color(0xFFFFD600), // Day 4: Yellow
    const Color(0xFFFF9100), // Day 5: Orange
    const Color(0xFFFF3D00), // Day 6: Deep Orange
    const Color(0xFFD500F9), // Day 7: Purple (Epic)
  ];

  @override
  void initState() {
    super.initState();
    _fireController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    
    _fireAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _fireController, curve: Curves.easeInOut),
    );

    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _staggerController.forward();
      if (widget.streakDays > 0) {
        HapticService.light();
      }
    });
  }

  @override
  void dispose() {
    _fireController.dispose();
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isHot = widget.streakDays >= 5;
    final int currentStreak = widget.streakDays.clamp(0, 7);
    final Color mainColor = currentStreak > 0 ? _progressionColors[currentStreak - 1] : AppColors.primary;

    return InkWell(
      onTap: () {
        HapticService.medium();
        context.push('/student/streak-details');
      },
      borderRadius: BorderRadius.circular(32),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: mainColor.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: mainColor.withOpacity(0.1),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ScaleTransition(
                scale: _fireAnimation,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: mainColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: mainColor.withOpacity(0.2),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.local_fire_department_rounded,
                    color: mainColor,
                    size: 36,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.streakDays} Günlük Seriya!',
                      style: AppTextStyles.headlineSmall.copyWith(
                        fontWeight: FontWeight.w900,
                        color: mainColor,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      isHot ? 'Alovlanırsan! 🔥 Dayandırma.' : 'Öyrənməyə davam et, rekordunu yenilə!',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = (constraints.maxWidth - (6 * 8)) / 7;
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(7, (index) {
                  final List<String> days = ['BE', 'ÇA', 'ÇƏ', 'CA', 'CÜ', 'ŞƏ', 'BA'];
                  final bool isActive = index < currentStreak;
                  final Color dayColor = _progressionColors[index];
                  
                  return AnimatedBuilder(
                    animation: _staggerController,
                    builder: (context, child) {
                      final double delay = index * 0.1;
                      final double animValue = Curves.easeOutBack.transform(
                        (_staggerController.value - delay).clamp(0.0, 1.0),
                      );
                      
                      return Transform.scale(
                        scale: animValue,
                        child: Opacity(
                          opacity: animValue.clamp(0.0, 1.0),
                          child: Column(
                            children: [
                              Container(
                                width: itemWidth,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: isActive ? dayColor : AppColors.lightSurface,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: isActive ? [
                                    BoxShadow(
                                      color: dayColor.withOpacity(0.4),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    )
                                  ] : null,
                                  border: Border.all(
                                    color: isActive ? Colors.white.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
                                    width: 1.5,
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    isActive ? Icons.check_rounded : Icons.lock_outline_rounded,
                                    color: isActive ? Colors.white : Colors.grey.withOpacity(0.3),
                                    size: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                days[index],
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: isActive ? dayColor : Colors.grey.withOpacity(0.5),
                                  fontWeight: isActive ? FontWeight.w900 : FontWeight.w500,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
              );
            },
          ),
        ],
      ),
    ),
  );
}
}
