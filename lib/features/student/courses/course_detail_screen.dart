import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import '../../../providers/course_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/premium_button.dart';
import '../../../core/services/haptic_service.dart';
import '../../../models/course_model.dart';
import '../../../core/constants/app_strings.dart';

/// Course detail screen with sections and lessons
class CourseDetailScreen extends StatelessWidget {
  final String courseId;
  const CourseDetailScreen({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CourseProvider>();
    final course = provider.courses.firstWhere(
      (c) => c.id == courseId,
      orElse: () => CourseModel.demoCourses.first,
    );

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Parallax Header
              SliverPersistentHeader(
                delegate: _ParallaxHeaderDelegate(
                  course: course,
                  statusBarHeight: MediaQuery.of(context).padding.top,
                ),
                pinned: true,
              ),

              // Course info
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Meta
                      Row(
                        children: [
                          const Icon(Icons.person_outline, size: 16),
                          const SizedBox(width: 6),
                          Text(course.instructor, style: AppTextStyles.bodySmall),
                          const SizedBox(width: 16),
                          const Icon(Icons.star, size: 16, color: AppColors.accent),
                          const SizedBox(width: 4),
                          Text(course.rating.toString(),
                              style: AppTextStyles.bodySmall),
                          const SizedBox(width: 16),
                          const Icon(Icons.people_outline, size: 16),
                          const SizedBox(width: 4),
                          Text(AppStrings.studentsCount.replaceFirst('%s', course.studentsCount.toString()),
                              style: AppTextStyles.bodySmall),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Description
                      Text(course.description, style: AppTextStyles.bodyMedium),
                      const SizedBox(height: 20),

                      // Progress
                      if (course.progress > 0)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(AppStrings.completedPercentage.replaceFirst('%s', '${(course.progress * 100).round()}%'),
                                        style: AppTextStyles.titleLarge),
                                    const SizedBox(height: 4),
                                    Text(
                                        AppStrings.lessonsCount.replaceFirst('%s', '${course.completedLessons}/${course.totalLessons}'),
                                        style: AppTextStyles.bodySmall),
                                  ],
                                ),
                              ),
                              PremiumButton(
                                label: 'Davam et',
                                onPressed: () {
                                  HapticService.medium();
                                },
                                icon: Icons.play_arrow,
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 24),
                      Text(AppStrings.curriculum, style: AppTextStyles.headlineMedium),
                      const SizedBox(height: 8),

                      // Notes feature button
                      OutlinedButton.icon(
                        onPressed: () {
                          HapticService.light();
                        },
                        icon: const Icon(Icons.note_add_outlined, size: 18),
                        label: const Text(AppStrings.myNotes),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),

              // Sections + Lessons
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final section = course.sections[index];
                    return _SectionTile(section: section);
                  },
                  childCount: course.sections.length,
                ),
              ),

              const SliverPadding(padding: EdgeInsets.only(bottom: 140)),
            ],
          ),
          
          // Floating Action Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildGlassActionBar(context, course),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassActionBar(BuildContext context, CourseModel course) {
    final provider = context.watch<CourseProvider>();
    final isEnrolled = provider.enrolledCourseIds.contains(course.id);
    final isGuest = context.read<AuthProvider>().isGuest;

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.black.withOpacity(0.5)
                    : Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEnrolled ? 'Abunəlik Aktivdir' : (course.price == 0 ? 'Pulsuz' : '${course.price} AZN'),
                          style: AppTextStyles.labelSmall.copyWith(
                            color: isEnrolled || course.price == 0 ? AppColors.success : AppColors.primary, 
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        Text(
                          isEnrolled ? 'Bütün dərslərə giriş' : 'Məhdudiyyətsiz giriş',
                          style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: isEnrolled 
                      ? () {
                          HapticService.medium();
                          // Navigate to first lesson or player
                        }
                      : () async {
                          if (isGuest) {
                            context.push('/login');
                            return;
                          }
                          
                          HapticService.heavy();
                          if (course.price == 0) {
                            final success = await provider.enrollInCourse(course.id);
                            if (success && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      const Icon(Icons.check_circle_rounded, color: Colors.white),
                                      const SizedBox(width: 12),
                                      const Text('Təbriklər! Kursa uğurla abunə oldunuz.'),
                                    ],
                                  ),
                                  backgroundColor: AppColors.success,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                              );
                                context.go('/student/my-courses');
                            }
                          } else {
                            // Navigate to payment screen
                            context.push('/payment', extra: course);
                          }
                        },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isEnrolled ? Colors.grey.withOpacity(0.1) : AppColors.primary,
                      foregroundColor: isEnrolled ? Colors.grey : Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: isEnrolled ? 0 : 8,
                      shadowColor: AppColors.primary.withOpacity(0.4),
                    ),
                    child: Text(
                      isEnrolled ? 'Artıq Alınıb' : (course.price == 0 ? 'İndi qatıl' : 'Abunə ol'), 
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5)
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ParallaxHeaderDelegate extends SliverPersistentHeaderDelegate {
  final CourseModel course;
  final double statusBarHeight;

  _ParallaxHeaderDelegate({required this.course, required this.statusBarHeight});

  @override
  double get minExtent => statusBarHeight + kToolbarHeight;

  @override
  double get maxExtent => 280;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final double percent = shrinkOffset / maxExtent;
    final double scrollTransform = (1 - percent).clamp(0.0, 1.0);
    
    return Stack(
      fit: StackFit.expand,
      children: [
        // Image with parallax scale
        Hero(
          tag: 'course-${course.id}',
          child: Transform.scale(
            scale: 1.0 + (0.2 * (1 - scrollTransform)),
            child: Container(
              decoration: BoxDecoration(
                image: course.thumbnailUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(course.thumbnailUrl),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          Colors.black.withValues(alpha: 0.2 + (0.4 * percent)),
                          BlendMode.darken,
                        ),
                      )
                    : null,
                gradient: AppColors.primaryGradient,
              ),
            ),
          ),
        ),
        
        // Content
        Positioned(
          bottom: 20 + (20 * scrollTransform),
          left: 20,
          right: 20,
          child: Opacity(
            opacity: scrollTransform,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    course.category.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  course.title,
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Navigation bar overlay
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            height: minExtent,
            padding: EdgeInsets.only(top: statusBarHeight),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6 * percent),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/student/courses');
                    }
                  },
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.share_outlined, color: Colors.white),
                  onPressed: () {
                    HapticService.light();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.favorite_border_rounded, color: Colors.white),
                  onPressed: () {
                    HapticService.light();
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  bool shouldRebuild(_ParallaxHeaderDelegate oldDelegate) => true;
}

class _SectionTile extends StatelessWidget {
  final CourseSection section;
  const _SectionTile({required this.section});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          onExpansionChanged: (val) {
            if (val) HapticService.light();
          },
          title: Text(section.title, style: AppTextStyles.titleLarge),
          subtitle: Text(
            AppStrings.lessonsCount.replaceFirst('%s', section.lessons.length.toString()),
            style: AppTextStyles.bodySmall,
          ),
          children: section.lessons.map((lesson) {
            return ListTile(
              leading: Icon(
                lesson.isCompleted
                    ? Icons.check_circle
                    : Icons.play_circle_outline,
                color: lesson.isCompleted ? AppColors.success : AppColors.primary,
                size: 24,
              ),
              title: Text(lesson.title, style: AppTextStyles.bodyMedium),
              trailing: Text(lesson.duration, style: AppTextStyles.bodySmall),
              onTap: () {
                HapticService.medium();
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
