/// ─────────────────────────────────────────────────────────────────────────────
/// [RoleRepository] – لایه Repository برای نقش‌ها و Mind Map
///
/// این کلاس تمام عملیات CRUD مربوط به جدول [RolesNodes] را پیاده‌سازی
/// می‌کند. این لایه واسط بین دیتابیس و لایه‌های بالاتر (Controller/Bloc)
/// است و مستقیماً با Drift تعامل دارد.
/// ─────────────────────────────────────────────────────────────────────────────
library;

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';

/// [RoleRepository] – مدیریت عملیات دیتابیسی نقش‌ها
class RoleRepository {
  /// نمونه دیتابیس برنامه
  final AppDatabase _db;

  /// تولیدکننده UUID برای کلیدهای اصلی
  final _uuid = const Uuid();

  /// [RoleRepository] سازنده - دریافت وابستگی دیتابیس
  RoleRepository(this._db);

  // ── خواندن / Read Operations ────────────────────────────────────────────────

  /// [getAllRoles] – دریافت تمام گره‌های نقش‌ها
  ///
  /// خروجی: Stream از لیست همه گره‌ها برای نمایش در Mind Map
  Stream<List<RolesNode>> getAllRoles() {
    return (_db.select(_db.rolesNodes)
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .watch();
  }

  /// [getRootRoles] – دریافت فقط گره‌های ریشه (بدون والد)
  ///
  /// خروجی: Stream از گره‌هایی که [parentId] آن‌ها NULL است
  Stream<List<RolesNode>> getRootRoles() {
    return (_db.select(_db.rolesNodes)
          ..where((t) => t.parentId.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .watch();
  }

  /// [getChildrenOf] – دریافت فرزندان مستقیم یک گره
  ///
  /// [parentId] – شناسه گره والد
  /// خروجی: Stream از لیست گره‌های فرزند
  Stream<List<RolesNode>> getChildrenOf(String parentId) {
    return (_db.select(_db.rolesNodes)
          ..where((t) => t.parentId.equals(parentId))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .watch();
  }

  /// [getRoleById] – دریافت یک گره خاص با شناسه
  ///
  /// [id] – شناسه UUID گره
  /// خروجی: گره یافت‌شده یا null
  Future<RolesNode?> getRoleById(String id) {
    return (_db.select(_db.rolesNodes)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  // ── نوشتن / Write Operations ────────────────────────────────────────────────

  /// [createRole] – ایجاد یک گره نقش جدید
  ///
  /// [title]       – عنوان نقش یا حوزه زندگی (اجباری)
  /// [parentId]    – شناسه والد (NULL برای گره ریشه)
  /// [description] – توضیحات اختیاری
  /// [icon]        – آیکون اختیاری (نام Material icon یا emoji)
  /// [color]       – رنگ اختیاری در فرمت هگز (#RRGGBB)
  ///
  /// خروجی: شناسه گره جدید ایجادشده
  Future<String> createRole({
    required String title,
    String? parentId,
    String? description,
    String? icon,
    String? color,
  }) async {
    final id = _uuid.v4();
    await _db.into(_db.rolesNodes).insert(
          RolesNodesCompanion.insert(
            id: id,
            title: title,
            parentId: Value(parentId),
            description: Value(description),
            icon: Value(icon),
            color: Value(color),
          ),
        );
    return id;
  }

  /// [updateRole] – بروزرسانی اطلاعات یک گره نقش
  ///
  /// [id]          – شناسه گره برای بروزرسانی
  /// [title]       – عنوان جدید (اختیاری)
  /// [description] – توضیحات جدید (اختیاری)
  /// [icon]        – آیکون جدید (اختیاری)
  /// [color]       – رنگ جدید (اختیاری)
  ///
  /// خروجی: تعداد ردیف‌های بروزشده
  Future<int> updateRole({
    required String id,
    String? title,
    String? description,
    String? icon,
    String? color,
  }) {
    return (_db.update(_db.rolesNodes)..where((t) => t.id.equals(id))).write(
      RolesNodesCompanion(
        title: title != null ? Value(title) : const Value.absent(),
        description: Value(description),
        icon: Value(icon),
        color: Value(color),
      ),
    );
  }

  /// [deleteRole] – حذف یک گره نقش
  ///
  /// با حذف گره والد، تمام فرزندان نیز حذف می‌شوند (CASCADE در SQLite).
  ///
  /// [id] – شناسه گره برای حذف
  /// خروجی: تعداد ردیف‌های حذف‌شده
  Future<int> deleteRole(String id) {
    return (_db.delete(_db.rolesNodes)..where((t) => t.id.equals(id))).go();
  }
}
