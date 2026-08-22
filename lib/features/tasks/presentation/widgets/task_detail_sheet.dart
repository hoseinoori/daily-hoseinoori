/// ─────────────────────────────────────────────────────────────────────────────
/// [TaskDetailSheet] – Bottom Sheet جزئیات تسک
///
/// نمایش کامل اطلاعات تسک شامل:
/// - توضیحات کامل
/// - مدیریت زیرتسک‌ها (چک‌لیست)
/// - دکمه‌های تغییر وضعیت
/// - ویرایش و حذف
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
import '../../providers/task_provider.dart';
import 'add_edit_task_sheet.dart';

/// [TaskDetailSheet] – شیت جزئیات کامل تسک
class TaskDetailSheet extends StatefulWidget {
  final Task task;

  const TaskDetailSheet({super.key, required this.task});

  @override
  State<TaskDetailSheet> createState() => _TaskDetailSheetState();
}

class _TaskDetailSheetState extends State<TaskDetailSheet> {
  final _subtaskController = TextEditingController();
  bool _isAddingSubtask = false;

  @override
  void dispose() {
    _subtaskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final subtasks = provider.getSubtasksOf(widget.task.id);
    final completedCount = subtasks.where((s) => s.isCompleted).length;

    return Container(
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── هدر ──────────────────────────────────────────────────────────────
          _buildHeader(context),

          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // اطلاعات اولویت و وضعیت
                  Row(
                    children: [
                      if (widget.task.priority != null)
                        PriorityBadge(priority: widget.task.priority!),
                      const Spacer(),
                      StatusChip(status: widget.task.status),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // پیشرفت
                  NeonProgressBar(
                    value: widget.task.progressPercentage / 100,
                    height: 8,
                    showLabel: true,
                  ),
                  const SizedBox(height: 16),

                  // توضیحات
                  if (widget.task.description != null &&
                      widget.task.description!.isNotEmpty) ...[
                    Text('توضیحات', style: AppTextStyles.titleSmall),
                    const SizedBox(height: 8),
                    GlassCard(
                      child: Text(
                        widget.task.description!,
                        style: AppTextStyles.bodyMedium,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ددلاین
                  if (widget.task.deadline != null) ...[
                    Row(
                      children: [
                        const Icon(Icons.schedule_rounded,
                            color: AppColors.neonOrange, size: 16),
                        const SizedBox(width: 6),
                        Text('مهلت: ', style: AppTextStyles.titleSmall),
                        Text(
                          _formatDate(widget.task.deadline!),
                          style: AppTextStyles.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  // زیرتسک‌ها / چک‌لیست
                  Row(
                    children: [
                      Text(
                        'چک‌لیست ($completedCount/${subtasks.length})',
                        style: AppTextStyles.titleSmall,
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () =>
                            setState(() => _isAddingSubtask = !_isAddingSubtask),
                        child: Icon(
                          _isAddingSubtask
                              ? Icons.close_rounded
                              : Icons.add_rounded,
                          color: AppColors.neonOrange,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // فرم افزودن زیرتسک
                  if (_isAddingSubtask) ...[
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _subtaskController,
                            autofocus: true,
                            style: AppTextStyles.bodyMedium,
                            decoration: const InputDecoration(
                              hintText: 'عنوان زیرتسک...',
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                            ),
                            onSubmitted: (_) => _addSubtask(context),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => _addSubtask(context),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(12),
                            minimumSize: const Size(44, 44),
                          ),
                          child: const Icon(Icons.check_rounded, size: 18),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],

                  // لیست زیرتسک‌ها
                  if (subtasks.isEmpty && !_isAddingSubtask)
                    Text(
                      'هنوز زیرتسکی تعریف نشده. + را بزن.',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textDisabled),
                    )
                  else
                    ...subtasks.map(
                      (subtask) => _SubtaskItem(
                        subtask: subtask,
                        taskId: widget.task.id,
                      ),
                    ),

                  const SizedBox(height: 24),

                  // دکمه‌های تغییر وضعیت سریع
                  Text('تغییر وضعیت', style: AppTextStyles.titleSmall),
                  const SizedBox(height: 10),
                  _buildStatusButtons(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// [_buildHeader] – هدر شیت با عنوان و دکمه‌های ویرایش/حذف
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 16, 16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.glassBorder, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(widget.task.title, style: AppTextStyles.headlineSmall),
          ),
          // ویرایش
          IconButton(
            icon: const Icon(Icons.edit_rounded, color: AppColors.textSecondary),
            onPressed: () {
              Navigator.pop(context);
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => AddEditTaskSheet(existingTask: widget.task),
              );
            },
          ),
          // حذف
          IconButton(
            icon: const Icon(Icons.delete_rounded,
                color: AppColors.priorityUrgent),
            onPressed: () => _deleteTask(context),
          ),
          // بستن
          IconButton(
            icon: const Icon(Icons.close_rounded,
                color: AppColors.textDisabled),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  /// [_buildStatusButtons] – دکمه‌های تغییر وضعیت سریع
  Widget _buildStatusButtons(BuildContext context) {
    final currentStatus = widget.task.status;
    final statuses = [
      (AppConstants.taskStatusTodo, 'در انتظار', AppColors.statusTodo),
      (
        AppConstants.taskStatusInProgress,
        'در جریان',
        AppColors.neonOrange
      ),
      (AppConstants.taskStatusDone, 'انجام‌شده', AppColors.statusDone),
    ];

    return Row(
      children: statuses
          .map(
            (s) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: OutlinedButton(
                    onPressed: currentStatus == s.$1
                        ? null
                        : () {
                            context
                                .read<TaskProvider>()
                                .moveTask(widget.task.id, s.$1);
                            Navigator.pop(context);
                          },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: s.$3,
                      side: BorderSide(
                        color: currentStatus == s.$1
                            ? s.$3
                            : s.$3.withOpacity(0.4),
                        width: currentStatus == s.$1 ? 2 : 1,
                      ),
                      backgroundColor: currentStatus == s.$1
                          ? s.$3.withOpacity(0.15)
                          : Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: Text(
                      s.$2,
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Future<void> _addSubtask(BuildContext context) async {
    final title = _subtaskController.text.trim();
    if (title.isEmpty) return;
    await context.read<TaskProvider>().addSubtask(widget.task.id, title);
    _subtaskController.clear();
    setState(() => _isAddingSubtask = false);
  }

  Future<void> _deleteTask(BuildContext context) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('حذف تسک'),
            content: Text(
                'آیا از حذف "${widget.task.title}" اطمینان دارید؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('انصراف'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.priorityUrgent),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('حذف'),
              ),
            ],
          ),
        ) ??
        false;

    if (confirmed && mounted) {
      await context.read<TaskProvider>().deleteTask(widget.task.id);
      if (mounted) Navigator.pop(context);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// ████  آیتم زیرتسک در چک‌لیست  ████
// ═════════════════════════════════════════════════════════════════════════════
class _SubtaskItem extends StatelessWidget {
  final Subtask subtask;
  final String taskId;

  const _SubtaskItem({required this.subtask, required this.taskId});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          // Checkbox
          GestureDetector(
            onTap: () => context.read<TaskProvider>().toggleSubtask(
                  subtask.id,
                  taskId,
                  !subtask.isCompleted,
                ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: subtask.isCompleted
                    ? AppColors.statusDone
                    : Colors.transparent,
                border: Border.all(
                  color: subtask.isCompleted
                      ? AppColors.statusDone
                      : AppColors.glassBorder,
                  width: 1.5,
                ),
              ),
              child: subtask.isCompleted
                  ? const Icon(Icons.check_rounded,
                      color: Colors.black, size: 14)
                  : null,
            ),
          ),
          const SizedBox(width: 10),
          // عنوان
          Expanded(
            child: Text(
              subtask.title,
              style: AppTextStyles.bodyMedium.copyWith(
                decoration: subtask.isCompleted
                    ? TextDecoration.lineThrough
                    : null,
                color: subtask.isCompleted
                    ? AppColors.textDisabled
                    : AppColors.textPrimary,
              ),
            ),
          ),
          // حذف زیرتسک
          GestureDetector(
            onTap: () => context
                .read<TaskProvider>()
                .deleteSubtask(subtask.id, taskId),
            child: const Icon(Icons.close_rounded,
                size: 16, color: AppColors.textDisabled),
          ),
        ],
      ),
    );
  }
}
