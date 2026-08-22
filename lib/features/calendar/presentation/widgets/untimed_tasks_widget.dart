/// ─────────────────────────────────────────────────────────────────────────────
/// [UntimedTasksWidget] – تسک‌های بدون زمان مشخص (چک‌لیست آزاد روز)
///
/// نمایش کارهایی که برای این تاریخ برنامه‌ریزی شده‌اند اما بازه ساعتی ندارند.
/// ─────────────────────────────────────────────────────────────────────────────
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/neon_progress_bar.dart';
import '../../../../core/widgets/task_indicators.dart';
import '../../../tasks/presentation/widgets/add_edit_task_sheet.dart';
import '../../../tasks/presentation/widgets/task_detail_sheet.dart';
import '../../../tasks/providers/task_provider.dart';
import '../../providers/calendar_provider.dart';

/// [UntimedTasksWidget] – لیست کارهای آزاد روز
class UntimedTasksWidget extends StatelessWidget {
  const UntimedTasksWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final calendarProvider = context.watch<CalendarProvider>();
    final taskProvider = context.watch<TaskProvider>();
    final untimedTasks = calendarProvider.untimedTasks;

    if (untimedTasks.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 36),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle_outline_rounded,
                size: 48,
                color: AppColors.textDisabled.withOpacity(0.5),
              ),
              const SizedBox(height: 12),
              Text(
                'هیچ کار آزادی برای این روز ثبت نشده است',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textDisabled,
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => AddEditTaskSheet(
                      existingTask: null,
                    ),
                  );
                },
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('افزودن کار برای امروز'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.neonOrange,
                  side: const BorderSide(color: AppColors.neonOrange),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: untimedTasks.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final task = untimedTasks[index];
        final isDone = task.status == AppConstants.taskStatusDone;

        return GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => TaskDetailSheet(task: task),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // چک‌باکس تغییر سریع وضعیت به Done
                  GestureDetector(
                    onTap: () {
                      final newStatus = isDone
                          ? AppConstants.taskStatusTodo
                          : AppConstants.taskStatusDone;
                      taskProvider.moveTask(task.id, newStatus);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDone
                            ? AppColors.statusDone
                            : Colors.transparent,
                        border: Border.all(
                          color: isDone
                              ? AppColors.statusDone
                              : AppColors.glassBorder,
                          width: 1.5,
                        ),
                      ),
                      child: isDone
                          ? const Icon(
                              Icons.check_rounded,
                              size: 16,
                              color: Colors.black,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // عنوان تسک
                  Expanded(
                    child: Text(
                      task.title,
                      style: AppTextStyles.titleMedium.copyWith(
                        decoration: isDone ? TextDecoration.lineThrough : null,
                        color: isDone
                            ? AppColors.textDisabled
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),

                  // اولویت
                  if (task.priority != null)
                    PriorityBadge(
                      priority: task.priority!,
                      showLabel: false,
                    ),
                ],
              ),

              // نوار پیشرفت در صورت وجود زیرتسک یا پیشرفت جزئی
              if (task.progressPercentage > 0 && !isDone) ...[
                const SizedBox(height: 10),
                NeonProgressBar(
                  value: task.progressPercentage / 100,
                  height: 4,
                  showLabel: false,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
