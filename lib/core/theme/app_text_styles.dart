/// ─────────────────────────────────────────────────────────────────────────────
/// [AppTextStyles] – استایل‌های متنی برنامه
///
/// این فایل تمام TextStyle های مورد استفاده در برنامه را با فونت Vazirmatn
/// (فونت استاندارد فارسی) تعریف می‌کند.
/// ─────────────────────────────────────────────────────────────────────────────
library;

import 'package:flutter/material.dart';
import 'app_colors.dart';

/// کلاس مدیریت استایل‌های متنی با فونت فارسی Vazirmatn
abstract final class AppTextStyles {
  // ── نام فونت اصلی ─────────────────────────────────────────────────────────
  static const String _fontFamily = 'Vazirmatn';

  // ── عناوین اصلی / Headlines ───────────────────────────────────────────────
  /// عنوان بزرگ - برای صفحه اصلی و هدرهای اصلی
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.4,
    letterSpacing: -0.5,
  );

  /// عنوان متوسط - برای عناوین بخش‌ها
  static const TextStyle headlineMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  /// عنوان کوچک - برای عناوین کارت‌ها
  static const TextStyle headlineSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  // ── عناوین کانبان و آیتم / Title ─────────────────────────────────────────
  /// عنوان بزرگ آیتم
  static const TextStyle titleLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  /// عنوان متوسط آیتم
  static const TextStyle titleMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  /// عنوان کوچک آیتم
  static const TextStyle titleSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  // ── متن بدنه / Body Text ─────────────────────────────────────────────────
  /// متن بدنه بزرگ
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.7,
  );

  /// متن بدنه متوسط
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.7,
  );

  /// متن بدنه کوچک
  static const TextStyle bodySmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textDisabled,
    height: 1.5,
  );

  // ── برچسب و دکمه / Label & Button ────────────────────────────────────────
  /// برچسب بزرگ - برای دکمه‌ها
  static const TextStyle labelLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0.5,
  );

  /// برچسب متوسط
  static const TextStyle labelMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  /// برچسب کوچک - برای تگ‌ها و badge ها
  static const TextStyle labelSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.textDisabled,
    letterSpacing: 0.3,
  );

  // ── متن نئونی / Neon Text ─────────────────────────────────────────────────
  /// متن نئونی برجسته برای موارد مهم
  static const TextStyle neonAccent = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.neonOrange,
    shadows: [
      Shadow(
        color: AppColors.glowNeonOrange,
        blurRadius: 8,
      ),
    ],
  );

  /// متن ساعت و تایمر با فونت monospace
  static const TextStyle timerDisplay = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 48,
    fontWeight: FontWeight.w700,
    color: AppColors.neonOrangeLight,
    letterSpacing: 4,
    shadows: [
      Shadow(
        color: AppColors.glowNeonOrange,
        blurRadius: 20,
      ),
    ],
  );
}
