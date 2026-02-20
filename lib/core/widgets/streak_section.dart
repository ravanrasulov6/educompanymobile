import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class StreakSection extends StatefulWidget {
  final int streakDays;
  const StreakSection({super.key, this.streakDays = 7});

  @override
  State<StreakSection> createState() => _StreakSectionState();
}

class _StreakSectionState extends State<StreakSection> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isHot = widget.streakDays >= 5;
    final Color streakColor = isHot ? const Color(0xFFFF3D00) : AppColors.primary;
    final Color backColor = isHot ? const Color(0xFFFF3D00).withValues(alpha: 0.1) : AppColors.primary.withValues(alpha: 0.1);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ScaleTransition(
                scale: _animation,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: backColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.local_fire_department_rounded,
                    color: streakColor,
                    size: 32,
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
                        fontWeight: FontWeight.w800,
                        color: isHot ? streakColor : null,
                      ),
                    ),
                    Text(
                      'Öyrənməyə davam et, rekordunu yenilə!',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final List<String> days = ['B.E', 'Ç.A', 'Ç.', 'C.A', 'C.', 'Ş.', 'B.'];
              final bool isActive = index < widget.streakDays;
              return Column(
                children: [
                  Container(
                    width: 38,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isActive ? streakColor : AppColors.lightSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isActive ? streakColor : Colors.grey.withValues(alpha: 0.2),
                        width: 1,
                      ),
                      boxShadow: isActive ? [
                        BoxShadow(
                          color: streakColor.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        )
                      ] : null,
                    ),
                    child: Center(
                      child: Icon(
                        isActive ? Icons.check_rounded : Icons.lock_outline_rounded,
                        color: isActive ? Colors.white : Colors.grey.withValues(alpha: 0.5),
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    days[index],
                    style: AppTextStyles.labelSmall.copyWith(
                      color: isActive ? streakColor : Colors.grey,
                      fontWeight: isActive ? FontWeight.w700 : null,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
