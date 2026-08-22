/// ─────────────────────────────────────────────────────────────────────────────
/// [KanbanScreen] – صفحه اصلی Kanban Board
///
/// نمایش تسک‌ها در سه ستون: Todo, In Progress, Done
/// با قابلیت:
/// - Drag & Drop بین ستون‌ها
/// - فیلتر بر اساس نقش
/// - نوار پیشرفت نئونی برای هر تسک
/// - ددلاین و اولویت رنگی
/// ─────────────────────────────────────────────────────────────────────────────
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../roles/providers/role_provider.dart';
import '../../providers/task_provider.dart';
import '../widgets/add_edit_task_sheet.dart';
import '../widgets/kanban_column.dart';

/// [KanbanScreen] – صفحه Kanban Board اصلی
class KanbanScreen extends StatelessWidget {
  const KanbanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ── AppBar با فیلتر نقش ────────────────────────────────────────────────
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('کانبان تسک‌ها', style: AppTextStyles.headlineSmall),
            Consumer<TaskProvider>(
              builder: (_, p, __) => Text(
                '${p.totalActiveTasks} تسک فعال',
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textDisabled),
              ),
            ),
          ],
        ),
        actions: [
          // دکمه فیلتر نقش
          _RoleFilterButton(),
          const SizedBox(width: 8),
        ],
      ),

      // ── Kanban Board – اسکرول افقی ─────────────────────────────────────────
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, _) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16),
            physics: const BouncingScrollPhysics(),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ستون ۱: در انتظار
                KanbanColumn(
                  title: 'در انتظار',
                  status: AppConstants.taskStatusTodo,
                  tasks: taskProvider.todoTasks,
                  accentColor: AppColors.statusTodo,
                  icon: Icons.radio_button_unchecked_rounded,
                ),
                const SizedBox(width: 12),
                // ستون ۲: در جریان
                KanbanColumn(
                  title: 'در جریان',
                  status: AppConstants.taskStatusInProgress,
                  tasks: taskProvider.inProgressTasks,
                  accentColor: AppColors.neonOrange,
                  icon: Icons.timelapse_rounded,
                ),
                const SizedBox(width: 12),
                // ستون ۳: انجام‌شده
                KanbanColumn(
                  title: 'انجام‌شده',
                  status: AppConstants.taskStatusDone,
                  tasks: taskProvider.doneTasks,
                  accentColor: AppColors.statusDone,
                  icon: Icons.check_circle_rounded,
                ),
              ],
            ),
          );
        },
      ),

      // ── دکمه افزودن تسک ────────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTask(context),
        icon: const Icon(Icons.add_task_rounded),
        label: const Text('تسک جدید', style: AppTextStyles.labelLarge),
        backgroundColor: AppColors.neonOrange,
        foregroundColor: AppColors.textOnNeon,
      ),
    );
  }

  void _showAddTask(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddEditTaskSheet(),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// ████  دکمه فیلتر نقش  ████
// ═════════════════════════════════════════════════════════════════════════════
class _RoleFilterButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final roleProvider = context.watch<RoleProvider>();
    final isFiltered = taskProvider.activeRoleFilter != null;

    return IconButton(
      tooltip: 'فیلتر بر اساس نقش',
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isFiltered ? AppColors.glassActive : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isFiltered ? AppColors.neonOrange : AppColors.glassBorder,
            width: isFiltered ? 1.5 : 1,
          ),
        ),
        child: Icon(
          Icons.filter_list_rounded,
          color: isFiltered ? AppColors.neonOrange : AppColors.textSecondary,
          size: 20,
        ),
      ),
      onPressed: () => _showFilterSheet(context, taskProvider, roleProvider),
    );
  }

  void _showFilterSheet(BuildContext context, TaskProvider taskProvider,
      RoleProvider roleProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface2,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('فیلتر بر اساس نقش', style: AppTextStyles.titleLarge),
            ),
            const Divider(height: 1),
            // گزینه همه
            ListTile(
              leading: const Icon(Icons.select_all_rounded,
                  color: AppColors.textSecondary),
              title: const Text('همه تسک‌ها'),
              selected: taskProvider.activeRoleFilter == null,
              selectedColor: AppColors.neonOrange,
              onTap: () {
                taskProvider.setRoleFilter(null);
                Navigator.pop(context);
              },
            ),
            // نقش‌های موجود
            ...roleProvider.allRoles.map(
              (role) => ListTile(
                leading: const Icon(Icons.account_tree_rounded,
                    color: AppColors.neonOrange),
                title: Text(role.title),
                selected: taskProvider.activeRoleFilter == role.id,
                selectedColor: AppColors.neonOrange,
                onTap: () {
                  taskProvider.setRoleFilter(role.id);
                  Navigator.pop(context);
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
