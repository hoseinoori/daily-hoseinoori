/// ─────────────────────────────────────────────────────────────────────────────
/// [KanbanColumn] – ستون Kanban با DragTarget
///
/// هر ستون یک [DragTarget] است که TaskCard های [Draggable] را می‌پذیرد.
/// هنگام drop، وضعیت تسک به status این ستون تغییر می‌کند.
/// ─────────────────────────────────────────────────────────────────────────────
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../providers/task_provider.dart';
import 'task_card.dart';

/// [KanbanColumn] – ستون Kanban با امکان Drag & Drop
class KanbanColumn extends StatefulWidget {
  /// عنوان ستون (مثل: در انتظار)
  final String title;

  /// وضعیت این ستون: 'todo' | 'in_progress' | 'done'
  final String status;

  /// لیست تسک‌های این ستون
  final List<Task> tasks;

  /// رنگ شاخص ستون
  final Color accentColor;

  /// آیکون ستون
  final IconData icon;

  const KanbanColumn({
    super.key,
    required this.title,
    required this.status,
    required this.tasks,
    required this.accentColor,
    required this.icon,
  });

  @override
  State<KanbanColumn> createState() => _KanbanColumnState();
}

class _KanbanColumnState extends State<KanbanColumn> {
  /// آیا چیزی روی این ستون drag شده؟ (برای Highlight)
  bool _isDragOver = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: DragTarget<Task>(
        onWillAcceptWithDetails: (details) {
          // قبول کارت‌هایی که وضعیت متفاوت دارند
          final willAccept = details.data.status != widget.status;
          setState(() => _isDragOver = willAccept);
          return willAccept;
        },
        onAcceptWithDetails: (details) {
          setState(() => _isDragOver = false);
          context.read<TaskProvider>().moveTask(
                details.data.id,
                widget.status,
              );
        },
        onLeave: (_) => setState(() => _isDragOver = false),

        builder: (context, candidateData, rejectedData) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: _isDragOver
                  ? widget.accentColor.withOpacity(0.08)
                  : AppColors.surface1,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isDragOver
                    ? widget.accentColor.withOpacity(0.5)
                    : AppColors.glassBorder,
                width: _isDragOver ? 1.5 : 0.8,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── هدر ستون ─────────────────────────────────────────────────
                _buildColumnHeader(),

                // ── لیست تسک‌ها ──────────────────────────────────────────────
                if (widget.tasks.isEmpty)
                  _buildEmptyColumn()
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(10, 8, 10, 80),
                      itemCount: widget.tasks.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, index) => TaskCard(
                        task: widget.tasks[index],
                        columnStatus: widget.status,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// [_buildColumnHeader] – هدر ستون با تعداد تسک‌ها
  Widget _buildColumnHeader() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: widget.accentColor.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // آیکون رنگی
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: widget.accentColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(widget.icon, color: widget.accentColor, size: 18),
          ),
          const SizedBox(width: 10),
          // عنوان ستون
          Expanded(
            child: Text(
              widget.title,
              style: AppTextStyles.titleMedium.copyWith(
                color: widget.accentColor,
              ),
            ),
          ),
          // بج تعداد
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: widget.accentColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.accentColor.withOpacity(0.3),
              ),
            ),
            child: Text(
              '${widget.tasks.length}',
              style: AppTextStyles.labelSmall.copyWith(
                color: widget.accentColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// [_buildEmptyColumn] – نمایش حالت خالی ستون
  Widget _buildEmptyColumn() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Icon(
            Icons.inbox_rounded,
            color: AppColors.textDisabled,
            size: 36,
          ),
          const SizedBox(height: 8),
          Text(
            'خالی است',
            style:
                AppTextStyles.bodySmall.copyWith(color: AppColors.textDisabled),
          ),
          const SizedBox(height: 4),
          Text(
            'کارت‌ها را اینجا بکش',
            style:
                AppTextStyles.bodySmall.copyWith(color: AppColors.textDisabled),
          ),
        ],
      ),
    );
  }
}
