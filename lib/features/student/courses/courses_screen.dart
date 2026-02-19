import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../providers/course_provider.dart';
import '../../../core/widgets/course_card.dart';
import '../../../core/widgets/shimmer_loader.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_colors.dart';

/// Student courses screen
class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<CourseProvider>().loadCourses();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CourseProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return ShimmerLoader.list(itemCount: 5);
        }

        final inProgress =
            provider.courses.where((c) => c.progress > 0).toList();
        final explore =
            provider.courses.where((c) => c.progress == 0).toList();

        return CustomScrollView(
          slivers: [
            // Study streak banner
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.local_fire_department,
                          color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '🔥 7 Day Streak!',
                            style: AppTextStyles.headlineSmall
                                .copyWith(color: Colors.white),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Keep learning daily to maintain your streak',
                            style: AppTextStyles.bodySmall
                                .copyWith(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Continue learning
            if (inProgress.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: SectionHeader(
                  title: 'Continue Learning',
                  onSeeAll: () {},
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final course = inProgress[index];
                    return CourseCard(
                      title: course.title,
                      instructor: course.instructor,
                      progress: course.progress,
                      category: course.category,
                      rating: course.rating,
                      onTap: () => context.go('/student/courses/${course.id}'),
                      onContinue: () =>
                          context.go('/student/courses/${course.id}'),
                    );
                  },
                  childCount: inProgress.length,
                ),
              ),
            ],

            // Explore
            if (explore.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: SectionHeader(
                  title: 'Explore Courses',
                  onSeeAll: () {},
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final course = explore[index];
                    return CourseCard(
                      title: course.title,
                      instructor: course.instructor,
                      category: course.category,
                      rating: course.rating,
                      lessonsCount: course.totalLessons,
                      onTap: () => context.go('/student/courses/${course.id}'),
                    );
                  },
                  childCount: explore.length,
                ),
              ),
            ],

            const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
          ],
        );
      },
    );
  }
}
