import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/diary_element.dart';
import '../../providers/canvas_providers.dart';
import 'drawing_painter.dart';

class CanvasElementWidget extends ConsumerStatefulWidget {
  final DiaryElement element;

  const CanvasElementWidget({super.key, required this.element});

  @override
  ConsumerState<CanvasElementWidget> createState() =>
      _CanvasElementWidgetState();
}

class _CanvasElementWidgetState extends ConsumerState<CanvasElementWidget> {
  bool _isResizing = false;
  bool _isRotating = false;
  Offset _rotationCenter = Offset.zero;

  @override
  Widget build(BuildContext context) {
    final selectedId = ref.watch(selectedElementIdProvider);
    final isSelected = selectedId == widget.element.id;
    final isDrawing = ref.watch(isDrawingModeProvider);

    return Positioned(
      left: widget.element.x,
      top: widget.element.y,
      child: Transform.rotate(
        angle: widget.element.rotation,
        child: GestureDetector(
          onTap: isDrawing
              ? null
              : () {
                  ref.read(selectedElementIdProvider.notifier).state =
                      widget.element.id;
                  ref
                      .read(pageElementsProvider.notifier)
                      .bringToFront(widget.element.id);
                },
          onPanUpdate: isDrawing || _isResizing || _isRotating
              ? null
              : (details) {
                  if (!isSelected) {
                    ref.read(selectedElementIdProvider.notifier).state =
                        widget.element.id;
                  }
                  ref
                      .read(pageElementsProvider.notifier)
                      .updateElementPosition(
                        widget.element.id,
                        details.delta.dx,
                        details.delta.dy,
                      );
                },
          child: SizedBox(
            width: widget.element.width,
            height: widget.element.height,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Element content
                Positioned.fill(
                  child: Container(
                    decoration: isSelected
                        ? BoxDecoration(
                            border: Border.all(
                              color: AppColors.selectedElement,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          )
                        : null,
                    child: _buildElementContent(),
                  ),
                ),

                // Controls (visible when selected)
                if (isSelected && !isDrawing) ...[
                  // Delete button (top-left)
                  Positioned(
                    left: -12,
                    top: -12,
                    child: _buildControlButton(
                      icon: Icons.close,
                      color: Colors.red.shade400,
                      onTap: () {
                        ref
                            .read(pageElementsProvider.notifier)
                            .deleteElement(widget.element.id);
                        ref.read(selectedElementIdProvider.notifier).state =
                            null;
                      },
                    ),
                  ),

                  // Rotate button (top-right)
                  Positioned(
                    right: -12,
                    top: -12,
                    child: GestureDetector(
                      onPanStart: (details) {
                        _isRotating = true;
                        final box = context.findRenderObject() as RenderBox;
                        _rotationCenter = box.localToGlobal(
                          Offset(
                            widget.element.width / 2,
                            widget.element.height / 2,
                          ),
                        );
                      },
                      onPanUpdate: (details) {
                        final currentPos = details.globalPosition;
                        final angle = atan2(
                          currentPos.dy - _rotationCenter.dy,
                          currentPos.dx - _rotationCenter.dx,
                        );
                        ref
                            .read(pageElementsProvider.notifier)
                            .updateElementRotation(
                              widget.element.id,
                              angle,
                            );
                      },
                      onPanEnd: (_) {
                        _isRotating = false;
                      },
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppColors.accentBlue,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.rotate_right,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  // Resize handle (bottom-right)
                  Positioned(
                    right: -8,
                    bottom: -8,
                    child: GestureDetector(
                      onPanStart: (_) => _isResizing = true,
                      onPanUpdate: (details) {
                        final newWidth =
                            widget.element.width + details.delta.dx;
                        final newHeight =
                            widget.element.height + details.delta.dy;
                        ref
                            .read(pageElementsProvider.notifier)
                            .updateElementSize(
                              widget.element.id,
                              newWidth,
                              newHeight,
                            );
                      },
                      onPanEnd: (_) => _isResizing = false,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: AppColors.selectedElement,
                          borderRadius: BorderRadius.circular(3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.open_in_full,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  // Edit button for text (bottom-left)
                  if (widget.element.type == ElementType.text)
                    Positioned(
                      left: -12,
                      bottom: -12,
                      child: _buildControlButton(
                        icon: Icons.edit,
                        color: AppColors.accentGreen,
                        onTap: () => _editText(),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 3,
            ),
          ],
        ),
        child: Icon(icon, size: 14, color: Colors.white),
      ),
    );
  }

  Widget _buildElementContent() {
    switch (widget.element.type) {
      case ElementType.text:
        return _buildTextContent();
      case ElementType.image:
        return _buildImageContent();
      case ElementType.sticker:
        return _buildStickerContent();
      case ElementType.drawing:
        return _buildDrawingContent();
    }
  }

  Widget _buildTextContent() {
    final data = jsonDecode(widget.element.content) as Map<String, dynamic>;
    final text = data['text'] as String? ?? '';
    final fontName = data['font'] as String? ?? 'Nanum Pen Script';
    final fontSize = (data['fontSize'] as num?)?.toDouble() ?? 20.0;
    final colorValue = data['color'] as int? ?? Colors.black.toARGB32();

    TextStyle textStyle;
    switch (fontName) {
      case 'Gaegu':
        textStyle = GoogleFonts.gaegu(
          fontSize: fontSize,
          color: Color(colorValue),
        );
        break;
      case 'Poor Story':
        textStyle = GoogleFonts.poorStory(
          fontSize: fontSize,
          color: Color(colorValue),
        );
        break;
      case 'Stylish':
        textStyle = GoogleFonts.stylish(
          fontSize: fontSize,
          color: Color(colorValue),
        );
        break;
      case 'Sunflower':
        textStyle = GoogleFonts.sunflower(
          fontSize: fontSize,
          color: Color(colorValue),
        );
        break;
      default:
        textStyle = GoogleFonts.nanumPenScript(
          fontSize: fontSize,
          color: Color(colorValue),
        );
    }

    return Padding(
      padding: const EdgeInsets.all(4),
      child: Text(
        text,
        style: textStyle,
        overflow: TextOverflow.clip,
      ),
    );
  }

  Widget _buildImageContent() {
    final file = File(widget.element.content);
    if (!file.existsSync()) {
      return Container(
        color: AppColors.divider,
        child: const Center(
          child: Icon(Icons.broken_image, color: AppColors.textHint),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Image.file(
        file,
        fit: BoxFit.cover,
        width: widget.element.width,
        height: widget.element.height,
      ),
    );
  }

  Widget _buildStickerContent() {
    return Center(
      child: FittedBox(
        fit: BoxFit.contain,
        child: Text(
          widget.element.content,
          style: TextStyle(fontSize: widget.element.width * 0.7),
        ),
      ),
    );
  }

  Widget _buildDrawingContent() {
    final data = jsonDecode(widget.element.content) as Map<String, dynamic>;
    final pointsList = (data['points'] as List)
        .map((p) => p as Map<String, dynamic>)
        .toList();
    final colorValue = data['color'] as int? ?? Colors.black.toARGB32();
    final strokeWidth = (data['strokeWidth'] as num?)?.toDouble() ?? 3.0;

    return CustomPaint(
      painter: DrawingElementPainter(
        points: pointsList,
        color: Color(colorValue),
        strokeWidth: strokeWidth,
      ),
    );
  }

  void _editText() {
    final data =
        jsonDecode(widget.element.content) as Map<String, dynamic>;
    final controller =
        TextEditingController(text: data['text'] as String? ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text('텍스트 편집',
              style: GoogleFonts.nanumPenScript(fontSize: 22)),
          content: TextField(
            controller: controller,
            maxLines: 5,
            style: GoogleFonts.nanumPenScript(fontSize: 18),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              hintText: '내용을 입력하세요',
              hintStyle: GoogleFonts.nanumPenScript(
                fontSize: 18,
                color: AppColors.textHint,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child:
                  Text('취소', style: GoogleFonts.nanumPenScript(fontSize: 18)),
            ),
            TextButton(
              onPressed: () {
                data['text'] = controller.text;
                ref
                    .read(pageElementsProvider.notifier)
                    .updateElementContent(
                      widget.element.id,
                      jsonEncode(data),
                    );
                Navigator.pop(dialogContext);
              },
              child:
                  Text('확인', style: GoogleFonts.nanumPenScript(fontSize: 18)),
            ),
          ],
        );
      },
    );
  }
}
