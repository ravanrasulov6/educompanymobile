import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/premium_button.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_strings.dart';

/// Login screen
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthProvider>().login(
            _emailController.text,
            _passwordController.text,
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

                    // Header
                    Text(AppStrings.welcome, style: AppTextStyles.displayMedium),
                    const SizedBox(height: 8),
                    Text(
                      AppStrings.loginSubtitle,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Email
                    Text(AppStrings.email, style: AppTextStyles.labelLarge),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: AppStrings.emailHint,
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return AppStrings.emailRequired;
                        if (!v.contains('@')) return AppStrings.emailInvalid;
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
                        hintText: AppStrings.passwordHint,
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return AppStrings.passwordRequired;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // Forgot password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: const Text(AppStrings.forgotPassword),
                      ),
                    ),

                    // Error message
                    if (auth.error != null) ...[
                      const SizedBox(height: 8),
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
                              child: Text(
                                auth.error!,
                                style: AppTextStyles.bodySmall
                                    .copyWith(color: AppColors.error),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Login button
                    PremiumButton(
                      label: AppStrings.login,
                      onPressed: _submit,
                      isGradient: true,
                      isLoading: auth.status == AuthStatus.loading,
                      width: double.infinity,
                    ),
                    const SizedBox(height: 20),

                    // Demo accounts hint
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.info.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.info.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.info_outline,
                                  color: AppColors.info, size: 18),
                              const SizedBox(width: 8),
                              Text(AppStrings.demoAccounts,
                                  style: AppTextStyles.titleMedium
                                      .copyWith(color: AppColors.info)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '• ${AppStrings.student}: ${AppConstants.demoStudentEmail}\n'
                            '• ${AppStrings.teacherRole}: ${AppConstants.demoTeacherEmail}\n'
                            '• ${AppStrings.admin}: ${AppConstants.demoAdminEmail}\n'
                            '• ${AppStrings.password}: ${AppConstants.demoPassword}',
                            style: AppTextStyles.bodySmall.copyWith(
                              height: 1.8,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Sign up link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppStrings.dontHaveAccount,
                          style: AppTextStyles.bodyMedium,
                        ),
                        GestureDetector(
                          onTap: () => context.go('/signup'),
                          child: Text(
                            AppStrings.signUp,
                            style: AppTextStyles.titleMedium
                                .copyWith(color: AppColors.primary),
                          ),
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
