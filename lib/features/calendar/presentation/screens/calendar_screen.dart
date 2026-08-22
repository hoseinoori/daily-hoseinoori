/// ─────────────────────────────────────────────────────────────────────────────
/// [CalendarScreen] – صفحه اصلی تقویم شمسی و نمای تفصیلی روزانه
///
/// این صفحه شامل:
/// - کارت تقویم ماهانه جلالی (MonthCalendarWidget)
/// - نوار مشخصات روز انتخابی همراه با مناسبت‌ها و تعطیلات
/// - تب‌بار سوئیچ بین دو حالت:
///   ۱. گاه‌شمار ساعتی (Timeline Mode)
///   ۲. کارهای آزاد روز (Untimed Tasks)
/// - دکمه شناور افزودن تسک برای تاریخ انتخاب‌شده
/// ─────────────────────────────────────────────────────────────────────────────
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../tasks/presentation/widgets/add_edit_task_sheet.dart';
import '../../providers/calendar_provider.dart';
import '../widgets/month_calendar_widget.dart';
import '../widgets/timeline_view_widget.dart';
import '../widgets/untimed_tasks_widget.dart';

/// [CalendarScreen] – صفحه اصلی ماژول تقویم
class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final calendarProvider = context.watch<CalendarProvider>();
    final selectedDate = calendarProvider.selectedDate;
    final events = calendarProvider.selectedDayEvents;
    final isHoliday = calendarProvider.isHoliday(selectedDate);

    return Scaffold(
      // ── نوار بالایی ────────────────────────────────────────────────────────
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('تقویم و گاه‌شمار روزانه', style: AppTextStyles.headlineSmall),
            Text(
              selectedDate.fullFormatted,
              style: AppTextStyles.bodySmall.copyWith(
                color: isHoliday
                    ? AppColors.priorityUrgent
                    : AppColors.neonOrange,
              ),
            ),
          ],
        ),
        actions: [
          // دکمه بازگشت به امروز
          IconButton(
            icon: const Icon(Icons.today_rounded, color: AppColors.neonOrange),
            tooltip: 'امروز',
            onPressed: calendarProvider.goToToday,
          ),
          const SizedBox(width: 8),
        ],
      ),

      // ── بدنه اصلی تقویم و نمای روزانه ──────────────────────────────────────
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        children: [
          // ۱. ویجت تقویم ماهانه
          const MonthCalendarWidget(),
          const SizedBox(height: 16),

          // ۲. بنر اطلاعات روز انتخابی و رویدادها
          _SelectedDayBanner(
            date: selectedDate,
            isHoliday: isHoliday,
            events: events,
          ),
          const SizedBox(height: 16),

          // ۳. کنترل سوئیچ حالت نمایش روزانه (Timeline vs Untimed)
          _DailyModeSelector(
            isTimelineMode: calendarProvider.isTimelineMode,
            onModeChanged: calendarProvider.setTimelineMode,
          ),
          const SizedBox(height: 16),

          // ۴. محتوای روز انتخابی بر اساس حالت فعال
          if (calendarProvider.isTimelineMode)
            const TimelineViewWidget()
          else
            const UntimedTasksWidget(),
        ],
      ),

      // ── دکمه شناور افزودن تسک برای این تاریخ ────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => const AddEditTaskSheet(),
          );
        },
        icon: const Icon(Icons.add_task_rounded),
        label: const Text('تسک برای این روز', style: AppTextStyles.labelLarge),
        backgroundColor: AppColors.neonOrange,
        foregroundColor: AppColors.textOnNeon,
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// ████  بنر مشخصات روز انتخابی و مناسبت‌ها  ████
// ═════════════════════════════════════════════════════════════════════════════
class _SelectedDayBanner extends StatelessWidget {
  final dynamic date;
  final bool isHoliday;
  final List<dynamic> events;

  const _SelectedDayBanner({
    required this.date,
    required this.isHoliday,
    required this.events,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      borderColor: isHoliday
          ? AppColors.priorityUrgent.withOpacity(0.4)
          : AppColors.neonOrange.withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // آیکون وضعیت روز
              Icon(
                isHoliday ? Icons.celebration_rounded : Icons.event_rounded,
                color:
                    isHoliday ? AppColors.priorityUrgent : AppColors.neonOrange,
                size: 20,
              ),
              const SizedBox(width: 10),
              // نام روز و تاریخ
              Expanded(
                child: Text(
                  date.fullFormatted,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: isHoliday
                        ? AppColors.priorityUrgent
                        : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // بج تعطیل رسمی
              if (isHoliday)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.priorityUrgent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.priorityUrgent.withOpacity(0.5),
                    ),
                  ),
                  child: Text(
                    'تعطیل',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.priorityUrgent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),

          // لیست رویدادها و مناسبت‌ها
          if (events.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Divider(height: 1, color: AppColors.glassBorder),
            const SizedBox(height: 8),
            ...events.map(
              (event) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: event.isHoliday
                            ? AppColors.priorityUrgent
                            : AppColors.neonOrangeLight,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        event.title,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: event.isHoliday
                              ? AppColors.priorityUrgent
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// ████  سوئیچ دوحالته گاه‌شمار / کارهای آزاد  ████
// ═════════════════════════════════════════════════════════════════════════════
class _DailyModeSelector extends StatelessWidget {
  final bool isTimelineMode;
  final void Function(bool) onModeChanged;

  const _DailyModeSelector({
    required this.isTimelineMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.glassBorder),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          // تب ۱: گاه‌شمار ساعتی
          Expanded(
            child: _ModeTabButton(
              title: 'گاه‌شمار (Timeline)',
              icon: Icons.view_timeline_rounded,
              isActive: isTimelineMode,
              onTap: () => onModeChanged(true),
            ),
          ),
          const SizedBox(width: 6),
          // تب ۲: کارهای روز
          Expanded(
            child: _ModeTabButton(
              title: 'کارهای آزاد روز',
              icon: Icons.checklist_rounded,
              isActive: !isTimelineMode,
              onTap: () => onModeChanged(false),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeTabButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _ModeTabButton({
    required this.title,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.glassActive : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? AppColors.neonOrange : Colors.transparent,
            width: isActive ? 1.2 : 0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive ? AppColors.neonOrange : AppColors.textDisabled,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: AppTextStyles.labelSmall.copyWith(
                color: isActive ? AppColors.neonOrange : AppColors.textDisabled,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
