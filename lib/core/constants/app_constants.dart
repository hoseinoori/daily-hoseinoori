/// ─────────────────────────────────────────────────────────────────────────────
/// [AppConstants] – ثابت‌های سراسری برنامه
///
/// این فایل تمام مقادیر ثابت و قابل پیکربندی برنامه را نگهداری می‌کند.
/// ─────────────────────────────────────────────────────────────────────────────
library;

/// ثابت‌های سراسری برنامه
abstract final class AppConstants {
  // ── اطلاعات برنامه / App Info ────────────────────────────────────────────
  static const String appName = 'Daily Hoseinoori';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'مدیریت هوشمند زمان و زندگی';

  // ── دیتابیس / Database ────────────────────────────────────────────────────
  /// نام فایل دیتابیس SQLite
  static const String dbFileName = 'daily_hoseinoori.db';

  /// نسخه فعلی Schema دیتابیس (برای مدیریت migration)
  static const int dbVersion = 1;

  // ── مسیر فایل‌ها / Asset Paths ───────────────────────────────────────────
  /// مسیر فایل مناسبت‌های تقویم شمسی
  static const String persianEventsJsonPath = 'assets/data/persian_events.json';

  // ── تقویم / Calendar ─────────────────────────────────────────────────────
  /// نام روزهای هفته شمسی
  static const List<String> weekDayNames = [
    'شنبه',
    'یک‌شنبه',
    'دوشنبه',
    'سه‌شنبه',
    'چهارشنبه',
    'پنج‌شنبه',
    'جمعه',
  ];

  /// نام کوتاه روزهای هفته
  static const List<String> weekDayNamesShort = [
    'ش',
    'ی',
    'د',
    'س',
    'چ',
    'پ',
    'ج',
  ];

  /// نام ماه‌های شمسی
  static const List<String> persianMonthNames = [
    'فروردین',
    'اردیبهشت',
    'خرداد',
    'تیر',
    'مرداد',
    'شهریور',
    'مهر',
    'آبان',
    'آذر',
    'دی',
    'بهمن',
    'اسفند',
  ];

  // ── وضعیت تسک / Task Status ───────────────────────────────────────────────
  static const String taskStatusTodo = 'todo';
  static const String taskStatusInProgress = 'in_progress';
  static const String taskStatusDone = 'done';

  // ── اولویت تسک / Task Priority ───────────────────────────────────────────
  static const String priorityLow = 'low';
  static const String priorityMedium = 'medium';
  static const String priorityHigh = 'high';
  static const String priorityUrgent = 'urgent';

  // ── تایمر فوکوس / Focus Timer ────────────────────────────────────────────
  /// مدت زمان پیش‌فرض پومودورو (دقیقه)
  static const int defaultPomodoroDuration = 25;

  /// مدت زمان استراحت کوتاه (دقیقه)
  static const int defaultShortBreakDuration = 5;

  /// مدت زمان استراحت بلند (دقیقه)
  static const int defaultLongBreakDuration = 15;

  // ── انیمیشن / Animation ───────────────────────────────────────────────────
  /// مدت زمان انیمیشن سریع
  static const Duration animationFast = Duration(milliseconds: 200);

  /// مدت زمان انیمیشن معمولی
  static const Duration animationNormal = Duration(milliseconds: 350);

  /// مدت زمان انیمیشن کند
  static const Duration animationSlow = Duration(milliseconds: 600);
}
