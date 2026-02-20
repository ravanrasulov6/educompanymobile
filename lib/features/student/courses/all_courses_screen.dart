import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/course_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/video_lesson_card.dart';
import '../../../core/widgets/entrance_animation.dart';

class AllCoursesScreen extends StatefulWidget {
  const AllCoursesScreen({super.key});

  @override
  State<AllCoursesScreen> createState() => _AllCoursesScreenState();
}

class _AllCoursesScreenState extends State<AllCoursesScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<CourseProvider>(
        builder: (context, provider, _) {
          final courses = provider.filteredCourses;

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(context, provider),
              if (courses.isEmpty)
                _buildEmptyState()
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final course = courses[index];
                        return EntranceAnimation(
                          delay: Duration(milliseconds: 50 * (index % 10)),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            child: VideoLessonCard(
                              title: course.title,
                              instructor: course.instructor,
                              duration: course.isLive ? 'Canlı' : '${course.totalLessons} Dərs',
                              rating: course.rating.toString(),
                              level: provider.enrolledCourseIds.contains(course.id) ? 'Abunə' : (course.price == 0 ? 'Pulsuz' : '${course.price} AZN'),
                              thumbnailUrl: course.thumbnailUrl,
                              isLive: course.isLive,
                              onTap: () => context.push(course.isLive 
                                ? '/student/live-classes/${course.id}' 
                                : '/student/courses/${course.id}'),
                            ),
                          ),
                        );
                      },
                      childCount: courses.length,
                    ),
                  ),
                ),
              const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, CourseProvider provider) {
    return SliverAppBar(
      expandedHeight: 140,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
        onPressed: () => context.pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Bütün Kurslar',
          style: AppTextStyles.headlineSmall.copyWith(
            color: Colors.black87,
            fontWeight: FontWeight.w900,
          ),
        ),
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 56, bottom: 60),
        background: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: _buildSearchBar(provider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(CourseProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => provider.setSearchQuery(val),
        decoration: InputDecoration(
          hintText: 'Kurs axtarın...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: () {
                    _searchController.clear();
                    provider.setSearchQuery('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SliverFillRemaining(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 80, color: Colors.grey.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            'Kurs tapılmadı',
            style: AppTextStyles.titleLarge.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
