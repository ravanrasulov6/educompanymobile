import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/course_model.dart';
import '../../providers/teacher_course_provider.dart';

/// Teacher courses management screen — dynamic Supabase data
class TeacherCoursesScreen extends StatefulWidget {
  const TeacherCoursesScreen({super.key});

  @override
  State<TeacherCoursesScreen> createState() => _TeacherCoursesScreenState();
}

class _TeacherCoursesScreenState extends State<TeacherCoursesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TeacherCourseProvider>(context, listen: false)
          .loadTeacherCourses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TeacherCourseProvider>(
      builder: (_, provider, __) {
        return Column(
          children: [
            // Stats row
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _buildStatCard(
                    '${provider.teacherCourses.length}',
                    'Kurslar',
                    Icons.book_rounded,
                    AppColors.primary,
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    '${provider.teacherCourses.where((c) => c.status == "published").length}',
                    'Dərc olunmuş',
                    Icons.public_rounded,
                    AppColors.success,
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    '${provider.teacherCourses.where((c) => c.status == "draft").length}',
                    'Qaralama',
                    Icons.edit_note_rounded,
                    AppColors.warning,
                  ),
                ],
              ),
            ),

            // Action buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.add_circle_outline,
                      label: 'Yeni Kurs',
                      color: AppColors.primary,
                      onTap: () => context.push('/teacher/create-course'),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            const Divider(height: 1),

            // Courses list
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : provider.teacherCourses.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.school_outlined,
                                  size: 64,
                                  color: AppColors.textSecondary
                                      .withValues(alpha: 0.3)),
                              const SizedBox(height: 16),
                              Text('Hələ kurs yoxdur',
                                  style: AppTextStyles.headlineSmall),
                              const SizedBox(height: 8),
                              Text('İlk kursunuzu yaradın!',
                                  style: AppTextStyles.bodySmall),
                              const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildActionButton(
                              icon: Icons.assignment_turned_in,
                              label: 'Tapşırıq Yoxla',
                              color: AppColors.success,
                              onTap: () => context.push('/teacher/grade-assignments'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildActionButton(
                              icon: Icons.question_answer_rounded,
                              label: 'FAQ İdarəetmə',
                              color: AppColors.warning,
                              onTap: () => context.push('/teacher/courses/${provider.teacherCourses.isNotEmpty? provider.teacherCourses.first.id : "new"}/faqs'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                              FilledButton.icon(
                                onPressed: () =>
                                    context.push('/teacher/create-course'),
                                icon: const Icon(Icons.add),
                                label: const Text('Kurs Yarat'),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: provider.loadTeacherCourses,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: provider.teacherCourses.length,
                            itemBuilder: (_, i) =>
                                _buildCourseCard(provider.teacherCourses[i]),
                          ),
                        ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
      String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(value,
                style: AppTextStyles.headlineSmall.copyWith(color: color)),
            Text(label, style: AppTextStyles.labelSmall),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15)),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseCard(CourseModel course) {
    final statusColor = course.status == 'published'
        ? AppColors.success
        : course.status == 'archived'
            ? AppColors.textSecondary
            : AppColors.warning;
    final statusText = course.status == 'published'
        ? 'Dərc olunmuş'
        : course.status == 'archived'
            ? 'Arxiv'
            : 'Qaralama';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Thumbnail placeholder
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  AppColors.primary.withValues(alpha: 0.2),
                  AppColors.secondary.withValues(alpha: 0.2),
                ]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.play_lesson_rounded,
                  color: AppColors.primary, size: 28),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(course.title,
                      style: AppTextStyles.titleSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(statusText,
                            style: TextStyle(
                                color: statusColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        course.isFree ? 'Pulsuz' : '₼${course.price?.toStringAsFixed(2) ?? "0.00"}',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: course.isFree
                              ? AppColors.success
                              : AppColors.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${course.sections.length} bölmə • ${course.totalLessons} dərs',
                    style: AppTextStyles.labelSmall,
                  ),
                ],
              ),
            ),

            // Popup menu
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded, size: 20),
              onSelected: (value) {
                switch (value) {
                  case 'lessons':
                    context.push('/teacher/courses/${course.id}/lessons');
                    break;
                  case 'resources':
                    context.push('/teacher/courses/${course.id}/resources');
                    break;
                  case 'faqs':
                    context.push('/teacher/courses/${course.id}/faqs');
                    break;
                  case 'publish':
                    Provider.of<TeacherCourseProvider>(context, listen: false)
                        .publishCourse(course.id);
                    break;
                  case 'delete':
                    _confirmDelete(course);
                    break;
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'lessons',
                  child: ListTile(
                    leading: Icon(Icons.video_library_outlined, size: 20),
                    title: Text('Dərsləri idarə et'),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'resources',
                  child: ListTile(
                    leading: Icon(Icons.folder_outlined, size: 20),
                    title: Text('Resurslar'),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'faqs',
                  child: ListTile(
                    leading: Icon(Icons.quiz_outlined, size: 20),
                    title: Text('FAQ-lar'),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                if (course.status != 'published')
                  const PopupMenuItem(
                    value: 'publish',
                    child: ListTile(
                      leading:
                          Icon(Icons.publish_rounded, size: 20, color: AppColors.success),
                      title: Text('Dərc et', style: TextStyle(color: AppColors.success)),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete_outline, size: 20, color: AppColors.error),
                    title: Text('Sil', style: TextStyle(color: AppColors.error)),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(CourseModel course) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Kursu silmək istəyirsiniz?'),
        content: Text('\"${course.title}\" kursu silinəcək. Bu əməliyyat geri qaytarıla bilməz.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Ləğv et'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              Provider.of<TeacherCourseProvider>(context, listen: false)
                  .deleteCourse(course.id);
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }
}
