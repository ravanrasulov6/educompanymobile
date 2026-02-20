import 'package:flutter/material.dart';

/// Brand color palette for EduCompany
class AppColors {
  AppColors._();

  // ── Primary Brand ──────────────────────────────────────────────
  static const Color primary = Color(0xFF4F46E5);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF3730A3);
  static const Color skyBlue = Color(0xFF2B8CEE);

  // ── Secondary ──────────────────────────────────────────────────
  static const Color secondary = Color(0xFF0EA5E9);
  static const Color secondaryLight = Color(0xFF7DD3FC);

  // ── Accent ─────────────────────────────────────────────────────
  static const Color accent = Color(0xFFF59E0B);
  static const Color accentLight = Color(0xFFFCD34D);

  // ── Semantic ───────────────────────────────────────────────────
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF97316);
  static const Color info = Color(0xFF3B82F6);

  // ── Light Mode Surfaces ────────────────────────────────────────
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightDivider = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);
  static const Color lightTextHint = Color(0xFF94A3B8);

  // ── Dark Mode Surfaces ─────────────────────────────────────────
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkDivider = Color(0xFF334155);
  static const Color darkTextPrimary = Color(0xFFF1F5F9);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextHint = Color(0xFF64748B);

  // ── Premium Effects ──────────────────────────────────────────
  static const Color glassBorder = Color(0x33FFFFFF);
  static const Color glassSurface = Color(0x1AFFFFFF);
  static const Color shimmerBase = Color(0xFFE2E8F0);
  static const Color shimmerHighlight = Color(0xFFF8FAFC);
  static const Color darkShimmerBase = Color(0xFF1E293B);
  static const Color darkShimmerHighlight = Color(0xFF334155);

  // ── Gradients ──────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFFEEF2FF), Color(0xFFF8FAFC)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient darkHeroGradient = LinearGradient(
    colors: [Color(0xFF1E1B4B), Color(0xFF0F172A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
