import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/premium_button.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_constants.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

/// Premium landing screen redesign with cinematic feel and Azerbaijani localization
class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();
    _mainController = AnimationController(
      vsync: this,
      duration: AppConstants.animSlow,
    );

    _contentFade = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    );

    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));

    _mainController.forward();
  }

  @override
  void dispose() {
    _mainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // ── Cinematic Background ───────────────────────────
          _buildBackground(size, isDark),

          // ── Main Content ──────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  const SizedBox(height: 48),
                  
                  // Brand Header
                  _buildHeader(context),

                  const Spacer(),

                  // Hero Asset (Penguin GIF)
                  _buildHeroAsset(size),

                  const Spacer(),

                  // Action Buttons
                  FadeTransition(
                    opacity: _contentFade,
                    child: SlideTransition(
                      position: _contentSlide,
                      child: Column(
                        children: [
                          PremiumButton(
                            label: AppStrings.signUp,
                            onPressed: () => context.go('/signup'),
                            isGradient: true,
                            icon: Icons.stars_rounded,
                            width: double.infinity,
                          ),
                          const SizedBox(height: 16),
                          PremiumButton(
                            label: AppStrings.login,
                            onPressed: () => context.go('/login'),
                            isOutlined: true,
                            width: double.infinity,
                          ),
                          const SizedBox(height: 12),
                          PremiumButton(
                            label: AppStrings.continueAsGuest,
                            onPressed: () {
                              context.read<AuthProvider>().continueAsGuest();
                            },
                            isText: true,
                            icon: Icons.chevron_right_rounded,
                            width: double.infinity,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          
          // Decorative Elements
          _buildDecorativeElements(size),
        ],
      ),
    );
  }

  Widget _buildBackground(Size size, bool isDark) {
    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF121121) : const Color(0xFFF6F6F8),
      ),
      child: Stack(
        children: [
          // Subtle texture or placeholder for cinematic feel
          Opacity(
            opacity: 0.1,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage('https://images.unsplash.com/photo-1523050854058-8df90110c9f1?q=80&w=2070&auto=format&fit=crop'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  (isDark ? const Color(0xFF121121) : const Color(0xFFF6F6F8)).withValues(alpha: 0.8),
                  (isDark ? const Color(0xFF121121) : const Color(0xFFF6F6F8)).withValues(alpha: 0.2),
                  (isDark ? const Color(0xFF121121) : const Color(0xFFF6F6F8)).withValues(alpha: 1.0),
                ],
                stops: const [0.0, 0.4, 1.0],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return FadeTransition(
      opacity: _contentFade,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.child_care_rounded,
                  color: AppColors.primary,
                  size: 32,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                AppStrings.appName,
                style: AppTextStyles.headlineMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.appTagline,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroAsset(Size size) {
    return Container(
      width: size.width * 0.7,
      height: size.width * 0.7,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 40,
            spreadRadius: 10,
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/penguin.gif',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.error_outline, size: 64);
          },
        ),
      ),
    );
  }

  Widget _buildDecorativeElements(Size size) {
    return Positioned(
      top: size.height * 0.15,
      right: -20,
      child: Opacity(
        opacity: 0.1,
        child: Transform.rotate(
          angle: 0.2,
          child: const Icon(
            Icons.auto_awesome_rounded,
            size: 140,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
