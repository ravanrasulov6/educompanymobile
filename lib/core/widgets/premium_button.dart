import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Premium CTA button with optional gradient background
class PremiumButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isGradient;
  final bool isOutlined;
  final bool isText;
  final IconData? icon;
  final bool isLoading;
  final double? width;

  const PremiumButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isGradient = false,
    this.isOutlined = false,
    this.isText = false,
    this.icon,
    this.isLoading = false,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    if (isText) {
      return SizedBox(
        width: width,
        child: TextButton(
          onPressed: isLoading ? null : onPressed,
          child: _buildLabel(context),
        ),
      );
    }

    if (isOutlined) {
      return SizedBox(
        width: width,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          child: _buildLabel(context),
        ),
      );
    }

    if (isGradient) {
      return SizedBox(
        width: width,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
            ),
            child: _buildLabel(context),
          ),
        ),
      );
    }

    return SizedBox(
      width: width,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: _buildLabel(context),
      ),
    );
  }

  Widget _buildLabel(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(label),
        ],
      );
    }

    return Text(label);
  }
}
