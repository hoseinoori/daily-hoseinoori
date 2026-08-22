/// ─────────────────────────────────────────────────────────────────────────────
/// [FocusProvider] – مدیریت حالت تایمر فوکوس، پومودورو و لاگ سشن‌ها
///
/// این کلاس مسئول:
/// - اجرای تایمر معکوس (Countdown) و کرنومتر (Stopwatch)
/// - نگهداری زمان باقیمانده و درصد پیشرفت
/// - تنظیم دسته‌بندی سشن ('کار عمیق'، 'مطالعه'، 'فضای مجازی / استراحت')
/// - اتصال سشن به یک تسک خاص
/// - ثبت خودکار لاگ سشن در دیتابیس پس از اتمام زمان
/// - محاسبه مجموع دقایق تمرکز امروز
/// ─────────────────────────────────────────────────────────────────────────────
library;

import 'dart:async';
import 'package:flutter/foundation.dart';

import '../../../core/database/app_database.dart';
import '../data/repositories/focus_repository.dart';

/// حالت‌های تایمر
enum TimerMode {
  pomodoro25, // ۲۵ دقیقه
  deepWork50, // ۵۰ دقیقه
  shortBreak5, // ۵ دقیقه
  stopwatch, // کرنومتر آزاد
}

/// [FocusProvider] – ارائه‌دهنده حالت تایمر فوکوس
class FocusProvider extends ChangeNotifier {
  final FocusRepository _repository;

  FocusProvider(this._repository) {
    _initLogsStream();
    _applyPreset(TimerMode.pomodoro25);
  }

  // ── وضعیت داخلی ───────────────────────────────────────────────────────────
  Timer? _timer;
  TimerMode _mode = TimerMode.pomodoro25;
  int _targetSeconds = 25 * 60;
  int _currentSeconds = 25 * 60;
  bool _isRunning = false;
  bool _isPaused = false;

  String _selectedCategory = 'کار عمیق';
  String? _selectedTaskId;

  List<FocusTimerLog> _todayLogs = [];
  int _todayTotalMinutes = 0;

  // دسته‌بندی‌های پیش‌فرض
  static const List<String> categories = [
    'کار عمیق',
    'مطالعه / آموزش',
    'تسک کاری',
    'فضای مجازی / استراحت',
  ];

  // ── Getters ────────────────────────────────────────────────────────────────
  TimerMode get mode => _mode;
  int get targetSeconds => _targetSeconds;
  int get currentSeconds => _currentSeconds;
  bool get isRunning => _isRunning;
  bool get isPaused => _isPaused;
  String get selectedCategory => _selectedCategory;
  String? get selectedTaskId => _selectedTaskId;
  List<FocusTimerLog> get todayLogs => _todayLogs;
  int get todayTotalMinutes => _todayTotalMinutes;

  /// درصد پیشرفت تایمر (۰.۰ تا ۱.۰)
  double get progress {
    if (_mode == TimerMode.stopwatch) return 1.0;
    if (_targetSeconds == 0) return 0.0;
    return (_targetSeconds - _currentSeconds) / _targetSeconds;
  }

  /// فرمت متنی زمان "MM:SS"
  String get formattedTime {
    final minutes = _currentSeconds ~/ 60;
    final seconds = _currentSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // ── مقداردهی اولیه و لاگ‌ها ────────────────────────────────────────────────

  void _initLogsStream() {
    _repository.getAllLogs().listen((logs) {
      final now = DateTime.now();
      _todayLogs = logs.where((l) {
        return l.completedAt.year == now.year &&
            l.completedAt.month == now.month &&
            l.completedAt.day == now.day;
      }).toList();

      _todayTotalMinutes = _todayLogs.fold<int>(
        0,
        (sum, item) => sum + item.durationMinutes,
      );
      notifyListeners();
    });
  }

  // ── کنترل تایمر ────────────────────────────────────────────────────────────

  /// انتخاب حالت تایمر (پومودورو، کار عمیق، استراحت، کرنومتر)
  void setMode(TimerMode newMode) {
    if (_isRunning) resetTimer();
    _applyPreset(newMode);
    notifyListeners();
  }

  void _applyPreset(TimerMode mode) {
    _mode = mode;
    switch (mode) {
      case TimerMode.pomodoro25:
        _targetSeconds = 25 * 60;
        _currentSeconds = 25 * 60;
        break;
      case TimerMode.deepWork50:
        _targetSeconds = 50 * 60;
        _currentSeconds = 50 * 60;
        break;
      case TimerMode.shortBreak5:
        _targetSeconds = 5 * 60;
        _currentSeconds = 5 * 60;
        break;
      case TimerMode.stopwatch:
        _targetSeconds = 0;
        _currentSeconds = 0;
        break;
    }
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setTaskId(String? taskId) {
    _selectedTaskId = taskId;
    notifyListeners();
  }

  /// شروع یا ادامه تایمر
  void startTimer() {
    if (_isRunning && !_isPaused) return;

    _isRunning = true;
    _isPaused = false;
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_mode == TimerMode.stopwatch) {
        // حالت کرنومتر: افزایشی
        _currentSeconds++;
        notifyListeners();
      } else {
        // حالت معکوس: کاهشی
        if (_currentSeconds > 0) {
          _currentSeconds--;
          notifyListeners();
        } else {
          // اتمام تایمر!
          _onTimerComplete();
        }
      }
    });
    notifyListeners();
  }

  /// توقف موقت تایمر
  void pauseTimer() {
    if (!_isRunning) return;
    _timer?.cancel();
    _isPaused = true;
    notifyListeners();
  }

  /// ریست کردن تایمر
  void resetTimer() {
    _timer?.cancel();
    _isRunning = false;
    _isPaused = false;
    _applyPreset(_mode);
    notifyListeners();
  }

  /// توقف دستی کرنومتر و ذخیره سشن
  Future<void> stopAndLogStopwatch() async {
    if (_mode != TimerMode.stopwatch) return;
    final minutes = (_currentSeconds / 60).round();
    _timer?.cancel();
    _isRunning = false;
    _isPaused = false;

    if (minutes > 0) {
      await _repository.logSession(
        categoryLabel: _selectedCategory,
        durationMinutes: minutes,
        taskId: _selectedTaskId,
      );
    }
    _currentSeconds = 0;
    notifyListeners();
  }

  /// اتمام سشن معکوس و ثبت در لاگ
  Future<void> _onTimerComplete() async {
    _timer?.cancel();
    _isRunning = false;
    _isPaused = false;

    final durationMin = (_targetSeconds / 60).round();
    if (durationMin > 0) {
      await _repository.logSession(
        categoryLabel: _selectedCategory,
        durationMinutes: durationMin,
        taskId: _selectedTaskId,
      );
    }

    _applyPreset(_mode);
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
