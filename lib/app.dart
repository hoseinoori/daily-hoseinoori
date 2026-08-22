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
/// - تقویم روزانه (Calendar)
/// - کانبان / تسک‌ها (Kanban)
/// - نقشه ذهنی نقش‌ها (Mind Map)
/// - یادداشت‌ها (Notes)
/// - تایمر فوکوس (Focus)
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  /// ایندکس تب فعال در ناوبری
  int _currentIndex = 0;

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
    // در Phase 1 یک Placeholder نمایش می‌دهیم
    // در Phase های بعدی هر صفحه جایگزین می‌شود
    return _PlaceholderPage(
      navItem: _navItems[_currentIndex],
      pageIndex: _currentIndex,
    );
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
// ████  صفحه Placeholder برای Phase 1  ████
// ═════════════════════════════════════════════════════════════════════════════

/// [_PlaceholderPage] – صفحه موقت برای نمایش پایه برنامه در Phase 1
///
/// در فازهای بعدی با UI واقعی جایگزین می‌شود.
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
      // ── AppBar با عنوان بخش ────────────────────────────────────────────────
      appBar: AppBar(
        title: Row(
          children: [
            // لوگو / آیکون برنامه
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
            // عنوان بخش فعلی
            Text(
              navItem.label,
              style: AppTextStyles.headlineSmall,
            ),
          ],
        ),
        actions: [
          // دکمه تنظیمات
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            color: AppColors.textSecondary,
            onPressed: () {},
          ),
        ],
      ),

      // ── محتوای اصلی صفحه ──────────────────────────────────────────────────
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // آیکون بزرگ نئونی
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
            // عنوان صفحه
            Text(
              navItem.label,
              style: AppTextStyles.headlineMedium,
            ),
            const SizedBox(height: 12),
            // توضیح Phase
            Text(
              'در حال آماده‌سازی...',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.glassActive,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.neonOrange.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                'Phase 1 – Foundation ✓',
                style: AppTextStyles.neonAccent.copyWith(fontSize: 12),
              ),
            ),
          ],
        ),
      ),

      // ── دکمه عمل شناور ────────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}

/// [_NavItem] – مدل داده برای آیتم‌های ناوبری
class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.label,
  });
}
