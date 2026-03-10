import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/diary_element.dart';
import '../../../domain/entities/diary_page.dart';
import '../../providers/canvas_providers.dart';
import '../common/pressable.dart';
import 'canvas_element.dart';
import 'drawing_painter.dart';

class DiaryCanvas extends ConsumerStatefulWidget {
  final DiaryPage page;
  final VoidCallback? onTapImageArea;

  const DiaryCanvas({
    super.key,
    required this.page,
    this.onTapImageArea,
  });

  @override
  ConsumerState<DiaryCanvas> createState() => _DiaryCanvasState();
}

class _DiaryCanvasState extends ConsumerState<DiaryCanvas> {
  late TextEditingController _textController;
  final FocusNode _focusNode = FocusNode();
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
  }

  @override
  void dispose() {
    _saveCurrentText();
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _initText(List<DiaryElement> textElements) {
    if (_initialized) return;
    _initialized = true;
    if (textElements.isNotEmpty) {
      try {
        final data =
            jsonDecode(textElements.first.content) as Map<String, dynamic>;
        _textController.text = data['text'] as String? ?? '';
      } catch (_) {
        _textController.text = textElements.first.content;
      }
    }
  }

  void _saveCurrentText() {
    final elements = ref.read(pageElementsProvider);
    final textElements =
        elements.where((e) => e.type == ElementType.text).toList();
    final text = _textController.text;
    if (text.isEmpty) return;

    final content = jsonEncode({
      'text': text,
      'font': 'Nanum Pen Script',
      'fontSize': 20.0,
      'color': Colors.black.toARGB32(),
    });

    if (textElements.isNotEmpty) {
      ref
          .read(pageElementsProvider.notifier)
          .updateElementContent(textElements.first.id, content);
    } else {
      ref.read(pageElementsProvider.notifier).addTextElement(widget.page.id);
      Future.delayed(const Duration(milliseconds: 100), () {
        final els = ref.read(pageElementsProvider);
        final newText =
            els.where((e) => e.type == ElementType.text).lastOrNull;
        if (newText != null) {
          ref
              .read(pageElementsProvider.notifier)
              .updateElementContent(newText.id, content);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final elements = ref.watch(pageElementsProvider);
    final isDrawing = ref.watch(isDrawingModeProvider);
    final drawingPoints = ref.watch(currentDrawingPointsProvider);
    final drawingColor = ref.watch(drawingColorProvider);
    final strokeWidth = ref.watch(drawingStrokeWidthProvider);

    final sortedElements = List<DiaryElement>.from(elements)
      ..sort((a, b) => a.zIndex.compareTo(b.zIndex));

    final imageElements =
        sortedElements.where((e) => e.type == ElementType.image).toList();
    final textElements =
        sortedElements.where((e) => e.type == ElementType.text).toList();
    final stickerElements =
        sortedElements.where((e) => e.type == ElementType.sticker).toList();
    final drawingElements =
        sortedElements.where((e) => e.type == ElementType.drawing).toList();

    _initText(textElements);

    return GestureDetector(
      onTap: () {
        if (!isDrawing) {
          ref.read(selectedElementIdProvider.notifier).state = null;
        }
      },
      child: Container(
        color: AppColors.background,
        child: Stack(
          children: [
            // Main content
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  // Image area
                  _buildImageArea(imageElements),
                  const SizedBox(height: 16),

                  // Inline text area (바로 여기서 타이핑)
                  _buildInlineTextArea(),
                  const SizedBox(height: 100),
                ],
              ),
            ),

            // Stickers overlay
            ...stickerElements.map((element) => CanvasElementWidget(
                  key: ValueKey(element.id),
                  element: element,
                )),

            // Drawing overlays
            ...drawingElements.map((element) => CanvasElementWidget(
                  key: ValueKey(element.id),
                  element: element,
                )),

            // Active drawing
            if (isDrawing)
              Positioned.fill(
                child: GestureDetector(
                  onPanStart: (details) {
                    ref.read(currentDrawingPointsProvider.notifier).state = [
                      {
                        'x': details.localPosition.dx,
                        'y': details.localPosition.dy,
                        'pressure': 0.5,
                      }
                    ];
                  },
                  onPanUpdate: (details) {
                    final points = ref.read(currentDrawingPointsProvider);
                    ref.read(currentDrawingPointsProvider.notifier).state = [
                      ...points,
                      {
                        'x': details.localPosition.dx,
                        'y': details.localPosition.dy,
                        'pressure': 0.5,
                      },
                    ];
                  },
                  onPanEnd: (_) {
                    final points = ref.read(currentDrawingPointsProvider);
                    if (points.isNotEmpty) {
                      ref
                          .read(pageElementsProvider.notifier)
                          .addDrawingElement(
                              widget.page.id, points, drawingColor, strokeWidth);
                    }
                    ref.read(currentDrawingPointsProvider.notifier).state = [];
                  },
                  child: CustomPaint(
                    painter: ActiveDrawingPainter(
                      points: drawingPoints,
                      color: drawingColor,
                      strokeWidth: strokeWidth,
                    ),
                    size: Size.infinite,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageArea(List<DiaryElement> imageElements) {
    return Pressable(
      onTap: widget.onTapImageArea,
      scaleFactor: 0.98,
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: imageElements.isNotEmpty
              ? AppColors.divider.withValues(alpha: 0.3)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: imageElements.isEmpty
              ? Border.all(
                  color: AppColors.divider,
                  width: 1,
                  strokeAlign: BorderSide.strokeAlignInside,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: imageElements.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image_rounded,
                          size: 40, color: AppColors.textHint),
                      const SizedBox(height: 4),
                      Text(
                        '사진이 추가됨',
                        style: GoogleFonts.notoSans(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.divider.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.add_rounded,
                            size: 28, color: AppColors.textHint),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '사진 추가',
                        style: GoogleFonts.notoSans(
                          fontSize: 13,
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  /// 인라인 텍스트 — 바로 여기서 일기 작성
  Widget _buildInlineTextArea() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 300),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _textController,
        focusNode: _focusNode,
        maxLines: null,
        style: GoogleFonts.gowunBatang(
          fontSize: 16,
          color: AppColors.textPrimary,
          height: 2.0,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: '오늘 하루를 기록해보세요...',
          hintStyle: GoogleFonts.gowunBatang(
            fontSize: 16,
            color: AppColors.textHint,
            height: 2.0,
          ),
        ),
        onChanged: (_) {
          // Auto-save on change (debounced)
          _saveCurrentText();
        },
      ),
    );
  }
}
