import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/entrance_animation.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark 
              ? [const Color(0xFF0F172A), const Color(0xFF020617)] 
              : [Colors.white, const Color(0xFFF1F5F9)],
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                EntranceAnimation(
                  type: EntranceAnimationType.scale,
                  duration: const Duration(milliseconds: 1000),
                  child: Image.asset(
                    'assets/images/logo_m.png',
                    width: 200,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 60),
                // Modern Loader
                const _ModernLoader(),
              ],
            ),
            
            // Bottom Indicator
            Positioned(
              bottom: 40,
              child: EntranceAnimation(
                delay: const Duration(milliseconds: 500),
                child: Text(
                  'EDUCOMPANY • PREMIUM TƏHSİL',
                  style: TextStyle(
                    color: (isDark ? Colors.white : Colors.black).withOpacity(0.3),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModernLoader extends StatefulWidget {
  const _ModernLoader();

  @override
  State<_ModernLoader> createState() => _ModernLoaderState();
}

class _ModernLoaderState extends State<_ModernLoader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer Ring
            Transform.rotate(
              angle: _controller.value * 2 * 3.14159,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.1),
                    width: 3,
                  ),
                ),
              ),
            ),
            // Progress Segment
            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                value: 0.2, // Small segment
                strokeWidth: 3,
                color: AppColors.primary,
                strokeCap: StrokeCap.round,
              ),
            ),
            // Pulsing Center
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.4 + (0.6 * _controller.value)),
                shape: BoxShape.circle,
              ),
            ),
          ],
        );
      },
    );
  }
}
