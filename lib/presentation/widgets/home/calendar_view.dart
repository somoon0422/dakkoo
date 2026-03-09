import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/diary_providers.dart';

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

    final entryDates = datesWithEntries.when(
      data: (dates) => dates.toSet(),
      loading: () => <DateTime>{},
      error: (e, st) => <DateTime>{},
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TableCalendar(
        locale: 'ko_KR',
        firstDay: DateTime(2020, 1, 1),
        lastDay: DateTime(2030, 12, 31),
        focusedDay: focusedMonth,
        rowHeight: 40,
        daysOfWeekHeight: 24,
        calendarFormat: CalendarFormat.month,
        availableCalendarFormats: const {CalendarFormat.month: '월'},
        selectedDayPredicate: (day) => isSameDay(selectedDate, day),
        onDaySelected: (selectedDay, focusedDay) {
          ref.read(selectedDateProvider.notifier).state = selectedDay;
          ref.read(focusedMonthProvider.notifier).state = focusedDay;
          onDateSelected(selectedDay);
        },
        onPageChanged: (focusedDay) {
          ref.read(focusedMonthProvider.notifier).state = focusedDay;
        },
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, date, events) {
            final normalizedDate =
                DateTime(date.year, date.month, date.day);
            final hasEntry = entryDates.any((d) =>
                d.year == normalizedDate.year &&
                d.month == normalizedDate.month &&
                d.day == normalizedDate.day);
            if (hasEntry) {
              return Positioned(
                bottom: 1,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.accentPink,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }
            return null;
          },
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: GoogleFonts.nanumPenScript(
            fontSize: 22,
            color: AppColors.textPrimary,
          ),
          leftChevronIcon: const Icon(
            Icons.chevron_left,
            color: AppColors.textSecondary,
          ),
          rightChevronIcon: const Icon(
            Icons.chevron_right,
            color: AppColors.textSecondary,
          ),
        ),
        calendarStyle: CalendarStyle(
          defaultTextStyle: GoogleFonts.nanumPenScript(
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
          weekendTextStyle: GoogleFonts.nanumPenScript(
            fontSize: 16,
            color: AppColors.accentPink,
          ),
          outsideTextStyle: GoogleFonts.nanumPenScript(
            fontSize: 16,
            color: AppColors.textHint,
          ),
          selectedDecoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          selectedTextStyle: GoogleFonts.nanumPenScript(
            fontSize: 16,
            color: Colors.white,
          ),
          todayDecoration: BoxDecoration(
            color: AppColors.primaryLight.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
          todayTextStyle: GoogleFonts.nanumPenScript(
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: GoogleFonts.nanumPenScript(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
          weekendStyle: GoogleFonts.nanumPenScript(
            fontSize: 14,
            color: AppColors.accentPink,
          ),
        ),
      ),
    );
  }
}
