import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/course_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/premium_button.dart';
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
      body: CustomScrollView(
        slivers: [
          // Hero header
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: const Center(
                  child: Icon(Icons.play_circle_fill,
                      color: Colors.white54, size: 64),
                ),
              ),
              title: Text(
                course.title,
                style: AppTextStyles.titleLarge.copyWith(color: Colors.white),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
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
                      Text('${course.studentsCount} tələbə',
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
                        color: AppColors.primary.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${(course.progress * 100).round()}% Tamamlanıb',
                                    style: AppTextStyles.titleLarge),
                                const SizedBox(height: 4),
                                Text(
                                    '${course.completedLessons}/${course.totalLessons} dərs',
                                    style: AppTextStyles.bodySmall),
                              ],
                            ),
                          ),
                          PremiumButton(
                            label: 'Davam et',
                            onPressed: () {},
                            icon: Icons.play_arrow,
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 24),
                  Text('Kurikulum', style: AppTextStyles.headlineMedium),
                  const SizedBox(height: 8),

                  // Notes feature button
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.note_add_outlined, size: 18),
                    label: const Text('Qeydlərim'),
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

          const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
        ],
      ),
    );
  }
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
          title: Text(section.title, style: AppTextStyles.titleLarge),
          subtitle: Text(
            '${section.lessons.length} dərs',
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
              onTap: () {},
            );
          }).toList(),
        ),
      ),
    );
  }
}
