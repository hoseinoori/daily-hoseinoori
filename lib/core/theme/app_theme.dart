/// ─────────────────────────────────────────────────────────────────────────────
/// [AppTheme] – تم اصلی برنامه (Dark Glassmorphism)
///
/// این فایل ThemeData کامل برنامه را با تم تاریک، رنگ‌های نئونی نارنجی
/// و افکت‌های گلس‌مورفیسم پیکربندی می‌کند.
/// ─────────────────────────────────────────────────────────────────────────────
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// کلاس اصلی پیکربندی تم برنامه
abstract final class AppTheme {
  /// [darkTheme] – تم تاریک اصلی برنامه
  ///
  /// شامل تنظیمات کامل برای:
  /// - رنگ‌های اصلی و Accent نئونی
  /// - تایپوگرافی فارسی Vazirmatn
  /// - کامپوننت‌های Material 3
  /// - Glassmorphism design tokens
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,

      // ── پالت رنگی پایه ────────────────────────────────────────────────────
      colorScheme: const ColorScheme.dark(
        primary: AppColors.neonOrange,
        onPrimary: AppColors.textOnNeon,
        primaryContainer: AppColors.glassActive,
        onPrimaryContainer: AppColors.neonOrangeLight,
        secondary: AppColors.neonOrangeLight,
        onSecondary: AppColors.textOnNeon,
        surface: AppColors.surface1,
        onSurface: AppColors.textPrimary,
        surfaceContainerHighest: AppColors.surface3,
        onSurfaceVariant: AppColors.textSecondary,
        outline: AppColors.glassBorder,
        outlineVariant: AppColors.surface3,
        error: AppColors.priorityUrgent,
        onError: Colors.white,
        inverseSurface: AppColors.textPrimary,
        onInverseSurface: AppColors.background,
        inversePrimary: AppColors.neonOrangeDark,
        shadow: Colors.black,
        scrim: Colors.black87,
        tertiary: AppColors.statusDone,
        onTertiary: Colors.black,
      ),

      // ── پس‌زمینه اصلی ─────────────────────────────────────────────────────
      scaffoldBackgroundColor: AppColors.background,

      // ── تایپوگرافی ─────────────────────────────────────────────────────────
      fontFamily: 'Vazirmatn',
      textTheme: const TextTheme(
        headlineLarge: AppTextStyles.headlineLarge,
        headlineMedium: AppTextStyles.headlineMedium,
        headlineSmall: AppTextStyles.headlineSmall,
        titleLarge: AppTextStyles.titleLarge,
        titleMedium: AppTextStyles.titleMedium,
        titleSmall: AppTextStyles.titleSmall,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.labelLarge,
        labelMedium: AppTextStyles.labelMedium,
        labelSmall: AppTextStyles.labelSmall,
      ),

      // ── AppBar ─────────────────────────────────────────────────────────────
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: AppColors.background,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: AppTextStyles.headlineSmall,
      ),

      // ── Card ────────────────────────────────────────────────────────────────
      cardTheme: CardTheme(
        color: AppColors.surface2,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: AppColors.glassBorder,
            width: 0.5,
          ),
        ),
        margin: EdgeInsets.zero,
      ),

      // ── دکمه اصلی / ElevatedButton ─────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.neonOrange,
          foregroundColor: AppColors.textOnNeon,
          elevation: 0,
          shadowColor: AppColors.glowNeonOrange,
          textStyle: AppTextStyles.labelLarge,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // ── دکمه متنی / TextButton ─────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.neonOrange,
          textStyle: AppTextStyles.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      // ── دکمه‌ی Outlined ─────────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.neonOrange,
          side: const BorderSide(color: AppColors.neonOrange, width: 1.5),
          textStyle: AppTextStyles.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // ── FloatingActionButton ───────────────────────────────────────────────
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.neonOrange,
        foregroundColor: AppColors.textOnNeon,
        elevation: 8,
        focusElevation: 12,
        hoverElevation: 12,
        shape: CircleBorder(),
      ),

      // ── فیلدهای ورودی / Input Decoration ──────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface2,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.glassBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.glassBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.neonOrange, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.priorityUrgent, width: 1),
        ),
        hintStyle: AppTextStyles.bodyMedium,
        labelStyle: AppTextStyles.titleSmall,
        prefixIconColor: AppColors.textSecondary,
        suffixIconColor: AppColors.textSecondary,
      ),

      // ── Chip ───────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface3,
        disabledColor: AppColors.surface2,
        selectedColor: AppColors.glassActive,
        secondarySelectedColor: AppColors.neonOrange,
        labelStyle: AppTextStyles.labelSmall,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.glassBorder, width: 0.5),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),

      // ── Divider ────────────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.surface3,
        thickness: 0.5,
      ),

      // ── NavigationRail (منوی کناری) ────────────────────────────────────────
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: Colors.transparent,
        selectedIconTheme: IconThemeData(color: AppColors.neonOrange, size: 24),
        unselectedIconTheme:
            IconThemeData(color: AppColors.textDisabled, size: 22),
        selectedLabelTextStyle: TextStyle(
          fontFamily: 'Vazirmatn',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.neonOrange,
        ),
        unselectedLabelTextStyle: TextStyle(
          fontFamily: 'Vazirmatn',
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: AppColors.textDisabled,
        ),
        indicatorColor: AppColors.glassActive,
        elevation: 0,
        useIndicator: true,
      ),

      // ── Bottom Navigation Bar ──────────────────────────────────────────────
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface1,
        selectedItemColor: AppColors.neonOrange,
        unselectedItemColor: AppColors.textDisabled,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(
          fontFamily: 'Vazirmatn',
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Vazirmatn',
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
      ),

      // ── ProgressIndicator ──────────────────────────────────────────────────
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.neonOrange,
        linearTrackColor: AppColors.surface3,
        circularTrackColor: AppColors.surface3,
      ),

      // ── SnackBar ───────────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surface3,
        contentTextStyle: AppTextStyles.bodyMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.glassBorder, width: 0.5),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // ── Dialog ─────────────────────────────────────────────────────────────
      dialogTheme: DialogTheme(
        backgroundColor: AppColors.surface2,
        elevation: 24,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.glassBorder, width: 0.5),
        ),
        titleTextStyle: AppTextStyles.headlineSmall,
        contentTextStyle: AppTextStyles.bodyMedium,
      ),

      // ── Switch ─────────────────────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.neonOrange
              : AppColors.textDisabled,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.glassActive
              : AppColors.surface3,
        ),
      ),

      // ── Checkbox ───────────────────────────────────────────────────────────
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.neonOrange
              : Colors.transparent,
        ),
        checkColor: WidgetStateProperty.all(AppColors.textOnNeon),
        side: const BorderSide(color: AppColors.glassBorder, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
    );
  }

  // ── توکن‌های گلس‌مورفیسم / Glassmorphism Tokens ─────────────────────────────

  /// [glassBlurSigma] – شدت blur برای backdrop filter
  static const double glassBlurSigma = 20.0;

  /// [glassOpacity] – میزان شفافیت پس‌زمینه شیشه‌ای
  static const double glassOpacity = 0.10;

  /// [glassBorderOpacity] – میزان شفافیت حاشیه شیشه‌ای
  static const double glassBorderOpacity = 0.20;

  /// [glassBorderRadius] – شعاع گوشه‌های المان‌های شیشه‌ای
  static const double glassBorderRadius = 16.0;

  /// [cardBorderRadius] – شعاع گوشه‌های کارت‌ها
  static const double cardBorderRadius = 12.0;

  /// [neonGlowRadius] – شعاع Glow نئونی
  static const double neonGlowRadius = 12.0;
}
