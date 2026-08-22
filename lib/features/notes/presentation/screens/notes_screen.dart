/// ─────────────────────────────────────────────────────────────────────────────
/// [NotesScreen] – صفحه اصلی سیستم یادداشت‌ها
///
/// این صفحه شامل:
/// - نوار جستجوی متنی لحظه‌ای
/// - فیلتر بر اساس نقش‌ها
/// - تب‌بار سوئیچ بین:
///   ۱. یادداشت‌های سراسری (Global Notes)
///   ۲. یادداشت‌های روزانه و ژورنال‌نویسی (Daily Notes)
/// - گرید/لیست کارت‌های یادداشت
/// - دکمه شناور افزودن یادداشت جدید
/// ─────────────────────────────────────────────────────────────────────────────
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../calendar/utils/jalali_helper.dart';
import '../../../roles/providers/role_provider.dart';
import '../../providers/note_provider.dart';
import '../widgets/add_edit_note_sheet.dart';
import '../widgets/note_card.dart';

/// [NotesScreen] – صفحه اصلی یادداشت‌ها
class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final noteProvider = context.watch<NoteProvider>();
    final roleProvider = context.watch<RoleProvider>();
    final isDailyTab = noteProvider.activeTabIndex == 1;
    final currentNotes = isDailyTab
        ? noteProvider.filteredDailyNotes
        : noteProvider.filteredGlobalNotes;

    return Scaffold(
      // ── AppBar ─────────────────────────────────────────────────────────────
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('یادداشت‌ها و ژورنال', style: AppTextStyles.headlineSmall),
            Text(
              isDailyTab
                  ? 'یادداشت‌های متصل به روز'
                  : '${noteProvider.globalNotes.length} یادداشت سراسری',
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textDisabled),
            ),
          ],
        ),
      ),

      // ── محتوای اصلی ────────────────────────────────────────────────────────
      body: Column(
        children: [
          // ۱. نوار جستجو
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: noteProvider.setSearchQuery,
              style: AppTextStyles.bodyMedium,
              decoration: InputDecoration(
                hintText: 'جستجو در یادداشت‌ها...',
                prefixIcon: const Icon(Icons.search_rounded,
                    color: AppColors.neonOrange, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          noteProvider.setSearchQuery('');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),

          // ۲. سوئیچ تب‌ها (سراسری vs روزانه)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface2,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.glassBorder),
              ),
              padding: const EdgeInsets.all(3),
              child: Row(
                children: [
                  Expanded(
                    child: _TabButton(
                      title: 'یادداشت‌های سراسری',
                      icon: Icons.sticky_note_2_rounded,
                      isActive: !isDailyTab,
                      onTap: () => noteProvider.setActiveTab(0),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: _TabButton(
                      title: 'ژورنال روزانه',
                      icon: Icons.event_note_rounded,
                      isActive: isDailyTab,
                      onTap: () => noteProvider.setActiveTab(1),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ۳. کنترل انتخاب تاریخ (فقط برای تب روزانه)
          if (isDailyTab) _buildDailyDateSelector(context, noteProvider),

          // ۴. لیست یادداشت‌ها
          Expanded(
            child: currentNotes.isEmpty
                ? _buildEmptyState(isDailyTab)
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    itemCount: currentNotes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final note = currentNotes[index];
                      return NoteCard(
                        note: note,
                        onDelete: () => _confirmDelete(context, noteProvider, note.id),
                      );
                    },
                  ),
          ),
        ],
      ),

      // ── دکمه افزودن یادداشت ────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => AddEditNoteSheet(
              initialDate: isDailyTab ? noteProvider.selectedDate : null,
            ),
          );
        },
        icon: const Icon(Icons.note_add_rounded),
        label: Text(
          isDailyTab ? 'ژورنال برای امروز' : 'یادداشت جدید',
          style: AppTextStyles.labelLarge,
        ),
        backgroundColor: AppColors.neonOrange,
        foregroundColor: AppColors.textOnNeon,
      ),
    );
  }

  Widget _buildDailyDateSelector(BuildContext context, NoteProvider provider) {
    final jDate = JalaliDate.fromDateTime(provider.selectedDate);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_right_rounded,
                  color: AppColors.neonOrange),
              onPressed: () {
                provider.setSelectedDate(
                  provider.selectedDate.add(const Duration(days: 1)),
                );
              },
              tooltip: 'روز بعد',
            ),
            Expanded(
              child: Center(
                child: Text(
                  jDate.fullFormatted,
                  style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.neonOrangeLight,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_left_rounded,
                  color: AppColors.neonOrange),
              onPressed: () {
                provider.setSelectedDate(
                  provider.selectedDate.subtract(const Duration(days: 1)),
                );
              },
              tooltip: 'روز قبل',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDailyTab) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isDailyTab
                ? Icons.event_note_rounded
                : Icons.sticky_note_2_outlined,
            size: 56,
            color: AppColors.textDisabled.withOpacity(0.4),
          ),
          const SizedBox(height: 14),
          Text(
            isDailyTab
                ? 'برای این روز یادداشتی ثبت نشده است'
                : 'هنوز هیچ یادداشتی ننوشته‌اید',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textDisabled,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, NoteProvider provider, String noteId) async {
    final ok = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('حذف یادداشت'),
            content: const Text('آیا از حذف این یادداشت اطمینان دارید؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('انصراف'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.priorityUrgent,
                ),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('حذف'),
              ),
            ],
          ),
        ) ??
        false;

    if (ok) provider.removeNote(noteId);
  }
}

// ═════════════════════════════════════════════════════════════════════════════
class _TabButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _TabButton({
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
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.glassActive : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: isActive ? AppColors.neonOrange : Colors.transparent,
            width: isActive ? 1 : 0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
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
