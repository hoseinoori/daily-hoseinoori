/// ─────────────────────────────────────────────────────────────────────────────
/// [TaskProvider] – مدیریت حالت برای ماژول تسک‌ها و Kanban
///
/// این Provider مسئول:
/// - نگهداری state تسک‌ها بر اساس وضعیت (todo, in_progress, done)
/// - مدیریت فیلتر Kanban
/// - عملیات CRUD تسک‌ها و زیرتسک‌ها
/// - محاسبه درصد پیشرفت از روی زیرتسک‌ها
/// ─────────────────────────────────────────────────────────────────────────────
library;

import 'package:flutter/foundation.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/database/app_database.dart';
import '../data/repositories/task_repository.dart';

/// [TaskProvider] – مدیریت حالت تسک‌ها و Kanban Board
class TaskProvider extends ChangeNotifier {
  final TaskRepository _repository;

  TaskProvider(this._repository) {
    _initStreams();
  }

  // ── وضعیت داخلی ───────────────────────────────────────────────────────────
  List<Task> _todoTasks = [];
  List<Task> _inProgressTasks = [];
  List<Task> _doneTasks = [];
  Map<String, List<Subtask>> _subtasksMap = {};
  bool _isLoading = false;
  String? _error;

  /// فیلتر فعال Kanban (null = همه)
  String? _activeRoleFilter;

  // ── Getters ────────────────────────────────────────────────────────────────
  List<Task> get todoTasks => _filterByRole(_todoTasks);
  List<Task> get inProgressTasks => _filterByRole(_inProgressTasks);
  List<Task> get doneTasks => _filterByRole(_doneTasks);
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get activeRoleFilter => _activeRoleFilter;

  /// مجموع تعداد تسک‌های فعال
  int get totalActiveTasks => _todoTasks.length + _inProgressTasks.length;

  /// زیرتسک‌های یک تسک خاص
  List<Subtask> getSubtasksOf(String taskId) =>
      _subtasksMap[taskId] ?? [];

  // ── مقداردهی اولیه ────────────────────────────────────────────────────────

  /// [_initStreams] – گوش‌دادن به Stream های دیتابیس برای هر وضعیت
  void _initStreams() {
    _setLoading(true);

    _repository.getTasksByStatus(AppConstants.taskStatusTodo).listen(
      (tasks) {
        _todoTasks = tasks;
        _loadSubtasksForTasks(tasks);
        notifyListeners();
      },
    );

    _repository.getTasksByStatus(AppConstants.taskStatusInProgress).listen(
      (tasks) {
        _inProgressTasks = tasks;
        _loadSubtasksForTasks(tasks);
        notifyListeners();
      },
    );

    _repository.getTasksByStatus(AppConstants.taskStatusDone).listen(
      (tasks) {
        _doneTasks = tasks;
        _setLoading(false);
        notifyListeners();
      },
    );
  }

  /// [_loadSubtasksForTasks] – بارگذاری زیرتسک‌ها برای گروهی از تسک‌ها
  Future<void> _loadSubtasksForTasks(List<Task> tasks) async {
    for (final task in tasks) {
      _repository.getSubtasksOfTask(task.id).listen((subtasks) {
        _subtasksMap[task.id] = subtasks;
        notifyListeners();
      });
    }
  }

  // ── فیلتر ─────────────────────────────────────────────────────────────────

  /// [setRoleFilter] – فیلتر کردن تسک‌ها بر اساس نقش
  void setRoleFilter(String? roleId) {
    _activeRoleFilter = roleId;
    notifyListeners();
  }

  List<Task> _filterByRole(List<Task> tasks) {
    if (_activeRoleFilter == null) return tasks;
    return tasks.where((t) => t.roleId == _activeRoleFilter).toList();
  }

  // ── عملیات CRUD تسک ───────────────────────────────────────────────────────

  /// [createTask] – ایجاد تسک جدید
  Future<String?> createTask({
    required String title,
    String? roleId,
    String? description,
    String priority = AppConstants.priorityMedium,
    DateTime? deadline,
    DateTime? scheduledDate,
    String? startTime,
    String? endTime,
    bool isTimelineBounded = false,
  }) async {
    try {
      final id = await _repository.createTask(
        title: title,
        roleId: roleId,
        description: description,
        priority: priority,
        deadline: deadline,
        scheduledDate: scheduledDate,
        startTime: startTime,
        endTime: endTime,
        isTimelineBounded: isTimelineBounded,
      );
      return id;
    } catch (e) {
      _error = 'خطا در ایجاد تسک: $e';
      notifyListeners();
      return null;
    }
  }

  /// [moveTask] – انتقال تسک بین ستون‌های Kanban
  ///
  /// [taskId]    – شناسه تسک
  /// [newStatus] – وضعیت جدید: todo | in_progress | done
  Future<bool> moveTask(String taskId, String newStatus) async {
    try {
      await _repository.updateTaskStatus(taskId, newStatus);
      // اگر تسک به Done رفت، درصد پیشرفت را ۱۰۰ می‌کنیم
      if (newStatus == AppConstants.taskStatusDone) {
        await _repository.updateTaskProgress(taskId, 100);
      }
      return true;
    } catch (e) {
      _error = 'خطا در تغییر وضعیت: $e';
      notifyListeners();
      return false;
    }
  }

  /// [updateTask] – ویرایش کامل تسک
  Future<bool> updateTask({
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
  }) async {
    try {
      await _repository.updateTask(
        id: id,
        title: title,
        description: description,
        status: status,
        priority: priority,
        progressPercentage: progressPercentage,
        deadline: deadline,
        scheduledDate: scheduledDate,
        startTime: startTime,
        endTime: endTime,
        isTimelineBounded: isTimelineBounded,
        roleId: roleId,
      );
      return true;
    } catch (e) {
      _error = 'خطا در ویرایش تسک: $e';
      notifyListeners();
      return false;
    }
  }

  /// [deleteTask] – حذف تسک
  Future<bool> deleteTask(String taskId) async {
    try {
      await _repository.deleteTask(taskId);
      _subtasksMap.remove(taskId);
      return true;
    } catch (e) {
      _error = 'خطا در حذف تسک: $e';
      notifyListeners();
      return false;
    }
  }

  // ── عملیات زیرتسک ─────────────────────────────────────────────────────────

  /// [addSubtask] – افزودن زیرتسک
  Future<bool> addSubtask(String taskId, String title) async {
    try {
      await _repository.createSubtask(taskId: taskId, title: title);
      // بروزرسانی درصد پیشرفت تسک از روی زیرتسک‌ها
      await _syncProgressFromSubtasks(taskId);
      return true;
    } catch (e) {
      _error = 'خطا در افزودن زیرتسک: $e';
      notifyListeners();
      return false;
    }
  }

  /// [toggleSubtask] – تغییر وضعیت تکمیل زیرتسک
  Future<bool> toggleSubtask(
      String subtaskId, String taskId, bool isCompleted) async {
    try {
      await _repository.toggleSubtask(subtaskId, isCompleted: isCompleted);
      await _syncProgressFromSubtasks(taskId);
      return true;
    } catch (e) {
      _error = 'خطا در بروزرسانی زیرتسک: $e';
      notifyListeners();
      return false;
    }
  }

  /// [deleteSubtask] – حذف زیرتسک
  Future<bool> deleteSubtask(String subtaskId, String taskId) async {
    try {
      await _repository.deleteSubtask(subtaskId);
      await _syncProgressFromSubtasks(taskId);
      return true;
    } catch (e) {
      _error = 'خطا در حذف زیرتسک: $e';
      notifyListeners();
      return false;
    }
  }

  /// [_syncProgressFromSubtasks] – همگام‌سازی درصد پیشرفت از زیرتسک‌ها
  ///
  /// پس از هر تغییر در زیرتسک‌ها، درصد پیشرفت تسک والد بروزرسانی می‌شود.
  Future<void> _syncProgressFromSubtasks(String taskId) async {
    final percentage =
        await _repository.getSubtaskCompletionRate(taskId);
    await _repository.updateTaskProgress(taskId, percentage);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
