/// ─────────────────────────────────────────────────────────────────────────────
/// [CalendarProvider] – مدیریت حالت تقویم جلالی، مناسبت‌ها و نمای روزانه
///
/// این کلاس مسئول:
/// - لود کردن مناسبت‌ها و تعطیلات از assets/data/persian_events.json
/// - مدیریت تاریخ انتخاب‌شده و ماه جاری در تقویم
/// - واکشی تسک‌های روز جاری و تفکیک آنها به Timeline و Untimed
/// - واکشی روتین‌های روز جاری بر اساس ایندکس روز هفته
/// - مدیریت سوئیچ بین حالت Timeline و Untimed Tasks
/// ─────────────────────────────────────────────────────────────────────────────
library;

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../../core/database/app_database.dart';
import '../../routines/data/repositories/routine_repository.dart';
import '../../tasks/data/repositories/task_repository.dart';
import '../models/persian_event.dart';
import '../utils/jalali_helper.dart';

/// [CalendarProvider] – ارائه‌دهنده حالت تقویم و موتور روزانه
class CalendarProvider extends ChangeNotifier {
  final TaskRepository _taskRepository;
  final RoutineRepository _routineRepository;

  CalendarProvider(this._taskRepository, this._routineRepository) {
    _init();
  }

  // ── وضعیت داخلی ───────────────────────────────────────────────────────────
  late JalaliDate _selectedDate;
  late int _viewedYear;
  late int _viewedMonth;
  bool _isTimelineMode = true; // پیش‌فرض: حالت تایم‌لاین ساعتی

  List<PersianEvent> _allEvents = [];
  List<Task> _dailyTasks = [];
  List<RecurringRoutine> _dailyRoutines = [];
  final bool _isLoading = false;

  // ── Getters ────────────────────────────────────────────────────────────────
  JalaliDate get selectedDate => _selectedDate;
  int get viewedYear => _viewedYear;
  int get viewedMonth => _viewedMonth;
  String get viewedMonthName => JalaliDate.monthNames[_viewedMonth - 1];
  bool get isTimelineMode => _isTimelineMode;
  bool get isLoading => _isLoading;

  /// تسک‌های دارای ساعت مشخص (برای Timeline)
  List<Task> get timelineTasks =>
      _dailyTasks.where((t) => t.isTimelineBounded).toList();

  /// تسک‌های آزاد روز بدون ساعت مشخص (برای Untimed Tasks)
  List<Task> get untimedTasks =>
      _dailyTasks.where((t) => !t.isTimelineBounded).toList();

  /// تمام تسک‌های روز انتخابی
  List<Task> get dailyTasks => _dailyTasks;

  /// روتین‌های تکرارشونده روز انتخابی
  List<RecurringRoutine> get dailyRoutines => _dailyRoutines;

  // ── مقداردهی اولیه ────────────────────────────────────────────────────────

  Future<void> _init() async {
    final now = JalaliDate.now();
    _selectedDate = now;
    _viewedYear = now.year;
    _viewedMonth = now.month;

    await _loadPersianEvents();
    _fetchDailyData();
  }

  /// لود فایل JSON مناسبت‌های ایران
  Future<void> _loadPersianEvents() async {
    try {
      final jsonString =
          await rootBundle.loadString('assets/data/persian_events.json');
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      final list = data['holidays'] as List;
      _allEvents = list
          .map((item) => PersianEvent.fromJson(item as Map<String, dynamic>))
          .toList();
      notifyListeners();
    } catch (e) {
      debugPrint('خطا در لود مناسبت‌ها: $e');
    }
  }

  /// واکشی تسک‌ها و روتین‌های روز انتخاب‌شده
  void _fetchDailyData() {
    final gDate = _selectedDate.toDateTime();

    // ۱. تسک‌های تاریخ انتخابی از طریق Stream
    _taskRepository.getTasksForDate(gDate).listen((tasks) {
      _dailyTasks = tasks;
      notifyListeners();
    });

    // ۲. روتین‌های روز هفته (۰ تا ۶)
    _routineRepository
        .getRoutinesForDayOfWeek(_selectedDate.weekDayIndex)
        .then((routines) {
      _dailyRoutines = routines;
      notifyListeners();
    });
  }

  // ── ناوبری تقویم ──────────────────────────────────────────────────────────

  /// انتخاب یک روز خاص
  void selectDate(JalaliDate date) {
    _selectedDate = date;
    _viewedYear = date.year;
    _viewedMonth = date.month;
    _fetchDailyData();
    notifyListeners();
  }

  /// رفتن به ماه قبل
  void previousMonth() {
    if (_viewedMonth == 1) {
      _viewedMonth = 12;
      _viewedYear--;
    } else {
      _viewedMonth--;
    }
    notifyListeners();
  }

  /// رفتن به ماه بعد
  void nextMonth() {
    if (_viewedMonth == 12) {
      _viewedMonth = 1;
      _viewedYear++;
    } else {
      _viewedMonth++;
    }
    notifyListeners();
  }

  /// رفتن به امروز
  void goToToday() {
    selectDate(JalaliDate.now());
  }

  /// تغییر حالت نمایش روزانه (Timeline <-> Untimed)
  void setTimelineMode(bool isTimeline) {
    _isTimelineMode = isTimeline;
    notifyListeners();
  }

  // ── متدهای کمکی برای تقویم ─────────────────────────────────────────────────

  /// رویدادهای یک روز خاص شمسی
  List<PersianEvent> getEventsForDay(JalaliDate date) {
    return _allEvents
        .where((e) => e.month == date.month && e.day == date.day)
        .toList();
  }

  /// رویدادهای روز انتخابی فعلی
  List<PersianEvent> get selectedDayEvents => getEventsForDay(_selectedDate);

  /// آیا روز مورد نظر تعطیل است؟ (جمعه یا دارای مناسبت تعطیل)
  bool isHoliday(JalaliDate date) {
    if (date.isFriday) return true;
    return _allEvents.any(
        (e) => e.month == date.month && e.day == date.day && e.isHoliday);
  }

  /// تولید روزهای شبکه ماتریسی تقویم ماه انتخابی
  ///
  /// خروجی: لیست روزها شامل فاصله‌گذاری ابتدای ماه (پدینگ روزهای شنبه تا اول ماه)
  List<JalaliDate?> getMonthGridDays() {
    final firstDayOfMonth = JalaliDate(_viewedYear, _viewedMonth, 1);
    final emptyLeadingDays = firstDayOfMonth.weekDayIndex; // تعداد روزهای خالی قبل از ۱ ام
    final totalDays = firstDayOfMonth.daysInMonth;

    final grid = <JalaliDate?>[];

    // خانه‌های خالی ابتدای ماه
    for (var i = 0; i < emptyLeadingDays; i++) {
      grid.add(null);
    }

    // روزهای واقعی ماه
    for (var d = 1; d <= totalDays; d++) {
      grid.add(JalaliDate(_viewedYear, _viewedMonth, d));
    }

    return grid;
  }
}
