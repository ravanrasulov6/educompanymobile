import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../providers/course_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/student_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/shimmer_loader.dart';
import '../../../core/widgets/news_carousel.dart';
import '../../../core/widgets/entrance_animation.dart';
import '../../../core/services/haptic_service.dart';
import '../../../core/widgets/premium_fab.dart';
import '../../../core/widgets/video_lesson_card.dart';
import '../../../core/widgets/premium_kit.dart';
import 'widgets/active_course_card.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final courseProvider = context.read<CourseProvider>();
      final authProvider = context.read<AuthProvider>();
      final studentProvider = context.read<StudentProvider>();
      
      courseProvider.loadCourses();
      studentProvider.loadDashboardData();
      
      final user = authProvider.user;
      if (user != null) {
        courseProvider.loadUserEnrollments(user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: const Padding(
        padding: EdgeInsets.only(bottom: 90),
        child: PremiumExpandingFab(),
      ),
      body: Consumer<CourseProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.courses.isEmpty) {
            return ShimmerLoader.dashboard();
          }

          return RefreshIndicator(
            onRefresh: () async {
              HapticService.success();
              await provider.loadCourses();
              await context.read<StudentProvider>().loadDashboardData();
            },
            color: AppColors.primary,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Top Spacing
                const SliverToBoxAdapter(child: SizedBox(height: 12)),

                // 1. Search Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.black.withOpacity(0.03)),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) => provider.setSearchQuery(val),
                        decoration: InputDecoration(
                          hintText: 'Yeni nə öyrənmək istəyirsən?',
                          prefixIcon: const Icon(Icons.search, color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                  ),
                ),

                // 2. News Carousel (Banner) - Exactly under Search
                if (provider.searchQuery.isEmpty && provider.selectedCategory == 'Hamısı')
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: NewsCarousel(),
                    ),
                  ),

                // 3. Categories - Under Banner
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: Text('Kateqoriyalar', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                      ),
                      Container(
                        height: 50,
                        margin: const EdgeInsets.only(bottom: 16),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: provider.categories.length,
                          itemBuilder: (context, index) {
                            final category = provider.categories[index];
                            final isSelected = category == provider.selectedCategory;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(category),
                                selected: isSelected,
                                onSelected: (val) {
                                  if (val) provider.setCategory(category);
                                },
                                selectedColor: AppColors.primary,
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.white : Colors.black54,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                                backgroundColor: Colors.grey.withOpacity(0.05),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // 4. Statistics Row - After Categories
                if (provider.searchQuery.isEmpty && provider.selectedCategory == 'Hamısı')
                  SliverToBoxAdapter(
                    child: Consumer2<AuthProvider, CourseProvider>(
                      builder: (context, auth, course, _) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: StatChipsRow(
                            stats: [
                              StatChipItem(
                                label: 'Kurslar', 
                                value: '${course.enrolledVideoCourses.length}', 
                                icon: Icons.school_rounded, 
                                color: AppColors.primary,
                                onTap: () => context.push('/student/my-courses'),
                              ),
                              StatChipItem(
                                label: 'Seriya', 
                                value: '${auth.user?.streakDays ?? 0} gün', 
                                icon: Icons.local_fire_department_rounded, 
                                color: AppColors.accent,
                                onTap: () => context.push('/student/streak-details'),
                              ),
                              StatChipItem(
                                label: 'Xal', 
                                value: '${auth.user?.totalPoints ?? 0}', 
                                icon: Icons.stars_rounded, 
                                color: AppColors.success,
                                onTap: () => context.push('/student/profile'),
                              ),
                            ],
                          ),
                        );
                      }
                    ),
                  ),

                // 5. Continue Learning Carousel
                if (provider.searchQuery.isEmpty && provider.selectedCategory == 'Hamısı' && provider.enrolledVideoCourses.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Kursa davam et', style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold, color: Colors.black87)),
                          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.black26),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 150, // Increased height to prevent overflow
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: provider.enrolledVideoCourses.length,
                        itemBuilder: (context, index) {
                          final course = provider.enrolledVideoCourses[index];
                          return SizedBox(
                            width: 260,
                            child: EntranceAnimation(
                              delay: Duration(milliseconds: 100 * index),
                              child: ActiveCourseCard(
                                title: course.title,
                                category: 'Video Kurs',
                                progress: course.calculatedProgress,
                                thumbnailUrl: course.thumbnailUrl,
                                onTap: () {
                                  String? lessonId;
                                  for (var section in course.sections) {
                                    for (var lesson in section.lessons) {
                                      if (!lesson.isCompleted) {
                                        lessonId = lesson.id;
                                        break;
                                      }
                                    }
                                    if (lessonId != null) break;
                                  }
                                  lessonId ??= course.sections.isNotEmpty && course.sections[0].lessons.isNotEmpty 
                                    ? course.sections[0].lessons[0].id 
                                    : 'initial';
                                  context.push('/student/courses/${course.id}/workspace/$lessonId');
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],

                // 6. Recent Activities
                if (provider.searchQuery.isEmpty && provider.selectedCategory == 'Hamısı')
                  SliverToBoxAdapter(
                    child: Consumer<StudentProvider>(
                      builder: (context, student, _) {
                        if (student.activities.isEmpty) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Son Aktivliklər', style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold, color: Colors.black87)),
                              const SizedBox(height: 16),
                              ...student.activities.take(3).map((activity) => InkWell(
                                onTap: () {
                                  HapticService.light();
                                  if (activity['activity_type'] == 'lesson_view') {
                                    context.push('/student/courses/${activity['course_id']}/workspace/${activity['lesson_id'] ?? 'initial'}');
                                  } else if (activity['activity_type'] == 'assignment_submission') {
                                    context.push('/student/assignments/${activity['assignment_id']}/submit');
                                  }
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                    boxShadow: [
                                      BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          activity['activity_type'] == 'lesson_view' ? Icons.play_circle_fill : Icons.check_circle,
                                          color: AppColors.primary,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(activity['description'] ?? 'Aktivlik', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: Colors.black87)),
                                            Text(activity['courses']?['title'] ?? '', style: AppTextStyles.bodySmall.copyWith(color: Colors.black54)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )),
                            ],
                          ),
                        );
                      }
                    ),
                  ),

                // 7. Course List Title
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 32, 20, 8),
                    child: Text(
                      provider.searchQuery.isNotEmpty ? 'Axtarış nəticələri' : 'Bütün Kurslar',
                      style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ),
                ),

                // 8. List rendered
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: provider.filteredCourses.isEmpty
                    ? SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.withOpacity(0.2)),
                              const SizedBox(height: 16),
                              Text('Kurs tapılmadı', style: AppTextStyles.bodyMedium.copyWith(color: Colors.black54)),
                            ],
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final course = provider.filteredCourses[index];
                            return EntranceAnimation(
                              delay: Duration(milliseconds: 50 * (index % 10)),
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: VideoLessonCard(
                                  title: course.title,
                                  instructor: course.instructor,
                                  duration: '${course.totalLessons} Dərs',
                                  rating: course.rating.toString(),
                                  level: course.price == 0 ? 'Pulsuz' : '${course.price} AZN',
                                  thumbnailUrl: course.thumbnailUrl,
                                  onTap: () => context.push('/student/courses/${course.id}'),
                                ),
                              ),
                            );
                          },
                          childCount: provider.filteredCourses.length,
                        ),
                      ),
                ),

                const SliverPadding(padding: EdgeInsets.only(bottom: 120)),
              ],
            ),
          );
        },
      ),
    );
  }
}
