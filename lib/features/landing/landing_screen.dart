import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/premium_button.dart';
import '../../core/constants/app_constants.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

/// Premium landing screen with animated hero
class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _heroController;
  late AnimationController _buttonController;
  late AnimationController _floatController;

  late Animation<double> _logoFade;
  late Animation<Offset> _heroSlide;
  late Animation<double> _heroScale;
  late List<Animation<Offset>> _buttonSlides;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();

    // Logo fade-in
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _logoFade = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);

    // Hero entrance
    _heroController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _heroSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _heroController,
      curve: Curves.easeOutCubic,
    ));
    _heroScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _heroController, curve: Curves.easeOutCubic),
    );

    // Button stagger
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _buttonSlides = List.generate(3, (i) {
      return Tween<Offset>(
        begin: const Offset(0, 0.5),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _buttonController,
        curve: Interval(i * 0.2, 0.6 + i * 0.2, curve: Curves.easeOutCubic),
      ));
    });

    // Floating animation for hero (continuous)
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    // Start animations in sequence
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _heroController.forward();
    });
    Future.delayed(const Duration(milliseconds: 700), () {
      _buttonController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _heroController.dispose();
    _buttonController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark ? AppColors.darkHeroGradient : AppColors.heroGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 32),

                // ── Logo + App Name ────────────────────────────
                FadeTransition(
                  opacity: _logoFade,
                  child: Column(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.school_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        AppConstants.appName,
                        style: AppTextStyles.headlineLarge.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppConstants.appTagline,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── 3D Hero Animation ──────────────────────────
                Expanded(
                  child: SlideTransition(
                    position: _heroSlide,
                    child: ScaleTransition(
                      scale: _heroScale,
                      child: AnimatedBuilder(
                        animation: _floatAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _floatAnimation.value),
                            child: child,
                          );
                        },
                        child: _buildHeroIllustration(size, isDark),
                      ),
                    ),
                  ),
                ),

                // ── CTA Buttons ────────────────────────────────
                SlideTransition(
                  position: _buttonSlides[0],
                  child: FadeTransition(
                    opacity: _buttonController,
                    child: PremiumButton(
                      label: 'Premium Sign Up',
                      onPressed: () => context.go('/signup'),
                      isGradient: true,
                      icon: Icons.rocket_launch_rounded,
                      width: double.infinity,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                SlideTransition(
                  position: _buttonSlides[1],
                  child: FadeTransition(
                    opacity: _buttonController,
                    child: PremiumButton(
                      label: 'Log In',
                      onPressed: () => context.go('/login'),
                      isOutlined: true,
                      icon: Icons.login_rounded,
                      width: double.infinity,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                SlideTransition(
                  position: _buttonSlides[2],
                  child: FadeTransition(
                    opacity: _buttonController,
                    child: PremiumButton(
                      label: 'Continue as Guest',
                      onPressed: () {
                        context.read<AuthProvider>().continueAsGuest();
                      },
                      isText: true,
                      icon: Icons.explore_rounded,
                      width: double.infinity,
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build the hero illustration (fallback if no Rive asset)
  Widget _buildHeroIllustration(Size size, bool isDark) {
    return Center(
      child: SizedBox(
        width: size.width * 0.75,
        height: size.width * 0.75,
        child: CustomPaint(
          painter: _StudentHeroPainter(isDark: isDark),
        ),
      ),
    );
  }
}

/// Custom painter for an animated student illustration
class _StudentHeroPainter extends CustomPainter {
  final bool isDark;
  _StudentHeroPainter({this.isDark = false});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.35;

    // Background glow circle
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.primary.withValues(alpha: 0.15),
          AppColors.primary.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 1.5));
    canvas.drawCircle(center, radius * 1.5, glowPaint);

    // Main circle
    final circlePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.primary.withValues(alpha: 0.15),
          AppColors.primaryLight.withValues(alpha: 0.1),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, circlePaint);

    // Inner circle
    final innerPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.08);
    canvas.drawCircle(center, radius * 0.7, innerPaint);

    // Student icon (book + graduation cap) in center
    // Book
    final bookPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;
    final bookRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
          center: center + const Offset(0, 10),
          width: radius * 0.6,
          height: radius * 0.45),
      const Radius.circular(6),
    );
    canvas.drawRRect(bookRect, bookPaint);

    // Book pages
    final pagePaint = Paint()..color = Colors.white.withValues(alpha: 0.9);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: center + const Offset(0, 10),
            width: radius * 0.52,
            height: radius * 0.38),
        const Radius.circular(4),
      ),
      pagePaint,
    );

    // Lines on book
    final linePaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.3)
      ..strokeWidth = 2;
    for (var i = 0; i < 3; i++) {
      final y = center.dy + 2 + (i * 10);
      canvas.drawLine(
        Offset(center.dx - radius * 0.18, y),
        Offset(center.dx + radius * 0.18, y),
        linePaint,
      );
    }

    // Graduation cap
    final capPaint = Paint()..color = AppColors.primary;
    final capPath = Path();
    final capCenter = center - Offset(0, radius * 0.35);
    capPath.moveTo(capCenter.dx - radius * 0.35, capCenter.dy);
    capPath.lineTo(capCenter.dx, capCenter.dy - radius * 0.2);
    capPath.lineTo(capCenter.dx + radius * 0.35, capCenter.dy);
    capPath.lineTo(capCenter.dx, capCenter.dy + radius * 0.08);
    capPath.close();
    canvas.drawPath(capPath, capPaint);

    // Tassel
    final tasselPaint = Paint()
      ..color = AppColors.accent
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(capCenter.dx + radius * 0.35, capCenter.dy),
      Offset(capCenter.dx + radius * 0.4, capCenter.dy + radius * 0.2),
      tasselPaint,
    );
    canvas.drawCircle(
      Offset(capCenter.dx + radius * 0.4, capCenter.dy + radius * 0.22),
      4,
      Paint()..color = AppColors.accent,
    );

    // Floating particles
    final particlePaint = Paint()..color = AppColors.primaryLight.withValues(alpha: 0.4);
    final random = Random(42);
    for (var i = 0; i < 8; i++) {
      final angle = (i / 8) * 2 * pi;
      final dist = radius * (1.1 + random.nextDouble() * 0.4);
      final pCenter = center + Offset(cos(angle) * dist, sin(angle) * dist);
      canvas.drawCircle(pCenter, 3 + random.nextDouble() * 4, particlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
