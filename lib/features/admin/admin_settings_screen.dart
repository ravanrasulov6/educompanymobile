import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_strings.dart';

/// Admin settings screen
class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(AppStrings.appSettings, style: AppTextStyles.headlineMedium),
        const SizedBox(height: 16),

        _SettingsTile(
          icon: Icons.dark_mode_rounded,
          title: AppStrings.darkMode,
          subtitle: AppStrings.darkLightModeSub,
          trailing: Switch(
            value: theme.isDarkMode,
            onChanged: (_) => theme.toggleTheme(),
          ),
        ),
        _SettingsTile(
          icon: Icons.notifications_active_rounded,
          title: AppStrings.notifications,
          subtitle: AppStrings.notificationsSub,
          trailing: Switch(value: true, onChanged: (_) {}),
        ),
        _SettingsTile(
          icon: Icons.translate_rounded,
          title: AppStrings.appLanguage,
          subtitle: AppStrings.azLang,
          trailing: const Icon(Icons.chevron_right_rounded),
        ),
        const Divider(height: 32),

        Text(AppStrings.platform, style: AppTextStyles.headlineSmall),
        const SizedBox(height: 12),
        _SettingsTile(
          icon: Icons.payments_rounded,
          title: AppStrings.paymentSystem,
          subtitle: AppStrings.stripeConnected,
          trailing: const Icon(Icons.chevron_right_rounded),
        ),
        _SettingsTile(
          icon: Icons.contact_mail_rounded,
          title: AppStrings.emailSettings,
          subtitle: AppStrings.smtpConfig,
          trailing: const Icon(Icons.chevron_right_rounded),
        ),
        _SettingsTile(
          icon: Icons.cloud_done_rounded,
          title: AppStrings.storage,
          subtitle: AppStrings.storageUsed
              .replaceFirst('%s', '24.5')
              .replaceFirst('%s', '100'),
          trailing: const Icon(Icons.chevron_right_rounded),
        ),
        const Divider(height: 32),

        Text(AppStrings.about, style: AppTextStyles.headlineSmall),
        const SizedBox(height: 12),
        _SettingsTile(
          icon: Icons.verified_rounded,
          title: AppStrings.appVersion,
          subtitle: '1.0.0 (Build 1)',
        ),
        _SettingsTile(
          icon: Icons.gavel_rounded,
          title: AppStrings.licenses,
          subtitle: AppStrings.openSourceLicenses,
          trailing: const Icon(Icons.chevron_right_rounded),
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
