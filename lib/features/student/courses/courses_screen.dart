import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../providers/course_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/shimmer_loader.dart';
import '../../../core/widgets/news_carousel.dart';
import '../../../core/widgets/streak_section.dart';
import '../../../core/widgets/achievement_badge.dart';
import '../../../core/widgets/entrance_animation.dart';
import '../../../core/services/haptic_service.dart';
import '../../../core/widgets/premium_fab.dart';
import '../../../core/widgets/filter_bottom_sheet.dart';
import '../../../core/widgets/video_lesson_card.dart';
import '../../../providers/auth_provider.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CourseProvider>().loadCourses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CourseProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.courses.isEmpty) {
          return ShimmerLoader.dashboard();
        }

        // removed unused variables

        return Scaffold(
          floatingActionButton: const Padding(
            padding: EdgeInsets.only(bottom: 90),
            child: PremiumExpandingFab(),
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              HapticService.success();
              await provider.loadCourses();
            },
            color: AppColors.primary,
            backgroundColor: Theme.of(context).cardColor,
            strokeWidth: 3,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                // Premium Reference-Based Hero Header
                SliverToBoxAdapter(
                  child: EntranceAnimation(
                    child: Container(
                      height: 240, 
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(40),
                          bottomRight: Radius.circular(40),
                        ),
                        image: DecorationImage(
                          image: const AssetImage('assets/images/esassehifefoto.png'),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                            Colors.black.withValues(alpha: 0.3),
                            BlendMode.darken,
                          ),
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(40),
                            bottomRight: Radius.circular(40),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.1),
                              Colors.black.withValues(alpha: 0.6),
                            ],
                          ),
                        ),
                        child: SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildGreeting(context),
                                const Spacer(),
                                _buildSearchBar(context),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Category Chips
                SliverToBoxAdapter(
                  child: EntranceAnimation(
                    delay: const Duration(milliseconds: 100),
                    child: _buildCategoryChips(context),
                  ),
                ),

                // News Carousel
                const SliverToBoxAdapter(
                  child: EntranceAnimation(
                    delay: Duration(milliseconds: 200),
                    child: NewsCarousel(),
                  ),
                ),

                // Achievements
                const SliverToBoxAdapter(
                  child: EntranceAnimation(
                    delay: Duration(milliseconds: 250),
                    child: AchievementsSection(),
                  ),
                ),

                // Streak
                const SliverToBoxAdapter(
                  child: EntranceAnimation(
                    delay: Duration(milliseconds: 300),
                    child: StreakSection(),
                  ),
                ),

                // Tab View simulation for Canlı dərslər
                if (provider.courses.where((c) => c.isLive).isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Canlı dərslərim',
                              style: AppTextStyles.headlineMedium),
                          const Icon(Icons.videocam_rounded, color: AppColors.error, size: 24),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final liveCourses = provider.courses.where((c) => c.isLive).toList();
                          final course = liveCourses[index];
                          return EntranceAnimation(
                            delay: Duration(milliseconds: 300 + (index * 50)),
                            child: VideoLessonCard(
                              title: course.title,
                              instructor: course.instructor,
                              duration: 'Canlı Yayım', 
                              rating: course.rating.toString(),
                              level: 'Aktiv', 
                              thumbnailUrl: course.thumbnailUrl,
                              isLive: true,
                              onTap: () {
                                context.push('/student/live-classes/${course.id}');
                              },
                            ),
                          );
                        },
                        childCount: provider.courses.where((c) => c.isLive).length,
                      ),
                    ),
                  ),
                ],

                // Video Dərslər (Vertical)
                if (provider.courses.where((c) => !c.isLive).isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 32, 16, 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Video dərslərim',
                              style: AppTextStyles.headlineMedium),
                          const Icon(Icons.play_circle_filled, 
                              color: AppColors.primary, size: 24),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final videoCourses = provider.courses.where((c) => !c.isLive).toList();
                          final course = videoCourses[index];
                          return EntranceAnimation(
                            delay: Duration(milliseconds: 500 + (index * 100)),
                            child: VideoLessonCard(
                              title: course.title,
                              instructor: course.instructor,
                              duration: '${course.totalLessons} Dərs', 
                              rating: course.rating.toString(),
                              level: 'Hazır', 
                              thumbnailUrl: course.thumbnailUrl,
                              onTap: () {
                                context.push('/student/courses/${course.id}');
                              },
                            ),
                          );
                        },
                        childCount: provider.courses.where((c) => !c.isLive).length,
                      ),
                    ),
                  ),
                ],

                const SliverPadding(padding: EdgeInsets.only(bottom: 140)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGreeting(BuildContext context) {
    final hour = DateTime.now().hour;
    final user = context.watch<AuthProvider>().user;
    String greeting;

    if (hour < 12) {
      greeting = 'Sabahınız xeyir';
    } else if (hour < 18) {
      greeting = 'Günortanız xeyir';
    } else {
      greeting = 'Axşamınız xeyir';
    }

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              Text(
                '${user?.name ?? "Tələbə"} 👋',
                style: AppTextStyles.headlineMedium.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.85), // Lighter background so black is readable
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                ),
                child: TextField(
                  style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    hintText: 'Kurs axtarın...',
                    hintStyle: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.black54, // Changed to black/dark grey
                      fontWeight: FontWeight.w500,
                    ),
                    prefixIcon:
                        const Icon(Icons.search_rounded, color: Colors.black54),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        _buildFilterButton(context),
      ],
    );
  }

  Widget _buildFilterButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticService.medium();
          FilterBottomSheet.show(context);
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.primary.withValues(alpha: 0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.tune_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips(BuildContext context) {
    final categories = [
      'Hamısı',
      'Mobil',
      'Dizayn',
      'CS',
      'Biznes',
      'İncəsənət'
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text('Kateqoriyalar', style: AppTextStyles.titleLarge),
        ),
        SizedBox(
          height: 50,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final isSelected = index == 0;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text(categories[index]),
                  selected: isSelected,
                  onSelected: (val) {
                    if (val) HapticService.light();
                  },
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : AppColors.lightTextSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                  backgroundColor: Theme.of(context).cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(
                    color: isSelected
                        ? AppColors.primary
                        : Colors.grey.withValues(alpha: 0.2),
                  ),
                  showCheckmark: false,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
