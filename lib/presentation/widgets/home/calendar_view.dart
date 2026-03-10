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

  const CalendarView({
    super.key,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final focusedMonth = ref.watch(focusedMonthProvider);
    final datesWithEntries = ref.watch(datesWithEntriesProvider);
    final calendarStickers = ref.watch(calendarStickersProvider);
    final fontData = ref.watch(currentFontDataProvider);

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

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildHeader(context, ref, focusedMonth, fontData),
          const SizedBox(height: 12),
          _buildWeekdayLabels(fontData),
          const SizedBox(height: 4),
          _buildCalendarGrid(
            context,
            ref,
            focusedMonth,
            selectedDate,
            entryDates,
            stickersMap,
            fontData,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, DateTime focusedMonth,
      AppFontData fontData) {
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
          child: const Padding(
            padding: EdgeInsets.all(8),
            child:
                Icon(Icons.chevron_left_rounded, size: 22, color: AppColors.textSecondary),
          ),
        ),
        Text(
          title,
          style: getAppFont(fontData.googleFontName, 17, AppColors.textPrimary),
        ),
        Pressable(
          onTap: () {
            final next =
                DateTime(focusedMonth.year, focusedMonth.month + 1, 1);
            ref.read(focusedMonthProvider.notifier).state = next;
          },
          child: const Padding(
            padding: EdgeInsets.all(8),
            child:
                Icon(Icons.chevron_right_rounded, size: 22, color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }

  Widget _buildWeekdayLabels(AppFontData fontData) {
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
                    : AppColors.textSecondary,
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
    AppFontData fontData,
  ) {
    final firstDay = DateTime(focusedMonth.year, focusedMonth.month, 1);
    final lastDay = DateTime(focusedMonth.year, focusedMonth.month + 1, 0);
    final startWeekday = firstDay.weekday % 7; // 0=Sun
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
              return const Expanded(child: SizedBox(height: 52));
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

            return Expanded(
              child: GestureDetector(
                onTap: () {
                  ref.read(selectedDateProvider.notifier).state = date;
                  onDateSelected(date);
                },
                onLongPress: () =>
                    _showCalendarStickerPicker(context, ref, date),
                child: Container(
                  height: 52,
                  margin: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : isToday
                            ? AppColors.primary.withValues(alpha: 0.08)
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
                                  : AppColors.textPrimary,
                        ),
                      ),
                      if (stickers.isNotEmpty)
                        Text(
                          stickers.length <= 2
                              ? stickers.join('')
                              : '${stickers[0]}${stickers[1]}',
                          style: const TextStyle(fontSize: 10, height: 1.2),
                        )
                      else if (hasEntry)
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withValues(alpha: 0.8)
                                : AppColors.accentPink,
                            shape: BoxShape.circle,
                          ),
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
            // Clear stickers button
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
