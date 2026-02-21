import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/services/haptic_service.dart';

enum AcquiringState { idle, loading, success, error }

class AcquiringPremiumButton extends StatefulWidget {
  final String label;
  final Future<bool> Function() onPurchase;
  final VoidCallback? onSuccess;

  const AcquiringPremiumButton({
    super.key,
    required this.label,
    required this.onPurchase,
    this.onSuccess,
  });

  @override
  State<AcquiringPremiumButton> createState() => _AcquiringPremiumButtonState();
}

class _AcquiringPremiumButtonState extends State<AcquiringPremiumButton> with SingleTickerProviderStateMixin {
  AcquiringState _state = AcquiringState.idle;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (_state != AcquiringState.idle) return;

    HapticService.heavy();
    
    // Press down
    await _controller.forward();
    
    setState(() => _state = AcquiringState.loading);
    
    // Release
    await _controller.reverse();

    try {
      final success = await widget.onPurchase();
      
      if (!mounted) return;

      if (success) {
        setState(() => _state = AcquiringState.success);
        HapticService.success();
        
        // Wait for success animation
        await Future.delayed(const Duration(milliseconds: 1500));
        
        if (mounted && widget.onSuccess != null) {
          widget.onSuccess!();
        }
      } else {
        setState(() => _state = AcquiringState.idle);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _state = AcquiringState.idle);
        HapticService.error();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isIdle = _state == AcquiringState.idle;
    final bool isLoading = _state == AcquiringState.loading;
    final bool isSuccess = _state == AcquiringState.success;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: child,
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height: 48,
        width: isLoading || isSuccess ? 64 : 140, // Morph width
        decoration: BoxDecoration(
          color: isSuccess ? AppColors.success : AppColors.primary,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: (isSuccess ? AppColors.success : AppColors.primary).withOpacity(0.4),
              blurRadius: isIdle ? 12 : 4,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _handleTap,
            borderRadius: BorderRadius.circular(24),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                child: _buildContent(isIdle, isLoading, isSuccess),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(bool isIdle, bool isLoading, bool isSuccess) {
    if (isLoading) {
      return const SizedBox(
        key: ValueKey('loading'),
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 2.5,
        ),
      );
    }
    
    if (isSuccess) {
      return const Icon(
        Icons.check_rounded,
        key: ValueKey('success'),
        color: Colors.white,
        size: 28,
      );
    }

    return Text(
      widget.label,
      key: const ValueKey('idle'),
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w900,
        fontSize: 14,
        letterSpacing: 0.5,
      ),
      maxLines: 1,
      overflow: TextOverflow.visible,
    );
  }
}
