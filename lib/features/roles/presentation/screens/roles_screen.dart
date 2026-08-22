/// ─────────────────────────────────────────────────────────────────────────────
/// [RolesScreen] – صفحه اصلی نقشه ذهنی نقش‌ها
///
/// نمایش ساختار درختی نقش‌ها و مسئولیت‌های زندگی کاربر.
/// کاربر می‌تواند:
/// - نقش‌های ریشه (مثل: آموزش، سلامت، کار) اضافه کند
/// - زیرشاخه‌های بی‌نهایت اضافه کند
/// - هر گره را ویرایش یا حذف کند
/// - با tap روی گره، فرزندانش را expand/collapse کند
/// ─────────────────────────────────────────────────────────────────────────────
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../providers/role_provider.dart';
import '../widgets/add_edit_role_sheet.dart';
import '../widgets/role_tree_widget.dart';

/// [RolesScreen] – صفحه نقشه ذهنی نقش‌ها
class RolesScreen extends StatelessWidget {
  const RolesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ── AppBar ─────────────────────────────────────────────────────────────
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('نقشه ذهنی نقش‌ها', style: AppTextStyles.headlineSmall),
            Text(
              'حوزه‌های زندگی و مسئولیت‌ها',
              style:
                  AppTextStyles.bodySmall.copyWith(color: AppColors.textDisabled),
            ),
          ],
        ),
        actions: [
          // دکمه افزودن نقش ریشه جدید
          IconButton(
            icon: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.glassActive,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.neonOrange.withOpacity(0.5),
                ),
              ),
              child: const Icon(
                Icons.add_rounded,
                color: AppColors.neonOrange,
                size: 20,
              ),
            ),
            onPressed: () => _showAddRootRole(context),
          ),
          const SizedBox(width: 8),
        ],
      ),

      // ── محتوای اصلی ────────────────────────────────────────────────────────
      body: Consumer<RoleProvider>(
        builder: (context, provider, _) {
          // حالت بارگذاری
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.neonOrange),
            );
          }

          // حالت خالی
          if (provider.rootRoles.isEmpty) {
            return _buildEmptyState(context);
          }

          // نمایش درخت نقش‌ها
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            children: [
              // کارت راهنما
              _buildGuideCard(),
              const SizedBox(height: 16),
              // درخت نقش‌ها
              ...provider.rootRoles.map(
                (role) => RoleTreeWidget(
                  role: role,
                  depth: 0,
                ),
              ),
            ],
          );
        },
      ),

      // ── دکمه شناور ─────────────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddRootRole(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('نقش جدید', style: AppTextStyles.labelLarge),
        backgroundColor: AppColors.neonOrange,
        foregroundColor: AppColors.textOnNeon,
      ),
    );
  }

  /// [_buildGuideCard] – کارت راهنمای کوتاه برای کاربر
  Widget _buildGuideCard() {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          const Icon(
            Icons.lightbulb_outline_rounded,
            color: AppColors.neonOrangeLight,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'نقش‌های زندگی‌ات را مثل یک نقشه ذهنی بساز. روی هر نقش نگه‌دار تا زیرنقش اضافه کنی.',
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  /// [_buildEmptyState] – نمایش حالت خالی
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // آیکون بزرگ
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.glassBackground,
              border: Border.all(color: AppColors.glassBorder),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.glowNeonOrange,
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              Icons.account_tree_rounded,
              size: 56,
              color: AppColors.neonOrange,
            ),
          ),
          const SizedBox(height: 28),
          const Text('نقشه ذهنی خالی است', style: AppTextStyles.headlineSmall),
          const SizedBox(height: 12),
          Text(
            'اولین حوزه زندگی‌ات را اضافه کن\n(مثل: کار، آموزش، سلامت)',
            style:
                AppTextStyles.bodyMedium.copyWith(color: AppColors.textDisabled),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _showAddRootRole(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text('شروع کن'),
          ),
        ],
      ),
    );
  }

  /// [_showAddRootRole] – باز کردن bottom sheet افزودن نقش ریشه
  void _showAddRootRole(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddEditRoleSheet(),
    );
  }
}
