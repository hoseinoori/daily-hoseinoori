/// ─────────────────────────────────────────────────────────────────────────────
/// [AddEditRoleSheet] – Bottom Sheet افزودن یا ویرایش نقش
///
/// فرم جامع برای:
/// - افزودن نقش ریشه جدید
/// - افزودن زیرنقش (با parentId)
/// - ویرایش نقش موجود
/// ─────────────────────────────────────────────────────────────────────────────
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../providers/role_provider.dart';

/// [AddEditRoleSheet] – فرم افزودن/ویرایش نقش در Bottom Sheet
class AddEditRoleSheet extends StatefulWidget {
  /// اگر تنظیم شود، در حالت ویرایش هستیم
  final RolesNode? existingRole;

  /// شناسه والد برای افزودن زیرنقش (اختیاری)
  final String? parentId;

  /// عنوان والد برای نمایش راهنما (اختیاری)
  final String? parentTitle;

  const AddEditRoleSheet({
    super.key,
    this.existingRole,
    this.parentId,
    this.parentTitle,
  });

  bool get isEditing => existingRole != null;

  @override
  State<AddEditRoleSheet> createState() => _AddEditRoleSheetState();
}

class _AddEditRoleSheetState extends State<AddEditRoleSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  String _selectedIcon = 'circle';
  String _selectedColor = '#FF6B00';
  bool _isSaving = false;

  // آیکون‌های موجود برای انتخاب
  static const _icons = [
    ('circle', Icons.circle_rounded, 'پیش‌فرض'),
    ('work', Icons.work_rounded, 'کار'),
    ('school', Icons.school_rounded, 'آموزش'),
    ('health', Icons.favorite_rounded, 'سلامت'),
    ('family', Icons.people_rounded, 'خانواده'),
    ('finance', Icons.attach_money_rounded, 'مالی'),
    ('sport', Icons.fitness_center_rounded, 'ورزش'),
    ('book', Icons.menu_book_rounded, 'کتاب'),
    ('code', Icons.code_rounded, 'برنامه‌نویسی'),
    ('star', Icons.star_rounded, 'ستاره'),
  ];

  // رنگ‌های پیش‌فرض
  static const _colors = [
    '#FF6B00', // نارنجی نئونی
    '#4FC3F7', // آبی
    '#00E676', // سبز
    '#FFD740', // زرد
    '#FF5252', // قرمز
    '#CE93D8', // بنفش
    '#80DEEA', // آبی‌فیروزه‌ای
    '#FFAB40', // نارنجی روشن
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
        text: widget.existingRole?.title ?? '');
    _descController = TextEditingController(
        text: widget.existingRole?.description ?? '');
    if (widget.existingRole != null) {
      _selectedIcon = widget.existingRole!.icon ?? 'circle';
      _selectedColor = widget.existingRole!.color ?? '#FF6B00';
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

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
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
            // ── هدر ──────────────────────────────────────────────────────────
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.glassActive,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.account_tree_rounded,
                      color: AppColors.neonOrange),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.isEditing ? 'ویرایش نقش' : 'نقش جدید',
                      style: AppTextStyles.headlineSmall,
                    ),
                    if (widget.parentTitle != null)
                      Text(
                        'زیرنقش برای: ${widget.parentTitle}',
                        style: AppTextStyles.bodySmall,
                      ),
                  ],
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

            // ── عنوان ────────────────────────────────────────────────────────
            TextField(
              controller: _titleController,
              autofocus: true,
              style: AppTextStyles.titleMedium,
              decoration: const InputDecoration(
                labelText: 'عنوان نقش *',
                hintText: 'مثال: توسعه نرم‌افزار',
                prefixIcon:
                    Icon(Icons.title_rounded, color: AppColors.neonOrange),
              ),
            ),
            const SizedBox(height: 16),

            // ── توضیحات ──────────────────────────────────────────────────────
            TextField(
              controller: _descController,
              style: AppTextStyles.bodyMedium,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'توضیحات (اختیاری)',
                hintText: 'توضیح کوتاه درباره این حوزه...',
                prefixIcon:
                    Icon(Icons.description_rounded, color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 20),

            // ── انتخاب آیکون ─────────────────────────────────────────────────
            const Text('آیکون', style: AppTextStyles.titleSmall),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _icons
                  .map(
                    (item) => GestureDetector(
                      onTap: () => setState(() => _selectedIcon = item.$1),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: _selectedIcon == item.$1
                              ? AppColors.glassActive
                              : AppColors.surface3,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _selectedIcon == item.$1
                                ? AppColors.neonOrange
                                : AppColors.glassBorder,
                            width: 1.5,
                          ),
                        ),
                        child: Icon(item.$2,
                            color: _selectedIcon == item.$1
                                ? AppColors.neonOrange
                                : AppColors.textSecondary,
                            size: 22),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 20),

            // ── انتخاب رنگ ───────────────────────────────────────────────────
            const Text('رنگ', style: AppTextStyles.titleSmall),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _colors
                  .map(
                    (hex) => GestureDetector(
                      onTap: () => setState(() => _selectedColor = hex),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Color(
                              int.parse(hex.substring(1), radix: 16) +
                                  0xFF000000),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _selectedColor == hex
                                ? Colors.white
                                : Colors.transparent,
                            width: 3,
                          ),
                          boxShadow: _selectedColor == hex
                              ? [
                                  BoxShadow(
                                    color: Color(
                                      int.parse(hex.substring(1), radix: 16) +
                                          0x80000000,
                                    ),
                                    blurRadius: 8,
                                  )
                                ]
                              : null,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 28),

            // ── دکمه ذخیره ───────────────────────────────────────────────────
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
                    : Text(widget.isEditing ? 'ذخیره تغییرات' : 'ایجاد نقش'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// [_save] – ذخیره نقش جدید یا ویرایش نقش موجود
  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('عنوان نقش نمی‌تواند خالی باشد')),
      );
      return;
    }

    setState(() => _isSaving = true);
    final provider = context.read<RoleProvider>();

    bool success;
    if (widget.isEditing) {
      success = await provider.editRole(
        id: widget.existingRole!.id,
        title: title,
        description:
            _descController.text.isEmpty ? null : _descController.text,
        icon: _selectedIcon,
        color: _selectedColor,
      );
    } else {
      final id = await provider.addRole(
        title: title,
        parentId: widget.parentId,
        description:
            _descController.text.isEmpty ? null : _descController.text,
        icon: _selectedIcon,
        color: _selectedColor,
      );
      success = id != null;
      // expand والد تا فرزند جدید نمایش داده شود
      if (success && widget.parentId != null) {
        provider.toggleExpand(widget.parentId!);
      }
    }

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        Navigator.pop(context);
      }
    }
  }
}
