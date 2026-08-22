/// ─────────────────────────────────────────────────────────────────────────────
/// [MonthCalendarWidget] – ویجت نمایش ماهانه تقویم جلالی با گلس‌مورفیسم
///
/// نمایش گرید ۷ ستونی (شنبه تا جمعه) همراه با:
/// - سوئیچ بین ماه‌ها
/// - هایلایت روز جاری (Today Glow)
/// - هایلایت روز انتخابی (Selected Day)
/// - نشانگر تعطیلات و رویدادهای ملی/مذهبی با نقطه‌های رنگی
/// ─────────────────────────────────────────────────────────────────────────────
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../providers/calendar_provider.dart';
import '../../utils/jalali_helper.dart';

/// [MonthCalendarWidget] – کارت تقویم ماهانه
class MonthCalendarWidget extends StatelessWidget {
  const MonthCalendarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CalendarProvider>();
    final today = JalaliDate.now();
    final gridDays = provider.getMonthGridDays();

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // ── هدر ناوبری ماه و سال ─────────────────────────────────────────────
          Row(
            children: [
              // دکمه ماه بعد (در RTL: فلش راست به معنی بعدی است)
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded,
                    color: AppColors.neonOrange),
                onPressed: provider.nextMonth,
                tooltip: 'ماه بعد',
              ),
              // عنوان ماه و سال
              Expanded(
                child: Center(
                  child: Text(
                    '${provider.viewedMonthName} ${provider.viewedYear}',
                    style: AppTextStyles.titleLarge.copyWith(
                      color: AppColors.neonOrangeLight,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              // دکمه ماه قبل
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded,
                    color: AppColors.neonOrange),
                onPressed: provider.previousMonth,
                tooltip: 'ماه قبل',
              ),
              // دکمه بازگشت به امروز
              Container(
                margin: const EdgeInsets.only(right: 4),
                child: OutlinedButton(
                  onPressed: provider.goToToday,
                  style: OutlinedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    side: const BorderSide(
                        color: AppColors.neonOrange, width: 0.8),
                  ),
                  child: Text(
                    'امروز',
                    style: AppTextStyles.labelSmall
                        .copyWith(color: AppColors.neonOrange),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── هدر روزهای هفته (ش، ی، د، س، چ، پ، ج) ─────────────────────────
          Row(
            children: List.generate(7, (i) {
              final isFri = i == 6;
              return Expanded(
                child: Center(
                  child: Text(
                    JalaliDate.weekDayShortNames[i],
                    style: AppTextStyles.labelSmall.copyWith(
                      color: isFri
                          ? AppColors.priorityUrgent
                          : AppColors.textDisabled,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: AppColors.glassBorder),
          const SizedBox(height: 8),

          // ── گرید ماتریسی روزهای ماه ────────────────────────────────────────
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: gridDays.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              childAspectRatio: 1.0,
            ),
            itemBuilder: (context, index) {
              final day = gridDays[index];
              if (day == null) {
                return const SizedBox.shrink(); // خانه خالی قبل از اول ماه
              }

              final isToday = day.isSameDay(today);
              final isSelected = day.isSameDay(provider.selectedDate);
              final isHoliday = provider.isHoliday(day);
              final events = provider.getEventsForDay(day);

              return _DayCell(
                day: day,
                isToday: isToday,
                isSelected: isSelected,
                isHoliday: isHoliday,
                hasEvents: events.isNotEmpty,
                onTap: () => provider.selectDate(day),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// ████  سلول یک روز در گرید ماهانه  ████
// ═════════════════════════════════════════════════════════════════════════════
class _DayCell extends StatelessWidget {
  final JalaliDate day;
  final bool isToday;
  final bool isSelected;
  final bool isHoliday;
  final bool hasEvents;
  final VoidCallback onTap;

  const _DayCell({
    required this.day,
    required this.isToday,
    required this.isSelected,
    required this.isHoliday,
    required this.hasEvents,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // رنگ متن روز
    Color textColor = AppColors.textPrimary;
    if (isSelected) {
      textColor = AppColors.textOnNeon;
    } else if (isHoliday) {
      textColor = AppColors.priorityUrgent;
    } else if (isToday) {
      textColor = AppColors.neonOrange;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          // پس‌زمینه روز انتخابی یا امروز
          color: isSelected
              ? AppColors.neonOrange
              : isToday
                  ? AppColors.neonOrange.withOpacity(0.12)
                  : Colors.transparent,
          // حاشیه برای روز جاری یا انتخابی
          border: Border.all(
            color: isSelected
                ? AppColors.neonOrangeLight
                : isToday
                    ? AppColors.neonOrange
                    : Colors.transparent,
            width: isSelected || isToday ? 1.5 : 0,
          ),
          // Glow نئونی برای روز انتخابی
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.glowNeonOrange,
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // عدد روز
            Text(
              '${day.day}',
              style: AppTextStyles.bodyMedium.copyWith(
                color: textColor,
                fontWeight: isSelected || isToday || isHoliday
                    ? FontWeight.w700
                    : FontWeight.w400,
              ),
            ),
            // نقطه نشانگر رویداد یا تعطیلی
            if (hasEvents)
              Positioned(
                bottom: 4,
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? Colors.black
                        : isHoliday
                            ? AppColors.priorityUrgent
                            : AppColors.neonOrange,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
