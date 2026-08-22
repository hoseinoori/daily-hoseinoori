/// ─────────────────────────────────────────────────────────────────────────────
/// [GlassCard] – ویجت کارت گلس‌مورفیسم قابل استفاده مجدد
///
/// یک Container با افکت‌های:
/// - پس‌زمینه نیمه‌شفاف (Glass Background)
/// - حاشیه شیشه‌ای ظریف (Glass Border)
/// - گوشه‌های گرد (Rounded Corners)
/// - اختیاری: Glow نئونی
/// ─────────────────────────────────────────────────────────────────────────────
library;

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// [GlassCard] – کارت شیشه‌ای با طراحی Glassmorphism
class GlassCard extends StatelessWidget {
  /// محتوای داخل کارت
  final Widget child;

  /// padding داخلی (پیش‌فرض: 16)
  final EdgeInsetsGeometry? padding;

  /// شعاع گوشه‌ها (پیش‌فرض: 16)
  final double? borderRadius;

  /// آیا Glow نئونی نمایش داده شود؟
  final bool showGlow;

  /// شدت Glow (۰ تا ۱)
  final double glowIntensity;

  /// رنگ پس‌زمینه (پیش‌فرض: glassBackground)
  final Color? backgroundColor;

  /// رنگ حاشیه (پیش‌فرض: glassBorder)
  final Color? borderColor;

  /// callback برای کلیک روی کارت
  final VoidCallback? onTap;

  /// callback برای فشار طولانی
  final VoidCallback? onLongPress;

  /// margin خارجی
  final EdgeInsetsGeometry? margin;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.showGlow = false,
    this.glowIntensity = 0.5,
    this.backgroundColor,
    this.borderColor,
    this.onTap,
    this.onLongPress,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? AppTheme.glassBorderRadius;

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        color: backgroundColor ?? AppColors.glassBackground,
        border: Border.all(
          color: borderColor ?? AppColors.glassBorder,
          width: 0.8,
        ),
        // Glow نئونی اختیاری
        boxShadow: showGlow
            ? [
                BoxShadow(
                  color:
                      AppColors.glowNeonOrange.withOpacity(glowIntensity * 0.5),
                  blurRadius: AppTheme.neonGlowRadius,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(radius),
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(radius),
          splashColor: AppColors.glassActive,
          highlightColor: AppColors.glassBackground,
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}
