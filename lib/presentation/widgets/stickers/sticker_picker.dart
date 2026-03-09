import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

class StickerPicker extends StatefulWidget {
  final Function(String) onStickerSelected;

  const StickerPicker({super.key, required this.onStickerSelected});

  @override
  State<StickerPicker> createState() => _StickerPickerState();
}

class _StickerPickerState extends State<StickerPicker> {
  int _selectedCategory = 0;

  static const _categories = [
    _StickerCategory('하트', [
      '❤️', '🧡', '💛', '💚', '💙', '💜', '🖤', '🤍',
      '💕', '💖', '💗', '💘', '💝', '💞', '💓', '♥️',
    ]),
    _StickerCategory('날씨', [
      '☀️', '🌤️', '⛅', '🌥️', '☁️', '🌧️', '⛈️', '🌩️',
      '❄️', '🌈', '🌪️', '💨', '🌊', '🌸', '🍂', '🌻',
    ]),
    _StickerCategory('감정', [
      '😊', '😍', '🥰', '😢', '😎', '🤗', '😴', '🥺',
      '😤', '🤩', '😇', '🤔', '😋', '😌', '💪', '🙏',
    ]),
    _StickerCategory('여행', [
      '✈️', '🗺️', '🏖️', '🌴', '⛰️', '🏔️', '🗼', '🎡',
      '🚗', '🚃', '🛳️', '🎒', '📸', '🧭', '⛺', '🌅',
    ]),
    _StickerCategory('별', [
      '⭐', '🌟', '✨', '💫', '🌙', '🌝', '🌜', '🌛',
      '☄️', '🪐', '🌎', '🔮', '💎', '👑', '🎀', '🎊',
    ]),
    _StickerCategory('음식', [
      '☕', '🍰', '🧁', '🍩', '🍪', '🍕', '🍔', '🌮',
      '🍜', '🍣', '🧀', '🍓', '🍑', '🥑', '🍫', '🧋',
    ]),
    _StickerCategory('식물', [
      '🌱', '🌿', '🍀', '🌵', '🌲', '🎄', '🌷', '🌹',
      '🌺', '🌼', '💐', '🪴', '🍁', '🌾', '🎋', '🎍',
    ]),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '스티커',
            style: GoogleFonts.nanumPenScript(
              fontSize: 22,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          // Category tabs
          SizedBox(
            height: 36,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedCategory == index;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedCategory = index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(18),
                        border: isSelected
                            ? null
                            : Border.all(color: AppColors.divider),
                      ),
                      child: Text(
                        _categories[index].name,
                        style: GoogleFonts.nanumPenScript(
                          fontSize: 16,
                          color: isSelected
                              ? Colors.white
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // Sticker grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: _categories[_selectedCategory].stickers.length,
              itemBuilder: (context, index) {
                final sticker =
                    _categories[_selectedCategory].stickers[index];
                return GestureDetector(
                  onTap: () => widget.onStickerSelected(sticker),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(sticker, style: const TextStyle(fontSize: 28)),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StickerCategory {
  final String name;
  final List<String> stickers;

  const _StickerCategory(this.name, this.stickers);
}
