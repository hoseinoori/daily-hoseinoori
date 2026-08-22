/// ─────────────────────────────────────────────────────────────────────────────
/// [RoutinesScreen] – صفحه مدیریت روتین‌های تکرارشونده هفتگی
/// ─────────────────────────────────────────────────────────────────────────────
library;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../providers/routine_provider.dart';
import '../widgets/add_edit_routine_sheet.dart';

/// [RoutinesScreen] – صفحه برنامه هفتگی و روتین‌ها
class RoutinesScreen extends StatelessWidget {
  const RoutinesScreen({super.key});

  // نام روزهای هفته به فارسی
  static const _weekDays = ['ش', 'ی', 'د', 'س', 'چ', 'پ', 'ج'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('برنامه هفتگی', style: AppTextStyles.headlineSmall),
            Text(
              'روتین‌های تکرارشونده',
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textDisabled),
            ),
          ],
        ),
      ),
      body: Consumer<RoutineProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.neonOrange),
            );
          }

          if (provider.routines.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            children: [
              // نمایش گرید هفتگی
              _WeeklyGrid(
                routines: provider.routines,
                weekDays: _weekDays,
              ),
              const SizedBox(height: 20),
              // لیست روتین‌ها
              Text('تمام روتین‌ها', style: AppTextStyles.titleLarge),
              const SizedBox(height: 12),
              ...provider.routines.map(
                (routine) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _RoutineCard(routine: routine),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAdd(context),
        icon: const Icon(Icons.add_alarm_rounded),
        label: const Text('روتین جدید', style: AppTextStyles.labelLarge),
        backgroundColor: AppColors.neonOrange,
        foregroundColor: AppColors.textOnNeon,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.glassBackground,
              border: Border.all(color: AppColors.glassBorder),
              boxShadow: [
                BoxShadow(
                  color: AppColors.glowNeonOrange,
                  blurRadius: 30,
                ),
              ],
            ),
            child: const Icon(Icons.alarm_rounded,
                size: 56, color: AppColors.neonOrange),
          ),
          const SizedBox(height: 24),
          Text('هنوز روتینی نداری', style: AppTextStyles.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'عادت‌های روزانه و هفتگی‌ات را اینجا ثبت کن',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textDisabled,
            ),
          ),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            onPressed: () => _showAdd(context),
            icon: const Icon(Icons.add_alarm_rounded),
            label: const Text('اولین روتین'),
          ),
        ],
      ),
    );
  }

  void _showAdd(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddEditRoutineSheet(),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// ████  گرید هفتگی  ████
// ═════════════════════════════════════════════════════════════════════════════
class _WeeklyGrid extends StatelessWidget {
  final List<RecurringRoutine> routines;
  final List<String> weekDays;

  const _WeeklyGrid({required this.routines, required this.weekDays});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('نمای هفتگی', style: AppTextStyles.titleMedium),
          const SizedBox(height: 14),
          // هدر روزها
          Row(
            children: weekDays
                .map(
                  (day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textDisabled,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 10),
          // ستون روتین‌ها در هر روز
          ...List.generate(7, (dayIndex) {
            final dayRoutines = routines.where((r) {
              try {
                final days = (jsonDecode(r.daysOfWeek) as List)
                    .map((e) => e as int)
                    .toList();
                return days.contains(dayIndex);
              } catch (_) {
                return false;
              }
            }).toList();

            return dayRoutines.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        // نام روز
                        SizedBox(
                          width: 40,
                          child: Text(
                            _RoutinesScreen._weekDays[dayIndex],
                            style: AppTextStyles.labelSmall
                                .copyWith(color: AppColors.neonOrange),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        // روتین‌های این روز
                        Expanded(
                          child: Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: dayRoutines
                                .map(
                                  (r) => Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.neonOrange.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color:
                                            AppColors.neonOrange.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Text(
                                      r.title,
                                      style: AppTextStyles.labelSmall.copyWith(
                                        color: AppColors.neonOrangeLight,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink();
          }),
        ],
      ),
    );
  }
}

// Extension برای دسترسی به constant از داخل کلاس دیگر
extension _RoutinesScreen on RoutinesScreen {
  static const _weekDays = RoutinesScreen._weekDays;
}

// ═════════════════════════════════════════════════════════════════════════════
// ████  کارت روتین  ████
// ═════════════════════════════════════════════════════════════════════════════
class _RoutineCard extends StatelessWidget {
  final RecurringRoutine routine;

  const _RoutineCard({required this.routine});

  static const _dayNames = ['شنبه', 'یکشنبه', 'دوشنبه', 'سه‌شنبه', 'چهارشنبه', 'پنجشنبه', 'جمعه'];

  @override
  Widget build(BuildContext context) {
    final provider = context.read<RoutineProvider>();
    List<int> days = [];
    try {
      days = (jsonDecode(routine.daysOfWeek) as List)
          .map((e) => e as int)
          .toList();
    } catch (_) {}

    return GlassCard(
      showGlow: false,
      onTap: () => _showEdit(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ردیف اول: نام + ساعت + حذف
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.neonOrange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.alarm_rounded,
                    color: AppColors.neonOrange, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(routine.title, style: AppTextStyles.titleMedium),
                    Text(
                      '${routine.startTime} تا ${routine.endTime}',
                      style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.neonOrange),
                    ),
                  ],
                ),
              ),
              // دکمه حذف
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded,
                    color: AppColors.textDisabled, size: 20),
                onPressed: () => _delete(context, provider),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // روزهای هفته
          Wrap(
            spacing: 6,
            children: List.generate(7, (i) {
              final isActive = days.contains(i);
              return Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.neonOrange.withOpacity(0.2)
                      : AppColors.surface3,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isActive
                        ? AppColors.neonOrange
                        : AppColors.glassBorder,
                    width: isActive ? 1.5 : 0.8,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  RoutinesScreen._weekDays[i],
                  style: TextStyle(
                    fontSize: 11,
                    color:
                        isActive ? AppColors.neonOrange : AppColors.textDisabled,
                    fontWeight:
                        isActive ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  void _showEdit(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddEditRoutineSheet(existingRoutine: routine),
    );
  }

  Future<void> _delete(BuildContext context, RoutineProvider provider) async {
    final ok = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('حذف روتین'),
            content: Text('آیا از حذف "${routine.title}" اطمینان دارید؟'),
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
    if (ok) provider.removeRoutine(routine.id);
  }
}
