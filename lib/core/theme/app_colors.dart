/// ─────────────────────────────────────────────────────────────────────────────
/// [AppColors] – پالت رنگ‌های برنامه
///
/// این فایل تمام رنگ‌های اصلی برنامه را تعریف می‌کند.
/// تم: Dark Glassmorphism با رنگ شاخص نئونی نارنجی فسفری
/// ─────────────────────────────────────────────────────────────────────────────
library;

import 'package:flutter/material.dart';

/// کلاس اصلی پالت رنگ‌ها - تمام ثابت‌های رنگی اینجا تعریف می‌شوند
abstract final class AppColors {
  // ── رنگ شاخص نئونی / Neon Accent ──────────────────────────────────────────
  /// رنگ اصلی نئونی نارنجی (Neon Orange)
  static const Color neonOrange = Color(0xFFFF6B00);

  /// نسخه روشن‌تر نئونی برای Glow effects
  static const Color neonOrangeLight = Color(0xFFFF8C00);

  /// نسخه تیره‌تر نئونی برای سایه‌ها
  static const Color neonOrangeDark = Color(0xFFE55A00);

  // ── رنگ‌های پس‌زمینه / Background Colors ────────────────────────────────────
  /// پس‌زمینه اصلی برنامه - تاریک‌ترین لایه
  static const Color background = Color(0xFF0A0A0F);

  /// پس‌زمینه سطح اول (Surface Level 1)
  static const Color surface1 = Color(0xFF12121A);

  /// پس‌زمینه سطح دوم (Surface Level 2)
  static const Color surface2 = Color(0xFF1A1A25);

  /// پس‌زمینه سطح سوم (Surface Level 3)
  static const Color surface3 = Color(0xFF22222F);

  // ── گلس‌مورفیسم / Glassmorphism ─────────────────────────────────────────────
  /// رنگ پس‌زمینه شیشه‌ای (Glass Background)
  static const Color glassBackground = Color(0x1AFFFFFF); // 10% سفید

  /// رنگ حاشیه شیشه‌ای (Glass Border)
  static const Color glassBorder = Color(0x33FFFFFF); // 20% سفید

  /// رنگ گلس فعال (Active Glass)
  static const Color glassActive = Color(0x26FF6B00); // 15% نئونی

  // ── رنگ‌های متن / Text Colors ────────────────────────────────────────────────
  /// متن اصلی - سفید کامل
  static const Color textPrimary = Color(0xFFFFFFFF);

  /// متن ثانوی - خاکستری روشن
  static const Color textSecondary = Color(0xFFB3B3CC);

  /// متن ضعیف - خاکستری تیره
  static const Color textDisabled = Color(0xFF666680);

  /// متن روی پس‌زمینه نئونی
  static const Color textOnNeon = Color(0xFF000000);

  // ── رنگ‌های وضعیت تسک / Task Status Colors ───────────────────────────────────
  /// وضعیت: انجام نشده (Todo)
  static const Color statusTodo = Color(0xFF666680);

  /// وضعیت: در جریان (In Progress)
  static const Color statusInProgress = Color(0xFFFF6B00);

  /// وضعیت: انجام شده (Done)
  static const Color statusDone = Color(0xFF00E676);

  // ── رنگ‌های اولویت / Priority Colors ─────────────────────────────────────────
  /// اولویت پایین (Low)
  static const Color priorityLow = Color(0xFF4FC3F7);

  /// اولویت متوسط (Medium)
  static const Color priorityMedium = Color(0xFFFFD740);

  /// اولویت بالا (High)
  static const Color priorityHigh = Color(0xFFFF6B00);

  /// اولویت فوری (Urgent)
  static const Color priorityUrgent = Color(0xFFFF1744);

  // ── افکت‌های نوری / Glow Colors ──────────────────────────────────────────────
  /// Glow اصلی نئونی
  static const Color glowNeonOrange = Color(0x80FF6B00); // 50% opacity

  /// Glow سبز برای موارد تکمیل‌شده
  static const Color glowGreen = Color(0x8000E676);

  /// Glow آبی برای اطلاعات
  static const Color glowBlue = Color(0x804FC3F7);

  // ── رنگ‌های تقویم / Calendar Colors ──────────────────────────────────────────
  /// تعطیلات ایرانی
  static const Color holidayRed = Color(0xFFFF5252);

  /// مناسبت‌های ملی
  static const Color nationalEventBlue = Color(0xFF448AFF);

  /// مناسبت‌های مذهبی
  static const Color religiousEventGold = Color(0xFFFFD740);
}
