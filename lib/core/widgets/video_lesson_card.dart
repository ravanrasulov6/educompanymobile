import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../services/haptic_service.dart';

class VideoLessonCard extends StatelessWidget {
  final String title;
  final String instructor;
  final String duration;
  final String rating;
  final String level;
  final String thumbnailUrl;
  final bool isLive;
  final VoidCallback onTap;

  const VideoLessonCard({
    super.key,
    required this.title,
    required this.instructor,
    required this.duration,
    required this.rating,
    required this.level,
    required this.thumbnailUrl,
    this.isLive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
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
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Larger Thumbnail with Play Button
                Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                        ),
                        child: thumbnailUrl.isNotEmpty
                            ? Image.network(thumbnailUrl, fit: BoxFit.cover)
                            : Icon(isLive ? Icons.videocam_rounded : Icons.movie_rounded, color: Colors.white),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                      ),
                      child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
                    ),
                    // Duration Badge
                    Positioned(
                      bottom: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          duration,
                          style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              level.toUpperCase(),
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.accent,
                                fontWeight: FontWeight.bold,
                                fontSize: 9,
                              ),
                            ),
                          ),
                          const Spacer(),
                          const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                          const SizedBox(width: 4),
                          Text(rating, style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        title,
                        style: AppTextStyles.titleLarge.copyWith(fontSize: 15, height: 1.2),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        instructor,
                        style: AppTextStyles.bodySmall.copyWith(fontSize: 12),
                        maxLines: 1,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(isLive ? Icons.videocam_rounded : Icons.video_library_rounded, size: 14, color: isLive ? AppColors.error : AppColors.primary),
                          const SizedBox(width: 6),
                          Text(isLive ? 'Canlı Dərs' : 'Video Dərs', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                          const Spacer(),
                          Text(
                            'İndi izlə',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded, size: 14, color: AppColors.primary),
                        ],
                      ),
                    ],
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
