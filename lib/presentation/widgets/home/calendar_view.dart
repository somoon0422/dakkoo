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
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      child: Column(
        children: [
          _buildHeader(context, ref, focusedMonth, fontData, themeData),
          const SizedBox(height: 10),
          _buildWeekdayLabels(themeData, fontData),
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
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: themeData.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.chevron_left_rounded,
                size: 20, color: themeData.textSecondary),
          ),
        ),
        Text(
          title,
          style: getAppFont(fontData.googleFontName, 16, themeData.textPrimary),
        ),
        Pressable(
          onTap: () {
            final next =
                DateTime(focusedMonth.year, focusedMonth.month + 1, 1);
            ref.read(focusedMonthProvider.notifier).state = next;
          },
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: themeData.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.chevron_right_rounded,
                size: 20, color: themeData.textSecondary),
          ),
        ),
      ],
    );
  }

  Widget _buildWeekdayLabels(AppThemeData themeData, AppFontData fontData) {
    const days = ['일', '월', '화', '수', '목', '금', '토'];
    return Row(
      children: days.map((d) {
        final isSun = d == '일';
        final isSat = d == '토';
        return Expanded(
          child: Center(
            child: Text(
              d,
              style: GoogleFonts.notoSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isSun
                    ? AppColors.accentPink.withValues(alpha: 0.7)
                    : isSat
                        ? AppColors.accentBlue.withValues(alpha: 0.6)
                        : themeData.textSecondary.withValues(alpha: 0.6),
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
              return const Expanded(child: SizedBox(height: 50));
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
            final isSun = dayIdx == 0;
            final isSat = dayIdx == 6;
            final hasEntry = entryDates.any((d) =>
                d.year == date.year &&
                d.month == date.month &&
                d.day == date.day);
            final stickers = stickersMap[dateStr] ?? [];
            final schedules = schedulesMap[dateStr] ?? [];

            // Get first schedule emoji for display
            String? scheduleEmoji;
            if (schedules.isNotEmpty) {
              scheduleEmoji = schedules.first['emoji'] as String?;
            }

            return Expanded(
              child: GestureDetector(
                onTap: () {
                  ref.read(selectedDateProvider.notifier).state = date;
                  _showDateActionDialog(
                      context, ref, date, themeData, fontData);
                },
                child: Container(
                  height: 50,
                  margin: const EdgeInsets.all(1.5),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? themeData.primary
                        : isToday
                            ? themeData.primary.withValues(alpha: 0.06)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
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
                              : isSun
                                  ? AppColors.accentPink
                                  : isSat
                                      ? AppColors.accentBlue
                                      : themeData.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 1),
                      if (stickers.isNotEmpty)
                        Text(
                          stickers.length <= 2
                              ? stickers.join('')
                              : '${stickers[0]}${stickers[1]}',
                          style: const TextStyle(fontSize: 8, height: 1.0),
                        )
                      else if (scheduleEmoji != null && scheduleEmoji != '📅')
                        Text(
                          scheduleEmoji,
                          style: const TextStyle(fontSize: 9, height: 1.0),
                        )
                      else
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (hasEntry)
                              Container(
                                width: 4,
                                height: 4,
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
                                width: 4,
                                height: 4,
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

  /// 날짜 클릭 시 중앙 다이얼로그 (세련된 디자인)
  void _showDateActionDialog(
    BuildContext context,
    WidgetRef ref,
    DateTime date,
    AppThemeData themeData,
    AppFontData fontData,
  ) {
    final dayStr = DateFormat('M월 d일 EEEE', 'ko_KR').format(date);

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'dismiss',
      barrierColor: Colors.black.withValues(alpha: 0.3),
      transitionDuration: const Duration(milliseconds: 250),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return ScaleTransition(
          scale: Tween<double>(begin: 0.9, end: 1.0).animate(curvedAnimation),
          child: FadeTransition(
            opacity: curvedAnimation,
            child: child,
          ),
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.82,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              decoration: BoxDecoration(
                color: themeData.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Date header
                  Text(
                    dayStr,
                    style: getAppFont(
                        fontData.googleFontName, 17, themeData.textPrimary),
                  ),
                  const SizedBox(height: 24),

                  // Options
                  _ActionOption(
                    emoji: '📝',
                    title: '일기 쓰기',
                    subtitle: '오늘 하루를 꾸며보세요',
                    color: AppColors.accentPink,
                    themeData: themeData,
                    fontData: fontData,
                    onTap: () {
                      Navigator.pop(context);
                      onDateSelected(date);
                    },
                  ),
                  const SizedBox(height: 10),
                  _ActionOption(
                    emoji: '📅',
                    title: '일정 관리',
                    subtitle: '할 일과 약속을 기록해요',
                    color: AppColors.accentBlue,
                    themeData: themeData,
                    fontData: fontData,
                    onTap: () {
                      Navigator.pop(context);
                      onScheduleSelected?.call(date);
                    },
                  ),
                  const SizedBox(height: 10),
                  _ActionOption(
                    emoji: '🎀',
                    title: '스티커 붙이기',
                    subtitle: '달력에 귀여운 스티커를 꾸며요',
                    color: Colors.amber,
                    themeData: themeData,
                    fontData: fontData,
                    onTap: () {
                      Navigator.pop(context);
                      _showCalendarStickerPicker(
                          context, ref, date, themeData, fontData);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showCalendarStickerPicker(
    BuildContext context,
    WidgetRef ref,
    DateTime date,
    AppThemeData themeData,
    AppFontData fontData,
  ) {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final dayStr = DateFormat('M월 d일', 'ko_KR').format(date);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.5,
        decoration: BoxDecoration(
          color: themeData.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: themeData.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              '$dayStr 스티커',
              style: getAppFont(
                  fontData.googleFontName, 16, themeData.textPrimary),
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
                style: getAppFont(
                    fontData.googleFontName, 12, AppColors.accent),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
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

/// 세련된 액션 옵션 위젯
class _ActionOption extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final Color color;
  final AppThemeData themeData;
  final AppFontData fontData;
  final VoidCallback onTap;

  const _ActionOption({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.themeData,
    required this.fontData,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scaleFactor: 0.97,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: getAppFont(fontData.googleFontName, 15,
                        themeData.textPrimary),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: getAppFont(fontData.googleFontName, 11,
                        themeData.textSecondary),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: themeData.textSecondary.withValues(alpha: 0.4)),
          ],
        ),
      ),
    );
  }
}
