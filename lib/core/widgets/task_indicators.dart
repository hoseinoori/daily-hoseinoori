/// ─────────────────────────────────────────────────────────────────────────────
/// [PriorityBadge] – بج نمایش اولویت تسک
/// [StatusChip]    – چیپ نمایش وضعیت تسک
/// ─────────────────────────────────────────────────────────────────────────────
library;

import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

// ═════════════════════════════════════════════════════════════════════════════
// ████  PriorityBadge – نمایشگر اولویت  ████
// ═════════════════════════════════════════════════════════════════════════════

/// [PriorityBadge] – نشانگر اولویت تسک
///
/// نمایش بج رنگی برای سطوح اولویت: low | medium | high | urgent
class PriorityBadge extends StatelessWidget {
  /// سطح اولویت: 'low' | 'medium' | 'high' | 'urgent'
  final String priority;

  /// آیا لیبل متنی نمایش داده شود؟
  final bool showLabel;

  /// اندازه آیکون/دایره
  final double size;

  const PriorityBadge({
    super.key,
    required this.priority,
    this.showLabel = true,
    this.size = 8,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getPriorityConfig(priority);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // دایره رنگی نشانگر اولویت
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: config.color,
            boxShadow: [
              BoxShadow(
                color: config.color.withOpacity(0.6),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        if (showLabel) ...[
          const SizedBox(width: 6),
          Text(
            config.label,
            style: AppTextStyles.labelSmall.copyWith(
              color: config.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }

  /// [_getPriorityConfig] – تنظیمات رنگ و متن هر سطح اولویت
  _PriorityConfig _getPriorityConfig(String priority) {
    return switch (priority) {
      AppConstants.priorityUrgent => _PriorityConfig(
          color: AppColors.priorityUrgent,
          label: 'فوری',
          icon: Icons.warning_rounded,
        ),
      AppConstants.priorityHigh => _PriorityConfig(
          color: AppColors.priorityHigh,
          label: 'بالا',
          icon: Icons.keyboard_arrow_up_rounded,
        ),
      AppConstants.priorityMedium => _PriorityConfig(
          color: AppColors.priorityMedium,
          label: 'متوسط',
          icon: Icons.remove_rounded,
        ),
      _ => _PriorityConfig(
          color: AppColors.priorityLow,
          label: 'پایین',
          icon: Icons.keyboard_arrow_down_rounded,
        ),
    };
  }
}

/// مدل داخلی برای تنظیمات اولویت
class _PriorityConfig {
  final Color color;
  final String label;
  final IconData icon;

  _PriorityConfig({
    required this.color,
    required this.label,
    required this.icon,
  });
}

// ═════════════════════════════════════════════════════════════════════════════
// ████  StatusChip – نمایشگر وضعیت تسک  ████
// ═════════════════════════════════════════════════════════════════════════════

/// [StatusChip] – چیپ نمایش وضعیت تسک
///
/// نمایش وضعیت رنگی: todo | in_progress | done
class StatusChip extends StatelessWidget {
  /// وضعیت تسک: 'todo' | 'in_progress' | 'done'
  final String status;

  /// آیا compact باشد؟
  final bool compact;

  const StatusChip({
    super.key,
    required this.status,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig(status);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: config.color.withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: config.color,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            config.label,
            style: AppTextStyles.labelSmall.copyWith(
              color: config.color,
              fontWeight: FontWeight.w600,
              fontSize: compact ? 10 : 11,
            ),
          ),
        ],
      ),
    );
  }

  _StatusConfig _getStatusConfig(String status) {
    return switch (status) {
      AppConstants.taskStatusDone => _StatusConfig(
          color: AppColors.statusDone,
          label: 'انجام‌شده',
        ),
      AppConstants.taskStatusInProgress => _StatusConfig(
          color: AppColors.statusInProgress,
          label: 'در جریان',
        ),
      _ => _StatusConfig(
          color: AppColors.statusTodo,
          label: 'در انتظار',
        ),
    };
  }
}

class _StatusConfig {
  final Color color;
  final String label;
  _StatusConfig({required this.color, required this.label});
}
