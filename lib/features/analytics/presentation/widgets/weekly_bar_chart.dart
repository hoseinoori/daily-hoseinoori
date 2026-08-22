/// ─────────────────────────────────────────────────────────────────────────────
/// [WeeklyBarChart] – نمودار میله‌ای ۷ روز گذشته با افکت‌های نور نئونی
/// ─────────────────────────────────────────────────────────────────────────────
library;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../providers/analytics_provider.dart';

/// [WeeklyBarChart] – نمودار میله‌ای روند تمرکز هفتگی
class WeeklyBarChart extends StatelessWidget {
  final List<DayFocusStat> stats;

  const WeeklyBarChart({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    // پیدا کردن بیشترین دقیقه برای مقیاس‌دهی ارتفاع میله‌ها
    var maxMinutes = 1;
    for (final s in stats) {
      final total = s.deepWorkMinutes + s.restMinutes;
      if (total > maxMinutes) maxMinutes = total;
    }

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── سربرگ ─────────────────────────────────────────────────────────
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.neonOrange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.bar_chart_rounded,
                  color: AppColors.neonOrange,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('روند تمرکز در ۷ روز گذشته',
                      style: AppTextStyles.titleMedium),
                  Text(
                    'دقایق کار عمیق در هر روز',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textDisabled,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── نمودار میله‌ای ────────────────────────────────────────────────
          SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: stats.map((stat) {
                final heightFactor =
                    (stat.deepWorkMinutes / maxMinutes).clamp(0.05, 1.0);

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // برچسب دقیقه بالای میله (در صورت وجود زمان)
                        if (stat.deepWorkMinutes > 0)
                          Text(
                            '${stat.deepWorkMinutes}',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.neonOrange,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        const SizedBox(height: 4),

                        // میله نئونی با انیمیشن
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: FractionallySizedBox(
                              heightFactor: heightFactor,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      AppColors.neonOrange.withOpacity(0.4),
                                      AppColors.neonOrange,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                  boxShadow: stat.deepWorkMinutes > 0
                                      ? [
                                          BoxShadow(
                                            color: AppColors.glowNeonOrange,
                                            blurRadius: 8,
                                            spreadRadius: 1,
                                          ),
                                        ]
                                      : null,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // نام روز (ش، ی، د...)
                        Text(
                          stat.dayName,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: stat.deepWorkMinutes > 0
                                ? AppColors.textPrimary
                                : AppColors.textDisabled,
                            fontWeight: stat.deepWorkMinutes > 0
                                ? FontWeight.w700
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
