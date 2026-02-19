import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Course list card with progress indicator
class CourseCard extends StatelessWidget {
  final String title;
  final String instructor;
  final double progress;
  final String category;
  final double rating;
  final int lessonsCount;
  final VoidCallback? onTap;
  final VoidCallback? onContinue;

  const CourseCard({
    super.key,
    required this.title,
    required this.instructor,
    this.progress = 0.0,
    this.category = '',
    this.rating = 0.0,
    this.lessonsCount = 0,
    this.onTap,
    this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Thumbnail placeholder
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(Icons.play_circle_outline,
                      color: Colors.white, size: 32),
                ),
              ),
              const SizedBox(width: 14),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (category.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        margin: const EdgeInsets.only(bottom: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          category,
                          style: AppTextStyles.labelSmall
                              .copyWith(color: AppColors.primary),
                        ),
                      ),
                    Text(
                      title,
                      style: AppTextStyles.titleLarge,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      instructor,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (progress > 0)
                      LinearPercentIndicator(
                        padding: EdgeInsets.zero,
                        lineHeight: 6,
                        percent: progress.clamp(0.0, 1.0),
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        progressColor: AppColors.primary,
                        barRadius: const Radius.circular(3),
                        trailing: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text(
                            '${(progress * 100).round()}%',
                            style: AppTextStyles.labelSmall
                                .copyWith(color: AppColors.primary),
                          ),
                        ),
                      ),
                    if (progress > 0 && onContinue != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: SizedBox(
                          height: 30,
                          child: OutlinedButton.icon(
                            onPressed: onContinue,
                            icon: const Icon(Icons.play_arrow, size: 16),
                            label: const Text('Continue',
                                style: TextStyle(fontSize: 12)),
                            style: OutlinedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Rating
              if (rating > 0)
                Column(
                  children: [
                    const Icon(Icons.star, color: AppColors.accent, size: 18),
                    const SizedBox(height: 2),
                    Text(rating.toStringAsFixed(1),
                        style: AppTextStyles.labelSmall),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
