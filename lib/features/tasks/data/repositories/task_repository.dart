/// ─────────────────────────────────────────────────────────────────────────────
/// [TaskRepository] – لایه Repository برای تسک‌ها و زیرتسک‌ها
///
/// این کلاس تمام عملیات CRUD مربوط به جداول [Tasks] و [Subtasks] را
/// پیاده‌سازی می‌کند.
/// ─────────────────────────────────────────────────────────────────────────────
library;

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/app_database.dart';

/// [TaskRepository] – مدیریت عملیات دیتابیسی تسک‌ها
class TaskRepository {
  final AppDatabase _db;
  final _uuid = const Uuid();

  TaskRepository(this._db);

  // ─── عملیات خواندن تسک‌ها / Task Read Operations ─────────────────────────

  /// [getAllTasks] – دریافت تمام تسک‌ها
  Stream<List<Task>> getAllTasks() {
    return (_db.select(_db.tasks)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  /// [getTasksByStatus] – دریافت تسک‌ها بر اساس وضعیت
  ///
  /// [status] – یکی از: 'todo' | 'in_progress' | 'done'
  Stream<List<Task>> getTasksByStatus(String status) {
    return (_db.select(_db.tasks)
          ..where((t) => t.status.equals(status))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  /// [getTasksByRole] – دریافت تسک‌های مرتبط با یک نقش
  ///
  /// [roleId] – شناسه نقش
  Stream<List<Task>> getTasksByRole(String roleId) {
    return (_db.select(_db.tasks)
          ..where((t) => t.roleId.equals(roleId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  /// [getTasksForDate] – دریافت تسک‌های اختصاص‌یافته به یک روز خاص
  ///
  /// این متد برای نمایش در تقویم روزانه استفاده می‌شود.
  /// [date] – تاریخ مورد نظر
  Stream<List<Task>> getTasksForDate(DateTime date) {
    // شروع و پایان روز را محاسبه می‌کنیم
    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    return (_db.select(_db.tasks)
          ..where(
            (t) =>
                t.scheduledDate.isBiggerOrEqualValue(dayStart) &
                t.scheduledDate.isSmallerThanValue(dayEnd),
          )
          ..orderBy([
            (t) => OrderingTerm.asc(t.isTimelineBounded),
            (t) => OrderingTerm.asc(t.startTime),
          ]))
        .watch();
  }

  /// [getTaskById] – دریافت یک تسک با شناسه
  Future<Task?> getTaskById(String id) {
    return (_db.select(_db.tasks)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  // ─── عملیات نوشتن تسک‌ها / Task Write Operations ─────────────────────────

  /// [createTask] – ایجاد تسک جدید
  ///
  /// [title]              – عنوان تسک (اجباری)
  /// [roleId]             – شناسه نقش مرتبط (اختیاری)
  /// [description]        – توضیحات (اختیاری)
  /// [status]             – وضعیت اولیه (پیش‌فرض: 'todo')
  /// [priority]           – اولویت: low | medium | high | urgent
  /// [deadline]           – مهلت (اختیاری)
  /// [scheduledDate]      – تاریخ در تقویم (اختیاری)
  /// [startTime]          – ساعت شروع Timeline (اختیاری)
  /// [endTime]            – ساعت پایان Timeline (اختیاری)
  /// [isTimelineBounded]  – آیا به ساعت وابسته است؟
  ///
  /// خروجی: شناسه تسک ایجادشده
  Future<String> createTask({
    required String title,
    String? roleId,
    String? description,
    String status = AppConstants.taskStatusTodo,
    String? priority,
    DateTime? deadline,
    DateTime? scheduledDate,
    String? startTime,
    String? endTime,
    bool isTimelineBounded = false,
  }) async {
    final id = _uuid.v4();
    await _db.into(_db.tasks).insert(
          TasksCompanion.insert(
            id: id,
            title: title,
            roleId: Value(roleId),
            description: Value(description),
            status: Value(status),
            priority: Value(priority),
            deadline: Value(deadline),
            scheduledDate: Value(scheduledDate),
            startTime: Value(startTime),
            endTime: Value(endTime),
            isTimelineBounded: Value(isTimelineBounded),
          ),
        );
    return id;
  }

  /// [updateTaskStatus] – بروزرسانی وضعیت تسک
  ///
  /// [id]     – شناسه تسک
  /// [status] – وضعیت جدید: 'todo' | 'in_progress' | 'done'
  Future<int> updateTaskStatus(String id, String status) {
    return (_db.update(_db.tasks)..where((t) => t.id.equals(id))).write(
      TasksCompanion(status: Value(status)),
    );
  }

  /// [updateTaskProgress] – بروزرسانی درصد پیشرفت تسک
  ///
  /// [id]         – شناسه تسک
  /// [percentage] – درصد پیشرفت (۰ تا ۱۰۰)
  Future<int> updateTaskProgress(String id, int percentage) {
    final clampedPercentage = percentage.clamp(0, 100);
    return (_db.update(_db.tasks)..where((t) => t.id.equals(id))).write(
      TasksCompanion(progressPercentage: Value(clampedPercentage)),
    );
  }

  /// [updateTask] – بروزرسانی کامل اطلاعات تسک
  Future<int> updateTask({
    required String id,
    String? title,
    String? description,
    String? status,
    String? priority,
    int? progressPercentage,
    DateTime? deadline,
    DateTime? scheduledDate,
    String? startTime,
    String? endTime,
    bool? isTimelineBounded,
    String? roleId,
  }) {
    return (_db.update(_db.tasks)..where((t) => t.id.equals(id))).write(
      TasksCompanion(
        title: title != null ? Value(title) : const Value.absent(),
        description: description != null
            ? Value(description)
            : const Value.absent(),
        status: status != null ? Value(status) : const Value.absent(),
        priority: priority != null ? Value(priority) : const Value.absent(),
        progressPercentage: progressPercentage != null
            ? Value(progressPercentage)
            : const Value.absent(),
        deadline:
            deadline != null ? Value(deadline) : const Value.absent(),
        scheduledDate: scheduledDate != null
            ? Value(scheduledDate)
            : const Value.absent(),
        startTime:
            startTime != null ? Value(startTime) : const Value.absent(),
        endTime: endTime != null ? Value(endTime) : const Value.absent(),
        isTimelineBounded: isTimelineBounded != null
            ? Value(isTimelineBounded)
            : const Value.absent(),
        roleId: roleId != null ? Value(roleId) : const Value.absent(),
      ),
    );
  }

  /// [deleteTask] – حذف تسک (زیرتسک‌ها نیز CASCADE حذف می‌شوند)
  Future<int> deleteTask(String id) {
    return (_db.delete(_db.tasks)..where((t) => t.id.equals(id))).go();
  }

  // ─── عملیات زیرتسک‌ها / Subtask Operations ────────────────────────────────

  /// [getSubtasksOfTask] – دریافت تمام زیرتسک‌های یک تسک
  Stream<List<Subtask>> getSubtasksOfTask(String taskId) {
    return (_db.select(_db.subtasks)
          ..where((t) => t.taskId.equals(taskId)))
        .watch();
  }

  /// [createSubtask] – ایجاد زیرتسک جدید
  ///
  /// [taskId] – شناسه تسک والد (اجباری)
  /// [title]  – عنوان زیرتسک (اجباری)
  ///
  /// خروجی: شناسه زیرتسک ایجادشده
  Future<String> createSubtask({
    required String taskId,
    required String title,
  }) async {
    final id = _uuid.v4();
    await _db.into(_db.subtasks).insert(
          SubtasksCompanion.insert(
            id: id,
            taskId: taskId,
            title: title,
          ),
        );
    return id;
  }

  /// [toggleSubtask] – تغییر وضعیت تکمیل/ناتکمیل زیرتسک
  ///
  /// [id]          – شناسه زیرتسک
  /// [isCompleted] – وضعیت جدید
  Future<int> toggleSubtask(String id, {required bool isCompleted}) {
    return (_db.update(_db.subtasks)..where((t) => t.id.equals(id))).write(
      SubtasksCompanion(isCompleted: Value(isCompleted)),
    );
  }

  /// [deleteSubtask] – حذف یک زیرتسک
  Future<int> deleteSubtask(String id) {
    return (_db.delete(_db.subtasks)..where((t) => t.id.equals(id))).go();
  }

  /// [getSubtaskCompletionRate] – محاسبه درصد تکمیل زیرتسک‌ها
  ///
  /// [taskId] – شناسه تسک
  /// خروجی: عدد ۰ تا ۱۰۰ (درصد زیرتسک‌های تکمیل‌شده)
  Future<int> getSubtaskCompletionRate(String taskId) async {
    final allSubtasks = await (_db.select(_db.subtasks)
          ..where((t) => t.taskId.equals(taskId)))
        .get();

    if (allSubtasks.isEmpty) return 0;

    final completedCount =
        allSubtasks.where((s) => s.isCompleted).length;
    return ((completedCount / allSubtasks.length) * 100).round();
  }
}
