/// ─────────────────────────────────────────────────────────────────────────────
/// [TimelineViewWidget] – محور زمانی ۲۴ ساعته (Timeline Mode)
///
/// نمایش روزانه از ساعت ۰۰:۰۰ تا ۲۳:۰۰ شامل:
/// - خطوط افقی هر ساعت
/// - کارت تسک‌های دارای بازه زمانی مشخص (Scheduled Tasks)
/// - کارت روتین‌های هفتگی همان روز
/// - خط افقی نشانگر زمان فعلی (در صورت انتخاب امروز)
/// ─────────────────────────────────────────────────────────────────────────────
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../tasks/presentation/widgets/task_detail_sheet.dart';
import '../../providers/calendar_provider.dart';
import '../../utils/jalali_helper.dart';

/// [TimelineViewWidget] – نمای تایم‌لاین ۲۴ ساعته
class TimelineViewWidget extends StatelessWidget {
  const TimelineViewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CalendarProvider>();
    final timelineTasks = provider.timelineTasks;
    final routines = provider.dailyRoutines;
    final isToday = provider.selectedDate.isSameDay(JalaliDate.now());
    final now = DateTime.now();

    return Column(
      children: List.generate(24, (hour) {
        final hourStr = '${hour.toString().padLeft(2, '0')}:00';
        final nextHourStr = '${(hour + 1).toString().padLeft(2, '0')}:00';

        // تسک‌هایی که در این ساعت شروع می‌شوند
        final matchingTasks = timelineTasks.where((t) {
          if (t.startTime == null) return false;
          final startHour = int.tryParse(t.startTime!.split(':')[0]);
          return startHour == hour;
        }).toList();

        // روتین‌هایی که در این ساعت شروع می‌شوند
        final matchingRoutines = routines.where((r) {
          final startHour = int.tryParse(r.startTime.split(':')[0]);
          return startHour == hour;
        }).toList();

        final hasItems = matchingTasks.isNotEmpty || matchingRoutines.isNotEmpty;

        return Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppColors.glassBorder.withOpacity(0.4),
                width: 0.5,
              ),
            ),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── ستون ساعت (Ruler) ──────────────────────────────────────────
                SizedBox(
                  width: 54,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      hourStr,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: isToday && now.hour == hour
                            ? AppColors.neonOrange
                            : AppColors.textDisabled,
                        fontWeight: isToday && now.hour == hour
                            ? FontWeight.w700
                            : FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

                // ── خط جداکننده عمودی ─────────────────────────────────────────
                Container(
                  width: 1,
                  color: isToday && now.hour == hour
                      ? AppColors.neonOrange.withOpacity(0.5)
                      : AppColors.glassBorder,
                ),

                // ── محتوای بازه زمانی ─────────────────────────────────────────
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // خط نشانگر زمان واقعی (فقط برای امروز)
                        if (isToday && now.hour == hour)
                          _CurrentTimeIndicator(minute: now.minute),

                        // نمایش روتین‌ها
                        ...matchingRoutines.map(
                          (routine) => _RoutineTimelineBlock(routine: routine),
                        ),

                        // نمایش تسک‌ها
                        ...matchingTasks.map(
                          (task) => _TaskTimelineBlock(task: task),
                        ),

                        // اگر در این ساعت کلا کاری نیست، یک فضای خالی با حداقل ارتفاع
                        if (!hasItems) const SizedBox(height: 28),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// ████  بلاک تسک در تایم‌لاین  ████
// ═════════════════════════════════════════════════════════════════════════════
class _TaskTimelineBlock extends StatelessWidget {
  final Task task;

  const _TaskTimelineBlock({required this.task});

  @override
  Widget build(BuildContext context) {
    final isDone = task.status == 'done';

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: GestureDetector(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => TaskDetailSheet(task: task),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isDone
                ? AppColors.statusDone.withOpacity(0.12)
                : AppColors.neonOrange.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDone
                  ? AppColors.statusDone.withOpacity(0.5)
                  : AppColors.neonOrange.withOpacity(0.6),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isDone
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_checked_rounded,
                color: isDone ? AppColors.statusDone : AppColors.neonOrange,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  task.title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    decoration: isDone ? TextDecoration.lineThrough : null,
                    color: isDone ? AppColors.textDisabled : AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (task.startTime != null && task.endTime != null)
                Text(
                  '${task.startTime} - ${task.endTime}',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isDone ? AppColors.statusDone : AppColors.neonOrange,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// ████  بلاک روتین در تایم‌لاین  ████
// ═════════════════════════════════════════════════════════════════════════════
class _RoutineTimelineBlock extends StatelessWidget {
  final RecurringRoutine routine;

  const _RoutineTimelineBlock({required this.routine});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF4FC3F7).withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFF4FC3F7).withOpacity(0.4),
            width: 0.8,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.alarm_rounded,
              color: Color(0xFF4FC3F7),
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'روتین: ${routine.title}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '${routine.startTime} - ${routine.endTime}',
              style: AppTextStyles.labelSmall.copyWith(
                color: const Color(0xFF4FC3F7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// ████  نشانگر زمان جاری  ████
// ═════════════════════════════════════════════════════════════════════════════
class _CurrentTimeIndicator extends StatelessWidget {
  final int minute;

  const _CurrentTimeIndicator({required this.minute});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.neonOrange,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Container(
              height: 1.5,
              color: AppColors.neonOrange.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
