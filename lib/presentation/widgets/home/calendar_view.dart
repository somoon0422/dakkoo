import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/diary_providers.dart';
import '../../providers/theme_providers.dart';
import '../../../app.dart';
import '../stickers/sticker_picker.dart';
import '../common/pressable.dart';

class CalendarView extends ConsumerWidget {
  final Function(DateTime) onDateSelected;
  final Function(DateTime)? onScheduleSelected;

  const CalendarView({
    super.key,
    required this.onDateSelected,
    this.onScheduleSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final focusedMonth = ref.watch(focusedMonthProvider);
    final datesWithEntries = ref.watch(datesWithEntriesProvider);
    final calendarStickers = ref.watch(calendarStickersProvider);
    final allSchedules = ref.watch(allSchedulesProvider);
    final fontData = ref.watch(currentFontDataProvider);
    final themeData = ref.watch(currentThemeDataProvider);

    final entryDates = datesWithEntries.when(
      data: (dates) => dates.toSet(),
      loading: () => <DateTime>{},
      error: (e, st) => <DateTime>{},
    );

    final stickersMap = calendarStickers.when(
      data: (map) => map,
      loading: () => <String, List<String>>{},
      error: (e, st) => <String, List<String>>{},
    );

    final schedulesMap = allSchedules.when(
      data: (map) => map,
      loading: () => <String, List<Map<String, dynamic>>>{},
      error: (e, st) => <String, List<Map<String, dynamic>>>{},
    );

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildHeader(context, ref, focusedMonth, fontData, themeData),
          const SizedBox(height: 12),
          _buildWeekdayLabels(themeData),
          const SizedBox(height: 4),
          _buildCalendarGrid(
            context,
            ref,
            focusedMonth,
            selectedDate,
            entryDates,
            stickersMap,
            schedulesMap,
            fontData,
            themeData,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, DateTime focusedMonth,
      AppFontData fontData, AppThemeData themeData) {
    final title = DateFormat('yyyy년 M월', 'ko_KR').format(focusedMonth);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Pressable(
          onTap: () {
            final prev =
                DateTime(focusedMonth.year, focusedMonth.month - 1, 1);
            ref.read(focusedMonthProvider.notifier).state = prev;
          },
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(Icons.chevron_left_rounded,
                size: 22, color: themeData.textSecondary),
          ),
        ),
        Text(
          title,
          style: getAppFont(fontData.googleFontName, 17, themeData.textPrimary),
        ),
        Pressable(
          onTap: () {
            final next =
                DateTime(focusedMonth.year, focusedMonth.month + 1, 1);
            ref.read(focusedMonthProvider.notifier).state = next;
          },
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(Icons.chevron_right_rounded,
                size: 22, color: themeData.textSecondary),
          ),
        ),
      ],
    );
  }

  Widget _buildWeekdayLabels(AppThemeData themeData) {
    const days = ['일', '월', '화', '수', '목', '금', '토'];
    return Row(
      children: days.map((d) {
        final isWeekend = d == '일' || d == '토';
        return Expanded(
          child: Center(
            child: Text(
              d,
              style: GoogleFonts.notoSans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isWeekend
                    ? AppColors.accentPink.withValues(alpha: 0.7)
                    : themeData.textSecondary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCalendarGrid(
    BuildContext context,
    WidgetRef ref,
    DateTime focusedMonth,
    DateTime selectedDate,
    Set<DateTime> entryDates,
    Map<String, List<String>> stickersMap,
    Map<String, List<Map<String, dynamic>>> schedulesMap,
    AppFontData fontData,
    AppThemeData themeData,
  ) {
    final firstDay = DateTime(focusedMonth.year, focusedMonth.month, 1);
    final lastDay = DateTime(focusedMonth.year, focusedMonth.month + 1, 0);
    final startWeekday = firstDay.weekday % 7;
    final totalDays = lastDay.day;
    final totalCells = ((startWeekday + totalDays + 6) ~/ 7) * 7;

    final today = DateTime.now();

    return Column(
      children: List.generate((totalCells / 7).ceil(), (weekIdx) {
        return Row(
          children: List.generate(7, (dayIdx) {
            final cellIdx = weekIdx * 7 + dayIdx;
            final dayNum = cellIdx - startWeekday + 1;

            if (dayNum < 1 || dayNum > totalDays) {
              return const Expanded(child: SizedBox(height: 56));
            }

            final date =
                DateTime(focusedMonth.year, focusedMonth.month, dayNum);
            final dateStr = DateFormat('yyyy-MM-dd').format(date);
            final isSelected = selectedDate.year == date.year &&
                selectedDate.month == date.month &&
                selectedDate.day == date.day;
            final isToday = today.year == date.year &&
                today.month == date.month &&
                today.day == date.day;
            final isWeekend = dayIdx == 0 || dayIdx == 6;
            final hasEntry = entryDates.any((d) =>
                d.year == date.year &&
                d.month == date.month &&
                d.day == date.day);
            final stickers = stickersMap[dateStr] ?? [];
            final schedules = schedulesMap[dateStr] ?? [];

            return Expanded(
              child: GestureDetector(
                onTap: () {
                  ref.read(selectedDateProvider.notifier).state = date;
                  // Show diary/schedule choice
                  _showDateActionSheet(context, ref, date, themeData, fontData);
                },
                onLongPress: () =>
                    _showCalendarStickerPicker(context, ref, date),
                child: Container(
                  height: 56,
                  margin: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? themeData.primary
                        : isToday
                            ? themeData.primary.withValues(alpha: 0.08)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$dayNum',
                        style: GoogleFonts.notoSans(
                          fontSize: 13,
                          fontWeight:
                              isToday ? FontWeight.w700 : FontWeight.w400,
                          color: isSelected
                              ? Colors.white
                              : isWeekend
                                  ? AppColors.accentPink
                                  : themeData.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 1),
                      if (stickers.isNotEmpty)
                        Text(
                          stickers.length <= 2
                              ? stickers.join('')
                              : '${stickers[0]}${stickers[1]}',
                          style: const TextStyle(fontSize: 9, height: 1.0),
                        )
                      else
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (hasEntry)
                              Container(
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.white.withValues(alpha: 0.8)
                                      : AppColors.accentPink,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            if (hasEntry && schedules.isNotEmpty)
                              const SizedBox(width: 2),
                            if (schedules.isNotEmpty)
                              Container(
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.white.withValues(alpha: 0.8)
                                      : AppColors.accentBlue,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
        );
      }),
    );
  }

  /// 날짜 클릭 시 일기/일정 선택 바텀시트
  void _showDateActionSheet(
    BuildContext context,
    WidgetRef ref,
    DateTime date,
    AppThemeData themeData,
    AppFontData fontData,
  ) {
    final dayStr = DateFormat('M월 d일', 'ko_KR').format(date);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: themeData.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              dayStr,
              style: getAppFont(fontData.googleFontName, 18, themeData.textPrimary),
            ),
            const SizedBox(height: 20),
            // 일기 쓰기
            Pressable(
              onTap: () {
                Navigator.pop(context);
                onDateSelected(date);
              },
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.accentPink.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Text('📝', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '일기 쓰기',
                          style: getAppFont(fontData.googleFontName, 15,
                              themeData.textPrimary),
                        ),
                        Text(
                          '오늘 하루를 꾸며보세요',
                          style: getAppFont(fontData.googleFontName, 11,
                              themeData.textSecondary),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Icon(Icons.chevron_right_rounded,
                        color: themeData.textSecondary, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            // 일정 쓰기
            Pressable(
              onTap: () {
                Navigator.pop(context);
                onScheduleSelected?.call(date);
              },
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.accentBlue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Text('📅', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '일정 관리',
                          style: getAppFont(fontData.googleFontName, 15,
                              themeData.textPrimary),
                        ),
                        Text(
                          '할 일과 약속을 기록해요',
                          style: getAppFont(fontData.googleFontName, 11,
                              themeData.textSecondary),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Icon(Icons.chevron_right_rounded,
                        color: themeData.textSecondary, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showCalendarStickerPicker(
    BuildContext context,
    WidgetRef ref,
    DateTime date,
  ) {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final dayStr = DateFormat('M월 d일', 'ko_KR').format(date);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '$dayStr 스티커',
              style: GoogleFonts.notoSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Pressable(
              onTap: () async {
                final db = ref.read(localDatabaseProvider);
                await db.deleteCalendarStickersByDate(dateStr);
                ref.invalidate(calendarStickersProvider);
                if (context.mounted) Navigator.pop(context);
              },
              child: Text(
                '스티커 지우기',
                style: GoogleFonts.notoSans(
                  fontSize: 12,
                  color: AppColors.accent,
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 280,
              child: StickerPicker(
                onStickerSelected: (emoji) async {
                  final db = ref.read(localDatabaseProvider);
                  await db.insertCalendarSticker(
                    const Uuid().v4(),
                    dateStr,
                    emoji,
                  );
                  ref.invalidate(calendarStickersProvider);
                  if (context.mounted) Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
