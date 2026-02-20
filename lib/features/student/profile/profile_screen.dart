import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/student/courses');
            }
          },
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.settings_rounded),
              onPressed: () {},
              color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Image and Edit Badge
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDarkMode ? Colors.grey[800]! : Colors.white,
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuBlC-hOet5L8vWESFBceUvZPlzCh9nsPvzhlGpVVgYVX1pnB-D8fD04JdOSxUf7XeaMtcCWx3-nH-qsxEA2kTEMZAteZpGI78lNRkvsh8JShl1jtu2sR5q-cqGzwQi685AkOdw8iTlB0pfMp8GCdTLTPiWuONQSbFwiSRoN5aq1Kwl9HJR7k0venOWcuDwcnHd6AINVuZ8wWQ_T8hERGKcTZbx7ELrJMD-fW7seQRFOmUe7bI3izkNp8rBOtogtpokgonhHWlDaTh4',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDarkMode ? Colors.black : Colors.white,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.edit_rounded, color: Colors.white, size: 16),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Name and Role
              Text(
                user?.name ?? 'Anar Məmmədov',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified_rounded, color: AppColors.primary, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'PREMİUM TƏLƏBƏ',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                user?.email ?? 'anar.mammadov@example.az',
                style: TextStyle(
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Quick Stats
              Row(
                children: [
                  _buildStatCard(context, '14', 'Təlim', isDarkMode),
                  const SizedBox(width: 12),
                  _buildStatCard(context, '6', 'Sertifikat', isDarkMode, valueColor: AppColors.primary),
                  const SizedBox(width: 12),
                  _buildStatCard(context, '52', 'Saat', isDarkMode),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Təhsil fəaliyyəti Group
              _buildSectionTitle('Təhsil fəaliyyəti'),
              Container(
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[900] : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
                  ),
                ),
                child: Column(
                  children: [
                    _buildSettingsItem(
                      context: context,
                      icon: Icons.menu_book_rounded,
                      iconColor: AppColors.primary,
                      iconBgColor: AppColors.primary.withOpacity(0.1),
                      title: 'Alınmış təlimlər',
                      isDarkMode: isDarkMode,
                      onTap: () => context.push('/student/courses'),
                    ),
                    Divider(height: 1, color: isDarkMode ? Colors.grey[800] : Colors.grey[200], indent: 64),
                    _buildSettingsItem(
                      context: context,
                      icon: Icons.workspace_premium_rounded,
                      iconColor: Colors.amber[600]!,
                      iconBgColor: Colors.amber[100]!,
                      title: 'Sertifikatlar',
                      isDarkMode: isDarkMode,
                      onTap: () => context.push('/student/profile/certificates'),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Hesab və Ödəniş Group
              _buildSectionTitle('Hesab və Ödəniş'),
              Container(
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[900] : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
                  ),
                ),
                child: Column(
                  children: [
                    _buildSettingsItem(
                      context: context,
                      icon: Icons.receipt_long_rounded,
                      iconColor: Colors.teal[600]!,
                      iconBgColor: Colors.teal[100]!,
                      title: 'Ödəniş sistemi və Kartlar',
                      isDarkMode: isDarkMode,
                      onTap: () => context.push('/student/profile/payment'),
                    ),
                    Divider(height: 1, color: isDarkMode ? Colors.grey[800] : Colors.grey[200], indent: 64),
                    _buildSettingsItem(
                      context: context,
                      icon: Icons.notifications_active_rounded,
                      iconColor: Colors.indigo[600]!,
                      iconBgColor: Colors.indigo[100]!,
                      title: 'Bildiriş tənzimləmələri',
                      isDarkMode: isDarkMode,
                      onTap: () => context.push('/student/profile/notifications'),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Danger Zone
              InkWell(
                onTap: () {
                  context.read<AuthProvider>().logout();
                  context.go('/');
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.logout_rounded,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Çıxış et',
                        style: TextStyle(
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Footer info
              Text(
                'Versiya 2.4.0 (Premium)',
                style: TextStyle(
                  color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Yardım mərkəzi', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text('•', style: TextStyle(color: Colors.grey[400])),
                  ),
                  Text('Məxfilik siyasəti', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String value, String label, bool isDarkMode, {Color? valueColor}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[900]?.withOpacity(0.5) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
          ),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: valueColor ?? (isDarkMode ? Colors.white : Colors.black),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required bool isDarkMode,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}
