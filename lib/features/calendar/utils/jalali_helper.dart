/// ─────────────────────────────────────────────────────────────────────────────
/// [JalaliDate] – مدل و محاسبات تبدیل تقویم شمسی (جلالی) و میلادی
///
/// پیاده‌سازی دقیق الگوریتم تبدیل تقویم شمسی به میلادی و برعکس
/// همراه با محاسبه سال‌های کبیسه، روزهای هفته بر پایه تقویم ایران (شنبه=۰ تا جمعه=۶)،
/// و نام ماه‌ها و روزها به زبان فارسی.
/// ─────────────────────────────────────────────────────────────────────────────
library;

/// [JalaliDate] – نمایش یک تاریخ شمسی
class JalaliDate {
  final int year;
  final int month;
  final int day;

  const JalaliDate(this.year, this.month, this.day);

  /// نام‌های ۱۲ ماه شمسی
  static const List<String> monthNames = [
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

  /// نام‌های روزهای هفته (شنبه تا جمعه)
  static const List<String> weekDayNames = [
    'شنبه',
    'یکشنبه',
    'دوشنبه',
    'سه‌شنبه',
    'چهارشنبه',
    'پنجشنبه',
    'جمعه',
  ];

  /// نام کوتاه روزهای هفته
  static const List<String> weekDayShortNames = [
    'ش',
    'ی',
    'د',
    'س',
    'چ',
    'پ',
    'ج',
  ];

  /// تبدیل تاریخ میلادی [DateTime] به [JalaliDate]
  factory JalaliDate.fromDateTime(DateTime date) {
    return _gregorianToJalali(date.year, date.month, date.day);
  }

  /// تاریخ امروز شمسی
  factory JalaliDate.now() {
    return JalaliDate.fromDateTime(DateTime.now());
  }

  /// تبدیل این تاریخ شمسی به [DateTime] میلادی
  DateTime toDateTime([int hour = 0, int minute = 0, int second = 0]) {
    final g = _jalaliToGregorian(year, month, day);
    return DateTime(g.$1, g.$2, g.$3, hour, minute, second);
  }

  /// نام ماه جاری
  String get monthName => monthNames[month - 1];

  /// ایندکس روز هفته (۰ = شنبه، ۱ = یکشنبه، ...، ۶ = جمعه)
  int get weekDayIndex {
    final dt = toDateTime();
    // در DateTime دات‌نت/دارت: Monday = 1, ..., Sunday = 7
    // شنبه در تقویم ما = Saturday (6 در DateTime)
    // تبدیل:
    // Saturday(6) -> 0
    // Sunday(7)   -> 1
    // Monday(1)   -> 2
    // Tuesday(2)  -> 3
    // Wednesday(3)-> 4
    // Thursday(4) -> 5
    // Friday(5)   -> 6
    return (dt.weekday + 1) % 7;
  }

  /// نام روز هفته
  String get weekDayName => weekDayNames[weekDayIndex];

  /// آیا این روز جمعه (تعطیل پایان هفته) است؟
  bool get isFriday => weekDayIndex == 6;

  /// آیا سال جاری کبیسه شمسی است؟
  bool get isLeapYear => _isJalaliLeapYear(year);

  /// تعداد روزهای این ماه
  int get daysInMonth {
    if (month <= 6) return 31;
    if (month <= 11) return 30;
    return isLeapYear ? 30 : 29;
  }

  /// فرمت متنی کامل: "شنبه، ۲ شهریور ۱۴۰۵"
  String get fullFormatted => '$weekDayName، $day $monthName $year';

  /// فرمت متنی کوتاه: "۱۴۰۵/۰۶/۰۲"
  String get numericFormatted =>
      '$year/${month.toString().padLeft(2, '0')}/${day.toString().padLeft(2, '0')}';

  /// مقایسه برابری دو تاریخ شمسی
  bool isSameDay(JalaliDate other) =>
      year == other.year && month == other.month && day == other.day;

  /// افزودن یا کم کردن روز
  JalaliDate addDays(int days) {
    final g = toDateTime().add(Duration(days: days));
    return JalaliDate.fromDateTime(g);
  }

  // ── الگوریتم دقیق تبدیل جلالی به میلادی و برعکس ──────────────────────────

  static JalaliDate _gregorianToJalali(int gy, int gm, int gd) {
    final gDpm = [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    if (_isGregorianLeapYear(gy)) gDpm[2] = 29;

    var gy2 = (gm > 2) ? (gy + 1) : gy;
    var days = 355666 +
        (365 * gy) +
        ((gy2 + 3) ~/ 4) -
        ((gy2 + 99) ~/ 100) +
        ((gy2 + 399) ~/ 400) +
        gd;
    for (var i = 0; i < gm; ++i) {
      days += gDpm[i];
    }

    var jy = -1595 + (33 * (days ~/ 12053));
    days %= 12053;

    jy += 4 * (days ~/ 1461);
    days %= 1461;

    if (days > 365) {
      jy += (days - 1) ~/ 365;
      days = (days - 1) % 365;
    }

    int jm;
    int jd;
    if (days < 186) {
      jm = 1 + (days ~/ 31);
      jd = 1 + (days % 31);
    } else {
      jm = 7 + ((days - 186) ~/ 30);
      jd = 1 + ((days - 186) % 30);
    }

    return JalaliDate(jy, jm, jd);
  }

  static (int, int, int) _jalaliToGregorian(int jy, int jm, int jd) {
    jy += 1595;
    var days = -355668 +
        (365 * jy) +
        ((jy ~/ 33) * 8) +
        (((jy % 33) + 3) ~/ 4) +
        jd;
    if (jm < 7) {
      days += (jm - 1) * 31;
    } else {
      days += ((jm - 7) * 30) + 186;
    }

    var gy = 400 * (days ~/ 146097);
    days %= 146097;

    if (days > 36524) {
      gy += 100 * (--days ~/ 36524);
      days %= 36524;
      if (days >= 365) days++;
    }

    gy += 4 * (days ~/ 1461);
    days %= 1461;

    if (days > 365) {
      gy += (days - 1) ~/ 365;
      days = (days - 1) % 365;
    }

    var gd = days + 1;
    final gDpm = [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    if (_isGregorianLeapYear(gy)) gDpm[2] = 29;

    var gm = 0;
    while (gm < 12 && gd > gDpm[gm]) {
      gd -= gDpm[gm];
      gm++;
    }

    return (gy, gm, gd);
  }

  static bool _isGregorianLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }

  static bool _isJalaliLeapYear(int year) {
    final breaks = [-61, 9, 38, 199, 426, 686, 756, 818, 1111, 1181, 1210, 1635, 2060, 2097, 2192, 2262, 2324, 2394, 2456, 3178];
    var jp = breaks[0];
    var jm = 0;
    var jump = 0;
    var leap = -14;

    if (year < jp || year >= breaks.last) {
      return false;
    }

    for (var i = 1; i < breaks.length; i++) {
      jm = breaks[i];
      jump = jm - jp;
      if (year < jm) break;
      leap += (jump ~/ 33) * 8 + (((jump % 33)) ~/ 4);
      jp = jm;
    }

    var n = year - jp;
    leap += (n ~/ 33) * 8 + (((n % 33) + 3) ~/ 4);

    if ((jump % 33) == 4 && (jump - n) == 4) {
      leap += 1;
    }

    var r = (leap % 33);
    return r == 0 || (r > 0 && (r % 4 == 0));
  }
}
