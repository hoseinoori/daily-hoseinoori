/// ─────────────────────────────────────────────────────────────────────────────
/// [FocusRatioCard] – کارت نسبت کار عمیق به زمان استراحت و فضای مجازی
/// ─────────────────────────────────────────────────────────────────────────────
library;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/glass_card.dart';

/// [FocusRatioCard] – کارت مقایسه کار عمیق و استراحت
class FocusRatioCard extends StatelessWidget {
  final int deepWorkMinutes;
  final int restMinutes;
  final double deepWorkRatio;

  const FocusRatioCard({
    super.key,
    required this.deepWorkMinutes,
    required this.restMinutes,
    required this.deepWorkRatio,
  });

  @override
  Widget build(BuildContext context) {
    final totalMinutes = deepWorkMinutes + restMinutes;
    final deepPercentage = (deepWorkRatio * 100).round();
    final restPercentage = 100 - deepPercentage;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── هدر ────────────────────────────────────────────────────────────
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.neonOrange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.pie_chart_rounded,
                  color: AppColors.neonOrange,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('نسبت تمرکز به استراحت',
                      style: AppTextStyles.titleMedium),
                  Text(
                    'مجموع $totalMinutes دقیقه زمان ثبت‌شده',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textDisabled,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── نوار دو رنگ نئونی ─────────────────────────────────────────────
          if (totalMinutes > 0) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 12,
                child: Row(
                  children: [
                    // بخش کار عمیق (نارنجی نئونی)
                    Expanded(
                      flex: (deepWorkRatio * 1000).toInt(),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: AppColors.neonOrange,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.glowNeonOrange,
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // بخش استراحت / فضای مجازی (فیروزه‌ای)
                    Expanded(
                      flex: ((1 - deepWorkRatio) * 1000).toInt(),
                      child: Container(
                        color: const Color(0xFF80DEEA),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ── جزئیات مقادیر ─────────────────────────────────────────────────
          Row(
            children: [
              // کار عمیق
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.neonOrange,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'کار عمیق ($deepPercentage٪)',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.neonOrangeLight,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '$deepWorkMinutes دقیقه',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textDisabled,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // استراحت / فضای مجازی
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF80DEEA),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'استراحت ($restPercentage٪)',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: const Color(0xFF80DEEA),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '$restMinutes دقیقه',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textDisabled,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
