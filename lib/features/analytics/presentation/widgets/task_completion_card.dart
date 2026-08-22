/// ─────────────────────────────────────────────────────────────────────────────
/// [TaskCompletionCard] – کارت آمار درصد تکمیل تسک‌ها
/// ─────────────────────────────────────────────────────────────────────────────
library;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/neon_progress_bar.dart';

/// [TaskCompletionCard] – ویجت کارت آمار تسک‌ها
class TaskCompletionCard extends StatelessWidget {
  final int totalTasks;
  final int completedTasks;
  final int inProgressTasks;
  final int todoTasks;
  final int completionRate;

  const TaskCompletionCard({
    super.key,
    required this.totalTasks,
    required this.completedTasks,
    required this.inProgressTasks,
    required this.todoTasks,
    required this.completionRate,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── سربرگ کارت ─────────────────────────────────────────────────────
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.neonOrange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.task_alt_rounded,
                  color: AppColors.neonOrange,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('نرخ تکمیل تسک‌ها', style: AppTextStyles.titleMedium),
                  Text(
                    '$completedTasks از $totalTasks تسک انجام شده است',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textDisabled,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // برچسب درصد بزرگ
              Text(
                '$completionRate٪',
                style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.neonOrangeLight,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── نوار پیشرفت نئونی ─────────────────────────────────────────────
          NeonProgressBar(
            value: totalTasks > 0 ? completedTasks / totalTasks : 0.0,
            height: 8,
          ),
          const SizedBox(height: 16),

          // ── چیپ‌های تفکیک وضعیت‌ها ─────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _StatusStatChip(
                  label: 'انجام‌شده',
                  count: completedTasks,
                  color: AppColors.statusDone,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatusStatChip(
                  label: 'در جریان',
                  count: inProgressTasks,
                  color: AppColors.neonOrange,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatusStatChip(
                  label: 'در انتظار',
                  count: todoTasks,
                  color: AppColors.statusTodo,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusStatChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _StatusStatChip({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3), width: 0.8),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: AppTextStyles.titleMedium.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textDisabled,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
