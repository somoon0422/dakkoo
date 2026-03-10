import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../app.dart';
import '../../core/constants/app_colors.dart';
import '../providers/diary_providers.dart';
import '../providers/theme_providers.dart';
import '../widgets/common/pressable.dart';
import '../widgets/home/calendar_view.dart';
import 'diary_canvas_screen.dart';
import 'schedule_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final themeData = ref.watch(currentThemeDataProvider);
    final fontData = ref.watch(currentFontDataProvider);
    final dayNum = selectedDate.day;
    final monthYear = DateFormat('yyyy. MM', 'ko_KR').format(selectedDate);
    final dayOfWeek = DateFormat('EEEE', 'ko_KR').format(selectedDate);

    return Scaffold(
      backgroundColor: themeData.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                // Top bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '다꾸',
                      style: getAppFont(
                          fontData.googleFontName, 24, themeData.textPrimary),
                    ),
                    Row(
                      children: [
                        _iconButton(
                          Icons.ios_share_rounded,
                          themeData,
                          () => _showExportDialog(context, ref, themeData, fontData),
                        ),
                        const SizedBox(width: 8),
                        _iconButton(
                          Icons.tune_rounded,
                          themeData,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SettingsScreen()),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Date card — 컴팩트 + 세련
                Pressable(
                  onTap: () => _openDiaryPage(context, ref, selectedDate),
                  scaleFactor: 0.97,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          themeData.primary,
                          themeData.primary.withValues(alpha: 0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: themeData.primary.withValues(alpha: 0.2),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Left: date info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                monthYear,
                                style: getAppFont(
                                  fontData.googleFontName,
                                  11,
                                  Colors.white.withValues(alpha: 0.55),
                                ),
                              ),
                              const SizedBox(height: 1),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '$dayNum일',
                                    style: getAppFont(
                                      fontData.googleFontName,
                                      32,
                                      Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 3),
                                    child: Text(
                                      dayOfWeek,
                                      style: getAppFont(
                                        fontData.googleFontName,
                                        12,
                                        Colors.white.withValues(alpha: 0.45),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Right: write button
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.edit_rounded,
                                  size: 13, color: Colors.white70),
                              const SizedBox(width: 6),
                              Text(
                                '일기 쓰기',
                                style: getAppFont(
                                  fontData.googleFontName,
                                  12,
                                  Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Calendar — 컴팩트
                Container(
                  decoration: BoxDecoration(
                    color: themeData.surface,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: CalendarView(
                      onDateSelected: (date) {
                        ref.read(selectedDateProvider.notifier).state = date;
                        _openDiaryPage(context, ref, date);
                      },
                      onScheduleSelected: (date) {
                        ref.read(selectedDateProvider.notifier).state = date;
                        _openSchedulePage(context, date);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _iconButton(
      IconData icon, AppThemeData themeData, VoidCallback onTap) {
    return Pressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: themeData.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: themeData.textSecondary),
      ),
    );
  }

  Future<void> _openDiaryPage(
    BuildContext context,
    WidgetRef ref,
    DateTime date,
  ) async {
    final page = await ref.read(pageForDateProvider(date).future);
    if (context.mounted) {
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              DiaryCanvasScreen(page: page),
          transitionsBuilder:
              (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.05),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOut,
                )),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    }
  }

  void _openSchedulePage(BuildContext context, DateTime date) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ScheduleScreen(date: date),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.05),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              )),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _showExportDialog(BuildContext context, WidgetRef ref,
      AppThemeData themeData, AppFontData fontData) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'dismiss',
      barrierColor: Colors.black.withValues(alpha: 0.3),
      transitionDuration: const Duration(milliseconds: 250),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return ScaleTransition(
          scale: Tween<double>(begin: 0.9, end: 1.0).animate(curved),
          child: FadeTransition(opacity: curved, child: child),
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
                  Text(
                    '내보내기',
                    style: getAppFont(
                        fontData.googleFontName, 18, themeData.textPrimary),
                  ),
                  const SizedBox(height: 20),
                  _ExportOption(
                    icon: Icons.picture_as_pdf_rounded,
                    color: AppColors.accent,
                    label: 'PDF로 내보내기',
                    fontData: fontData,
                    themeData: themeData,
                    onTap: () {
                      Navigator.pop(context);
                      _exportAs(context, ref, 'pdf');
                    },
                  ),
                  const SizedBox(height: 8),
                  _ExportOption(
                    icon: Icons.folder_zip_rounded,
                    color: AppColors.accentBlue,
                    label: 'ZIP으로 내보내기',
                    fontData: fontData,
                    themeData: themeData,
                    onTap: () {
                      Navigator.pop(context);
                      _exportAs(context, ref, 'zip');
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

  Future<void> _exportAs(
    BuildContext context,
    WidgetRef ref,
    String format,
  ) async {
    final exportRepo = ref.read(exportRepositoryProvider);
    try {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('내보내기 준비 중...'),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
      String filePath;
      if (format == 'pdf') {
        filePath = await exportRepo.exportAsPdf();
      } else {
        filePath = await exportRepo.exportAsZip();
      }
      await Share.shareXFiles([XFile(filePath)]);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('내보내기 실패: $e'),
            backgroundColor: AppColors.accent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }
}

class _ExportOption extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;
  final AppFontData fontData;
  final AppThemeData themeData;

  const _ExportOption({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
    required this.fontData,
    required this.themeData,
  });

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 12),
            Text(
              label,
              style: getAppFont(
                  fontData.googleFontName, 15, themeData.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
