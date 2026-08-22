/// ─────────────────────────────────────────────────────────────────────────────
/// [RoutineRepository] – لایه Repository برای روتین‌های تکرارشونده
///
/// مدیریت CRUD برنامه‌های تکرارشونده هفتگی که به صورت خودکار
/// در تقویم روزانه نمایش داده می‌شوند.
/// ─────────────────────────────────────────────────────────────────────────────
library;

import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';

/// [RoutineRepository] – مدیریت روتین‌های تکرارشونده
class RoutineRepository {
  final AppDatabase _db;
  final _uuid = const Uuid();

  RoutineRepository(this._db);

  // ─── خواندن / Read Operations ─────────────────────────────────────────────

  /// [getAllRoutines] – دریافت تمام روتین‌های تعریف‌شده
  Stream<List<RecurringRoutine>> getAllRoutines() {
    return (_db.select(_db.recurringRoutines)
          ..orderBy([(t) => OrderingTerm.asc(t.startTime)]))
        .watch();
  }

  /// [getRoutinesForDayOfWeek] – دریافت روتین‌های یک روز خاص هفته
  ///
  /// این متد برای تقویم روزانه استفاده می‌شود تا روتین‌های آن روز
  /// به صورت خودکار نمایش داده شوند.
  ///
  /// [dayIndex] – ایندکس روز هفته: شنبه=0, یک‌شنبه=1, ..., جمعه=6
  /// خروجی: لیست روتین‌های آن روز به ترتیب ساعت شروع
  Future<List<RecurringRoutine>> getRoutinesForDayOfWeek(
      int dayIndex) async {
    final allRoutines = await _db.select(_db.recurringRoutines).get();

    // فیلتر روتین‌هایی که شامل این روز هفته هستند
    return allRoutines.where((routine) {
      final days =
          List<int>.from(jsonDecode(routine.daysOfWeek) as List);
      return days.contains(dayIndex);
    }).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  /// [getRoutineById] – دریافت یک روتین با شناسه
  Future<RecurringRoutine?> getRoutineById(String id) {
    return (
      _db.select(_db.recurringRoutines)..where((t) => t.id.equals(id))
    ).getSingleOrNull();
  }

  // ─── نوشتن / Write Operations ─────────────────────────────────────────────

  /// [createRoutine] – ایجاد روتین تکرارشونده جدید
  ///
  /// [title]      – عنوان روتین (مثل: باشگاه، مطالعه صبح)
  /// [startTime]  – ساعت شروع به فرمت "HH:mm" (مثل "07:30")
  /// [endTime]    – ساعت پایان به فرمت "HH:mm" (مثل "08:00")
  /// [daysOfWeek] – لیست ایندکس روزهای هفته [0-6] (شنبه تا جمعه)
  /// [roleId]     – شناسه نقش مرتبط (اختیاری)
  ///
  /// خروجی: شناسه روتین ایجادشده
  Future<String> createRoutine({
    required String title,
    required String startTime,
    required String endTime,
    required List<int> daysOfWeek,
    String? roleId,
  }) async {
    final id = _uuid.v4();
    await _db.into(_db.recurringRoutines).insert(
          RecurringRoutinesCompanion.insert(
            id: id,
            title: title,
            startTime: startTime,
            endTime: endTime,
            // ذخیره روزهای هفته به فرمت JSON
            daysOfWeek: jsonEncode(daysOfWeek),
            roleId: Value(roleId),
          ),
        );
    return id;
  }

  /// [updateRoutine] – بروزرسانی اطلاعات روتین
  Future<int> updateRoutine({
    required String id,
    String? title,
    String? startTime,
    String? endTime,
    List<int>? daysOfWeek,
    String? roleId,
  }) {
    return (_db.update(_db.recurringRoutines)
          ..where((t) => t.id.equals(id)))
        .write(
      RecurringRoutinesCompanion(
        title: title != null ? Value(title) : const Value.absent(),
        startTime:
            startTime != null ? Value(startTime) : const Value.absent(),
        endTime: endTime != null ? Value(endTime) : const Value.absent(),
        daysOfWeek: daysOfWeek != null
            ? Value(jsonEncode(daysOfWeek))
            : const Value.absent(),
        roleId: roleId != null ? Value(roleId) : const Value.absent(),
      ),
    );
  }

  /// [deleteRoutine] – حذف روتین
  Future<int> deleteRoutine(String id) {
    return (
      _db.delete(_db.recurringRoutines)..where((t) => t.id.equals(id))
    ).go();
  }
}
