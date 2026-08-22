/// ─────────────────────────────────────────────────────────────────────────────
/// [NeonTimerDisplay] – نمایشگر دایره‌ای تایمر با جلوه نور نئونی
/// ─────────────────────────────────────────────────────────────────────────────
library;

import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// [NeonTimerDisplay] – دایره پیشرفت نئونی برای تایمر فوکوس
class NeonTimerDisplay extends StatelessWidget {
  final double progress; // ۰.۰ تا ۱.۰
  final String formattedTime;
  final String category;
  final bool isRunning;
  final bool isPaused;

  const NeonTimerDisplay({
    super.key,
    required this.progress,
    required this.formattedTime,
    required this.category,
    required this.isRunning,
    required this.isPaused,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = _getCategoryColor(category);

    return Center(
      child: SizedBox(
        width: 260,
        height: 260,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // ۱. حلقه پس‌زمینه
            SizedBox(
              width: 250,
              height: 250,
              child: CircularProgressIndicator(
                value: 1.0,
                strokeWidth: 10,
                color: AppColors.surface3,
              ),
            ),

            // ۲. حلقه پیشرفت نئونی متحرک
            SizedBox(
              width: 250,
              height: 250,
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: progress),
                duration: const Duration(milliseconds: 300),
                builder: (context, value, _) {
                  return CustomPaint(
                    painter: _NeonCirclePainter(
                      progress: value,
                      color: effectiveColor,
                      glow: isRunning && !isPaused,
                    ),
                  );
                },
              ),
            ),

            // ۳. متون مرکزی: زمان و دسته‌بندی
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // آیکون وضعیت
                Icon(
                  isRunning
                      ? (isPaused
                          ? Icons.pause_circle_filled_rounded
                          : Icons.bolt_rounded)
                      : Icons.timer_rounded,
                  color: effectiveColor,
                  size: 28,
                ),
                const SizedBox(height: 6),

                // زمان دیجیتال بزرگ
                Text(
                  formattedTime,
                  style: AppTextStyles.headlineLarge.copyWith(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),

                // برچسب دسته‌بندی
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: effectiveColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: effectiveColor.withOpacity(0.4),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    category,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: effectiveColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String cat) {
    if (cat.contains('استراحت') || cat.contains('مجازی')) {
      return const Color(0xFF80DEEA); // فیروزه‌ای
    } else if (cat.contains('مطالعه')) {
      return const Color(0xFFFFD740); // زرد طلایی
    } else if (cat.contains('تسک')) {
      return const Color(0xFF00E676); // سبز
    }
    return AppColors.neonOrange; // نارنجی نئونی
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// ████  نقاش سفارشی دایره نئونی  ████
// ═════════════════════════════════════════════════════════════════════════════
class _NeonCirclePainter extends CustomPainter {
  final double progress;
  final Color color;
  final bool glow;

  _NeonCirclePainter({
    required this.progress,
    required this.color,
    required this.glow,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 10) / 2;
    const startAngle = -math.pi / 2; // شروع از بالا (۱۲ ساعت)
    final sweepAngle = 2 * math.pi * progress;

    // افکت درخشش نئونی (Glow Layer)
    if (glow) {
      final glowPaint = Paint()
        ..color = color.withOpacity(0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 16
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        glowPaint,
      );
    }

    // خط اصلی پیشرفت
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _NeonCirclePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.glow != glow;
  }
}
