import 'package:flutter/services.dart';

/// Centralized service for haptic feedback to provide world-class tactile feel.
class HapticService {
  HapticService._();

  /// Light tap for subtle interactions (e.g. chip selection)
  static Future<void> light() async {
    await HapticFeedback.selectionClick();
  }

  /// Medium tap for button presses
  static Future<void> medium() async {
    await HapticFeedback.mediumImpact();
  }

  /// Heavy tap for significant actions
  static Future<void> heavy() async {
    await HapticFeedback.heavyImpact();
  }

  /// Special vibration for success/completion
  static Future<void> success() async {
    // Mimic a success pattern
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.lightImpact();
  }

  /// Special vibration for error/warning
  static Future<void> error() async {
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.heavyImpact();
  }
}
