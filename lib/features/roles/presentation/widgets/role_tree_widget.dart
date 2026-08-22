/// ─────────────────────────────────────────────────────────────────────────────
/// [RoleTreeWidget] – ویجت بازنمایی درختی گره نقش
///
/// این ویجت به صورت بازگشتی (Recursive) برای هر گره و فرزندانش
/// فراخوانی می‌شود. با افزایش [depth]، indentation بیشتر می‌شود.
/// ─────────────────────────────────────────────────────────────────────────────
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../providers/role_provider.dart';
import 'add_edit_role_sheet.dart';

/// [RoleTreeWidget] – نمایش گره درختی نقش و فرزندانش
class RoleTreeWidget extends StatelessWidget {
  /// گره نقش جاری
  final RolesNode role;

  /// عمق در درخت (۰ = ریشه، ۱ = فرزند اول، ...)
  final int depth;

  const RoleTreeWidget({
    super.key,
    required this.role,
    required this.depth,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RoleProvider>();
    final children = provider.getChildrenOf(role.id);
    final hasChildren = provider.hasChildren(role.id);
    final isExpanded = provider.isExpanded(role.id);

    // رنگ خط عمودی کناری بر اساس عمق
    final lineColor = _getDepthColor(depth);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── خط اتصال و کارت گره ─────────────────────────────────────────────
        Padding(
          padding: EdgeInsets.only(
            right: depth * 20.0, // indentation RTL
            bottom: 8,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // خط عمودی کناری (برای نشان دادن سطح)
              if (depth > 0)
                Container(
                  width: 2,
                  height: 48,
                  margin: const EdgeInsets.only(left: 8),
                  decoration: BoxDecoration(
                    color: lineColor.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

              // کارت گره
              Expanded(
                child: GlassCard(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  backgroundColor: depth == 0
                      ? AppColors.surface2
                      : AppColors.surface1,
                  borderColor: hasChildren && isExpanded
                      ? lineColor.withOpacity(0.5)
                      : AppColors.glassBorder,
                  showGlow: hasChildren && isExpanded,
                  glowIntensity: 0.3,
                  onTap: hasChildren
                      ? () => provider.toggleExpand(role.id)
                      : null,
                  onLongPress: () => _showOptions(context),
                  child: Row(
                    children: [
                      // آیکون رنگی گره
                      _buildNodeIcon(lineColor),
                      const SizedBox(width: 12),

                      // اطلاعات گره
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              role.title,
                              style: depth == 0
                                  ? AppTextStyles.titleLarge
                                  : AppTextStyles.titleMedium,
                            ),
                            if (role.description != null &&
                                role.description!.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                role.description!,
                                style: AppTextStyles.bodySmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),

                      // دکمه‌های عملیات
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // دکمه افزودن فرزند
                          _ActionButton(
                            icon: Icons.add_rounded,
                            color: AppColors.neonOrange,
                            tooltip: 'افزودن زیرنقش',
                            onTap: () => _showAddChild(context),
                          ),
                          const SizedBox(width: 4),
                          // دکمه ویرایش
                          _ActionButton(
                            icon: Icons.edit_rounded,
                            color: AppColors.textSecondary,
                            tooltip: 'ویرایش',
                            onTap: () => _showEdit(context),
                          ),
                          // آیکون expand
                          if (hasChildren) ...[
                            const SizedBox(width: 4),
                            AnimatedRotation(
                              turns: isExpanded ? 0.5 : 0,
                              duration: const Duration(milliseconds: 250),
                              child: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: lineColor,
                                size: 20,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── فرزندان (با انیمیشن) ────────────────────────────────────────────
        if (hasChildren)
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: isExpanded
                ? Column(
                    children: children
                        .map(
                          (child) => RoleTreeWidget(
                            role: child,
                            depth: depth + 1,
                          ),
                        )
                        .toList(),
                  )
                : const SizedBox.shrink(),
          ),
      ],
    );
  }

  /// [_buildNodeIcon] – آیکون رنگی بر اساس رنگ سفارشی گره یا پیش‌فرض
  Widget _buildNodeIcon(Color defaultColor) {
    // اگر گره رنگ سفارشی داشت از آن استفاده می‌کنیم
    Color nodeColor = defaultColor;
    if (role.color != null && role.color!.startsWith('#')) {
      try {
        nodeColor = Color(
          int.parse(role.color!.substring(1), radix: 16) + 0xFF000000,
        );
      } catch (_) {}
    }

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: nodeColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: nodeColor.withOpacity(0.4), width: 1),
      ),
      child: Icon(
        _getIconData(role.icon),
        color: nodeColor,
        size: 18,
      ),
    );
  }

  /// [_getIconData] – تبدیل نام آیکون به IconData
  IconData _getIconData(String? iconName) {
    return switch (iconName) {
      'work' => Icons.work_rounded,
      'school' => Icons.school_rounded,
      'health' => Icons.favorite_rounded,
      'family' => Icons.people_rounded,
      'finance' => Icons.attach_money_rounded,
      'sport' => Icons.fitness_center_rounded,
      'travel' => Icons.flight_rounded,
      'book' => Icons.menu_book_rounded,
      'code' => Icons.code_rounded,
      'star' => Icons.star_rounded,
      _ => Icons.circle_rounded,
    };
  }

  /// [_getDepthColor] – رنگ خط کناری بر اساس عمق در درخت
  Color _getDepthColor(int depth) {
    return switch (depth % 5) {
      0 => AppColors.neonOrange,
      1 => AppColors.priorityLow,
      2 => AppColors.statusDone,
      3 => AppColors.priorityMedium,
      _ => const Color(0xFFFFD740),
    };
  }

  void _showAddChild(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddEditRoleSheet(parentId: role.id, parentTitle: role.title),
    );
  }

  void _showEdit(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddEditRoleSheet(existingRole: role),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _RoleOptionsSheet(role: role),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// ████  دکمه عملیات کوچک  ████
// ═════════════════════════════════════════════════════════════════════════════
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// ████  Bottom Sheet گزینه‌های گره  ████
// ═════════════════════════════════════════════════════════════════════════════
class _RoleOptionsSheet extends StatelessWidget {
  final RolesNode role;

  const _RoleOptionsSheet({required this.role});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<RoleProvider>();

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // هدر
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.account_tree_rounded,
                    color: AppColors.neonOrange),
                const SizedBox(width: 10),
                Text(role.title, style: AppTextStyles.titleLarge),
              ],
            ),
          ),
          const Divider(height: 1),
          // گزینه حذف
          ListTile(
            leading: const Icon(Icons.delete_rounded,
                color: AppColors.priorityUrgent),
            title: Text(
              'حذف نقش و تمام زیرنقش‌ها',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.priorityUrgent,
              ),
            ),
            onTap: () async {
              Navigator.pop(context);
              final confirmed = await _confirmDelete(context);
              if (confirmed) await provider.removeRole(role.id);
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('حذف نقش'),
            content: Text(
                'آیا مطمئن هستید؟ نقش "${role.title}" و تمام زیرنقش‌هایش حذف می‌شوند.'),
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
  }
}
