import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/premium_button.dart';
import '../../core/constants/app_strings.dart';

/// Sign up screen
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  UserRole _selectedRole = UserRole.student;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthProvider>().signUp(
            name: _nameController.text,
            email: _emailController.text,
            password: _passwordController.text,
            role: _selectedRole,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.go('/'),
        ),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),

                    Text('Hesab Yaradın', style: AppTextStyles.displayMedium),
                    const SizedBox(height: 8),
                    Text(
                      'Təhsil yolculuğunuza bugün başlayın',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Name
                    Text(AppStrings.name, style: AppTextStyles.labelLarge),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        hintText: 'Adınız və Soyadınız',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Ad tələb olunur' : null,
                    ),
                    const SizedBox(height: 20),

                    // Email
                    Text(AppStrings.email, style: AppTextStyles.labelLarge),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: 'nümunə@edu.com',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'E-poçt tələb olunur';
                        if (!v.contains('@')) return 'E-poçt formatı düzgün deyil';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Password
                    Text(AppStrings.password, style: AppTextStyles.labelLarge),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: 'Şifrə yaradın',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined),
                          onPressed: () =>
                              setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Şifrə tələb olunur';
                        if (v.length < 6) return 'Minimum 6 simvol';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Role selection
                    Text('Mən bir ...', style: AppTextStyles.labelLarge),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _RoleChip(
                          label: 'Tələbəyəm',
                          icon: Icons.school_outlined,
                          isSelected: _selectedRole == UserRole.student,
                          onTap: () =>
                              setState(() => _selectedRole = UserRole.student),
                        ),
                        const SizedBox(width: 12),
                        _RoleChip(
                          label: 'Müəlliməm',
                          icon: Icons.cast_for_education_outlined,
                          isSelected: _selectedRole == UserRole.teacher,
                          onTap: () =>
                              setState(() => _selectedRole = UserRole.teacher),
                        ),
                      ],
                    ),

                    // Error
                    if (auth.error != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline,
                                color: AppColors.error, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(auth.error!,
                                  style: AppTextStyles.bodySmall
                                      .copyWith(color: AppColors.error)),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 28),

                    PremiumButton(
                      label: AppStrings.signUp,
                      onPressed: _submit,
                      isGradient: true,
                      isLoading: auth.status == AuthStatus.loading,
                      icon: Icons.rocket_launch_rounded,
                      width: double.infinity,
                    ),

                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Artıq hesabınız var? ',
                            style: AppTextStyles.bodyMedium),
                        GestureDetector(
                          onTap: () => context.go('/login'),
                          child: Text(AppStrings.login,
                              style: AppTextStyles.titleMedium
                                  .copyWith(color: AppColors.primary)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.1)
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : Theme.of(context).dividerColor,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon,
                  color: isSelected
                      ? AppColors.primary
                      : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
              const SizedBox(height: 6),
              Text(
                label,
                style: AppTextStyles.titleMedium.copyWith(
                  color: isSelected
                      ? AppColors.primary
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
