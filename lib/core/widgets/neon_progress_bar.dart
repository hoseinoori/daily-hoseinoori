/// ─────────────────────────────────────────────────────────────────────────────
/// [NeonProgressBar] – نوار پیشرفت نئونی
///
/// نمایش درصد پیشرفت تسک با افکت Glow نئونی و انیمیشن روان.
/// ─────────────────────────────────────────────────────────────────────────────
library;

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// [NeonProgressBar] – نوار پیشرفت با Glow نئونی
class NeonProgressBar extends StatelessWidget {
  /// مقدار پیشرفت (۰.۰ تا ۱.۰)
  final double value;

  /// ارتفاع نوار پیشرفت
  final double height;

  /// رنگ نوار پیشرفت (پیش‌فرض: neonOrange)
  final Color? color;

  /// رنگ پس‌زمینه نوار
  final Color? backgroundColor;

  /// آیا مقدار درصد نمایش داده شود؟
  final bool showLabel;

  /// شعاع گوشه‌ها
  final double borderRadius;

  const NeonProgressBar({
    super.key,
    required this.value,
    this.height = 6,
    this.color,
    this.backgroundColor,
    this.showLabel = false,
    this.borderRadius = 4,
  });

  @override
  Widget build(BuildContext context) {
    final clampedValue = value.clamp(0.0, 1.0);
    final barColor = color ?? AppColors.neonOrange;
    final percentage = (clampedValue * 100).round();

    // تعیین رنگ بر اساس درصد پیشرفت
    final effectiveColor = _getProgressColor(percentage, barColor);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        // نمایش لیبل درصد (اختیاری)
        if (showLabel) ...[
          Text(
            '$percentage٪',
            style: AppTextStyles.labelSmall.copyWith(
              color: effectiveColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
        ],
        // نوار پیشرفت
        Container(
          height: height,
          decoration: BoxDecoration(
            color: backgroundColor ?? AppColors.surface3,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              alignment: Alignment.centerRight, // RTL: از راست شروع
              child: FractionallySizedBox(
                widthFactor: clampedValue,
                alignment: Alignment.centerRight,
                child: Container(
                  decoration: BoxDecoration(
                    // گرادیان نئونی
                    gradient: LinearGradient(
                      colors: [
                        effectiveColor.withOpacity(0.7),
                        effectiveColor,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(borderRadius),
                    // Glow effect
                    boxShadow: [
                      BoxShadow(
                        color: effectiveColor.withOpacity(0.5),
                        blurRadius: 6,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// [_getProgressColor] – تعیین رنگ نوار بر اساس درصد پیشرفت
  ///
  /// - ۰٪ تا ۳۰٪: خاکستری/غیرفعال
  /// - ۳۱٪ تا ۶۹٪: نئونی نارنجی
  /// - ۷۰٪ تا ۱۰۰٪: سبز (تکمیل)
  Color _getProgressColor(int percentage, Color fallback) {
    if (percentage == 100) return AppColors.statusDone;
    if (percentage >= 70) return AppColors.statusDone.withOpacity(0.8);
    if (percentage >= 30) return fallback;
    return AppColors.textDisabled;
  }
}
