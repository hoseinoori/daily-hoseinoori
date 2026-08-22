/// ─────────────────────────────────────────────────────────────────────────────
/// [NoteRepository] – لایه Repository برای یادداشت‌ها
///
/// مدیریت دو نوع یادداشت:
/// - یادداشت‌های عمومی (Global): بدون تاریخ متصل
/// - یادداشت‌های روزانه (Daily): متصل به روز خاص در تقویم
/// ─────────────────────────────────────────────────────────────────────────────
library;

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';

/// [NoteRepository] – مدیریت عملیات دیتابیسی یادداشت‌ها
class NoteRepository {
  final AppDatabase _db;
  final _uuid = const Uuid();

  NoteRepository(this._db);

  // ─── خواندن / Read Operations ─────────────────────────────────────────────

  /// [getGlobalNotes] – دریافت یادداشت‌های عمومی (بدون تاریخ)
  ///
  /// خروجی: Stream از یادداشت‌هایی که [attachedDate] آن‌ها NULL است
  Stream<List<Note>> getGlobalNotes() {
    return (_db.select(_db.notes)
          ..where((t) => t.attachedDate.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .watch();
  }

  /// [getDailyNotes] – دریافت یادداشت‌های روزانه یک روز خاص
  ///
  /// [date] – تاریخ روز مورد نظر
  /// خروجی: Stream از یادداشت‌های آن روز
  Stream<List<Note>> getDailyNotes(DateTime date) {
    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    return (_db.select(_db.notes)
          ..where(
            (t) =>
                t.attachedDate.isBiggerOrEqualValue(dayStart) &
                t.attachedDate.isSmallerThanValue(dayEnd),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .watch();
  }

  /// [getNoteById] – دریافت یک یادداشت با شناسه
  Future<Note?> getNoteById(String id) {
    return (_db.select(_db.notes)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// [getNotesByRole] – دریافت یادداشت‌های مرتبط با یک نقش
  Stream<List<Note>> getNotesByRole(String roleId) {
    return (_db.select(_db.notes)
          ..where((t) => t.roleId.equals(roleId))
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .watch();
  }

  // ─── نوشتن / Write Operations ─────────────────────────────────────────────

  /// [createNote] – ایجاد یادداشت جدید
  ///
  /// [content]      – محتوای یادداشت (اجباری)
  /// [title]        – عنوان اختیاری
  /// [attachedDate] – تاریخ روز برای یادداشت روزانه (NULL = عمومی)
  /// [roleId]       – نقش مرتبط (اختیاری)
  ///
  /// خروجی: شناسه یادداشت ایجادشده
  Future<String> createNote({
    required String content,
    String? title,
    DateTime? attachedDate,
    String? roleId,
  }) async {
    final id = _uuid.v4();
    await _db.into(_db.notes).insert(
          NotesCompanion.insert(
            id: id,
            content: content,
            title: Value(title),
            attachedDate: Value(attachedDate),
            roleId: Value(roleId),
          ),
        );
    return id;
  }

  /// [updateNote] – بروزرسانی یادداشت
  ///
  /// تاریخ [updatedAt] به صورت خودکار به‌روز می‌شود.
  Future<int> updateNote({
    required String id,
    String? title,
    String? content,
    String? roleId,
  }) {
    return (_db.update(_db.notes)..where((t) => t.id.equals(id))).write(
      NotesCompanion(
        title: title != null ? Value(title) : const Value.absent(),
        content: content != null ? Value(content) : const Value.absent(),
        roleId: roleId != null ? Value(roleId) : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// [deleteNote] – حذف یادداشت
  Future<int> deleteNote(String id) {
    return (_db.delete(_db.notes)..where((t) => t.id.equals(id))).go();
  }
}
