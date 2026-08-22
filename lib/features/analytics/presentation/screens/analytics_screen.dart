/// ─────────────────────────────────────────────────────────────────────────────
/// [AnalyticsScreen] – صفحه داشبورد آمار و بهره‌وری
/// ─────────────────────────────────────────────────────────────────────────────
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../providers/analytics_provider.dart';
import '../widgets/focus_ratio_card.dart';
import '../widgets/task_completion_card.dart';
import '../widgets/weekly_bar_chart.dart';

/// [AnalyticsScreen] – داشبورد آمار و تحلیل بهره‌وری
class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AnalyticsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('آمار و تحلیل بهره‌وری', style: AppTextStyles.headlineSmall),
            Text(
              'گزارش جامع عملکرد و تمرکز',
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textDisabled),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.neonOrange),
            tooltip: 'بروزرسانی آمار',
            onPressed: provider.refreshStats,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: provider.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.neonOrange),
            )
          : RefreshIndicator(
              onRefresh: provider.refreshStats,
              color: AppColors.neonOrange,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                children: [
                  // ۱. کارت درصد تکمیل تسک‌ها
                  TaskCompletionCard(
                    totalTasks: provider.totalTasks,
                    completedTasks: provider.completedTasks,
                    inProgressTasks: provider.inProgressTasks,
                    todoTasks: provider.todoTasks,
                    completionRate: provider.weeklyCompletionRate,
                  ),
                  const SizedBox(height: 16),

                  // ۲. نمودار مقایسه نسبت کار عمیق به استراحت
                  FocusRatioCard(
                    deepWorkMinutes: provider.totalDeepWorkMinutes,
                    restMinutes: provider.totalRestMinutes,
                    deepWorkRatio: provider.deepWorkRatio,
                  ),
                  const SizedBox(height: 16),

                  // ۳. نمودار میله‌ای ۷ روز گذشته
                  WeeklyBarChart(stats: provider.last7DaysStats),
                ],
              ),
            ),
    );
  }
}
