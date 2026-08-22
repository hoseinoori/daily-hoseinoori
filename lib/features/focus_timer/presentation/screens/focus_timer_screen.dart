/// ─────────────────────────────────────────────────────────────────────────────
/// [FocusTimerScreen] – صفحه تایمر فوکوس، پومودورو و تایم‌باکسینگ
/// ─────────────────────────────────────────────────────────────────────────────
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../tasks/providers/task_provider.dart';
import '../../providers/focus_provider.dart';
import '../widgets/neon_timer_display.dart';

/// [FocusTimerScreen] – صفحه تایمر تمرکز
class FocusTimerScreen extends StatelessWidget {
  const FocusTimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final focusProvider = context.watch<FocusProvider>();
    final taskProvider = context.watch<TaskProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('تایمر فوکوس و تایم‌باکس', style: AppTextStyles.headlineSmall),
            Text(
              'امروز: ${focusProvider.todayTotalMinutes} دقیقه تمرکز (${focusProvider.todayLogs.length} سشن)',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.neonOrange,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        children: [
          // ۱. انتخاب حالت تایمر (۲۵ دقیقه، ۵۰ دقیقه، ۵ دقیقه، کرنومتر)
          _buildModeSelector(focusProvider),
          const SizedBox(height: 20),

          // ۲. نمایشگر دایره‌ای نئونی تایمر
          NeonTimerDisplay(
            progress: focusProvider.progress,
            formattedTime: focusProvider.formattedTime,
            category: focusProvider.selectedCategory,
            isRunning: focusProvider.isRunning,
            isPaused: focusProvider.isPaused,
          ),
          const SizedBox(height: 24),

          // ۳. دکمه‌های کنترل تایمر (شروع / توقف / ریست)
          _buildControls(context, focusProvider),
          const SizedBox(height: 24),

          // ۴. انتخاب دسته‌بندی سشن
          const Text('دسته‌بندی تمرکز', style: AppTextStyles.titleMedium),
          const SizedBox(height: 10),
          _buildCategorySelector(focusProvider),
          const SizedBox(height: 20),

          // ۵. اتصال به تسک فعال (اختیاری)
          const Text('اتصال به تسک (اختیاری)', style: AppTextStyles.titleMedium),
          const SizedBox(height: 10),
          _buildTaskSelector(focusProvider, taskProvider),
          const SizedBox(height: 24),

          // ۶. تاریخچه سشن‌های ثبت‌شده امروز
          _buildTodayLogsSection(focusProvider),
        ],
      ),
    );
  }

  /// ۱. انتخابگر حالت‌های تایمر
  Widget _buildModeSelector(FocusProvider provider) {
    final modes = [
      (TimerMode.pomodoro25, '۲۵ دقیقه', Icons.timer_outlined),
      (TimerMode.deepWork50, '۵۰ دقیقه', Icons.bolt_rounded),
      (TimerMode.shortBreak5, '۵ دقیقه', Icons.coffee_rounded),
      (TimerMode.stopwatch, 'کرنومتر', Icons.timelapse_rounded),
    ];

    return GlassCard(
      padding: const EdgeInsets.all(6),
      child: Row(
        children: modes
            .map(
              (m) => Expanded(
                child: GestureDetector(
                  onTap: () => provider.setMode(m.$1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: provider.mode == m.$1
                          ? AppColors.glassActive
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: provider.mode == m.$1
                            ? AppColors.neonOrange
                            : Colors.transparent,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          m.$3,
                          size: 16,
                          color: provider.mode == m.$1
                              ? AppColors.neonOrange
                              : AppColors.textDisabled,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          m.$2,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: provider.mode == m.$1
                                ? AppColors.neonOrange
                                : AppColors.textDisabled,
                            fontWeight: provider.mode == m.$1
                                ? FontWeight.w700
                                : FontWeight.w400,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  /// ۲. دکمه‌های کنترل تایمر
  Widget _buildControls(BuildContext context, FocusProvider provider) {
    final isStopwatch = provider.mode == TimerMode.stopwatch;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // دکمه ریست
        IconButton.filledTonal(
          onPressed: (provider.isRunning || provider.isPaused)
              ? provider.resetTimer
              : null,
          icon: const Icon(Icons.refresh_rounded),
          style: IconButton.styleFrom(
            backgroundColor: AppColors.surface3,
            foregroundColor: AppColors.textSecondary,
            padding: const EdgeInsets.all(14),
          ),
          tooltip: 'ریست',
        ),
        const SizedBox(width: 20),

        // دکمه اصلی (شروع / توقف موقت)
        GestureDetector(
          onTap: () {
            if (provider.isRunning && !provider.isPaused) {
              provider.pauseTimer();
            } else {
              provider.startTimer();
            }
          },
          child: Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.neonOrange,
              boxShadow: [
                BoxShadow(
                  color: AppColors.glowNeonOrange,
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              provider.isRunning && !provider.isPaused
                  ? Icons.pause_rounded
                  : Icons.play_arrow_rounded,
              color: AppColors.textOnNeon,
              size: 38,
            ),
          ),
        ),
        const SizedBox(width: 20),

        // دکمه پایان برای کرنومتر یا ثبت سریع
        if (isStopwatch)
          IconButton.filledTonal(
            onPressed: provider.isRunning || provider.isPaused
                ? provider.stopAndLogStopwatch
                : null,
            icon: const Icon(Icons.check_rounded),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.statusDone.withOpacity(0.2),
              foregroundColor: AppColors.statusDone,
              padding: const EdgeInsets.all(14),
            ),
            tooltip: 'پایان و ثبت لاگ',
          )
        else
          const SizedBox(width: 48), // حفظ تراز
      ],
    );
  }

  /// ۳. انتخابگر دسته‌بندی
  Widget _buildCategorySelector(FocusProvider provider) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: FocusProvider.categories
          .map(
            (cat) => GestureDetector(
              onTap: () => provider.setCategory(cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: provider.selectedCategory == cat
                      ? AppColors.glassActive
                      : AppColors.surface2,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: provider.selectedCategory == cat
                        ? AppColors.neonOrange
                        : AppColors.glassBorder,
                    width: provider.selectedCategory == cat ? 1.5 : 0.8,
                  ),
                ),
                child: Text(
                  cat,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: provider.selectedCategory == cat
                        ? AppColors.neonOrange
                        : AppColors.textSecondary,
                    fontWeight: provider.selectedCategory == cat
                        ? FontWeight.w700
                        : FontWeight.w400,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  /// ۴. انتخابگر تسک
  Widget _buildTaskSelector(FocusProvider provider, TaskProvider taskProvider) {
    final activeTasks = [
      ...taskProvider.inProgressTasks,
      ...taskProvider.todoTasks,
    ];

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: provider.selectedTaskId,
          isExpanded: true,
          dropdownColor: AppColors.surface3,
          style: AppTextStyles.bodyMedium,
          hint: Text(
            'تسک مورد نظر را انتخاب کنید...',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textDisabled),
          ),
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text('بدون تسک (تمرکز عمومی)'),
            ),
            ...activeTasks.map(
              (t) => DropdownMenuItem<String?>(
                value: t.id,
                child: Text(
                  t.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
          onChanged: provider.setTaskId,
        ),
      ),
    );
  }

  /// ۵. سشن‌های امروز
  Widget _buildTodayLogsSection(FocusProvider provider) {
    final logs = provider.todayLogs;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('سشن‌های ثبت‌شده امروز', style: AppTextStyles.titleMedium),
            const Spacer(),
            Text(
              '${logs.length} مورد',
              style: AppTextStyles.labelSmall
                  .copyWith(color: AppColors.textDisabled),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (logs.isEmpty)
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Text(
                'امروز هنوز سشنی تکمیل نشده است',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textDisabled),
              ),
            ),
          )
        else
          ...logs.map(
            (log) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: GlassCard(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.neonOrange,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        log.categoryLabel,
                        style: AppTextStyles.titleSmall,
                      ),
                    ),
                    Text(
                      '${log.durationMinutes} دقیقه',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.neonOrange,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
