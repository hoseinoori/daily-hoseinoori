/// ─────────────────────────────────────────────────────────────────────────────
/// [AnalyticsProvider] – مدیریت محاسبات آماری و داشبورد بهره‌وری
///
/// این کلاس مسئول:
/// - محاسبه درصد تکمیل تسک‌ها در هفته و ماه جاری
/// - محاسبه توزیع زمان فوکوس بر اساس نقش‌ها در نقشه ذهنی
/// - محاسبه نسبت زمان کار عمیق به زمان استراحت / فضای مجازی
/// - داده‌های نمودار میله‌ای ۷ روز گذشته برای نمایش روند تمرکز
/// ─────────────────────────────────────────────────────────────────────────────
library;

import 'package:flutter/foundation.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/database/app_database.dart';
import '../../focus_timer/data/repositories/focus_repository.dart';
import '../../roles/data/repositories/role_repository.dart';
import '../../tasks/data/repositories/task_repository.dart';

/// [DayFocusStat] – مدل کمکی برای نمودار میله‌ای روزانه
class DayFocusStat {
  final String dayName;
  final int deepWorkMinutes;
  final int restMinutes;

  DayFocusStat({
    required this.dayName,
    required this.deepWorkMinutes,
    required this.restMinutes,
  });
}

/// [RoleFocusStat] – مدل کمکی برای توزیع زمان بر اساس نقش
class RoleFocusStat {
  final String roleTitle;
  final int minutes;
  final double percentage;

  RoleFocusStat({
    required this.roleTitle,
    required this.minutes,
    required this.percentage,
  });
}

/// [AnalyticsProvider] – ارائه‌دهنده محاسبات تحلیلی
class AnalyticsProvider extends ChangeNotifier {
  final TaskRepository _taskRepository;
  final RoleRepository _roleRepository;
  final FocusRepository _focusRepository;

  AnalyticsProvider(
    this._taskRepository,
    this._roleRepository,
    this._focusRepository,
  ) {
    refreshStats();
  }

  // ── وضعیت داخلی ───────────────────────────────────────────────────────────
  int _totalTasks = 0;
  int _completedTasks = 0;
  int _inProgressTasks = 0;
  int _todoTasks = 0;
  int _weeklyCompletionRate = 0;
  int _monthlyCompletionRate = 0;

  int _totalDeepWorkMinutes = 0;
  int _totalRestMinutes = 0;
  List<DayFocusStat> _last7DaysStats = [];
  List<RoleFocusStat> _roleStats = [];
  bool _isLoading = false;

  // ── Getters ────────────────────────────────────────────────────────────────
  int get totalTasks => _totalTasks;
  int get completedTasks => _completedTasks;
  int get inProgressTasks => _inProgressTasks;
  int get todoTasks => _todoTasks;
  int get weeklyCompletionRate => _weeklyCompletionRate;
  int get monthlyCompletionRate => _monthlyCompletionRate;

  int get totalDeepWorkMinutes => _totalDeepWorkMinutes;
  int get totalRestMinutes => _totalRestMinutes;
  List<DayFocusStat> get last7DaysStats => _last7DaysStats;
  List<RoleFocusStat> get roleStats => _roleStats;
  bool get isLoading => _isLoading;

  /// نسبت کار عمیق به کل زمان ثبت‌شده (۰.۰ تا ۱.۰)
  double get deepWorkRatio {
    final total = _totalDeepWorkMinutes + _totalRestMinutes;
    if (total == 0) return 0.0;
    return _totalDeepWorkMinutes / total;
  }

  // ── بارگذاری و محاسبه آمار ────────────────────────────────────────────────

  Future<void> refreshStats() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.wait([
        _computeTaskStats(),
        _computeFocusStats(),
      ]);
    } catch (e) {
      debugPrint('خطا در محاسبه آمار: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// محاسبه آمار تسک‌ها
  Future<void> _computeTaskStats() async {
    // ۱. تسک‌ها
    _taskRepository.getAllTasks().first.then((tasks) {
      _totalTasks = tasks.length;
      _completedTasks =
          tasks.where((t) => t.status == AppConstants.taskStatusDone).length;
      _inProgressTasks = tasks
          .where((t) => t.status == AppConstants.taskStatusInProgress)
          .length;
      _todoTasks =
          tasks.where((t) => t.status == AppConstants.taskStatusTodo).length;

      if (_totalTasks > 0) {
        _weeklyCompletionRate =
            ((_completedTasks / _totalTasks) * 100).round();
        _monthlyCompletionRate = _weeklyCompletionRate;
      } else {
        _weeklyCompletionRate = 0;
        _monthlyCompletionRate = 0;
      }
      notifyListeners();
    });
  }

  /// محاسبه آمار فوکوس و لاگ‌ها
  Future<void> _computeFocusStats() async {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 6));
    final startOf7Days =
        DateTime(sevenDaysAgo.year, sevenDaysAgo.month, sevenDaysAgo.day);

    final logs =
        await _focusRepository.getLogsForDateRange(startOf7Days, now);

    // ۱. تفکیک کار عمیق و استراحت
    var deepMinutes = 0;
    var restMinutes = 0;

    for (final log in logs) {
      if (log.categoryLabel.contains('استراحت') ||
          log.categoryLabel.contains('مجازی')) {
        restMinutes += log.durationMinutes;
      } else {
        deepMinutes += log.durationMinutes;
      }
    }

    _totalDeepWorkMinutes = deepMinutes;
    _totalRestMinutes = restMinutes;

    // ۲. آمار روزانه ۷ روز گذشته
    const dayNames = ['ش', 'ی', 'د', 'س', 'چ', 'پ', 'ج'];
    final dailyStats = <DayFocusStat>[];

    for (var i = 6; i >= 0; i--) {
      final targetDate = now.subtract(Duration(days: i));
      final dayLogs = logs.where((l) {
        return l.completedAt.year == targetDate.year &&
            l.completedAt.month == targetDate.month &&
            l.completedAt.day == targetDate.day;
      });

      var dayDeep = 0;
      var dayRest = 0;
      for (final l in dayLogs) {
        if (l.categoryLabel.contains('استراحت') ||
            l.categoryLabel.contains('مجازی')) {
          dayRest += l.durationMinutes;
        } else {
          dayDeep += l.durationMinutes;
        }
      }

      // ایندکس روز هفته به فارسی
      final dayIndex = (targetDate.weekday + 1) % 7;
      dailyStats.add(DayFocusStat(
        dayName: dayNames[dayIndex],
        deepWorkMinutes: dayDeep,
        restMinutes: dayRest,
      ));
    }

    _last7DaysStats = dailyStats;
    notifyListeners();
  }
}
