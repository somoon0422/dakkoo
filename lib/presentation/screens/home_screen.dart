import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_colors.dart';
import '../providers/diary_providers.dart';
import '../widgets/common/pressable.dart';
import '../widgets/home/calendar_view.dart';
import 'diary_canvas_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 설정 버튼 (오른쪽 상단)
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 12, right: 16),
                  child: Pressable(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const SettingsScreen()),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: const Icon(Icons.settings,
                          size: 20, color: AppColors.textSecondary),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Date display
              _buildDateDisplay(context, selectedDate),
              const SizedBox(height: 32),
              // Open today's page button
              _buildOpenPageButton(context, ref, selectedDate),
              const SizedBox(height: 32),
              // Calendar (tap date to open diary)
              CalendarView(
                onDateSelected: (date) {
                  ref.read(selectedDateProvider.notifier).state = date;
                  _openDiaryPage(context, ref, date);
                },
              ),
              const SizedBox(height: 16),
              // Export button
              _buildExportButton(context, ref),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateDisplay(BuildContext context, DateTime date) {
    final dayOfWeek = DateFormat('EEEE', 'ko_KR').format(date);
    final dateStr = DateFormat('yyyy년 M월 d일', 'ko_KR').format(date);

    return Column(
      children: [
        Text(
          dateStr,
          style: GoogleFonts.nanumPenScript(
            fontSize: 36,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          dayOfWeek,
          style: GoogleFonts.nanumPenScript(
            fontSize: 22,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildOpenPageButton(
    BuildContext context,
    WidgetRef ref,
    DateTime date,
  ) {
    return Pressable(
      onTap: () => _openDiaryPage(context, ref, date),
      scaleFactor: 0.96,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_stories, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Text(
              '오늘의 페이지 열기',
              style: GoogleFonts.nanumPenScript(
                fontSize: 22,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportButton(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Pressable(
        onTap: () => _showExportDialog(context, ref),
        scaleFactor: 0.96,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.divider),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.download,
                  size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(
                '내보내기',
                style: GoogleFonts.nanumPenScript(
                  fontSize: 18,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
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
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              )),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    }
  }

  void _showExportDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '내보내기',
                style: GoogleFonts.nanumPenScript(
                  fontSize: 24,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading:
                    const Icon(Icons.picture_as_pdf, color: AppColors.accent),
                title: Text(
                  'PDF로 내보내기',
                  style: GoogleFonts.nanumPenScript(fontSize: 20),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  _exportAs(context, ref, 'pdf');
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.folder_zip, color: AppColors.accentBlue),
                title: Text(
                  'ZIP으로 내보내기',
                  style: GoogleFonts.nanumPenScript(fontSize: 20),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  _exportAs(context, ref, 'zip');
                },
              ),
              const SizedBox(height: 16),
            ],
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
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('내보내기 준비 중...',
              style: GoogleFonts.nanumPenScript(fontSize: 18)),
          backgroundColor: AppColors.primary,
        ),
      );

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
            content: Text('내보내기 실패: $e',
                style: GoogleFonts.nanumPenScript(fontSize: 18)),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
