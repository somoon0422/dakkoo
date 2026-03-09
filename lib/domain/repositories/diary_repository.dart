import '../entities/diary_page.dart';
import '../entities/diary_element.dart';

abstract class DiaryRepository {
  // Page operations
  Future<DiaryPage> createPage(DateTime date);
  Future<DiaryPage?> getPageByDate(DateTime date);
  Future<DiaryPage?> getPageById(String id);
  Future<List<DiaryPage>> getAllPages();
  Future<List<DateTime>> getDatesWithEntries();
  Future<void> updatePage(DiaryPage page);
  Future<void> deletePage(String id);

  // Element operations
  Future<void> addElement(DiaryElement element);
  Future<List<DiaryElement>> getElementsByPageId(String pageId);
  Future<void> updateElement(DiaryElement element);
  Future<void> deleteElement(String id);
  Future<void> deleteElementsByPageId(String pageId);
}
