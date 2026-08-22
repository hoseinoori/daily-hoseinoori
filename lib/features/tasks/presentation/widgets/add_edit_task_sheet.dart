/// ─────────────────────────────────────────────────────────────────────────────
/// [AddEditTaskSheet] – فرم جامع افزودن/ویرایش تسک
///
/// شامل:
/// - عنوان و توضیحات
/// - انتخاب نقش مرتبط
/// - انتخاب اولویت
/// - تاریخ ددلاین
/// - تاریخ تقویم
/// - ساعت شروع/پایان (Timeline Mode)
/// - وضعیت اولیه
/// ─────────────────────────────────────────────────────────────────────────────
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/task_indicators.dart';
import '../../../roles/providers/role_provider.dart';
import '../../providers/task_provider.dart';

/// [AddEditTaskSheet] – فرم کامل ایجاد/ویرایش تسک
class AddEditTaskSheet extends StatefulWidget {
  /// اگر تنظیم شود، در حالت ویرایش هستیم
  final Task? existingTask;

  const AddEditTaskSheet({super.key, this.existingTask});

  bool get isEditing => existingTask != null;

  @override
  State<AddEditTaskSheet> createState() => _AddEditTaskSheetState();
}

class _AddEditTaskSheetState extends State<AddEditTaskSheet> {
  // کنترلرهای متن
  late final TextEditingController _titleController;
  late final TextEditingController _descController;

  // مقادیر فیلدهای انتخابی
  String _selectedPriority = AppConstants.priorityMedium;
  String _selectedStatus = AppConstants.taskStatusTodo;
  String? _selectedRoleId;
  DateTime? _deadline;
  DateTime? _scheduledDate;
  String? _startTime;
  String? _endTime;
  bool _isTimelineBounded = false;
  bool _isSaving = false;

  // آرایه اولویت‌ها
  static const _priorities = [
    (AppConstants.priorityLow, 'پایین', AppColors.priorityLow),
    (AppConstants.priorityMedium, 'متوسط', AppColors.priorityMedium),
    (AppConstants.priorityHigh, 'بالا', AppColors.priorityHigh),
    (AppConstants.priorityUrgent, 'فوری', AppColors.priorityUrgent),
  ];

  @override
  void initState() {
    super.initState();
    final t = widget.existingTask;
    _titleController = TextEditingController(text: t?.title ?? '');
    _descController = TextEditingController(text: t?.description ?? '');
    if (t != null) {
      _selectedPriority = t.priority ?? AppConstants.priorityMedium;
      _selectedStatus = t.status;
      _selectedRoleId = t.roleId;
      _deadline = t.deadline;
      _scheduledDate = t.scheduledDate;
      _startTime = t.startTime;
      _endTime = t.endTime;
      _isTimelineBounded = t.isTimelineBounded;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final roles = context.watch<RoleProvider>().allRoles;

    return Container(
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      padding: EdgeInsets.only(bottom: bottomInset),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── هدر ─────────────────────────────────────────────────────────────
          _buildHeader(),
          const Divider(height: 1),

          // ── فرم ─────────────────────────────────────────────────────────────
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // عنوان *
                  TextField(
                    controller: _titleController,
                    autofocus: true,
                    style: AppTextStyles.titleMedium,
                    decoration: const InputDecoration(
                      labelText: 'عنوان تسک *',
                      hintText: 'مثال: نوشتن مقاله هوش مصنوعی',
                      prefixIcon: Icon(Icons.task_alt_rounded,
                          color: AppColors.neonOrange),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // توضیحات
                  TextField(
                    controller: _descController,
                    maxLines: 3,
                    style: AppTextStyles.bodyMedium,
                    decoration: const InputDecoration(
                      labelText: 'توضیحات (اختیاری)',
                      prefixIcon: Icon(Icons.notes_rounded,
                          color: AppColors.textSecondary),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── اولویت ──────────────────────────────────────────────────
                  Text('اولویت', style: AppTextStyles.titleSmall),
                  const SizedBox(height: 10),
                  Row(
                    children: _priorities
                        .map(
                          (p) => Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 2),
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedPriority = p.$1),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10),
                                  decoration: BoxDecoration(
                                    color: _selectedPriority == p.$1
                                        ? p.$3.withOpacity(0.2)
                                        : AppColors.surface3,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: _selectedPriority == p.$1
                                          ? p.$3
                                          : AppColors.glassBorder,
                                      width:
                                          _selectedPriority == p.$1 ? 1.5 : 1,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    p.$2,
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: _selectedPriority == p.$1
                                          ? p.$3
                                          : AppColors.textSecondary,
                                      fontWeight: _selectedPriority == p.$1
                                          ? FontWeight.w700
                                          : FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 20),

                  // ── نقش مرتبط ────────────────────────────────────────────────
                  Text('نقش مرتبط', style: AppTextStyles.titleSmall),
                  const SizedBox(height: 10),
                  if (roles.isEmpty)
                    Text(
                      'هنوز نقشی تعریف نشده است. ابتدا نقش بساز.',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textDisabled),
                    )
                  else
                    DropdownButtonFormField<String?>(
                      value: _selectedRoleId,
                      dropdownColor: AppColors.surface3,
                      style: AppTextStyles.bodyMedium,
                      decoration: const InputDecoration(
                        hintText: 'انتخاب نقش (اختیاری)',
                        prefixIcon: Icon(Icons.account_tree_rounded,
                            color: AppColors.textSecondary),
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('بدون نقش'),
                        ),
                        ...roles.map(
                          (r) => DropdownMenuItem<String?>(
                            value: r.id,
                            child: Text(r.title),
                          ),
                        ),
                      ],
                      onChanged: (v) => setState(() => _selectedRoleId = v),
                    ),
                  const SizedBox(height: 20),

                  // ── ددلاین ──────────────────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: Text('مهلت انجام', style: AppTextStyles.titleSmall),
                      ),
                      if (_deadline != null)
                        TextButton(
                          onPressed: () => setState(() => _deadline = null),
                          child: const Text('حذف'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _pickDeadline,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.surface3,
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: AppColors.glassBorder, width: 1),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.schedule_rounded,
                              color: AppColors.neonOrange, size: 18),
                          const SizedBox(width: 10),
                          Text(
                            _deadline != null
                                ? _formatDate(_deadline!)
                                : 'انتخاب تاریخ...',
                            style: _deadline != null
                                ? AppTextStyles.bodyMedium
                                : AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textDisabled),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── تاریخ تقویم + Timeline ──────────────────────────────────
                  Row(
                    children: [
                      Text('برنامه‌ریزی در تقویم',
                          style: AppTextStyles.titleSmall),
                      const Spacer(),
                      Switch(
                        value: _scheduledDate != null,
                        onChanged: (v) async {
                          if (v) {
                            final picked = await _pickDate(context);
                            if (picked != null) {
                              setState(() => _scheduledDate = picked);
                            }
                          } else {
                            setState(() {
                              _scheduledDate = null;
                              _startTime = null;
                              _endTime = null;
                              _isTimelineBounded = false;
                            });
                          }
                        },
                      ),
                    ],
                  ),

                  if (_scheduledDate != null) ...[
                    const SizedBox(height: 8),
                    // آیا Timeline مشخص دارد؟
                    Row(
                      children: [
                        Text('با ساعت مشخص (Timeline)',
                            style: AppTextStyles.bodyMedium),
                        const Spacer(),
                        Switch(
                          value: _isTimelineBounded,
                          onChanged: (v) =>
                              setState(() => _isTimelineBounded = v),
                        ),
                      ],
                    ),
                    if (_isTimelineBounded) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _pickTime(context, isStart: true),
                              child: _TimePickerField(
                                label: 'شروع',
                                value: _startTime,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _pickTime(context, isStart: false),
                              child: _TimePickerField(
                                label: 'پایان',
                                value: _endTime,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],

                  const SizedBox(height: 28),

                  // ── دکمه ذخیره ──────────────────────────────────────────────
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
                          : Text(
                              widget.isEditing ? 'ذخیره تغییرات' : 'ایجاد تسک'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 16, 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.glassActive,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.add_task_rounded,
                color: AppColors.neonOrange),
          ),
          const SizedBox(width: 12),
          Text(
            widget.isEditing ? 'ویرایش تسک' : 'تسک جدید',
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
    );
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('عنوان تسک الزامی است')),
      );
      return;
    }

    setState(() => _isSaving = true);
    final provider = context.read<TaskProvider>();
    bool success;

    if (widget.isEditing) {
      success = await provider.updateTask(
        id: widget.existingTask!.id,
        title: title,
        description: _descController.text.isEmpty ? null : _descController.text,
        priority: _selectedPriority,
        status: _selectedStatus,
        roleId: _selectedRoleId,
        deadline: _deadline,
        scheduledDate: _scheduledDate,
        startTime: _isTimelineBounded ? _startTime : null,
        endTime: _isTimelineBounded ? _endTime : null,
        isTimelineBounded: _isTimelineBounded,
      );
    } else {
      final id = await provider.createTask(
        title: title,
        description: _descController.text.isEmpty ? null : _descController.text,
        priority: _selectedPriority,
        roleId: _selectedRoleId,
        deadline: _deadline,
        scheduledDate: _scheduledDate,
        startTime: _isTimelineBounded ? _startTime : null,
        endTime: _isTimelineBounded ? _endTime : null,
        isTimelineBounded: _isTimelineBounded,
      );
      success = id != null;
    }

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) Navigator.pop(context);
    }
  }

  Future<void> _pickDeadline() async {
    final picked = await _pickDate(context);
    if (picked != null) setState(() => _deadline = picked);
  }

  Future<DateTime?> _pickDate(BuildContext context) {
    return showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.neonOrange,
            onPrimary: Colors.black,
            surface: AppColors.surface2,
          ),
        ),
        child: child!,
      ),
    );
  }

  Future<void> _pickTime(BuildContext context, {required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
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
      final formatted =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      setState(() {
        if (isStart) {
          _startTime = formatted;
        } else {
          _endTime = formatted;
        }
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }
}

// ═════════════════════════════════════════════════════════════════════════════
class _TimePickerField extends StatelessWidget {
  final String label;
  final String? value;

  const _TimePickerField({required this.label, this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface3,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.access_time_rounded,
              color: AppColors.neonOrange, size: 16),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: AppTextStyles.labelSmall
                      .copyWith(color: AppColors.textDisabled)),
              Text(
                value ?? 'انتخاب',
                style: AppTextStyles.titleSmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
