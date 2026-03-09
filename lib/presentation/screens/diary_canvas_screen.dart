import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/image_utils.dart';
import '../../domain/entities/diary_page.dart';
import '../providers/canvas_providers.dart';
import '../providers/diary_providers.dart';
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
    final dateStr = DateFormat('M월 d일 (E)', 'ko_KR').format(_currentDate);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.toolbarBg,
        elevation: 1,
        leading: Pressable(
          onTap: () {
            ref.invalidate(datesWithEntriesProvider);
            ref.invalidate(allPagesProvider);
            Navigator.of(context).pop();
          },
          child: const Icon(Icons.arrow_back_ios, size: 20),
        ),
        title: Pressable(
          onTap: () => _showDatePicker(context),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                dateStr,
                style: GoogleFonts.nanumPenScript(
                  fontSize: 24,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_drop_down,
                  size: 20, color: AppColors.textSecondary),
            ],
          ),
        ),
        actions: [
          // Background picker
          PopupMenuButton<BackgroundType>(
            icon: const Icon(Icons.wallpaper, size: 22),
            onSelected: (bg) async {
              final updated = page.copyWith(
                backgroundType: bg,
                updatedAt: DateTime.now(),
              );
              ref.read(currentPageProvider.notifier).state = updated;
              await ref.read(diaryRepositoryProvider).updatePage(updated);
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: BackgroundType.notePaper,
                child: Text('노트 종이',
                    style: GoogleFonts.nanumPenScript(fontSize: 18)),
              ),
              PopupMenuItem(
                value: BackgroundType.kraftPaper,
                child: Text('크래프트 종이',
                    style: GoogleFonts.nanumPenScript(fontSize: 18)),
              ),
              PopupMenuItem(
                value: BackgroundType.vintagePaper,
                child: Text('빈티지 종이',
                    style: GoogleFonts.nanumPenScript(fontSize: 18)),
              ),
              PopupMenuItem(
                value: BackgroundType.blank,
                child: Text('빈 종이',
                    style: GoogleFonts.nanumPenScript(fontSize: 18)),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Page navigation arrows + swipe
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
                  left: 4,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Pressable(
                      onTap: () => _goToPreviousDay(),
                      scaleFactor: 0.85,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.7),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.chevron_left,
                          color: AppColors.textSecondary,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
                // Right arrow
                Positioned(
                  right: 4,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Pressable(
                      onTap: () => _goToNextDay(),
                      scaleFactor: 0.85,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.7),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.chevron_right,
                          color: AppColors.textSecondary,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          CanvasToolbar(
            onAddText: () => _addText(),
            onAddPhoto: () => _addPhoto(),
            onAddSticker: () => _showStickerPicker(),
            onToggleDrawing: () => _toggleDrawing(),
          ),
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
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StickerPicker(
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
