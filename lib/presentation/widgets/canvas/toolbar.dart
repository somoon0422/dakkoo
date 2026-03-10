import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/canvas_providers.dart';
import '../common/pressable.dart';

class CanvasToolbar extends ConsumerWidget {
  final VoidCallback onAddText;
  final VoidCallback onAddPhoto;
  final VoidCallback onAddSticker;
  final VoidCallback onToggleDrawing;

  const CanvasToolbar({
    super.key,
    required this.onAddText,
    required this.onAddPhoto,
    required this.onAddSticker,
    required this.onToggleDrawing,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDrawing = ref.watch(isDrawingModeProvider);
    final drawingColor = ref.watch(drawingColorProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: isDrawing
          ? _buildDrawingToolbar(context, ref, drawingColor)
          : _buildMainToolbar(),
    );
  }

  Widget _buildMainToolbar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _ToolbarButton(
          icon: Icons.text_fields_rounded,
          label: '텍스트',
          onTap: onAddText,
        ),
        _ToolbarButton(
          icon: Icons.photo_library_rounded,
          label: '사진',
          onTap: onAddPhoto,
        ),
        _ToolbarButton(
          icon: Icons.emoji_emotions_rounded,
          label: '스티커',
          onTap: onAddSticker,
        ),
        _ToolbarButton(
          icon: Icons.brush_rounded,
          label: '그리기',
          onTap: onToggleDrawing,
        ),
      ],
    );
  }

  Widget _buildDrawingToolbar(
    BuildContext context,
    WidgetRef ref,
    Color currentColor,
  ) {
    final strokeWidth = ref.watch(drawingStrokeWidthProvider);

    return Row(
      children: [
        Pressable(
          onTap: onToggleDrawing,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.close_rounded,
                color: AppColors.textPrimary, size: 20),
          ),
        ),
        const SizedBox(width: 12),

        // Color picker button
        Pressable(
          onTap: () => _showColorPicker(context, ref, currentColor),
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: currentColor,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.divider, width: 2),
              boxShadow: [
                BoxShadow(
                  color: currentColor.withValues(alpha: 0.3),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Quick colors
        ...[Colors.black, Colors.red, Colors.blue, Colors.green].map(
          (color) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Pressable(
              onTap: () =>
                  ref.read(drawingColorProvider.notifier).state = color,
              scaleFactor: 0.8,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: currentColor == color
                      ? Border.all(color: AppColors.accentBlue, width: 2.5)
                      : Border.all(
                          color: Colors.black.withValues(alpha: 0.1),
                          width: 1),
                ),
              ),
            ),
          ),
        ),

        const Spacer(),

        // Stroke width
        SizedBox(
          width: 90,
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
              activeTrackColor: AppColors.textPrimary,
              inactiveTrackColor: AppColors.divider,
              thumbColor: AppColors.textPrimary,
              overlayColor: AppColors.textPrimary.withValues(alpha: 0.1),
            ),
            child: Slider(
              value: strokeWidth,
              min: 1.0,
              max: 10.0,
              onChanged: (v) =>
                  ref.read(drawingStrokeWidthProvider.notifier).state = v,
            ),
          ),
        ),
      ],
    );
  }

  void _showColorPicker(
    BuildContext context,
    WidgetRef ref,
    Color currentColor,
  ) {
    Color pickedColor = currentColor;
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title:
              Text('색상 선택', style: GoogleFonts.notoSans(fontSize: 18, fontWeight: FontWeight.w600)),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: currentColor,
              onColorChanged: (color) => pickedColor = color,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('취소',
                  style: GoogleFonts.notoSans(
                      fontSize: 14, color: AppColors.textSecondary)),
            ),
            TextButton(
              onPressed: () {
                ref.read(drawingColorProvider.notifier).state = pickedColor;
                Navigator.pop(dialogContext);
              },
              child: Text('확인',
                  style: GoogleFonts.notoSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
            ),
          ],
        );
      },
    );
  }
}

class _ToolbarButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ToolbarButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<_ToolbarButton> createState() => _ToolbarButtonState();
}

class _ToolbarButtonState extends State<_ToolbarButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnim.value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _controller.isAnimating || _controller.value > 0
                    ? AppColors.background
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(widget.icon,
                      color: AppColors.textPrimary, size: 22),
                  const SizedBox(height: 3),
                  Text(
                    widget.label,
                    style: GoogleFonts.notoSans(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
