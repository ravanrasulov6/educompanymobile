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
      final provider = context.read<CourseProvider>();
      provider.loadCourses();
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        provider.loadUserEnrollments(user.id);
      }
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
                      height: MediaQuery.of(context).size.height * 0.32 < 280 ? 280 : MediaQuery.of(context).size.height * 0.32, 
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(48),
                          bottomRight: Radius.circular(48),
                        ),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Background Image with Parallax-like scale
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(48),
                              bottomRight: Radius.circular(48),
                            ),
                            child: Image.asset(
                              'assets/images/esassehifefoto.png',
                              fit: BoxFit.cover,
                              color: Colors.black.withOpacity(0.4),
                              colorBlendMode: BlendMode.darken,
                            ),
                          ),
                          // Premium Gradient Overlay
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(48),
                                bottomRight: Radius.circular(48),
                              ),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withOpacity(0.2),
                                  Colors.black.withOpacity(0.8),
                                ],
                              ),
                            ),
                          ),
                          // Content
                          SafeArea(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
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
                        ],
                      ),
                    ),
                  ),
                ),

                // News, Achievements, Streak - Shaking/Hiding during search
                SliverToBoxAdapter(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, -0.1),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    ),
                    child: provider.searchQuery.isEmpty
                        ? Column(
                            key: const ValueKey('discovery_sections'),
                            children: [
                              const EntranceAnimation(
                                delay: Duration(milliseconds: 200),
                                child: NewsCarousel(),
                              ),
                              if (!context.read<AuthProvider>().isGuest) ...[
                                const EntranceAnimation(
                                  delay: Duration(milliseconds: 250),
                                  child: AchievementsSection(),
                                ),
                                const EntranceAnimation(
                                  delay: Duration(milliseconds: 300),
                                  child: StreakSection(streakDays: 7), // Using 7 to show the full color progression requested
                                ),
                              ],
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),
                ),

                // Popular Courses - Guest specific or discovery
                if (provider.searchQuery.isEmpty && (context.read<AuthProvider>().isGuest || provider.enrolledLiveCourses.isEmpty)) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Populyar Kurslar', style: AppTextStyles.headlineMedium.copyWith(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                              TextButton(
                                onPressed: () => context.push('/student/all-courses'),
                                style: TextButton.styleFrom(
                                  backgroundColor: AppColors.primary.withOpacity(0.1),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                ),
                                child: Text('Hamısı', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text('Sənin üçün ən yaxşı təhsil kontenti', style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey.withOpacity(0.7))),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 220,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: provider.popularCourses.length,
                        itemBuilder: (context, index) {
                          final course = provider.popularCourses[index];
                          return Container(
                            width: 300,
                            margin: const EdgeInsets.only(right: 16),
                            child: VideoLessonCard(
                              title: course.title,
                              instructor: course.instructor,
                              duration: course.isLive ? 'Canlı' : '${course.totalLessons} Dərs',
                              rating: course.rating.toString(),
                              level: 'Populyar',
                              thumbnailUrl: course.thumbnailUrl,
                              isLive: course.isLive,
                              onTap: () => context.push('/student/courses/${course.id}'),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],

                // Tab View simulation for Canlı dərslər
                if (provider.enrolledLiveCourses.isNotEmpty && provider.searchQuery.isEmpty) ...[
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
                          final liveCourses = provider.enrolledLiveCourses;
                          if (index >= liveCourses.length) return null;
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
                        childCount: provider.enrolledLiveCourses.length,
                      ),
                    ),
                  ),
                ],

                // Video Dərslər (Vertical)
                if (provider.enrolledVideoCourses.isNotEmpty && provider.searchQuery.isEmpty) ...[
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
                          final videoCourses = provider.enrolledVideoCourses;
                          if (index >= videoCourses.length) return null;
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
                        childCount: provider.enrolledVideoCourses.length,
                      ),
                    ),
                  ),
                ],

                // Result title
                if (provider.searchQuery.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 20),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Axtarış nəticələri',
                                style: AppTextStyles.headlineMedium.copyWith(fontSize: 26, fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Axtarışınıza uyğun ${provider.filteredCourses.length} kurs tapıldı',
                                style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.sort_rounded, color: Colors.white, size: 20),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Category Chips (Moved down or kept under header)
                if (provider.searchQuery.isEmpty)
                  SliverToBoxAdapter(
                    child: EntranceAnimation(
                      delay: const Duration(milliseconds: 100),
                      child: _buildCategoryChips(context),
                    ),
                  ),

                // All Courses section (for discovery or search results)
                if (provider.searchQuery.isNotEmpty || provider.selectedCategory != 'Hamısı' || context.read<AuthProvider>().isGuest) ...[
                  if (provider.filteredCourses.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: EntranceAnimation(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.05),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.search_off_rounded, size: 80, color: AppColors.primary.withOpacity(0.5)),
                            ),
                            const SizedBox(height: 32),
                            Text(
                              'Heç nə tapılmadı',
                              style: AppTextStyles.headlineMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 48),
                              child: Text(
                                'Axtardığınız meyarlara uyğun kurs tapılmadı. Başqa bir sözlə sınayın.',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey, height: 1.5),
                              ),
                            ),
                            const SizedBox(height: 32),
                            ElevatedButton(
                              onPressed: () {
                                provider.setSearchQuery('');
                                provider.setCategory('Hamısı');
                                _searchController.clear();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              child: const Text('Axtarışı təmizlə', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final allCourses = provider.filteredCourses;
                            if (index >= allCourses.length) return null;
                            final course = allCourses[index];
                            return EntranceAnimation(
                              delay: Duration(milliseconds: 50 * (index % 10)),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 20),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.05),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: VideoLessonCard(
                                  title: course.title,
                                  instructor: course.instructor,
                                  duration: course.isLive ? 'Canlı' : '${course.totalLessons} Dərs',
                                  rating: course.rating.toString(),
                                  level: provider.enrolledCourseIds.contains(course.id) ? 'Abunə' : 'Kəşf et',
                                  thumbnailUrl: course.thumbnailUrl,
                                  isLive: course.isLive,
                                  onTap: () => context.push(course.isLive 
                                    ? '/student/live-classes/${course.id}' 
                                    : '/student/courses/${course.id}'),
                                ),
                              ),
                            );
                          },
                          childCount: provider.filteredCourses.length,
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
                  color: Colors.white.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${user?.name ?? "Tələbə"} 🔥',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.headlineMedium.copyWith(
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.5,
                  fontSize: 28,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return _SearchBarWidget(
      controller: _searchController,
      onChanged: (val) => context.read<CourseProvider>().setSearchQuery(val),
    );
  }

  Widget _buildCategoryChips(BuildContext context) {
    final provider = context.watch<CourseProvider>();
    final categories = provider.categories;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text('Kateqoriyalar', style: AppTextStyles.titleLarge),
        ),
        SizedBox(
          height: 60,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              final isSelected = cat == provider.selectedCategory;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text(cat),
                  selected: cat == provider.selectedCategory,
                  onSelected: (val) {
                    if (val) {
                      HapticService.light();
                      provider.setCategory(cat);
                    }
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
                        : Colors.grey.withOpacity(0.2),
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

class _SearchBarWidget extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchBarWidget({
    required this.controller,
    required this.onChanged,
  });

  @override
  State<_SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<_SearchBarWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                  border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
                ),
                child: TextField(
                  controller: widget.controller,
                  onChanged: widget.onChanged,
                  style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    hintText: 'Öyrənməyə nə ilə başlayaq?',
                    hintStyle: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.black38,
                      fontWeight: FontWeight.w500,
                    ),
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary, size: 28),
                    suffixIcon: widget.controller.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, color: Colors.black54),
                            onPressed: () {
                              final provider = context.read<CourseProvider>();
                              widget.controller.clear();
                              provider.setCategory('Hamısı');
                              widget.onChanged('');
                              setState(() {}); // Local update for icon visibility
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
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
                AppColors.primary.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
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
}


