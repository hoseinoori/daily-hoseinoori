/// ─────────────────────────────────────────────────────────────────────────────
/// [NoteCard] – کارت نمایش خلاصه یادداشت با طراحی گلس‌مورفیسم
/// ─────────────────────────────────────────────────────────────────────────────
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../roles/providers/role_provider.dart';
import '../widgets/add_edit_note_sheet.dart';

/// [NoteCard] – کارت یادداشت
class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback? onDelete;

  const NoteCard({
    super.key,
    required this.note,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final roleProvider = context.watch<RoleProvider>();
    final role = note.roleId != null
        ? roleProvider.getRoleById(note.roleId!)
        : null;

    return GlassCard(
      padding: const EdgeInsets.all(14),
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => AddEditNoteSheet(existingNote: note),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── عنوان و برچسب نقش ──────────────────────────────────────────────
          Row(
            children: [
              if (note.title != null && note.title!.isNotEmpty)
                Expanded(
                  child: Text(
                    note.title!,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.neonOrangeLight,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              else
                Expanded(
                  child: Text(
                    'بدون عنوان',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.textDisabled,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),

              // برچسب نقش مرتبط
              if (role != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.glassActive,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppColors.neonOrange.withOpacity(0.4),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    role.title,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.neonOrange,
                      fontSize: 10,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // ── متن محتوای یادداشت ─────────────────────────────────────────────
          Text(
            note.content,
            style: AppTextStyles.bodyMedium,
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),

          // ── ردیف پایین: تاریخ ویرایش + دکمه حذف ────────────────────────────
          Row(
            children: [
              Icon(
                Icons.access_time_rounded,
                size: 12,
                color: AppColors.textDisabled.withOpacity(0.7),
              ),
              const SizedBox(width: 4),
              Text(
                _formatDate(note.updatedAt),
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textDisabled.withOpacity(0.7),
                  fontSize: 10,
                ),
              ),
              const Spacer(),
              if (onDelete != null)
                GestureDetector(
                  onTap: onDelete,
                  child: Icon(
                    Icons.delete_outline_rounded,
                    size: 16,
                    color: AppColors.textDisabled.withOpacity(0.7),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')} - ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
