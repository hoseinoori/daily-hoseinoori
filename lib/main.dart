/// ─────────────────────────────────────────────────────────────────────────────
/// [main.dart] – نقطه ورود برنامه Daily Hoseinoori
///
/// این فایل مسئول:
/// 1. راه‌اندازی Flutter Engine
/// 2. مقداردهی اولیه سرویس‌ها و وابستگی‌ها
/// 3. تزریق دیتابیس و Repository ها از طریق Provider
/// 4. اجرای اپلیکیشن
/// ─────────────────────────────────────────────────────────────────────────────
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/database/app_database.dart';
import 'features/focus_timer/data/repositories/focus_repository.dart';
import 'features/notes/data/repositories/note_repository.dart';
import 'features/roles/data/repositories/role_repository.dart';
import 'features/routines/data/repositories/routine_repository.dart';
import 'features/tasks/data/repositories/task_repository.dart';

/// [main] – نقطه ورود اصلی برنامه
///
/// ترتیب اجرا:
/// 1. مقداردهی اولیه WidgetsFlutterBinding
/// 2. تنظیم جهت‌گیری صفحه (Portrait + Landscape)
/// 3. تنظیم رنگ Status Bar
/// 4. ایجاد نمونه دیتابیس
/// 5. اجرای برنامه با MultiProvider
void main() async {
  // اطمینان از راه‌اندازی صحیح WidgetsBinding قبل از استفاده از async ops
  WidgetsFlutterBinding.ensureInitialized();

  // تنظیم جهت‌های پشتیبانی‌شده صفحه نمایش
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // تنظیم رنگ‌های Status Bar برای تم تاریک
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0A0A0F),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // ایجاد نمونه دیتابیس (Singleton در طول عمر برنامه)
  final database = AppDatabase();

  // اجرای برنامه با تزریق وابستگی‌ها از طریق MultiProvider
  runApp(
    MultiProvider(
      providers: [
        // ── دیتابیس اصلی ────────────────────────────────────────────────────
        Provider<AppDatabase>.value(value: database),

        // ── Repository های هر فیچر ──────────────────────────────────────────
        /// Repository نقش‌ها و Mind Map
        ProxyProvider<AppDatabase, RoleRepository>(
          update: (_, db, __) => RoleRepository(db),
        ),
        /// Repository تسک‌ها و زیرتسک‌ها
        ProxyProvider<AppDatabase, TaskRepository>(
          update: (_, db, __) => TaskRepository(db),
        ),
        /// Repository روتین‌های تکرارشونده
        ProxyProvider<AppDatabase, RoutineRepository>(
          update: (_, db, __) => RoutineRepository(db),
        ),
        /// Repository یادداشت‌ها
        ProxyProvider<AppDatabase, NoteRepository>(
          update: (_, db, __) => NoteRepository(db),
        ),
        /// Repository تایمر فوکوس
        ProxyProvider<AppDatabase, FocusRepository>(
          update: (_, db, __) => FocusRepository(db),
        ),
      ],
      child: const DailyHoseinooriApp(),
    ),
  );
}
