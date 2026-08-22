دستورالعمل اجرایی و سند مشخصات فنی پروژه (Master Project Prompt)
ماموریت هوش مصنوعی (Role & Goal)
شما یک معمار ارشد نرم‌افزار و توسعه‌دهنده Full-Stack هستید. وظیفه شما پیاده‌سازی گام‌به‌گام، ماژولار، با ساختار پوشه‌بندی تمیز و کامنت‌گذاری جامع برای یک پلتفرم مدیریت زندگی، زمان و وظایف چندسکویی (Cross-Platform) و کاملاً آفلاین است.

۱. پشته فنی و معماری پایه (Tech Stack & Architecture)
فریم‌ورک هسته: Flutter (یا React با Tauri/Electron برای دسکتاپ + React Native/Capacitor) با اولویت معماری تمیز (Clean Architecture / Feature-First).

پایگاه داده: SQLite محلی (با استفاده از کتابخانه‌هایی نظیر sqflite / drift در فلاتر یا better-sqlite3 در وب/دسکتاپ).

سیستم اعلان‌ها: پکیج محلی اعلان‌های دسکتاپ و موبایل (Local Notifications) بدون وابستگی به سرور یا Push Notification خارجی.

زبان و متادیتا: کامنت‌گذاری کامل فارسی/انگلیسی برای تمامی کلاس‌ها، توابع، مدل‌های داده و کنترلرها.

۲. زبان طراحی و هویت بصری (UI/UX Design System)
تم اصلی: Dark Theme با کنتراست بالا.

رنگ شاخص (Accent): نئونی نارنجی فسفری (#FF6B00 یا #FF8C00) همراه با Glow Effects.

سبک بصری: گلس‌مورفیسم کامل (Glassmorphism) با المان‌های نیمه‌شفاف، پس‌زمینه‌های تار (Backdrop Filter / Blur) و حاشیه‌های خطی ظریف شیشه‌ای.

تایپوگرافی: پشتیبانی از فونت‌های استاندارد فارسی نظیر Vazirmatn یا Dana.

۳. مدل داده و ساختار دیتابیس محلی (SQLite Schema)
SQL
-- ۱. جدول نقش‌ها و مسئولیت‌ها (ساختار درختی / Mind Map)
CREATE TABLE roles_nodes (
    id TEXT PRIMARY KEY,
    parent_id TEXT NULL,
    title TEXT NOT NULL,
    description TEXT,
    icon TEXT,
    color TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_id) REFERENCES roles_nodes(id) ON DELETE CASCADE
);

-- ۲. جدول تسک‌ها و وظایف (ارتباط با نقش‌ها)
CREATE TABLE tasks (
    id TEXT PRIMARY KEY,
    role_id TEXT,
    title TEXT NOT NULL,
    description TEXT,
    status TEXT CHECK(status IN ('todo', 'in_progress', 'done')) DEFAULT 'todo',
    progress_percentage INTEGER DEFAULT 0,
    deadline TIMESTAMP,
    scheduled_date DATE, -- تاریخ اختصاص‌یافته در تقویم
    start_time TIME NULL, -- برای حالت Timeline روزانه
    end_time TIME NULL,
    is_timeline_bounded BOOLEAN DEFAULT 0, -- آیا وابسته به ساعت مشخص است یا تسک آزاد روز
    priority TEXT CHECK(priority IN ('low', 'medium', 'high', 'urgent')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (role_id) REFERENCES roles_nodes(id) ON DELETE SET NULL
);

-- ۳. جدول زیرتسک‌ها / چک‌لیست
CREATE TABLE subtasks (
    id TEXT PRIMARY KEY,
    task_id TEXT NOT NULL,
    title TEXT NOT NULL,
    is_completed BOOLEAN DEFAULT 0,
    FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE
);

-- ۴. جدول روتین‌ها و برنامه‌های تکرارشونده
CREATE TABLE recurring_routines (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    days_of_week TEXT NOT NULL, -- فرمت JSON ذخیره روزها: [0, 2, 4] (شنبه، دوشنبه، چهارشنبه)
    role_id TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (role_id) REFERENCES roles_nodes(id) ON DELETE SET NULL
);

-- ۵. جدول یادداشت‌ها (عمومی و وابسته به روز)
CREATE TABLE notes (
    id TEXT PRIMARY KEY,
    title TEXT,
    content TEXT NOT NULL,
    attached_date DATE NULL, -- اگر NULL باشد یعنی یادداشت عمومی است
    role_id TEXT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (role_id) REFERENCES roles_nodes(id) ON DELETE SET NULL
);

-- ۶. جدول لاگ‌های پومودورو و تایمر فوکوس / تایم‌باکسینگ
CREATE TABLE focus_timer_logs (
    id TEXT PRIMARY KEY,
    task_id TEXT NULL,
    category_label TEXT NOT NULL, -- مثل 'کار عمیق'، 'اینستاگردی / استراحت'
    duration_minutes INTEGER NOT NULL,
    completed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
۴. ماژول‌ها و مشخصات عملکردی برنامه
ماژول ۱: تقویم شمسی و نمای تفصیلی روز (Solar Calendar & Daily View)
نمایش ماهانه: رندر کامل ماه‌های تقویم جلالی با نمایش ایام تعطیل، مناسبت‌های تاریخی، ملی و مذهبی ایران (بارگذاری از فایل محلی persian_events.json).

نمای روزانه منعطف (دو حالته):

حالت گاه‌شمار (Timeline Mode): محور ساعتی (۰ تا ۲۴) برای چینش کارهایی که بازه زمانی مشخص دارند (مانند جلسه ساعت ۱۰ تا ۱۱ یا باشگاه).

حالت چک‌لیست آزاد (Untimed Tasks): کارهایی که صرفاً باید در طول آن روز بدون ساعت مشخص انجام شوند.

یکپارچگی با روتین‌ها: روتین‌های تکرارشونده تعریف‌شده در روزهای انتخابی هفته، به‌صورت خودکار در تایم‌لاین یا لیست آن روز رندر شوند.

ماژول ۲: درخت نقش‌ها و نقشه ذهنی مسئولیت‌ها (Life Roles Mind Map)
ساختار ریشه‌ای: کاربر در رأس درخت قرار دارد و می‌تواند بی‌نهایت لایه زیرشاخه برای حوزه‌های زندگی خود بسازد (مثال: آموزش/دانشگاه، توسعه نرم‌افزار، سلامت و ورزش، روابط خانوادگی).

اتصال به تسک‌ها: هنگام تعریف هر تسک، می‌توان نقش مربوطه را انتخاب کرد تا تسک‌ها زیر چتر آن نقش دسته‌بندی شوند.

ماژول ۳: برد کانبان و مدیریت تسک‌های فرآیندی (Kanban & Task Tracking)
ستون‌های کانبان: ستون‌های استاندارد (To Do ،In Progress ،Done) با امکان جابه‌جایی کارت‌ها.

کارت تسک تفصیلی: شامل نمایش درصد پیشرفت با نوار لودینگ نئونی، ددلاین، برچسب‌ها، مدیریت ساب‌تسک‌ها و لاگ گزارش‌های پیشرفت متنی.

ماژول ۴: یادداشت‌ها (Notes System)
یادداشت‌های سراسری (Global Notes): بخش اختصاصی برای ذخیره و دسته‌بندی یادداشت‌های عمومی، ایده‌ها و پیش‌نویس‌ها.

یادداشت‌های متصل به روز (Daily Notes): تب اختصاصی در نمای روزانه برای ژورنال‌نویسی، وقایع‌نگاری و یادداشت اختصاصی همان روز.

ماژول ۵: تایمر فوکوس، پومودورو و تایم‌باکسینگ (Focus & Activity Timer)
تایمر با قابلیت شمارش معکوس یا کرنومتر.

حالت‌های انتخابی: فوکوس روی تسک‌های کاری / محدودسازی فعالیت‌هایی نظیر گردش در شبکه‌های اجتماعی (اینستاگرام، وب‌گردی و غیره).

ذخیره خودکار سشن‌ها برای گزارش‌گیری.

ماژول ۶: گزارش‌گیری و آمار بهره‌وری (Analytics & Productivity Insights)
داشبورد تحلیلی: نمایش نمودارهای گرافیکی نئونی (میله‌ای/دایره‌ای) از:

درصد انجام تسک‌ها در هفته و ماه جاری.

تفکیک زمان صرف‌شده بر اساس نقش‌های مختلف در نقشه ذهنی.

نسبت زمان فوکوس عمیق به زمان استراحت/فضای مجازی.

۵. فازبندی پیاده‌سازی برای ایجنت توسعه‌دهنده (Step-by-Step Roadmap)
[Phase 1: Foundation & Database]
  ├── راه‌اندازی ساختار پروژه و پکیج‌های مورد نیاز
  ├── پیاده‌سازی Schema کامل دیتابیس SQLite و لایه Repository
  └── تزریق سیستم تم تاریک، گلس‌مورفیسم و توکن‌های رنگی نئونی
         │
[Phase 2: Core Tree & Task Architecture]
  ├── پیاده‌سازی ماژول ساختار درختی نقش‌ها (Mind Map Nodes)
  ├── توسعه فرم جامع تعریف تسک، ساب‌تسک و روتین‌های تکرارشونده
  └── ساخت نمای Kanban Board با مدیریت وضعیت‌ها و درصد پیشرفت
         │
[Phase 3: Persian Calendar & Daily Engine]
  ├── پیاده‌سازی الگوریتم تبدیل و نمایش تقویم شمسی + لود JSON رویدادها
  ├── ساخت نمای تفصیلی روز (سوئیچ بین Timeline Mode و Untimed Tasks)
  └── ادغام خودکار تسک‌های روزانه و روتین‌های هفتگی در تقویم
         │
[Phase 4: Productivity Utilities & Notes]
  ├── توسعه ماژول یادداشت‌ها (سراسری + روزانه)
  ├── پیاده‌سازی تایمر فوکوس / تایم‌باکسینگ با ثبت خودکار لاگ‌ها
  └── ساخت سرویس نوتیفیکیشن‌های محلی برای دسکتاپ و موبایل
         │
[Phase 5: Analytics & Polish]
  ├── ساخت داشبورد نمودارها و آمار بهره‌وری
  └── بهینه‌سازی انیمیشن‌ها، افکت‌های نوری (Glow) و تست نهایی آفلاین
۶. الزامات و استاندارد کدنویسی برای ایجنت
قانون تفکیک ماژول‌ها: هر بخش (Calendar, Kanban, MindMap, Notes, Timer) باید در دایرکتوری اختصاصی خود شامل لایه‌های Model، View/Screen، Controller/Bloc/State و Service قرار گیرد.

کامنت‌گذاری: تمامی متدهای ورودی و خروجی، تریگرهای دیتابیس و لاجیک‌های محاسباتی تقویم باید کامنت توضیحی داشته باشند.

پیشروی پیوسته: ایجنت باید کدنویسی را از Phase 1 شروع کرده و پس از اتمام و تست هر فاز، فاز بعدی را تحویل دهد.