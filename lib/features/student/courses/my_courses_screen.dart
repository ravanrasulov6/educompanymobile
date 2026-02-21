import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/course_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/entrance_animation.dart';
import '../../../core/widgets/premium_kit.dart';

class MyCoursesScreen extends StatefulWidget {
  const MyCoursesScreen({super.key});

  @override
  State<MyCoursesScreen> createState() => _MyCoursesScreenState();
}

class _MyCoursesScreenState extends State<MyCoursesScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'Hamısı';
  final List<String> _categories = ['Hamısı', 'Riyaziyyat', 'Xarici dil', 'Proqramlaşdırma', 'Dizayn'];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CourseProvider>();
    
    final filteredCourses = provider.enrolledVideoCourses.where((c) {
      final matchesSearch = c.title.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'Hamısı' || (c.category ?? '').contains(_selectedCategory);
      return matchesSearch && matchesCategory;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // HTML background-light
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. Sticky Header with Search
          SliverAppBar(
            expandedHeight: 200,
            collapsedHeight: 120,
            pinned: true,
            floating: true,
            backgroundColor: const Color(0xFFF8F9FA).withValues(alpha: 0.8),
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: FlexibleSpaceBar(
                  background: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 60, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Dərslərim',
                              style: AppTextStyles.headlineMedium.copyWith(
                                color: const Color(0xFF0F172A), // Slate-900
                                fontWeight: FontWeight.bold,
                                fontSize: 32,
                              ),
                            ),
                            Stack(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(Icons.notifications_none_rounded, color: Color(0xFF475569), size: 24),
                                ),
                                Positioned(
                                  right: 8,
                                  top: 8,
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: const Color(0xFFF8F9FA), width: 2),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Search Bar
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: TextField(
                            onChanged: (val) => setState(() => _searchQuery = val),
                            style: const TextStyle(color: Color(0xFF0F172A), fontSize: 14),
                            decoration: InputDecoration(
                              hintText: 'Kurs axtar...',
                              hintStyle: TextStyle(color: const Color(0xFF0F172A).withValues(alpha: 0.3)),
                              prefixIcon: Icon(Icons.search_rounded, color: const Color(0xFF0F172A).withValues(alpha: 0.4)),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 2. Categories Section
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
                  child: Text(
                    'KATEQORİYALAR',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: const Color(0xFF475569), // Slate-600
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                SizedBox(
                  height: 44,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = _selectedCategory == category;
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: InkWell(
                          onTap: () => setState(() => _selectedCategory = category),
                          borderRadius: BorderRadius.circular(25),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: isSelected ? [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ] : [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                )
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              category,
                              style: TextStyle(
                                color: isSelected ? Colors.white : const Color(0xFF475569),
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),

          // 3. Course List (Vertical Cards)
          if (filteredCourses.isEmpty)
            _buildEmptyState(context)
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final course = filteredCourses[index];
                    return EntranceAnimation(
                      delay: Duration(milliseconds: 100 * index),
                      child: _VerticalCourseCard(course: course),
                    );
                  },
                  childCount: filteredCourses.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Icon(Icons.school_outlined, size: 64, color: AppColors.primary.withValues(alpha: 0.6)),
            ),
            const SizedBox(height: 24),
            Text('Kurs tapılmadı', style: AppTextStyles.headlineSmall.copyWith(color: const Color(0xFF0F172A), fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text('Axtarış meyarlarını dəyişərək yenidən yoxlayın', 
              style: AppTextStyles.bodyMedium.copyWith(color: const Color(0xFF475569)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _VerticalCourseCard extends StatelessWidget {
  final dynamic course;
  const _VerticalCourseCard({required this.course});

  @override
  Widget build(BuildContext context) {
    final progress = course.calculatedProgress;
    final totalLessons = course.sections.fold(0, (sum, sec) => sum + (sec.lessons?.length ?? 0)) as int;
    final completedLessons = (totalLessons * progress).toInt();

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white, // Card background
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)), // Slate-200
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: SizedBox(
                  height: 180,
                  width: double.infinity,
                  child: course.thumbnailUrl != null && course.thumbnailUrl.isNotEmpty
                      ? Image.network(course.thumbnailUrl, fit: BoxFit.cover)
                      : Container(
                          color: const Color(0xFFF1F5F9), // Slate-100
                          child: Icon(Icons.image_outlined, color: const Color(0xFF94A3B8), size: 48),
                        ),
                ),
              ),
              // Difficulty Tag
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: const Text(
                    'ORTA SƏVİYYƏ',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          // Info Section
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.title,
                  style: AppTextStyles.titleLarge.copyWith(
                    color: const Color(0xFF0F172A),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.person_outline_rounded, size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Pərviz Məmmədov tərəfindən',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: const Color(0xFF64748B), // Slate-500
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Progress Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${(progress * 100).toInt()}% tamamlanıb',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$completedLessons/$totalLessons Dərs',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: const Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: const Color(0xFFF1F5F9),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Action Button
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ).copyWith(
                      backgroundColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.pressed)) return AppColors.primary;
                        if (states.contains(WidgetState.hovered)) return AppColors.primary.withValues(alpha: 0.2);
                        return AppColors.primary.withValues(alpha: 0.1);
                      }),
                      foregroundColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.pressed)) return Colors.white;
                        return AppColors.primary;
                      }),
                    ),
                    child: const Text(
                      'Davam et',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
