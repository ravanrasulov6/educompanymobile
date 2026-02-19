import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Premium CTA button with high-quality press animation and gradient support
class PremiumButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isGradient;
  final bool isOutlined;
  final bool isText;
  final IconData? icon;
  final bool isLoading;
  final double? width;
  final double height;

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
    this.height = 56,
  });

  @override
  State<PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<PremiumButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.isLoading) _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.isLoading) _controller.reverse();
  }

  void _handleTapCancel() {
    if (!widget.isLoading) _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.isLoading ? null : widget.onPressed,
      child: ScaleTransition(
        scale: _scale,
        child: SizedBox(
          width: widget.width,
          height: widget.height,
          child: _buildButton(context),
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context) {
    if (widget.isText) {
      return TextButton(
        onPressed: null, // Handled by GestureDetector
        child: _buildLabel(context),
      );
    }

    if (widget.isOutlined) {
      return OutlinedButton(
        onPressed: null, // Handled by GestureDetector
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
          backgroundColor: Theme.of(context).cardColor.withValues(alpha: 0.6),
        ),
        child: _buildLabel(context),
      );
    }

    if (widget.isGradient) {
      return DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(child: _buildLabel(context, isWhite: true)),
      );
    }

    return ElevatedButton(
      onPressed: null, // Handled by GestureDetector
      child: _buildLabel(context),
    );
  }

  Widget _buildLabel(BuildContext context, {bool isWhite = false}) {
    if (widget.isLoading) {
      return const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation(Colors.white),
        ),
      );
    }

    final color = isWhite ? Colors.white : null;

    if (widget.icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(widget.icon, size: 20, color: color),
          const SizedBox(width: 10),
          Text(
            widget.label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ],
      );
    }

    return Text(
      widget.label,
      style: TextStyle(
        color: color,
        fontWeight: FontWeight.w600,
        fontSize: 17,
      ),
    );
  }
}
