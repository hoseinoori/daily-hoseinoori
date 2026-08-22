/// ─────────────────────────────────────────────────────────────────────────────
/// [TaskCard] – کارت تسک در Kanban Board
///
/// نمایش تفصیلی تسک شامل:
/// - عنوان و توضیحات
/// - نوار پیشرفت نئونی
/// - بج اولویت رنگی
/// - تعداد زیرتسک‌ها
/// - ددلاین
/// - قابل Drag بین ستون‌ها
/// ─────────────────────────────────────────────────────────────────────────────
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/neon_progress_bar.dart';
import '../../../../core/widgets/task_indicators.dart';
import '../../providers/task_provider.dart';
import 'add_edit_task_sheet.dart';
import 'task_detail_sheet.dart';

/// [TaskCard] – کارت Draggable برای Kanban Board
class TaskCard extends StatelessWidget {
  final Task task;
  final String columnStatus;

  const TaskCard({
    super.key,
    required this.task,
    required this.columnStatus,
  });

  @override
  Widget build(BuildContext context) {
    final subtasks = context.watch<TaskProvider>().getSubtasksOf(task.id);
    final completedSubtasks = subtasks.where((s) => s.isCompleted).length;

    return LongPressDraggable<Task>(
      data: task,
      // فیدبک بصری هنگام drag
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: 260,
          child: _CardContent(
            task: task,
            subtasks: subtasks,
            completedSubtasks: completedSubtasks,
            isDragging: true,
          ),
        ),
      ),
      // نمایش سایه در جای اصلی هنگام drag
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _CardContent(
          task: task,
          subtasks: subtasks,
          completedSubtasks: completedSubtasks,
        ),
      ),
      child: GlassCard(
        padding: EdgeInsets.zero,
        onTap: () => _showDetail(context),
        child: _CardContent(
          task: task,
          subtasks: subtasks,
          completedSubtasks: completedSubtasks,
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TaskDetailSheet(task: task),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// ████  محتوای کارت تسک  ████
// ═════════════════════════════════════════════════════════════════════════════
class _CardContent extends StatelessWidget {
  final Task task;
  final List<Subtask> subtasks;
  final int completedSubtasks;
  final bool isDragging;

  const _CardContent({
    required this.task,
    required this.subtasks,
    required this.completedSubtasks,
    this.isDragging = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.surface2,
        border: Border.all(
          color: isDragging
              ? AppColors.neonOrange.withOpacity(0.6)
              : AppColors.glassBorder,
          width: isDragging ? 1.5 : 0.8,
        ),
        boxShadow: isDragging
            ? [
                BoxShadow(
                  color: AppColors.glowNeonOrange,
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── ردیف اول: اولویت + وضعیت ─────────────────────────────────────
            Row(
              children: [
                if (task.priority != null)
                  PriorityBadge(priority: task.priority!, showLabel: false),
                const Spacer(),
                StatusChip(status: task.status, compact: true),
              ],
            ),
            const SizedBox(height: 8),

            // ── عنوان تسک ────────────────────────────────────────────────────
            Text(
              task.title,
              style: AppTextStyles.titleMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            // ── توضیحات (اختیاری) ────────────────────────────────────────────
            if (task.description != null && task.description!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                task.description!,
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textDisabled),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            const SizedBox(height: 10),

            // ── نوار پیشرفت نئونی ─────────────────────────────────────────────
            NeonProgressBar(
              value: task.progressPercentage / 100.0,
              height: 5,
              showLabel: true,
            ),

            const SizedBox(height: 10),

            // ── ردیف پایین: زیرتسک‌ها + ددلاین ───────────────────────────────
            Row(
              children: [
                // تعداد زیرتسک‌ها
                if (subtasks.isNotEmpty) ...[
                  Icon(
                    Icons.checklist_rounded,
                    size: 14,
                    color: completedSubtasks == subtasks.length
                        ? AppColors.statusDone
                        : AppColors.textDisabled,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$completedSubtasks/${subtasks.length}',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: completedSubtasks == subtasks.length
                          ? AppColors.statusDone
                          : AppColors.textDisabled,
                    ),
                  ),
                ],
                const Spacer(),
                // ددلاین
                if (task.deadline != null)
                  _DeadlineChip(deadline: task.deadline!),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// ████  چیپ ددلاین  ████
// ═════════════════════════════════════════════════════════════════════════════
class _DeadlineChip extends StatelessWidget {
  final DateTime deadline;

  const _DeadlineChip({required this.deadline});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final daysLeft = deadline.difference(now).inDays;
    final isOverdue = deadline.isBefore(now);
    final isUrgent = daysLeft <= 2 && !isOverdue;

    final Color chipColor = isOverdue
        ? AppColors.priorityUrgent
        : isUrgent
            ? AppColors.priorityHigh
            : AppColors.textDisabled;

    final String label = isOverdue
        ? 'گذشته'
        : daysLeft == 0
            ? 'امروز'
            : '$daysLeft روز';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: chipColor.withOpacity(0.4), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOverdue ? Icons.warning_rounded : Icons.schedule_rounded,
            size: 11,
            color: chipColor,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(color: chipColor),
          ),
        ],
      ),
    );
  }
}
