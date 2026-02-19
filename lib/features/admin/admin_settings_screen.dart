import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Admin settings screen
class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Tətbiq Parametrləri', style: AppTextStyles.headlineMedium),
        const SizedBox(height: 16),

        _SettingsTile(
          icon: Icons.dark_mode,
          title: 'Qaranlıq Rejim',
          subtitle: 'Qaranlıq/İşıqlı mövzu',
          trailing: Switch(
            value: theme.isDarkMode,
            onChanged: (_) => theme.toggleTheme(),
          ),
        ),
        _SettingsTile(
          icon: Icons.notifications,
          title: 'Bildirişlər',
          subtitle: 'Bildirişləri aktivləşdir',
          trailing: Switch(value: true, onChanged: (_) {}),
        ),
        _SettingsTile(
          icon: Icons.language,
          title: 'Dil',
          subtitle: 'Azərbaycan dili',
          trailing: const Icon(Icons.chevron_right),
        ),
        const Divider(height: 32),

        Text('Platforma', style: AppTextStyles.headlineSmall),
        const SizedBox(height: 12),
        _SettingsTile(
          icon: Icons.payment,
          title: 'Ödəniş Sistemi',
          subtitle: 'Stripe qoşulub',
          trailing: const Icon(Icons.chevron_right),
        ),
        _SettingsTile(
          icon: Icons.email,
          title: 'E-poçt Parametrləri',
          subtitle: 'SMTP konfiqurasiyası',
          trailing: const Icon(Icons.chevron_right),
        ),
        _SettingsTile(
          icon: Icons.storage,
          title: 'Depolama',
          subtitle: '24.5 GB / 100 GB istifadə olunub',
          trailing: const Icon(Icons.chevron_right),
        ),
        const Divider(height: 32),

        Text('Haqqında', style: AppTextStyles.headlineSmall),
        const SizedBox(height: 12),
        _SettingsTile(
          icon: Icons.info_outline,
          title: 'Tətbiq Versiyası',
          subtitle: '1.0.0 (Build 1)',
        ),
        _SettingsTile(
          icon: Icons.code,
          title: 'Lisenziyalar',
          subtitle: 'Açıq mənbə lisenziyaları',
          trailing: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
        title: Text(title, style: AppTextStyles.titleMedium),
        subtitle: Text(subtitle, style: AppTextStyles.bodySmall),
        trailing: trailing,
      ),
    );
  }
}
