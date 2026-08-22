/// ─────────────────────────────────────────────────────────────────────────────
/// [AppDatabase] – تعریف اصلی دیتابیس با Drift (SQLite ORM)
///
/// این فایل Schema کامل دیتابیس را تعریف می‌کند. شامل تمام جداول و
/// روابط بین آن‌ها طبق مستندات PRD.
///
/// جداول تعریف‌شده:
/// 1. [RolesNodes]      - ساختار درختی نقش‌ها و مسئولیت‌ها (Mind Map)
/// 2. [Tasks]           - تسک‌ها و وظایف با پشتیبانی از Timeline
/// 3. [Subtasks]        - زیرتسک‌ها و چک‌لیست
/// 4. [RecurringRoutines] - برنامه‌های تکرارشونده هفتگی
/// 5. [Notes]           - یادداشت‌های عمومی و روزانه
/// 6. [FocusTimerLogs]  - لاگ سشن‌های تایمر فوکوس / پومودورو
/// ─────────────────────────────────────────────────────────────────────────────
library;

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

// کد تولیدشده توسط build_runner
part 'app_database.g.dart';

// ═════════════════════════════════════════════════════════════════════════════
// ████  جدول ۱: نقش‌ها و مسئولیت‌ها (Mind Map Tree)  ████
// ═════════════════════════════════════════════════════════════════════════════

/// [RolesNodes] – جدول ساختار درختی نقش‌ها و حوزه‌های زندگی
///
/// هر گره می‌تواند زیرشاخه‌های بی‌نهایت داشته باشد.
/// کاربر در رأس درخت قرار دارد و حوزه‌هایی مانند آموزش، سلامت،
/// روابط خانوادگی و ... به عنوان شاخه تعریف می‌شوند.
class RolesNodes extends Table {
  /// شناسه منحصربه‌فرد (UUID v4)
  TextColumn get id => text()();

  /// شناسه گره والد (NULL برای گره‌های ریشه)
  TextColumn get parentId => text().nullable().references(RolesNodes, #id)();

  /// عنوان نقش یا حوزه زندگی
  TextColumn get title => text().withLength(min: 1, max: 100)();

  /// توضیحات اختیاری
  TextColumn get description => text().nullable()();

  /// آیکون (نام آیکون Material یا emoji)
  TextColumn get icon => text().nullable()();

  /// رنگ اختصاصی این گره در نقشه ذهنی (هگز مثل #FF6B00)
  TextColumn get color => text().nullable()();

  /// زمان ایجاد گره
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// ═════════════════════════════════════════════════════════════════════════════
// ████  جدول ۲: تسک‌ها و وظایف  ████
// ═════════════════════════════════════════════════════════════════════════════

/// [Tasks] – جدول وظایف اصلی با پشتیبانی از Timeline روزانه
///
/// هر تسک می‌تواند به یک نقش (role) متصل باشد و در تقویم روزانه
/// به دو صورت نمایش داده شود:
/// - [isTimelineBounded=true]: بازه زمانی مشخص (مثل جلسه ۱۰-۱۱)
/// - [isTimelineBounded=false]: تسک آزاد روز بدون ساعت خاص
class Tasks extends Table {
  /// شناسه منحصربه‌فرد (UUID v4)
  TextColumn get id => text()();

  /// ارتباط با گره نقش (اختیاری - ON DELETE SET NULL)
  TextColumn get roleId =>
      text().nullable().references(RolesNodes, #id)();

  /// عنوان تسک
  TextColumn get title => text().withLength(min: 1, max: 200)();

  /// توضیحات کامل تسک
  TextColumn get description => text().nullable()();

  /// وضعیت فعلی: todo | in_progress | done
  TextColumn get status => text().withDefault(const Constant('todo'))();

  /// درصد پیشرفت (۰ تا ۱۰۰)
  IntColumn get progressPercentage => integer().withDefault(const Constant(0))();

  /// مهلت انجام (Deadline) - اختیاری
  DateTimeColumn get deadline => dateTime().nullable()();

  /// تاریخ اختصاص‌یافته در تقویم (بدون ساعت)
  DateTimeColumn get scheduledDate => dateTime().nullable()();

  /// ساعت شروع در Timeline - اختیاری
  TextColumn get startTime => text().nullable()();

  /// ساعت پایان در Timeline - اختیاری
  TextColumn get endTime => text().nullable()();

  /// آیا به بازه زمانی خاص در روز وابسته است؟
  BoolColumn get isTimelineBounded =>
      boolean().withDefault(const Constant(false))();

  /// سطح اولویت: low | medium | high | urgent
  TextColumn get priority => text().nullable()();

  /// زمان ایجاد تسک
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// ═════════════════════════════════════════════════════════════════════════════
// ████  جدول ۳: زیرتسک‌ها و چک‌لیست  ████
// ═════════════════════════════════════════════════════════════════════════════

/// [Subtasks] – جدول زیرتسک‌ها و آیتم‌های چک‌لیست
///
/// هر تسک می‌تواند چندین زیرتسک داشته باشد.
/// با حذف تسک والد، تمام زیرتسک‌ها نیز حذف می‌شوند (CASCADE).
class Subtasks extends Table {
  /// شناسه منحصربه‌فرد (UUID v4)
  TextColumn get id => text()();

  /// ارتباط با تسک والد (ON DELETE CASCADE)
  TextColumn get taskId => text().references(Tasks, #id)();

  /// عنوان زیرتسک
  TextColumn get title => text().withLength(min: 1, max: 200)();

  /// آیا این زیرتسک تکمیل شده؟
  BoolColumn get isCompleted =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// ═════════════════════════════════════════════════════════════════════════════
// ████  جدول ۴: روتین‌های تکرارشونده  ████
// ═════════════════════════════════════════════════════════════════════════════

/// [RecurringRoutines] – جدول برنامه‌های تکرارشونده هفتگی
///
/// روتین‌ها در روزهای مشخص هفته به صورت خودکار در تقویم نمایش داده
/// می‌شوند. [daysOfWeek] در قالب JSON آرایه ذخیره می‌شود.
///
/// مثال daysOfWeek: "[0, 2, 4]" = شنبه، دوشنبه، چهارشنبه
class RecurringRoutines extends Table {
  /// شناسه منحصربه‌فرد (UUID v4)
  TextColumn get id => text()();

  /// عنوان روتین (مثل: باشگاه، مطالعه صبحگاهی)
  TextColumn get title => text().withLength(min: 1, max: 100)();

  /// ساعت شروع روتین (فرمت HH:mm مثل "07:30")
  TextColumn get startTime => text()();

  /// ساعت پایان روتین (فرمت HH:mm مثل "08:30")
  TextColumn get endTime => text()();

  /// روزهای هفته به فرمت JSON - ایندکس شنبه=0 تا جمعه=6
  TextColumn get daysOfWeek => text()();

  /// ارتباط اختیاری با نقش مرتبط
  TextColumn get roleId =>
      text().nullable().references(RolesNodes, #id)();

  /// زمان ایجاد روتین
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// ═════════════════════════════════════════════════════════════════════════════
// ████  جدول ۵: یادداشت‌ها  ████
// ═════════════════════════════════════════════════════════════════════════════

/// [Notes] – جدول یادداشت‌های عمومی و روزانه
///
/// دو نوع یادداشت وجود دارد:
/// - [attachedDate=NULL]: یادداشت عمومی (Global Note) - ایده‌ها و پیش‌نویس‌ها
/// - [attachedDate≠NULL]: یادداشت روزانه (Daily Note) - ژورنال روز خاص
class Notes extends Table {
  /// شناسه منحصربه‌فرد (UUID v4)
  TextColumn get id => text()();

  /// عنوان یادداشت (اختیاری)
  TextColumn get title => text().nullable()();

  /// محتوای یادداشت
  TextColumn get content => text()();

  /// تاریخ متصل‌شده برای یادداشت روزانه (NULL = یادداشت عمومی)
  DateTimeColumn get attachedDate => dateTime().nullable()();

  /// ارتباط اختیاری با نقش
  TextColumn get roleId =>
      text().nullable().references(RolesNodes, #id)();

  /// آخرین زمان ویرایش
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// ═════════════════════════════════════════════════════════════════════════════
// ████  جدول ۶: لاگ تایمر فوکوس / پومودورو  ████
// ═════════════════════════════════════════════════════════════════════════════

/// [FocusTimerLogs] – جدول سوابق سشن‌های تایمر فوکوس
///
/// هر بار که کاربر یک سشن فوکوس یا استراحت را تکمیل می‌کند،
/// یک رکورد در این جدول ثبت می‌شود.
/// این داده‌ها برای داشبورد تحلیلی و آمار بهره‌وری استفاده می‌شوند.
class FocusTimerLogs extends Table {
  /// شناسه منحصربه‌فرد (UUID v4)
  TextColumn get id => text()();

  /// ارتباط اختیاری با تسک مرتبط
  TextColumn get taskId =>
      text().nullable().references(Tasks, #id)();

  /// برچسب دسته‌بندی سشن (مثل 'کار عمیق'، 'استراحت'، 'اینستاگردی')
  TextColumn get categoryLabel => text()();

  /// مدت زمان سشن به دقیقه
  IntColumn get durationMinutes => integer()();

  /// زمان اتمام سشن
  DateTimeColumn get completedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// ═════════════════════════════════════════════════════════════════════════════
// ████  کلاس اصلی دیتابیس  ████
// ═════════════════════════════════════════════════════════════════════════════

/// [AppDatabase] – کلاس اصلی دیتابیس Drift
///
/// این کلاس تمام جداول را ثبت می‌کند و مسئول:
/// - ایجاد و مدیریت اتصال به SQLite
/// - مدیریت migration های دیتابیس
/// - فراهم کردن DAO ها برای هر جدول
@DriftDatabase(
  tables: [
    RolesNodes,
    Tasks,
    Subtasks,
    RecurringRoutines,
    Notes,
    FocusTimerLogs,
  ],
)
class AppDatabase extends _$AppDatabase {
  /// [AppDatabase] – سازنده کلاس دیتابیس
  ///
  /// [executor] به صورت خودکار از [_openConnection] مقداردهی می‌شود
  AppDatabase() : super(_openConnection());

  /// [schemaVersion] – نسخه Schema دیتابیس
  ///
  /// هر بار که Schema تغییر می‌کند، این عدد باید افزایش یابد
  /// تا migration به درستی اجرا شود.
  @override
  int get schemaVersion => 1;

  /// [migration] – مدیریت ارتقاء دیتابیس بین نسخه‌ها
  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      // اجرا شود وقتی دیتابیس برای اولین بار ساخته می‌شود
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      // اجرا شود وقتی Schema از نسخه قدیمی ارتقاء می‌یابد
      onUpgrade: (Migrator m, int from, int to) async {
        // نسخه‌های آینده اینجا اضافه خواهند شد
      },
    );
  }
}

/// [_openConnection] – تابع باز کردن اتصال به دیتابیس SQLite
///
/// مسیر فایل دیتابیس را از [getApplicationDocumentsDirectory] دریافت
/// می‌کند تا در ذخیره‌سازی اختصاصی برنامه قرار گیرد.
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'daily_hoseinoori.db'));
    return NativeDatabase.createInBackground(file);
  });
}
