import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography system using Inter font family
class AppTextStyles {
  AppTextStyles._();

  static TextStyle get _headingStyle => GoogleFonts.outfit();
  static TextStyle get _bodyStyle => GoogleFonts.inter();

  // ── Display ────────────────────────────────────────────────────
  static TextStyle get displayLarge => _headingStyle.copyWith(
        fontSize: 36,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.0,
        height: 1.2,
      );

  static TextStyle get displayMedium => _headingStyle.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.3,
      );

  // ── Heading ────────────────────────────────────────────────────
  static TextStyle get headlineLarge => _headingStyle.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        height: 1.3,
      );

  static TextStyle get headlineMedium => _headingStyle.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );

  static TextStyle get headlineSmall => _headingStyle.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );

  // ── Title ──────────────────────────────────────────────────────
  static TextStyle get titleLarge => _bodyStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.5,
      );

  static TextStyle get titleMedium => _bodyStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.5,
      );

  // ── Body ───────────────────────────────────────────────────────
  static TextStyle get bodyLarge => _bodyStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.6,
      );

  static TextStyle get bodyMedium => _bodyStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle get bodySmall => _bodyStyle.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  // ── Labels ─────────────────────────────────────────────────────
  static TextStyle get labelLarge => _bodyStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        height: 1.4,
      );

  static TextStyle get labelSmall => _bodyStyle.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.4,
      );

  // ── Button ─────────────────────────────────────────────────────
  static TextStyle get button => _bodyStyle.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      );
}
