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
  @override
  Widget build(BuildContext context) {
    final elements = ref.watch(pageElementsProvider);
    final isDrawing = ref.watch(isDrawingModeProvider);
    final drawingPoints = ref.watch(currentDrawingPointsProvider);
    final drawingColor = ref.watch(drawingColorProvider);
    final strokeWidth = ref.watch(drawingStrokeWidthProvider);

    // Sort by zIndex
    final sortedElements = List<DiaryElement>.from(elements)
      ..sort((a, b) => a.zIndex.compareTo(b.zIndex));

    // Separate elements by type
    final imageElements =
        sortedElements.where((e) => e.type == ElementType.image).toList();
    final textElements =
        sortedElements.where((e) => e.type == ElementType.text).toList();
    final stickerElements =
        sortedElements.where((e) => e.type == ElementType.sticker).toList();
    final drawingElements =
        sortedElements.where((e) => e.type == ElementType.drawing).toList();

    // Get main text content from first text element
    String bodyText = '';
    if (textElements.isNotEmpty) {
      try {
        final data =
            jsonDecode(textElements.first.content) as Map<String, dynamic>;
        bodyText = data['text'] as String? ?? '';
      } catch (_) {
        bodyText = textElements.first.content;
      }
    }

    return GestureDetector(
      onTap: () {
        if (!isDrawing) {
          ref.read(selectedElementIdProvider.notifier).state = null;
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: _getBackgroundColor(widget.page.backgroundType),
        ),
        child: Stack(
          children: [
            // Background pattern
            _buildBackgroundPattern(widget.page.backgroundType),

            // 그림일기 레이아웃
            Column(
              children: [
                // 상단 이미지 영역 (그림일기)
                _buildImageArea(imageElements),

                // 하단 텍스트 영역 (터치해서 바로 쓰기)
                Expanded(
                  child: _buildTextArea(bodyText, textElements),
                ),
              ],
            ),

            // 스티커 오버레이 (자유 배치)
            ...stickerElements.map((element) => CanvasElementWidget(
                  key: ValueKey(element.id),
                  element: element,
                )),

            // 그리기 오버레이
            ...drawingElements.map((element) => CanvasElementWidget(
                  key: ValueKey(element.id),
                  element: element,
                )),

            // Active drawing overlay
            if (isDrawing)
              Positioned.fill(
                child: GestureDetector(
                  onPanStart: (details) {
                    final point = {
                      'x': details.localPosition.dx,
                      'y': details.localPosition.dy,
                      'pressure': 0.5,
                    };
                    ref.read(currentDrawingPointsProvider.notifier).state = [
                      point
                    ];
                  },
                  onPanUpdate: (details) {
                    final points = ref.read(currentDrawingPointsProvider);
                    final point = {
                      'x': details.localPosition.dx,
                      'y': details.localPosition.dy,
                      'pressure': 0.5,
                    };
                    ref.read(currentDrawingPointsProvider.notifier).state = [
                      ...points,
                      point,
                    ];
                  },
                  onPanEnd: (_) {
                    final points = ref.read(currentDrawingPointsProvider);
                    if (points.isNotEmpty) {
                      ref
                          .read(pageElementsProvider.notifier)
                          .addDrawingElement(
                            widget.page.id,
                            points,
                            drawingColor,
                            strokeWidth,
                          );
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

  /// 상단 이미지 영역 - 그림일기 스타일 (적당한 크기)
  Widget _buildImageArea(List<DiaryElement> imageElements) {
    return Pressable(
      onTap: widget.onTapImageArea,
      scaleFactor: 0.98,
      child: Container(
        height: 200,
        margin: const EdgeInsets.fromLTRB(20, 12, 20, 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.divider.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: imageElements.isNotEmpty
              ? _buildImagePreview(imageElements)
              : _buildImagePlaceholder(),
        ),
      ),
    );
  }

  /// 이미지 미리보기 (여러 장이면 가로 스크롤)
  Widget _buildImagePreview(List<DiaryElement> imageElements) {
    if (imageElements.length == 1) {
      return SizedBox.expand(
        child: _buildSingleImage(imageElements.first),
      );
    }
    return PageView.builder(
      itemCount: imageElements.length,
      itemBuilder: (context, index) {
        return _buildSingleImage(imageElements[index]);
      },
    );
  }

  Widget _buildSingleImage(DiaryElement element) {
    // On web, content is a path string; show placeholder
    return Container(
      color: AppColors.divider.withValues(alpha: 0.2),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.image, size: 48, color: AppColors.textHint),
            const SizedBox(height: 4),
            Text(
              '사진이 추가되었어요',
              style: GoogleFonts.nanumPenScript(
                fontSize: 16,
                color: AppColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 이미지 없을 때 플레이스홀더
  Widget _buildImagePlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate_outlined,
            size: 40,
            color: AppColors.textHint.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 4),
          Text(
            '터치하여 사진 추가',
            style: GoogleFonts.nanumPenScript(
              fontSize: 16,
              color: AppColors.textHint.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  /// 하단 텍스트 영역 - 터치하면 바로 글 쓰기
  Widget _buildTextArea(String bodyText, List<DiaryElement> textElements) {
    return GestureDetector(
      onTap: () => _openTextEditor(bodyText, textElements),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(56, 12, 24, 12),
        child: bodyText.isEmpty
            ? Text(
                '터치하여 일기를 쓰세요...',
                style: GoogleFonts.nanumPenScript(
                  fontSize: 20,
                  color: AppColors.textHint.withValues(alpha: 0.5),
                ),
              )
            : Text(
                bodyText,
                style: GoogleFonts.nanumPenScript(
                  fontSize: 20,
                  color: AppColors.textPrimary,
                  height: 1.8,
                ),
              ),
      ),
    );
  }

  /// 텍스트 편집 다이얼로그
  void _openTextEditor(
      String currentText, List<DiaryElement> textElements) {
    final controller = TextEditingController(text: currentText);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (dialogContext) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            MediaQuery.of(dialogContext).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '일기 쓰기',
                    style: GoogleFonts.nanumPenScript(
                      fontSize: 22,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Pressable(
                    onTap: () {
                      _saveText(controller.text, textElements);
                      Navigator.pop(dialogContext);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '완료',
                        style: GoogleFonts.nanumPenScript(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                maxLines: 8,
                autofocus: true,
                style: GoogleFonts.nanumPenScript(
                  fontSize: 20,
                  height: 1.8,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: '오늘 하루는 어땠나요?',
                  hintStyle: GoogleFonts.nanumPenScript(
                    fontSize: 20,
                    color: AppColors.textHint,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.divider),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 텍스트 저장
  void _saveText(String text, List<DiaryElement> textElements) {
    final content = jsonEncode({
      'text': text,
      'font': 'Nanum Pen Script',
      'fontSize': 20.0,
      'color': Colors.black.toARGB32(),
    });

    if (textElements.isNotEmpty) {
      // Update existing text element
      ref
          .read(pageElementsProvider.notifier)
          .updateElementContent(textElements.first.id, content);
    } else {
      // Create new text element
      ref
          .read(pageElementsProvider.notifier)
          .addTextElement(widget.page.id);
      // Then update with typed text (addTextElement creates with default text)
      // Better: directly set content after creation
      Future.delayed(const Duration(milliseconds: 100), () {
        final elements = ref.read(pageElementsProvider);
        final newText =
            elements.where((e) => e.type == ElementType.text).lastOrNull;
        if (newText != null) {
          ref
              .read(pageElementsProvider.notifier)
              .updateElementContent(newText.id, content);
        }
      });
    }
  }

  Color _getBackgroundColor(BackgroundType type) {
    switch (type) {
      case BackgroundType.notePaper:
        return AppColors.notePaper;
      case BackgroundType.kraftPaper:
        return AppColors.kraftPaper;
      case BackgroundType.vintagePaper:
        return AppColors.vintagePaper;
      case BackgroundType.blank:
        return Colors.white;
    }
  }

  Widget _buildBackgroundPattern(BackgroundType type) {
    switch (type) {
      case BackgroundType.notePaper:
        return CustomPaint(
          painter: NotePaperPainter(),
          size: Size.infinite,
        );
      case BackgroundType.kraftPaper:
        return CustomPaint(
          painter: KraftPaperPainter(),
          size: Size.infinite,
        );
      case BackgroundType.vintagePaper:
        return CustomPaint(
          painter: VintagePaperPainter(),
          size: Size.infinite,
        );
      case BackgroundType.blank:
        return const SizedBox.shrink();
    }
  }
}

// Background painters
class NotePaperPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE0D8CC).withValues(alpha: 0.4)
      ..strokeWidth = 0.5;

    // Horizontal lines (start below image area ~230px)
    for (double y = 230; y < size.height; y += 28) {
      canvas.drawLine(Offset(30, y), Offset(size.width - 30, y), paint);
    }

    // Left margin line
    final marginPaint = Paint()
      ..color = const Color(0xFFE8A0A0).withValues(alpha: 0.3)
      ..strokeWidth = 1.0;
    canvas.drawLine(
      const Offset(50, 220),
      Offset(50, size.height),
      marginPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class KraftPaperPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFC4A882).withValues(alpha: 0.2);

    for (double x = 0; x < size.width; x += 15) {
      for (double y = 0; y < size.height; y += 15) {
        final offset = (x * 7 + y * 13) % 3;
        if (offset == 0) {
          canvas.drawCircle(Offset(x, y), 0.8, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class VintagePaperPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4B896).withValues(alpha: 0.3)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const cornerSize = 30.0;

    canvas.drawLine(
        const Offset(20, 20), const Offset(20 + cornerSize, 20), paint);
    canvas.drawLine(
        const Offset(20, 20), const Offset(20, 20 + cornerSize), paint);
    canvas.drawLine(Offset(size.width - 20, 20),
        Offset(size.width - 20 - cornerSize, 20), paint);
    canvas.drawLine(Offset(size.width - 20, 20),
        Offset(size.width - 20, 20 + cornerSize), paint);
    canvas.drawLine(Offset(20, size.height - 20),
        Offset(20 + cornerSize, size.height - 20), paint);
    canvas.drawLine(Offset(20, size.height - 20),
        Offset(20, size.height - 20 - cornerSize), paint);
    canvas.drawLine(Offset(size.width - 20, size.height - 20),
        Offset(size.width - 20 - cornerSize, size.height - 20), paint);
    canvas.drawLine(Offset(size.width - 20, size.height - 20),
        Offset(size.width - 20, size.height - 20 - cornerSize), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
