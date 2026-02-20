import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AchievementBadge extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const AchievementBadge({
    super.key,
    required this.title,
    required this.icon,
    this.color = AppColors.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.1),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.labelSmall.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 10,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class AchievementsSection extends StatelessWidget {
  const AchievementsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final achievements = [
      {'title': 'İlk Dərs', 'icon': Icons.stars_rounded, 'color': AppColors.accent},
      {'title': 'Sürətli Öyrənən', 'icon': Icons.bolt_rounded, 'color': AppColors.primary},
      {'title': 'İmtahan Çempionu', 'icon': Icons.emoji_events_rounded, 'color': Colors.amber},
      {'title': 'Aktiv Tələbə', 'icon': Icons.favorite_rounded, 'color': Colors.redAccent},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Nailiyyətləriniz',
            style: AppTextStyles.headlineSmall,
          ),
        ),
        SizedBox(
          height: 140,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            scrollDirection: Axis.horizontal,
            itemCount: achievements.length,
            itemBuilder: (context, index) {
              final item = achievements[index];
              return AchievementBadge(
                title: item['title'] as String,
                icon: item['icon'] as IconData,
                color: item['color'] as Color,
              );
            },
          ),
        ),
      ],
    );
  }
}
