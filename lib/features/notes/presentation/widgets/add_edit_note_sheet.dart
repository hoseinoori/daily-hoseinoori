/// ─────────────────────────────────────────────────────────────────────────────
/// [AddEditNoteSheet] – فرم ایجاد و ویرایش یادداشت
/// ─────────────────────────────────────────────────────────────────────────────
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../roles/providers/role_provider.dart';
import '../../providers/note_provider.dart';

/// [AddEditNoteSheet] – فرم یادداشت
class AddEditNoteSheet extends StatefulWidget {
  final Note? existingNote;
  final DateTime? initialDate; // اگر از صفحه یادداشت روزانه باز شده باشد

  const AddEditNoteSheet({
    super.key,
    this.existingNote,
    this.initialDate,
  });

  bool get isEditing => existingNote != null;

  @override
  State<AddEditNoteSheet> createState() => _AddEditNoteSheetState();
}

class _AddEditNoteSheetState extends State<AddEditNoteSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  String? _selectedRoleId;
  DateTime? _attachedDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final n = widget.existingNote;
    _titleController = TextEditingController(text: n?.title ?? '');
    _contentController = TextEditingController(text: n?.content ?? '');
    _selectedRoleId = n?.roleId;
    _attachedDate = n?.attachedDate ?? widget.initialDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
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
        maxHeight: MediaQuery.of(context).size.height * 0.9,
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
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 16, 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.glassActive,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.sticky_note_2_rounded,
                      color: AppColors.neonOrange, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  widget.isEditing ? 'ویرایش یادداشت' : 'یادداشت جدید',
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
          ),
          const Divider(height: 1, color: AppColors.glassBorder),

          // ── فرم ─────────────────────────────────────────────────────────────
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // عنوان اختیاری
                  TextField(
                    controller: _titleController,
                    style: AppTextStyles.titleMedium,
                    decoration: const InputDecoration(
                      labelText: 'عنوان (اختیاری)',
                      hintText: 'مثال: ایده اپلیکیشن جدید',
                      prefixIcon: Icon(Icons.title_rounded,
                          color: AppColors.textSecondary),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // محتوای یادداشت *
                  TextField(
                    controller: _contentController,
                    autofocus: true,
                    maxLines: 8,
                    style: AppTextStyles.bodyMedium,
                    decoration: const InputDecoration(
                      labelText: 'متن یادداشت *',
                      hintText: 'نوشتن ایده، نکات جلسه، ژورنال...',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // انتخاب نقش
                  if (roles.isNotEmpty) ...[
                    DropdownButtonFormField<String?>(
                      value: _selectedRoleId,
                      dropdownColor: AppColors.surface3,
                      style: AppTextStyles.bodyMedium,
                      decoration: const InputDecoration(
                        labelText: 'نقش مرتبط (اختیاری)',
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
                    const SizedBox(height: 16),
                  ],

                  // اتصال به روز (یادداشت روزانه)
                  Row(
                    children: [
                      Text(
                        'اتصال به تاریخ روز (ژورنال روزانه)',
                        style: AppTextStyles.bodyMedium,
                      ),
                      const Spacer(),
                      Switch(
                        value: _attachedDate != null,
                        onChanged: (v) {
                          setState(() {
                            _attachedDate = v ? DateTime.now() : null;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

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
                          : Text(widget.isEditing
                              ? 'ذخیره تغییرات'
                              : 'ایجاد یادداشت'),
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

  Future<void> _save() async {
    final content = _contentController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('متن یادداشت نمی‌تواند خالی باشد')),
      );
      return;
    }

    setState(() => _isSaving = true);
    final provider = context.read<NoteProvider>();
    final title = _titleController.text.trim();

    bool success;
    if (widget.isEditing) {
      success = await provider.editNote(
        id: widget.existingNote!.id,
        title: title.isEmpty ? null : title,
        content: content,
        roleId: _selectedRoleId,
      );
    } else {
      final id = await provider.addNote(
        title: title.isEmpty ? null : title,
        content: content,
        attachedDate: _attachedDate,
        roleId: _selectedRoleId,
      );
      success = id != null;
    }

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) Navigator.pop(context);
    }
  }
}
