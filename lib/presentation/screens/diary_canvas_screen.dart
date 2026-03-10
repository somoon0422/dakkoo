import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../app.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/image_utils.dart';
import '../../domain/entities/diary_page.dart';
import '../providers/canvas_providers.dart';
import '../providers/diary_providers.dart';
import '../providers/theme_providers.dart';
import '../widgets/canvas/diary_canvas.dart';
import '../widgets/canvas/toolbar.dart';
import '../widgets/common/pressable.dart';
import '../widgets/stickers/sticker_picker.dart';

class DiaryCanvasScreen extends ConsumerStatefulWidget {
  final DiaryPage page;

  const DiaryCanvasScreen({super.key, required this.page});

  @override
  ConsumerState<DiaryCanvasScreen> createState() => _DiaryCanvasScreenState();
}

class _DiaryCanvasScreenState extends ConsumerState<DiaryCanvasScreen> {
  final _imagePicker = ImagePicker();
  late PageController _pageController;
  late DateTime _currentDate;

  @override
  void initState() {
    super.initState();
    _currentDate = widget.page.date;
    _pageController = PageController(initialPage: 1000);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPage(widget.page);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _loadPage(DiaryPage page) {
    ref.read(currentPageProvider.notifier).state = page;
    ref.read(pageElementsProvider.notifier).loadElements(page.id);
    ref.read(selectedElementIdProvider.notifier).state = null;
    ref.read(isDrawingModeProvider.notifier).state = false;
  }

  DateTime _dateForIndex(int index) {
    final offset = index - 1000;
    return widget.page.date.add(Duration(days: offset));
  }

  Future<void> _navigateToDate(DateTime newDate) async {
    setState(() => _currentDate = newDate);
    final newPage = await ref.read(pageForDateProvider(newDate).future);
    _loadPage(newPage);
  }

  @override
  Widget build(BuildContext context) {
    final page = ref.watch(currentPageProvider) ?? widget.page;
    final themeData = ref.watch(currentThemeDataProvider);
    final fontData = ref.watch(currentFontDataProvider);
    final dayNum = _currentDate.day;
    final monthNum = _currentDate.month;
    final weekdayStr = DateFormat('EEEE', 'ko_KR').format(_currentDate);

    return Scaffold(
      backgroundColor: themeData.background,
      body: SafeArea(
        child: Column(
          children: [
            // Custom top bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  // Back button
                  Pressable(
                    onTap: () {
                      ref.invalidate(datesWithEntriesProvider);
                      ref.invalidate(allPagesProvider);
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: themeData.surface,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(Icons.arrow_back_ios_new_rounded,
                          size: 18, color: themeData.textPrimary),
                    ),
                  ),

                  const Spacer(),

                  // Date display
                  Pressable(
                    onTap: () => _showDatePicker(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: themeData.surface,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$monthNum월 $dayNum일',
                            style: getAppFont(fontData.googleFontName, 16,
                                themeData.textPrimary),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            weekdayStr,
                            style: getAppFont(fontData.googleFontName, 12,
                                themeData.textSecondary),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.keyboard_arrow_down_rounded,
                              size: 18, color: themeData.textSecondary),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Background picker
                  PopupMenuButton<BackgroundType>(
                    offset: const Offset(0, 40),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: themeData.surface,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(Icons.palette_outlined,
                          size: 18, color: themeData.textPrimary),
                    ),
                    onSelected: (bg) async {
                      final updated = page.copyWith(
                        backgroundType: bg,
                        updatedAt: DateTime.now(),
                      );
                      ref.read(currentPageProvider.notifier).state = updated;
                      await ref
                          .read(diaryRepositoryProvider)
                          .updatePage(updated);
                    },
                    itemBuilder: (_) => [
                      _buildPopupItem(
                          BackgroundType.notePaper, '노트 종이', Icons.note_alt_outlined),
                      _buildPopupItem(BackgroundType.kraftPaper, '크래프트 종이',
                          Icons.texture_rounded),
                      _buildPopupItem(BackgroundType.vintagePaper, '빈티지 종이',
                          Icons.auto_awesome_outlined),
                      _buildPopupItem(
                          BackgroundType.blank, '빈 종이', Icons.crop_square_rounded),
                    ],
                  ),
                ],
              ),
            ),

            // Page content
            Expanded(
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) async {
                      final newDate = _dateForIndex(index);
                      await _navigateToDate(newDate);
                    },
                    itemBuilder: (context, index) {
                      return DiaryCanvas(
                        page: page,
                        onTapImageArea: () => _addPhoto(),
                      );
                    },
                  ),
                  // Left arrow
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: Pressable(
                        onTap: () => _goToPreviousDay(),
                        scaleFactor: 0.85,
                        child: Container(
                          margin: const EdgeInsets.only(left: 4),
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: themeData.surface.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.chevron_left_rounded,
                            color: themeData.textSecondary,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Right arrow
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: Pressable(
                        onTap: () => _goToNextDay(),
                        scaleFactor: 0.85,
                        child: Container(
                          margin: const EdgeInsets.only(right: 4),
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: themeData.surface.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.chevron_right_rounded,
                            color: themeData.textSecondary,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Toolbar
            CanvasToolbar(
              onAddText: () => _addText(),
              onAddPhoto: () => _addPhoto(),
              onAddSticker: () => _showStickerPicker(),
              onToggleDrawing: () => _toggleDrawing(),
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<BackgroundType> _buildPopupItem(
      BackgroundType value, String label, IconData icon) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Text(label, style: GoogleFonts.notoSans(fontSize: 14)),
        ],
      ),
    );
  }

  void _goToPreviousDay() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _goToNextDay() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _currentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('ko', 'KR'),
    );
    if (picked != null) {
      final dayDiff = picked.difference(widget.page.date).inDays;
      final targetIndex = 1000 + dayDiff;
      _pageController.jumpToPage(targetIndex);
      await _navigateToDate(picked);
    }
  }

  void _addText() {
    final page = ref.read(currentPageProvider);
    if (page == null) return;
    ref.read(pageElementsProvider.notifier).addTextElement(page.id);
  }

  Future<void> _addPhoto() async {
    final page = ref.read(currentPageProvider);
    if (page == null) return;

    if (kIsWeb) {
      final images = await _imagePicker.pickMultiImage(
        maxWidth: 1024,
        imageQuality: 80,
      );
      for (final image in images) {
        ref
            .read(pageElementsProvider.notifier)
            .addImageElement(page.id, image.path);
      }
      return;
    }

    final images = await _imagePicker.pickMultiImage(
      maxWidth: 1024,
      imageQuality: 80,
    );

    for (final image in images) {
      final sourceFile = File(image.path);
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${images.indexOf(image)}.png';

      final savedFile = await ImageUtils.compressAndSaveImage(
        sourceFile,
        page.date,
        fileName,
      );

      ref
          .read(pageElementsProvider.notifier)
          .addImageElement(page.id, savedFile.path);
    }
  }

  void _showStickerPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: StickerPicker(
          onStickerSelected: (emoji) {
            Navigator.pop(context);
            final page = ref.read(currentPageProvider);
            if (page != null) {
              ref
                  .read(pageElementsProvider.notifier)
                  .addStickerElement(page.id, emoji);
            }
          },
        ),
      ),
    );
  }

  void _toggleDrawing() {
    final current = ref.read(isDrawingModeProvider);
    ref.read(isDrawingModeProvider.notifier).state = !current;
    if (!current) {
      ref.read(selectedElementIdProvider.notifier).state = null;
    }
  }
}
