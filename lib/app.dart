/// ─────────────────────────────────────────────────────────────────────────────
/// [DailyHoseinooriApp] – کلاس اصلی اپلیکیشن و اسکلت UI
///
/// این فایل Widget ریشه برنامه را تعریف می‌کند که شامل:
/// - MaterialApp با تم تاریک گلس‌مورفیسم
/// - LocalizationsDelegate فارسی (RTL)
/// - پوسته (Shell) اصلی ناوبری برنامه
/// ─────────────────────────────────────────────────────────────────────────────
library;

import 'package:flutter/material.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_text_styles.dart';
import 'core/theme/app_theme.dart';
import 'features/roles/presentation/screens/roles_screen.dart';
import 'features/routines/presentation/screens/routines_screen.dart';
import 'features/tasks/presentation/screens/kanban_screen.dart';

/// [DailyHoseinooriApp] – Widget ریشه اپلیکیشن
class DailyHoseinooriApp extends StatelessWidget {
  const DailyHoseinooriApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // ── اطلاعات پایه برنامه ──────────────────────────────────────────────
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,

      // ── تم برنامه ──────────────────────────────────────────────────────────
      theme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,

      // ── پشتیبانی از زبان فارسی و RTL ──────────────────────────────────────
      locale: const Locale('fa', 'IR'),
      supportedLocales: const [
        Locale('fa', 'IR'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        DefaultMaterialLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
      builder: (context, child) {
        return Directionality(
          // برنامه از راست به چپ (RTL) نمایش داده می‌شود
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },

      // ── صفحه اولیه ─────────────────────────────────────────────────────────
      home: const AppShell(),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// ████  اسکلت اصلی برنامه  ████
// ═════════════════════════════════════════════════════════════════════════════

/// [AppShell] – اسکلت اصلی UI با ناوبری پایین (Bottom Navigation)
///
/// این Widget مسئول مدیریت ناوبری بین ماژول‌های اصلی برنامه است:
/// - ۰: تقویم روزانه (Calendar) - Phase 3
/// - ۱: کانبان / تسک‌ها (Kanban) - Phase 2
/// - ۲: نقشه ذهنی نقش‌ها (Mind Map) - Phase 2
/// - ۳: روتین‌های هفتگی (Routines) - Phase 2
/// - ۴: تایمر فوکوس (Focus) - Phase 4
/// - ۵: یادداشت‌ها (Notes) - Phase 4
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  /// ایندکس تب فعال در ناوبری
  int _currentIndex = 1; // شروع با کانبان در Phase 2

  /// لیست آیتم‌های ناوبری
  static const List<_NavItem> _navItems = [
    _NavItem(
      icon: Icons.calendar_today_rounded,
      label: 'تقویم',
    ),
    _NavItem(
      icon: Icons.view_kanban_rounded,
      label: 'کانبان',
    ),
    _NavItem(
      icon: Icons.account_tree_rounded,
      label: 'نقش‌ها',
    ),
    _NavItem(
      icon: Icons.alarm_rounded,
      label: 'روتین‌ها',
    ),
    _NavItem(
      icon: Icons.sticky_note_2_rounded,
      label: 'یادداشت',
    ),
    _NavItem(
      icon: Icons.timer_rounded,
      label: 'فوکوس',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ── بدنه اصلی ─────────────────────────────────────────────────────────
      body: _buildCurrentPage(),

      // ── نوار ناوبری پایین ──────────────────────────────────────────────────
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  /// [_buildCurrentPage] – ساخت صفحه فعلی بر اساس تب انتخابی
  Widget _buildCurrentPage() {
    switch (_currentIndex) {
      case 1:
        return const KanbanScreen();
      case 2:
        return const RolesScreen();
      case 3:
        return const RoutinesScreen();
      default:
        return _PlaceholderPage(
          navItem: _navItems[_currentIndex],
          pageIndex: _currentIndex,
        );
    }
  }

  /// [_buildBottomNav] – ساخت نوار ناوبری پایین با طراحی گلس‌مورفیسم
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        // پس‌زمینه نیمه‌شفاف
        color: AppColors.surface1.withOpacity(0.95),
        // حاشیه شیشه‌ای در بالا
        border: const Border(
          top: BorderSide(
            color: AppColors.glassBorder,
            width: 0.5,
          ),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _currentIndex = index),
        items: _navItems
            .map(
              (item) => BottomNavigationBarItem(
                icon: Icon(item.icon),
                label: item.label,
              ),
            )
            .toList(),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// ████  مدل داخلی آیتم ناوبری  ████
// ═════════════════════════════════════════════════════════════════════════════
class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.label,
  });
}

// ═════════════════════════════════════════════════════════════════════════════
// ████  صفحه Placeholder برای ماژول‌های آینده  ████
// ═════════════════════════════════════════════════════════════════════════════
class _PlaceholderPage extends StatelessWidget {
  final _NavItem navItem;
  final int pageIndex;

  const _PlaceholderPage({
    required this.navItem,
    required this.pageIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.glassActive,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.neonOrange.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.bolt_rounded,
                color: AppColors.neonOrange,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              navItem.label,
              style: AppTextStyles.headlineSmall,
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.glassBackground,
                border: Border.all(
                  color: AppColors.glassBorder,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.glowNeonOrange,
                    blurRadius: AppTheme.neonGlowRadius,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                navItem.icon,
                color: AppColors.neonOrange,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              navItem.label,
              style: AppTextStyles.headlineMedium,
            ),
            const SizedBox(height: 12),
            Text(
              pageIndex == 0
                  ? 'این ماژول در Phase 3 (تقویم و تایم‌لاین) فعال خواهد شد'
                  : 'این ماژول در فازهای بعدی فعال خواهد شد',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textDisabled,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
