import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/stat_card.dart';
import '../../models/course_model.dart';
import '../../core/constants/app_strings.dart';

/// Teacher course management screen
class TeacherCoursesScreen extends StatelessWidget {
  const TeacherCoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Stats row
        Row(
          children: const [
            Expanded(
              child: StatCard(
                title: 'Ümumi dərslər',
                value: '5',
                icon: Icons.menu_book,
                color: AppColors.primary,
                trend: 12.5,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: StatCard(
                title: 'Ümumi tələbələr',
                value: '4.2K',
                icon: Icons.people,
                color: AppColors.secondary,
                trend: 8.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Actions
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Yeni dərs'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.upload, size: 18),
                label: const Text('Dərs yüklə'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.videocam, size: 18),
            label: const Text('Canlı dərs planla'),
          ),
        ),
        const SizedBox(height: 24),

        Text('Mənim dərslərim', style: AppTextStyles.headlineSmall),
        const SizedBox(height: 12),

        // Course list
        ...CourseModel.demoCourses.map((course) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.menu_book,
                      color: Colors.white, size: 24),
                ),
                title: Text(course.title,
                    style: AppTextStyles.titleLarge, maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                subtitle: Text(
                  '${course.studentsCount} tələbə • ${course.rating} ★',
                  style: AppTextStyles.bodySmall,
                ),
                trailing: PopupMenuButton(
                  icon: const Icon(Icons.more_vert),
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                        value: 'edit', child: Text('Dərsi redaktə et')),
                    const PopupMenuItem(
                        value: 'lessons', child: Text('Dərsləri idarə et')),
                    const PopupMenuItem(
                        value: 'students', child: Text('Tələbələrə bax')),
                  ],
                ),
              ),
            )),
      ],
    );
  }
}
