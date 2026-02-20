import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../services/haptic_service.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class ContinueLearningCard extends StatelessWidget {
  final String title;
  final String category;
  final double progress;
  final String thumbnailUrl;
  final int completedLessons;
  final int totalLessons;
  final VoidCallback onTap;

  const ContinueLearningCard({
    super.key,
    required this.title,
    required this.category,
    required this.progress,
    required this.thumbnailUrl,
    required this.completedLessons,
    required this.totalLessons,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.1),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticService.medium();
            onTap();
          },
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Small Thumbnail
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                        ),
                        child: thumbnailUrl.isNotEmpty 
                          ? Image.network(thumbnailUrl, fit: BoxFit.cover)
                          : const Icon(Icons.play_circle_fill, color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              category.toUpperCase(),
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 9,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            title,
                            style: AppTextStyles.titleLarge.copyWith(height: 1.1),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildContinueButton(),
                  ],
                ),
                const SizedBox(height: 20),
                // Progress Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$completedLessons/$totalLessons ders tamamlanıb',
                      style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '${(progress * 100).round()}%',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                LinearPercentIndicator(
                  padding: EdgeInsets.zero,
                  lineHeight: 8.0,
                  percent: progress.clamp(0.0, 1.0),
                  backgroundColor: isDark ? Colors.white10 : Colors.grey.withValues(alpha: 0.1),
                  progressColor: AppColors.primary,
                  barRadius: const Radius.circular(4),
                  animation: true,
                  animationDuration: 1000,
                  animateFromLastPercent: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
    );
  }
}
