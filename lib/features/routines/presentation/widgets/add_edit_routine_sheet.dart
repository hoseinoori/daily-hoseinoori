/// ─────────────────────────────────────────────────────────────────────────────
/// [AddEditRoutineSheet] – فرم افزودن/ویرایش روتین هفتگی
/// ─────────────────────────────────────────────────────────────────────────────
library;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../providers/routine_provider.dart';

/// [AddEditRoutineSheet] – فرم روتین هفتگی
class AddEditRoutineSheet extends StatefulWidget {
  final RecurringRoutine? existingRoutine;

  const AddEditRoutineSheet({super.key, this.existingRoutine});

  bool get isEditing => existingRoutine != null;

  @override
  State<AddEditRoutineSheet> createState() => _AddEditRoutineSheetState();
}

class _AddEditRoutineSheetState extends State<AddEditRoutineSheet> {
  late final TextEditingController _titleController;
  Set<int> _selectedDays = {};
  String _startTime = '08:00';
  String _endTime = '09:00';
  bool _isSaving = false;

  static const _dayNames = [
    'شنبه', 'یکشنبه', 'دوشنبه', 'سه‌شنبه',
    'چهارشنبه', 'پنجشنبه', 'جمعه'
  ];

  @override
  void initState() {
    super.initState();
    final r = widget.existingRoutine;
    _titleController = TextEditingController(text: r?.title ?? '');
    if (r != null) {
      _startTime = r.startTime;
      _endTime = r.endTime;
      try {
        _selectedDays = (jsonDecode(r.daysOfWeek) as List)
            .map((e) => e as int)
            .toSet();
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // هدر
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.glassActive,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.alarm_add_rounded,
                      color: AppColors.neonOrange),
                ),
                const SizedBox(width: 12),
                Text(
                  widget.isEditing ? 'ویرایش روتین' : 'روتین جدید',
                  style: AppTextStyles.headlineSmall,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_rounded,
                      color: AppColors.textDisabled),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // عنوان
            TextField(
              controller: _titleController,
              autofocus: true,
              style: AppTextStyles.titleMedium,
              decoration: const InputDecoration(
                labelText: 'عنوان روتین *',
                hintText: 'مثال: مطالعه صبحگاهی',
                prefixIcon:
                    Icon(Icons.alarm_rounded, color: AppColors.neonOrange),
              ),
            ),
            const SizedBox(height: 20),

            // انتخاب ساعت
            Text('بازه زمانی', style: AppTextStyles.titleSmall),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTimePicker(
                    context,
                    label: 'شروع',
                    time: _startTime,
                    onPick: (t) => setState(() => _startTime = t),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(Icons.arrow_forward_rounded,
                      color: AppColors.textDisabled, size: 18),
                ),
                Expanded(
                  child: _buildTimePicker(
                    context,
                    label: 'پایان',
                    time: _endTime,
                    onPick: (t) => setState(() => _endTime = t),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // انتخاب روزهای هفته
            Text('روزهای تکرار', style: AppTextStyles.titleSmall),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(7, (i) {
                final isSelected = _selectedDays.contains(i);
                return GestureDetector(
                  onTap: () => setState(() {
                    if (isSelected) {
                      _selectedDays.remove(i);
                    } else {
                      _selectedDays.add(i);
                    }
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.neonOrange.withOpacity(0.2)
                          : AppColors.surface3,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.neonOrange
                            : AppColors.glassBorder,
                        width: isSelected ? 1.5 : 0.8,
                      ),
                    ),
                    child: Text(
                      _dayNames[i],
                      style: AppTextStyles.labelSmall.copyWith(
                        color: isSelected
                            ? AppColors.neonOrange
                            : AppColors.textSecondary,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 28),

            // دکمه ذخیره
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.textOnNeon,
                        ),
                      )
                    : Text(widget.isEditing ? 'ذخیره تغییرات' : 'ایجاد روتین'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// [_buildTimePicker] – فیلد انتخاب ساعت
  Widget _buildTimePicker(
    BuildContext context, {
    required String label,
    required String time,
    required void Function(String) onPick,
  }) {
    return GestureDetector(
      onTap: () async {
        final parts = time.split(':');
        final picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay(
            hour: int.parse(parts[0]),
            minute: int.parse(parts[1]),
          ),
          builder: (context, child) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.dark(
                primary: AppColors.neonOrange,
                surface: AppColors.surface2,
              ),
            ),
            child: child!,
          ),
        );
        if (picked != null) {
          onPick(
              '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}');
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface3,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time_rounded,
                color: AppColors.neonOrange, size: 16),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: AppTextStyles.labelSmall
                        .copyWith(color: AppColors.textDisabled)),
                Text(time, style: AppTextStyles.titleMedium),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('عنوان روتین الزامی است')),
      );
      return;
    }
    if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حداقل یک روز را انتخاب کنید')),
      );
      return;
    }

    setState(() => _isSaving = true);
    final provider = context.read<RoutineProvider>();
    final days = _selectedDays.toList()..sort();

    bool success;
    if (widget.isEditing) {
      success = await provider.editRoutine(
        id: widget.existingRoutine!.id,
        title: title,
        startTime: _startTime,
        endTime: _endTime,
        daysOfWeek: days,
      );
    } else {
      final id = await provider.addRoutine(
        title: title,
        startTime: _startTime,
        endTime: _endTime,
        daysOfWeek: days,
      );
      success = id != null;
    }

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) Navigator.pop(context);
    }
  }
}
