/// ─────────────────────────────────────────────────────────────────────────────
/// [RoleProvider] – مدیریت حالت برای ماژول نقش‌ها (Mind Map)
///
/// این Provider مسئول:
/// - نگهداری state درخت نقش‌ها
/// - ارتباط با [RoleRepository]
/// - مدیریت حالت loading و error
/// - ارائه داده‌ها به UI
/// ─────────────────────────────────────────────────────────────────────────────
library;

import 'package:flutter/foundation.dart';

import '../../../core/database/app_database.dart';
import '../data/repositories/role_repository.dart';

/// [RoleProvider] – ChangeNotifier برای مدیریت state نقش‌ها
class RoleProvider extends ChangeNotifier {
  final RoleRepository _repository;

  RoleProvider(this._repository) {
    // شروع گوش‌دادن به تغییرات دیتابیس
    _initStreams();
  }

  // ── وضعیت داخلی / Internal State ─────────────────────────────────────────
  List<RolesNode> _allRoles = [];
  bool _isLoading = false;
  String? _error;

  /// شناسه گره‌ای که در حال expand است (برای UI)
  String? _expandedNodeId;

  // ── Getters ────────────────────────────────────────────────────────────────

  /// لیست تمام نقش‌ها
  List<RolesNode> get allRoles => _allRoles;

  /// در حال بارگذاری؟
  bool get isLoading => _isLoading;

  /// پیام خطا (اگر وجود داشته باشد)
  String? get error => _error;

  /// شناسه گره expand شده
  String? get expandedNodeId => _expandedNodeId;

  /// [rootRoles] – گره‌های ریشه (بدون والد)
  List<RolesNode> get rootRoles =>
      _allRoles.where((r) => r.parentId == null).toList();

  /// [getChildrenOf] – دریافت فرزندان مستقیم یک گره
  List<RolesNode> getChildrenOf(String parentId) =>
      _allRoles.where((r) => r.parentId == parentId).toList();

  /// [hasChildren] – آیا گره مورد نظر فرزند دارد؟
  bool hasChildren(String nodeId) =>
      _allRoles.any((r) => r.parentId == nodeId);

  /// [getRoleById] – دریافت گره با شناسه
  RolesNode? getRoleById(String id) {
    try {
      return _allRoles.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  // ── مقداردهی اولیه / Initialization ───────────────────────────────────────

  /// [_initStreams] – شروع گوش‌دادن به Stream دیتابیس
  void _initStreams() {
    _setLoading(true);
    _repository.getAllRoles().listen(
      (roles) {
        _allRoles = roles;
        _setLoading(false);
        _error = null;
        notifyListeners();
      },
      onError: (error) {
        _error = 'خطا در بارگذاری نقش‌ها: $error';
        _setLoading(false);
        notifyListeners();
      },
    );
  }

  // ── عملیات CRUD ────────────────────────────────────────────────────────────

  /// [addRole] – افزودن گره نقش جدید
  ///
  /// [title]       – عنوان نقش (اجباری)
  /// [parentId]    – شناسه والد (NULL برای گره ریشه)
  /// [description] – توضیحات اختیاری
  /// [icon]        – آیکون اختیاری
  /// [color]       – رنگ اختیاری
  ///
  /// خروجی: شناسه گره جدید یا null در صورت خطا
  Future<String?> addRole({
    required String title,
    String? parentId,
    String? description,
    String? icon,
    String? color,
  }) async {
    try {
      final id = await _repository.createRole(
        title: title,
        parentId: parentId,
        description: description,
        icon: icon,
        color: color,
      );
      return id;
    } catch (e) {
      _error = 'خطا در ایجاد نقش: $e';
      notifyListeners();
      return null;
    }
  }

  /// [editRole] – ویرایش اطلاعات گره
  Future<bool> editRole({
    required String id,
    String? title,
    String? description,
    String? icon,
    String? color,
  }) async {
    try {
      await _repository.updateRole(
        id: id,
        title: title,
        description: description,
        icon: icon,
        color: color,
      );
      return true;
    } catch (e) {
      _error = 'خطا در ویرایش نقش: $e';
      notifyListeners();
      return false;
    }
  }

  /// [removeRole] – حذف گره (و تمام فرزندانش)
  Future<bool> removeRole(String id) async {
    try {
      await _repository.deleteRole(id);
      return true;
    } catch (e) {
      _error = 'خطا در حذف نقش: $e';
      notifyListeners();
      return false;
    }
  }

  // ── مدیریت UI State ────────────────────────────────────────────────────────

  /// [toggleExpand] – باز/بسته کردن گره در UI
  void toggleExpand(String nodeId) {
    _expandedNodeId = _expandedNodeId == nodeId ? null : nodeId;
    notifyListeners();
  }

  /// [isExpanded] – آیا گره expand شده؟
  bool isExpanded(String nodeId) => _expandedNodeId == nodeId;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

}
