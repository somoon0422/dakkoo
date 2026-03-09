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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.toolbarBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: isDrawing
            ? _buildDrawingToolbar(context, ref, drawingColor)
            : _buildMainToolbar(context),
      ),
    );
  }

  Widget _buildMainToolbar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _ToolbarButton(
          icon: Icons.text_fields,
          label: '텍스트',
          onTap: onAddText,
        ),
        _ToolbarButton(
          icon: Icons.photo_library,
          label: '사진',
          onTap: onAddPhoto,
        ),
        _ToolbarButton(
          icon: Icons.emoji_emotions,
          label: '스티커',
          onTap: onAddSticker,
        ),
        _ToolbarButton(
          icon: Icons.brush,
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
          child: const Padding(
            padding: EdgeInsets.all(8),
            child: Icon(Icons.close, color: AppColors.textPrimary, size: 22),
          ),
        ),
        const SizedBox(width: 8),

        // Color picker
        Pressable(
          onTap: () => _showColorPicker(context, ref, currentColor),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: currentColor,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.divider, width: 2),
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Quick colors
        ...[Colors.black, Colors.red, Colors.blue, Colors.green].map(
          (color) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Pressable(
              onTap: () =>
                  ref.read(drawingColorProvider.notifier).state = color,
              scaleFactor: 0.8,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: currentColor == color
                      ? Border.all(color: AppColors.selectedElement, width: 2)
                      : null,
                ),
              ),
            ),
          ),
        ),

        const Spacer(),

        // Stroke width
        SizedBox(
          width: 100,
          child: Slider(
            value: strokeWidth,
            min: 1.0,
            max: 10.0,
            activeColor: AppColors.primary,
            onChanged: (v) =>
                ref.read(drawingStrokeWidthProvider.notifier).state = v,
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
          title:
              Text('색상 선택', style: GoogleFonts.nanumPenScript(fontSize: 22)),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: currentColor,
              onColorChanged: (color) => pickedColor = color,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                ref.read(drawingColorProvider.notifier).state = pickedColor;
                Navigator.pop(dialogContext);
              },
              child: Text('확인',
                  style: GoogleFonts.nanumPenScript(fontSize: 18)),
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
  late Animation<Color?> _colorAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _colorAnim = ColorTween(
      begin: AppColors.textPrimary,
      end: AppColors.primary,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(widget.icon, color: _colorAnim.value, size: 24),
                const SizedBox(height: 4),
                Text(
                  widget.label,
                  style: GoogleFonts.nanumPenScript(
                    fontSize: 14,
                    color: _colorAnim.value?.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
