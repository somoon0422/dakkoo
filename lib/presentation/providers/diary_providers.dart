import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/local_database.dart';
import '../../data/repositories/diary_repository_impl.dart';
import '../../data/repositories/export_repository_impl.dart';
import '../../domain/entities/diary_page.dart';
import '../../domain/repositories/diary_repository.dart';
import '../../domain/repositories/export_repository.dart';

// Database provider
final localDatabaseProvider = Provider<LocalDatabase>((ref) {
  return LocalDatabase();
});

// Repository providers
final diaryRepositoryProvider = Provider<DiaryRepository>((ref) {
  return DiaryRepositoryImpl(ref.watch(localDatabaseProvider));
});

final exportRepositoryProvider = Provider<ExportRepository>((ref) {
  return ExportRepositoryImpl(ref.watch(localDatabaseProvider));
});

// All diary pages
final allPagesProvider = FutureProvider<List<DiaryPage>>((ref) async {
  final repo = ref.watch(diaryRepositoryProvider);
  return repo.getAllPages();
});

// Dates with entries (for calendar)
final datesWithEntriesProvider = FutureProvider<List<DateTime>>((ref) async {
  final repo = ref.watch(diaryRepositoryProvider);
  return repo.getDatesWithEntries();
});

// Get or create page for a specific date
final pageForDateProvider =
    FutureProvider.family<DiaryPage, DateTime>((ref, date) async {
  final repo = ref.watch(diaryRepositoryProvider);
  final existing = await repo.getPageByDate(date);
  if (existing != null) return existing;
  return repo.createPage(date);
});

// Selected date for calendar
final selectedDateProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

// Focused month for calendar
final focusedMonthProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});
