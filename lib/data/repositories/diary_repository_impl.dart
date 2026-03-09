import 'package:uuid/uuid.dart';
import '../../domain/entities/diary_page.dart';
import '../../domain/entities/diary_element.dart';
import '../../domain/repositories/diary_repository.dart';
import '../datasources/local_database.dart';
import '../models/diary_page_model.dart';
import '../models/element_model.dart';

class DiaryRepositoryImpl implements DiaryRepository {
  final LocalDatabase _database;
  final _uuid = const Uuid();

  DiaryRepositoryImpl(this._database);

  @override
  Future<DiaryPage> createPage(DateTime date) async {
    final now = DateTime.now();
    final page = DiaryPage(
      id: _uuid.v4(),
      date: DateTime(date.year, date.month, date.day),
      backgroundType: BackgroundType.notePaper,
      createdAt: now,
      updatedAt: now,
    );
    await _database.insertPage(DiaryPageModel.fromEntity(page));
    return page;
  }

  @override
  Future<DiaryPage?> getPageByDate(DateTime date) async {
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final model = await _database.getPageByDate(dateStr);
    return model?.toEntity();
  }

  @override
  Future<DiaryPage?> getPageById(String id) async {
    final model = await _database.getPageById(id);
    return model?.toEntity();
  }

  @override
  Future<List<DiaryPage>> getAllPages() async {
    final models = await _database.getAllPages();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<DateTime>> getDatesWithEntries() async {
    final dates = await _database.getDatesWithEntries();
    return dates.map((d) => DateTime.parse(d)).toList();
  }

  @override
  Future<void> updatePage(DiaryPage page) async {
    final updated = page.copyWith(updatedAt: DateTime.now());
    await _database.updatePage(DiaryPageModel.fromEntity(updated));
  }

  @override
  Future<void> deletePage(String id) async {
    await _database.deletePage(id);
  }

  @override
  Future<void> addElement(DiaryElement element) async {
    await _database.insertElement(ElementModel.fromEntity(element));
  }

  @override
  Future<List<DiaryElement>> getElementsByPageId(String pageId) async {
    final models = await _database.getElementsByPageId(pageId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> updateElement(DiaryElement element) async {
    await _database.updateElement(ElementModel.fromEntity(element));
  }

  @override
  Future<void> deleteElement(String id) async {
    await _database.deleteElement(id);
  }

  @override
  Future<void> deleteElementsByPageId(String pageId) async {
    await _database.deleteElementsByPageId(pageId);
  }
}
