/// ─────────────────────────────────────────────────────────────────────────────
/// [FocusRepository] – لایه Repository برای تایمر فوکوس و پومودورو
///
/// مدیریت لاگ سشن‌های تایمر فوکوس برای گزارش‌گیری و آمار بهره‌وری.
/// ─────────────────────────────────────────────────────────────────────────────
library;

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';

/// [FocusRepository] – مدیریت لاگ‌های تایمر فوکوس
class FocusRepository {
  final AppDatabase _db;
  final _uuid = const Uuid();

  FocusRepository(this._db);

  // ─── خواندن / Read Operations ─────────────────────────────────────────────

  /// [getAllLogs] – دریافت تمام لاگ‌های فوکوس
  Stream<List<FocusTimerLog>> getAllLogs() {
    return (_db.select(_db.focusTimerLogs)
          ..orderBy([(t) => OrderingTerm.desc(t.completedAt)]))
        .watch();
  }

  /// [getLogsForDateRange] – دریافت لاگ‌ها در یک بازه زمانی
  ///
  /// برای نمودارهای داشبورد تحلیلی استفاده می‌شود.
  ///
  /// [from] – تاریخ شروع بازه
  /// [to]   – تاریخ پایان بازه
  Future<List<FocusTimerLog>> getLogsForDateRange(
      DateTime from, DateTime to) {
    return (_db.select(_db.focusTimerLogs)
          ..where(
            (t) =>
                t.completedAt.isBiggerOrEqualValue(from) &
                t.completedAt.isSmallerOrEqualValue(to),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.completedAt)]))
        .get();
  }

  /// [getTodayLogs] – دریافت لاگ‌های امروز
  Future<List<FocusTimerLog>> getTodayLogs() {
    final now = DateTime.now();
    final dayStart = DateTime(now.year, now.month, now.day);
    final dayEnd = dayStart.add(const Duration(days: 1));
    return getLogsForDateRange(dayStart, dayEnd);
  }

  /// [getLogsByTask] – دریافت لاگ‌های مرتبط با یک تسک
  Stream<List<FocusTimerLog>> getLogsByTask(String taskId) {
    return (_db.select(_db.focusTimerLogs)
          ..where((t) => t.taskId.equals(taskId))
          ..orderBy([(t) => OrderingTerm.desc(t.completedAt)]))
        .watch();
  }

  /// [getTotalFocusMinutesToday] – محاسبه مجموع دقایق فوکوس امروز
  ///
  /// خروجی: مجموع دقایق فوکوس عمیق امروز
  Future<int> getTotalFocusMinutesToday() async {
    final todayLogs = await getTodayLogs();
    return todayLogs.fold<int>(0, (sum, log) => sum + log.durationMinutes);
  }

  // ─── نوشتن / Write Operations ─────────────────────────────────────────────

  /// [logSession] – ثبت یک سشن تایمر فوکوس
  ///
  /// این متد پس از اتمام هر سشن فوکوس یا استراحت فراخوانی می‌شود.
  ///
  /// [categoryLabel]   – دسته‌بندی سشن (مثل 'کار عمیق'، 'استراحت')
  /// [durationMinutes] – مدت زمان سشن به دقیقه
  /// [taskId]          – شناسه تسک مرتبط (اختیاری)
  ///
  /// خروجی: شناسه لاگ ثبت‌شده
  Future<String> logSession({
    required String categoryLabel,
    required int durationMinutes,
    String? taskId,
  }) async {
    final id = _uuid.v4();
    await _db.into(_db.focusTimerLogs).insert(
          FocusTimerLogsCompanion.insert(
            id: id,
            categoryLabel: categoryLabel,
            durationMinutes: durationMinutes,
            taskId: Value(taskId),
          ),
        );
    return id;
  }

  /// [deleteLog] – حذف یک لاگ فوکوس
  Future<int> deleteLog(String id) {
    return (_db.delete(_db.focusTimerLogs)
          ..where((t) => t.id.equals(id)))
        .go();
  }
}
