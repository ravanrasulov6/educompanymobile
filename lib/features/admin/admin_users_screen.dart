import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/user_model.dart';

/// Admin user management screen
class AdminUsersScreen extends StatelessWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search & filter bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search users...',
                    prefixIcon: const Icon(Icons.search),
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                      color: Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: PopupMenuButton<String>(
                  icon: const Icon(Icons.filter_list),
                  onSelected: (_) {},
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'all', child: Text('All Users')),
                    PopupMenuItem(value: 'student', child: Text('Students')),
                    PopupMenuItem(value: 'teacher', child: Text('Teachers')),
                    PopupMenuItem(value: 'admin', child: Text('Admins')),
                  ],
                ),
              ),
            ],
          ),
        ),

        // User list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: UserModel.demoUsers.length,
            itemBuilder: (context, index) {
              final user = UserModel.demoUsers[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _roleColor(user.role).withValues(alpha: 0.1),
                    child: Text(
                      user.name[0],
                      style: TextStyle(
                        color: _roleColor(user.role),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  title: Text(user.name, style: AppTextStyles.titleMedium),
                  subtitle: Text(user.email, style: AppTextStyles.bodySmall),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _roleColor(user.role).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      user.role.name.toUpperCase(),
                      style: AppTextStyles.labelSmall
                          .copyWith(color: _roleColor(user.role)),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Color _roleColor(UserRole role) {
    switch (role) {
      case UserRole.student:
        return AppColors.primary;
      case UserRole.teacher:
        return AppColors.secondary;
      case UserRole.admin:
        return AppColors.error;
      case UserRole.guest:
        return AppColors.lightTextHint;
    }
  }
}
