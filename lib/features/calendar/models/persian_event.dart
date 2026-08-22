/// ─────────────────────────────────────────────────────────────────────────────
/// [PersianEvent] – مدل داده مناسبت‌ها و تعطیلات رسمی
///
/// خوانده‌شده از فایل محلی `assets/data/persian_events.json`
/// ─────────────────────────────────────────────────────────────────────────────
library;

/// [PersianEvent] – نمایش یک مناسبت یا تعطیلی رسمی در تقویم
class PersianEvent {
  final int month;
  final int day;
  final String title;
  final String type; // 'national' | 'religious'
  final bool isHoliday;

  const PersianEvent({
    required this.month,
    required this.day,
    required this.title,
    required this.type,
    required this.isHoliday,
  });

  factory PersianEvent.fromJson(Map<String, dynamic> json) {
    return PersianEvent(
      month: json['month'] as int,
      day: json['day'] as int,
      title: json['title'] as String,
      type: json['type'] as String? ?? 'national',
      isHoliday: json['is_holiday'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'month': month,
        'day': day,
        'title': title,
        'type': type,
        'is_holiday': isHoliday,
      };
}
