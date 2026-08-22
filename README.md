# daily_hoseinoori

پلتفرم مدیریت زندگی، زمان و وظایف — آفلاین و چندسکویی

## درباره پروژه

**Daily Hoseinoori** یک اپلیکیشن Flutter است که برای مدیریت هوشمند زمان، وظایف و زندگی روزمره طراحی شده است. این برنامه کاملاً آفلاین کار می‌کند و داده‌ها را به صورت محلی در SQLite ذخیره می‌کند.

## ویژگی‌ها

- 📅 **تقویم شمسی** — نمایش کامل تقویم جلالی با مناسبت‌های ایرانی
- ✅ **مدیریت تسک** — Kanban Board با Timeline روزانه
- 🧠 **نقشه ذهنی نقش‌ها** — ساختار درختی حوزه‌های زندگی  
- 📝 **یادداشت‌ها** — یادداشت‌های عمومی و روزانه
- ⏱️ **تایمر فوکوس** — پومودورو و تایم‌باکسینگ
- 📊 **آمار بهره‌وری** — داشبورد تحلیلی

## پشته فنی

| فناوری | هدف |
|--------|-----|
| Flutter | فریم‌ورک UI چندسکویی |
| Drift (SQLite) | پایگاه داده محلی |
| Provider | مدیریت حالت |
| uuid | تولید شناسه منحصربه‌فرد |

## فازبندی توسعه

- [x] **Phase 1** – Foundation & Database (در حال اجرا)
- [ ] **Phase 2** – Core Tree & Task Architecture
- [ ] **Phase 3** – Persian Calendar & Daily Engine
- [ ] **Phase 4** – Productivity Utilities & Notes
- [ ] **Phase 5** – Analytics & Polish

## اجرا

```bash
# نصب وابستگی‌ها
flutter pub get

# تولید کد Drift
dart run build_runner build

# اجرای برنامه
flutter run
```

## ساختار پروژه

```
lib/
├── main.dart                  # Entry point + DI
├── app.dart                   # Root Widget + Theme
├── core/
│   ├── database/              # Drift Schema
│   ├── theme/                 # Dark + Glassmorphism
│   └── constants/
└── features/
    ├── roles/                 # Mind Map
    ├── tasks/                 # Kanban + Tasks
    ├── routines/              # Weekly Routines
    ├── notes/                 # Notes System
    └── focus_timer/           # Focus Timer
```
