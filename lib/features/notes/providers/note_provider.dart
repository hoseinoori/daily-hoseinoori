/// ─────────────────────────────────────────────────────────────────────────────
/// [NoteProvider] – مدیریت حالت ماژول یادداشت‌ها (سراسری و روزانه)
///
/// این کلاس مسئول:
/// - گوش دادن به Stream یادداشت‌های عمومی (Global Notes)
/// - گوش دادن به Stream یادداشت‌های روزانه (Daily Notes) برای تاریخ انتخابی
/// - جستجو و فیلتر متنی لحظه‌ای در یادداشت‌ها
/// - فیلتر یادداشت‌ها بر اساس نقش
/// - عملیات CRUD کامل یادداشت‌ها
/// ─────────────────────────────────────────────────────────────────────────────
library;

import 'package:flutter/foundation.dart';

import '../../../core/database/app_database.dart';
import '../data/repositories/note_repository.dart';

/// [NoteProvider] – مدیریت حالت یادداشت‌ها
class NoteProvider extends ChangeNotifier {
  final NoteRepository _repository;

  NoteProvider(this._repository) {
    _initStreams();
  }

  // ── وضعیت داخلی ───────────────────────────────────────────────────────────
  List<Note> _globalNotes = [];
  List<Note> _dailyNotes = [];
  DateTime _selectedDate = DateTime.now();
  String _searchQuery = '';
  String? _selectedRoleId;
  int _activeTabIndex = 0; // 0 = سراسری، 1 = روزانه
  bool _isLoading = false;
  String? _error;

  // ── Getters ────────────────────────────────────────────────────────────────
  DateTime get selectedDate => _selectedDate;
  String get searchQuery => _searchQuery;
  String? get selectedRoleId => _selectedRoleId;
  int get activeTabIndex => _activeTabIndex;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// یادداشت‌های سراسری فیلترشده بر اساس جستجو و نقش
  List<Note> get filteredGlobalNotes => _applyFilter(_globalNotes);

  /// یادداشت‌های روزانه فیلترشده
  List<Note> get filteredDailyNotes => _applyFilter(_dailyNotes);

  /// تمام یادداشت‌های سراسری خام
  List<Note> get globalNotes => _globalNotes;

  /// تمام یادداشت‌های روزانه خام
  List<Note> get dailyNotes => _dailyNotes;

  // ── مقداردهی اولیه ────────────────────────────────────────────────────────

  void _initStreams() {
    _setLoading(true);

    // ۱. یادداشت‌های سراسری
    _repository.getGlobalNotes().listen(
      (notes) {
        _globalNotes = notes;
        _setLoading(false);
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _error = 'خطا در بارگذاری یادداشت‌های سراسری: $e';
        _setLoading(false);
        notifyListeners();
      },
    );

    // ۲. یادداشت‌های متصل به روز
    _listenDailyNotes();
  }

  void _listenDailyNotes() {
    _repository.getDailyNotes(_selectedDate).listen(
      (notes) {
        _dailyNotes = notes;
        notifyListeners();
      },
      onError: (e) {
        _error = 'خطا در بارگذاری یادداشت‌های روزانه: $e';
        notifyListeners();
      },
    );
  }

  // ── فیلتر و جستجو ─────────────────────────────────────────────────────────

  void setSearchQuery(String query) {
    _searchQuery = query.trim().toLowerCase();
    notifyListeners();
  }

  void setRoleFilter(String? roleId) {
    _selectedRoleId = roleId;
    notifyListeners();
  }

  void setActiveTab(int index) {
    _activeTabIndex = index;
    notifyListeners();
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    _listenDailyNotes();
    notifyListeners();
  }

  List<Note> _applyFilter(List<Note> notes) {
    return notes.where((note) {
      // فیلتر نقش
      if (_selectedRoleId != null && note.roleId != _selectedRoleId) {
        return false;
      }

      // فیلتر متنی
      if (_searchQuery.isNotEmpty) {
        final title = note.title?.toLowerCase() ?? '';
        final content = note.content.toLowerCase();
        return title.contains(_searchQuery) || content.contains(_searchQuery);
      }

      return true;
    }).toList();
  }

  // ── عملیات CRUD ────────────────────────────────────────────────────────────

  /// [addNote] – افزودن یادداشت جدید
  Future<String?> addNote({
    required String content,
    String? title,
    DateTime? attachedDate,
    String? roleId,
  }) async {
    try {
      final id = await _repository.createNote(
        content: content,
        title: title,
        attachedDate: attachedDate,
        roleId: roleId,
      );
      return id;
    } catch (e) {
      _error = 'خطا در ثبت یادداشت: $e';
      notifyListeners();
      return null;
    }
  }

  /// [editNote] – ویرایش یادداشت
  Future<bool> editNote({
    required String id,
    String? title,
    String? content,
    String? roleId,
  }) async {
    try {
      await _repository.updateNote(
        id: id,
        title: title,
        content: content,
        roleId: roleId,
      );
      return true;
    } catch (e) {
      _error = 'خطا در ویرایش یادداشت: $e';
      notifyListeners();
      return false;
    }
  }

  /// [removeNote] – حذف یادداشت
  Future<bool> removeNote(String id) async {
    try {
      await _repository.deleteNote(id);
      return true;
    } catch (e) {
      _error = 'خطا در حذف یادداشت: $e';
      notifyListeners();
      return false;
    }
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }
}
