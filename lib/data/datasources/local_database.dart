import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/diary_page_model.dart';
import '../models/element_model.dart';

class LocalDatabase {
  static Database? _database;
  static const String _dbName = 'dakkoo.db';
  static const int _dbVersion = 1;

  // In-memory storage for web
  static final List<Map<String, dynamic>> _memPages = [];
  static final List<Map<String, dynamic>> _memElements = [];
  static final List<Map<String, dynamic>> _memCalendarStickers = [];

  bool get _isWeb => kIsWeb;

  Future<Database> get database async {
    if (_isWeb) throw UnsupportedError('Use in-memory on web');
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE diary_pages (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL UNIQUE,
        background_type TEXT NOT NULL DEFAULT 'notePaper',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE elements (
        id TEXT PRIMARY KEY,
        page_id TEXT NOT NULL,
        type TEXT NOT NULL,
        x REAL NOT NULL DEFAULT 0,
        y REAL NOT NULL DEFAULT 0,
        width REAL NOT NULL DEFAULT 100,
        height REAL NOT NULL DEFAULT 100,
        rotation REAL NOT NULL DEFAULT 0,
        content TEXT NOT NULL DEFAULT '',
        z_index INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        FOREIGN KEY (page_id) REFERENCES diary_pages(id) ON DELETE CASCADE
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_elements_page_id ON elements(page_id)',
    );
    await db.execute(
      'CREATE INDEX idx_diary_pages_date ON diary_pages(date)',
    );

    await db.execute('''
      CREATE TABLE calendar_stickers (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL,
        emoji TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
    await db.execute(
      'CREATE INDEX idx_calendar_stickers_date ON calendar_stickers(date)',
    );
  }

  // Page operations
  Future<void> insertPage(DiaryPageModel page) async {
    if (_isWeb) {
      _memPages.removeWhere((p) => p['id'] == page.id);
      _memPages.add(page.toMap());
      return;
    }
    final db = await database;
    await db.insert(
      'diary_pages',
      page.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<DiaryPageModel?> getPageByDate(String date) async {
    if (_isWeb) {
      final match = _memPages.where((p) => p['date'] == date);
      if (match.isEmpty) return null;
      return DiaryPageModel.fromMap(match.first);
    }
    final db = await database;
    final maps = await db.query(
      'diary_pages',
      where: 'date = ?',
      whereArgs: [date],
    );
    if (maps.isEmpty) return null;
    return DiaryPageModel.fromMap(maps.first);
  }

  Future<DiaryPageModel?> getPageById(String id) async {
    if (_isWeb) {
      final match = _memPages.where((p) => p['id'] == id);
      if (match.isEmpty) return null;
      return DiaryPageModel.fromMap(match.first);
    }
    final db = await database;
    final maps = await db.query(
      'diary_pages',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return DiaryPageModel.fromMap(maps.first);
  }

  Future<List<DiaryPageModel>> getAllPages() async {
    if (_isWeb) {
      final sorted = List<Map<String, dynamic>>.from(_memPages)
        ..sort((a, b) => (b['date'] as String).compareTo(a['date'] as String));
      return sorted.map((m) => DiaryPageModel.fromMap(m)).toList();
    }
    final db = await database;
    final maps = await db.query('diary_pages', orderBy: 'date DESC');
    return maps.map((m) => DiaryPageModel.fromMap(m)).toList();
  }

  Future<List<String>> getDatesWithEntries() async {
    if (_isWeb) {
      // 실제 엘리먼트가 있는 페이지만 반환
      final pageIdsWithElements =
          _memElements.map((e) => e['page_id'] as String).toSet();
      return _memPages
          .where((p) => pageIdsWithElements.contains(p['id']))
          .map((m) => m['date'] as String)
          .toList();
    }
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT DISTINCT dp.date
      FROM diary_pages dp
      INNER JOIN elements e ON e.page_id = dp.id
    ''');
    return maps.map((m) => m['date'] as String).toList();
  }

  Future<void> updatePage(DiaryPageModel page) async {
    if (_isWeb) {
      final idx = _memPages.indexWhere((p) => p['id'] == page.id);
      if (idx >= 0) _memPages[idx] = page.toMap();
      return;
    }
    final db = await database;
    await db.update(
      'diary_pages',
      page.toMap(),
      where: 'id = ?',
      whereArgs: [page.id],
    );
  }

  Future<void> deletePage(String id) async {
    if (_isWeb) {
      _memPages.removeWhere((p) => p['id'] == id);
      _memElements.removeWhere((e) => e['page_id'] == id);
      return;
    }
    final db = await database;
    await db.delete('elements', where: 'page_id = ?', whereArgs: [id]);
    await db.delete('diary_pages', where: 'id = ?', whereArgs: [id]);
  }

  // Element operations
  Future<void> insertElement(ElementModel element) async {
    if (_isWeb) {
      _memElements.removeWhere((e) => e['id'] == element.id);
      _memElements.add(element.toMap());
      return;
    }
    final db = await database;
    await db.insert(
      'elements',
      element.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ElementModel>> getElementsByPageId(String pageId) async {
    if (_isWeb) {
      final matches =
          _memElements.where((e) => e['page_id'] == pageId).toList()
            ..sort((a, b) =>
                (a['z_index'] as int).compareTo(b['z_index'] as int));
      return matches.map((m) => ElementModel.fromMap(m)).toList();
    }
    final db = await database;
    final maps = await db.query(
      'elements',
      where: 'page_id = ?',
      whereArgs: [pageId],
      orderBy: 'z_index ASC',
    );
    return maps.map((m) => ElementModel.fromMap(m)).toList();
  }

  Future<void> updateElement(ElementModel element) async {
    if (_isWeb) {
      final idx = _memElements.indexWhere((e) => e['id'] == element.id);
      if (idx >= 0) _memElements[idx] = element.toMap();
      return;
    }
    final db = await database;
    await db.update(
      'elements',
      element.toMap(),
      where: 'id = ?',
      whereArgs: [element.id],
    );
  }

  Future<void> deleteElement(String id) async {
    if (_isWeb) {
      _memElements.removeWhere((e) => e['id'] == id);
      return;
    }
    final db = await database;
    await db.delete('elements', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteElementsByPageId(String pageId) async {
    if (_isWeb) {
      _memElements.removeWhere((e) => e['page_id'] == pageId);
      return;
    }
    final db = await database;
    await db.delete('elements', where: 'page_id = ?', whereArgs: [pageId]);
  }

  // Calendar sticker operations
  Future<void> insertCalendarSticker(String id, String date, String emoji) async {
    if (_isWeb) {
      _memCalendarStickers.add({
        'id': id,
        'date': date,
        'emoji': emoji,
        'created_at': DateTime.now().toIso8601String(),
      });
      return;
    }
    final db = await database;
    await db.insert('calendar_stickers', {
      'id': id,
      'date': date,
      'emoji': emoji,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<Map<String, List<String>>> getAllCalendarStickers() async {
    if (_isWeb) {
      final result = <String, List<String>>{};
      for (final s in _memCalendarStickers) {
        final date = s['date'] as String;
        result.putIfAbsent(date, () => []);
        result[date]!.add(s['emoji'] as String);
      }
      return result;
    }
    final db = await database;
    final maps = await db.query('calendar_stickers', orderBy: 'created_at ASC');
    final result = <String, List<String>>{};
    for (final m in maps) {
      final date = m['date'] as String;
      result.putIfAbsent(date, () => []);
      result[date]!.add(m['emoji'] as String);
    }
    return result;
  }

  Future<void> deleteCalendarSticker(String id) async {
    if (_isWeb) {
      _memCalendarStickers.removeWhere((s) => s['id'] == id);
      return;
    }
    final db = await database;
    await db.delete('calendar_stickers', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteCalendarStickersByDate(String date) async {
    if (_isWeb) {
      _memCalendarStickers.removeWhere((s) => s['date'] == date);
      return;
    }
    final db = await database;
    await db.delete('calendar_stickers', where: 'date = ?', whereArgs: [date]);
  }

  // For export
  Future<List<DiaryPageModel>> getPagesByDateRange(
    String startDate,
    String endDate,
  ) async {
    if (_isWeb) {
      final matches = _memPages
          .where((p) =>
              (p['date'] as String).compareTo(startDate) >= 0 &&
              (p['date'] as String).compareTo(endDate) <= 0)
          .toList()
        ..sort((a, b) => (a['date'] as String).compareTo(b['date'] as String));
      return matches.map((m) => DiaryPageModel.fromMap(m)).toList();
    }
    final db = await database;
    final maps = await db.query(
      'diary_pages',
      where: 'date >= ? AND date <= ?',
      whereArgs: [startDate, endDate],
      orderBy: 'date ASC',
    );
    return maps.map((m) => DiaryPageModel.fromMap(m)).toList();
  }
}
