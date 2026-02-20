import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Material 3 theme configuration for EduCompany
class AppTheme {
  AppTheme._();

  // ── Light Theme ────────────────────────────────────────────────
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
          surface: AppColors.lightSurface,
        ),
        scaffoldBackgroundColor: AppColors.lightBackground,
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme),

        // AppBar
        appBarTheme: AppBarTheme(
          elevation: 0,
          scrolledUnderElevation: 1,
          centerTitle: true,
          backgroundColor: AppColors.lightSurface,
          foregroundColor: AppColors.lightTextPrimary,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.lightTextPrimary,
            letterSpacing: -0.5,
          ),
        ),

        // Cards
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: AppColors.lightDivider.withValues(alpha: 0.5)),
          ),
          color: AppColors.lightCard,
          surfaceTintColor: Colors.transparent,
        ),

        // Elevated Button
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            textStyle: GoogleFonts.outfit(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ),

        // Outlined Button
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            side: const BorderSide(color: AppColors.primary, width: 1.5),
            foregroundColor: AppColors.primary,
            textStyle: GoogleFonts.outfit(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ),

        // Text Button
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            foregroundColor: AppColors.lightTextSecondary,
            textStyle: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        // Input Decoration
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.lightBackground,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: AppColors.lightDivider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          hintStyle: GoogleFonts.outfit(
            color: AppColors.lightTextHint,
            fontSize: 14,
          ),
        ),

        // Bottom Navigation
        navigationBarTheme: NavigationBarThemeData(
          elevation: 0,
          backgroundColor: AppColors.lightSurface,
          surfaceTintColor: Colors.transparent,
          height: 72,
          indicatorColor: AppColors.primary.withValues(alpha: 0.1),
          indicatorShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: AppColors.primary, size: 26);
            }
            return IconThemeData(
              color: AppColors.lightTextSecondary.withValues(alpha: 0.8),
              size: 24,
            );
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final style = GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: states.contains(WidgetState.selected)
                  ? FontWeight.w600
                  : FontWeight.w500,
            );
            if (states.contains(WidgetState.selected)) {
              return style.copyWith(color: AppColors.primary);
            }
            return style.copyWith(color: AppColors.lightTextSecondary);
          }),
        ),

        // Navigation Rail (Admin sidebar)
        navigationRailTheme: const NavigationRailThemeData(
          backgroundColor: AppColors.lightSurface,
          selectedIconTheme: IconThemeData(color: AppColors.primary),
          indicatorColor: Color(0xFFEEF2FF),
        ),

        // Divider
        dividerTheme: const DividerThemeData(
          color: AppColors.lightDivider,
          thickness: 1,
        ),

        // Animations
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: ZoomPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      );

  // ── Dark Theme ─────────────────────────────────────────────────
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
          surface: AppColors.darkSurface,
        ),
        scaffoldBackgroundColor: AppColors.darkBackground,
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),

        // AppBar
        appBarTheme: AppBarTheme(
          elevation: 0,
          scrolledUnderElevation: 1,
          centerTitle: true,
          backgroundColor: AppColors.darkSurface,
          foregroundColor: AppColors.darkTextPrimary,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.darkTextPrimary,
            letterSpacing: -0.5,
          ),
        ),

        // Cards
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: AppColors.darkDivider.withValues(alpha: 0.5)),
          ),
          color: AppColors.darkCard,
          surfaceTintColor: Colors.transparent,
        ),

        // Elevated Button
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            backgroundColor: AppColors.primaryLight,
            foregroundColor: AppColors.darkBackground,
            textStyle: GoogleFonts.outfit(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ),

        // Outlined Button
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            side: const BorderSide(color: AppColors.primaryLight, width: 1.5),
            foregroundColor: AppColors.primaryLight,
            textStyle: GoogleFonts.outfit(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ),

        // Text Button
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            foregroundColor: AppColors.darkTextSecondary,
            textStyle: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        // Input Decoration
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.darkBackground,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: AppColors.darkDivider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                const BorderSide(color: AppColors.primaryLight, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          hintStyle: GoogleFonts.outfit(
            color: AppColors.darkTextHint,
            fontSize: 14,
          ),
        ),

        // Bottom Navigation
        navigationBarTheme: NavigationBarThemeData(
          elevation: 0,
          backgroundColor: AppColors.darkSurface,
          surfaceTintColor: Colors.transparent,
          height: 72,
          indicatorColor: AppColors.primaryLight.withValues(alpha: 0.15),
          indicatorShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: AppColors.primaryLight, size: 26);
            }
            return IconThemeData(
              color: AppColors.darkTextSecondary.withValues(alpha: 0.8),
              size: 24,
            );
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final style = GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: states.contains(WidgetState.selected)
                  ? FontWeight.w600
                  : FontWeight.w500,
            );
            if (states.contains(WidgetState.selected)) {
              return style.copyWith(color: AppColors.primaryLight);
            }
            return style.copyWith(color: AppColors.darkTextSecondary);
          }),
        ),

        // Navigation Rail
        navigationRailTheme: const NavigationRailThemeData(
          backgroundColor: AppColors.darkSurface,
          selectedIconTheme: IconThemeData(color: AppColors.primaryLight),
          indicatorColor: Color(0xFF312E81),
        ),

        // Divider
        dividerTheme: const DividerThemeData(
          color: AppColors.darkDivider,
          thickness: 1,
        ),

        // Animations
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: ZoomPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      );
}
