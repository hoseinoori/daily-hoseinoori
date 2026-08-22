/// ─────────────────────────────────────────────────────────────────────────────
/// [RoutineProvider] – مدیریت حالت روتین‌های تکرارشونده
/// ─────────────────────────────────────────────────────────────────────────────
library;

import 'package:flutter/foundation.dart';

import '../../../core/database/app_database.dart';
import '../data/repositories/routine_repository.dart';

/// [RoutineProvider] – مدیریت state روتین‌های هفتگی
class RoutineProvider extends ChangeNotifier {
  final RoutineRepository _repository;

  RoutineProvider(this._repository) {
    _initStreams();
  }

  List<RecurringRoutine> _routines = [];
  bool _isLoading = false;
  String? _error;

  List<RecurringRoutine> get routines => _routines;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _initStreams() {
    _setLoading(true);
    _repository.getAllRoutines().listen(
      (routines) {
        _routines = routines;
        _setLoading(false);
        notifyListeners();
      },
      onError: (e) {
        _error = 'خطا در بارگذاری روتین‌ها: $e';
        _setLoading(false);
        notifyListeners();
      },
    );
  }

  /// [addRoutine] – افزودن روتین جدید
  Future<String?> addRoutine({
    required String title,
    required String startTime,
    required String endTime,
    required List<int> daysOfWeek,
    String? roleId,
  }) async {
    try {
      final id = await _repository.createRoutine(
        title: title,
        startTime: startTime,
        endTime: endTime,
        daysOfWeek: daysOfWeek,
        roleId: roleId,
      );
      return id;
    } catch (e) {
      _error = 'خطا در ایجاد روتین: $e';
      notifyListeners();
      return null;
    }
  }

  /// [editRoutine] – ویرایش روتین
  Future<bool> editRoutine({
    required String id,
    String? title,
    String? startTime,
    String? endTime,
    List<int>? daysOfWeek,
    String? roleId,
  }) async {
    try {
      await _repository.updateRoutine(
        id: id,
        title: title,
        startTime: startTime,
        endTime: endTime,
        daysOfWeek: daysOfWeek,
        roleId: roleId,
      );
      return true;
    } catch (e) {
      _error = 'خطا در ویرایش روتین: $e';
      notifyListeners();
      return false;
    }
  }

  /// [removeRoutine] – حذف روتین
  Future<bool> removeRoutine(String id) async {
    try {
      await _repository.deleteRoutine(id);
      return true;
    } catch (e) {
      _error = 'خطا در حذف روتین: $e';
      notifyListeners();
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
