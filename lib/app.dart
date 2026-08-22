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
import 'core/theme/app_theme.dart';
import 'features/analytics/presentation/screens/analytics_screen.dart';
import 'features/calendar/presentation/screens/calendar_screen.dart';
import 'features/focus_timer/presentation/screens/focus_timer_screen.dart';
import 'features/notes/presentation/screens/notes_screen.dart';
import 'features/roles/presentation/screens/roles_screen.dart';
import 'features/routines/presentation/screens/routines_screen.dart';
import 'features/tasks/presentation/screens/kanban_screen.dart';

/// [DailyHoseinooriApp] – Widget ریشه اپلیکیشن
class DailyHoseinooriApp extends StatelessWidget {
  const DailyHoseinooriApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
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
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      home: const AppShell(),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// ████  اسکلت اصلی برنامه  ████
// ═════════════════════════════════════════════════════════════════════════════

/// [AppShell] – اسکلت اصلی UI با ناوبری پایین (Bottom Navigation)
///
/// مدیریت ناوبری بین ماژول‌های برنامه:
/// - ۰: تقویم روزانه (Calendar & Timeline)
/// - ۱: کانبان / تسک‌ها (Kanban)
/// - ۲: نقشه ذهنی نقش‌ها (Mind Map)
/// - ۳: روتین‌های هفتگی (Routines)
/// - ۴: یادداشت‌ها و ژورنال (Notes & Journal)
/// - ۵: تایمر فوکوس (Focus & Pomodoro)
/// - ۶: آمار و بهره‌وری (Analytics)
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

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
    _NavItem(
      icon: Icons.analytics_rounded,
      label: 'آمار',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildCurrentPage(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildCurrentPage() {
    switch (_currentIndex) {
      case 0:
        return const CalendarScreen();
      case 1:
        return const KanbanScreen();
      case 2:
        return const RolesScreen();
      case 3:
        return const RoutinesScreen();
      case 4:
        return const NotesScreen();
      case 5:
        return const FocusTimerScreen();
      case 6:
        return const AnalyticsScreen();
      default:
        return const CalendarScreen();
    }
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface1.withOpacity(0.95),
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
        selectedFontSize: 11,
        unselectedFontSize: 10,
        onTap: (index) => setState(() => _currentIndex = index),
        items: _navItems
            .map(
              (item) => BottomNavigationBarItem(
                icon: Icon(item.icon, size: 20),
                label: item.label,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.label,
  });
}
