import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../common/pressable.dart';

class StickerPicker extends StatefulWidget {
  final Function(String) onStickerSelected;

  const StickerPicker({super.key, required this.onStickerSelected});

  @override
  State<StickerPicker> createState() => _StickerPickerState();
}

class _StickerPickerState extends State<StickerPicker> {
  int _selectedCategory = 0;

  static const _categories = [
    _StickerCategory('인기', '⭐', [
      '🎀', '🧸', '🐰', '🐱', '🌸', '💌', '🍰', '☁️',
      '🌈', '✨', '💖', '🦋', '🍓', '🧁', '🎠', '🪄',
      '🫧', '🌷', '💐', '🧚', '🦄', '🐣', '🎪', '🪷',
    ]),
    _StickerCategory('하트', '💕', [
      '❤️', '🧡', '💛', '💚', '💙', '💜', '🖤', '🤍',
      '💕', '💖', '💗', '💘', '💝', '💞', '💓', '♥️',
      '❣️', '💟', '🫶', '💑', '💏', '😘', '🥰', '😍',
    ]),
    _StickerCategory('동물', '🐰', [
      '🐰', '🐱', '🐶', '🐻', '🐼', '🦊', '🐹', '🐭',
      '🐧', '🐥', '🐣', '🦋', '🐝', '🐞', '🦄', '🐑',
      '🦮', '🐈', '🐇', '🐿️', '🦔', '🐨', '🦁', '🐯',
    ]),
    _StickerCategory('꽃/식물', '🌸', [
      '🌸', '🌷', '🌹', '🌺', '🌻', '🌼', '💐', '🪷',
      '🌱', '🌿', '🍀', '🪴', '🌵', '🎋', '🍁', '🍂',
      '🌾', '🎍', '🪻', '💮', '🏵️', '🌲', '🌴', '☘️',
    ]),
    _StickerCategory('날씨', '☀️', [
      '☀️', '🌤️', '⛅', '🌥️', '☁️', '🌧️', '⛈️', '🌩️',
      '❄️', '🌈', '💨', '🌊', '⭐', '🌟', '🌙', '🌝',
      '🌜', '☄️', '🪐', '💫', '✨', '🔮', '🌅', '🌄',
    ]),
    _StickerCategory('음식', '🧁', [
      '☕', '🧁', '🍰', '🎂', '🍩', '🍪', '🧋', '🍭',
      '🍬', '🍫', '🍡', '🧇', '🥞', '🍨', '🍦', '🧀',
      '🍓', '🍑', '🍒', '🫐', '🥝', '🍇', '🍎', '🥑',
    ]),
    _StickerCategory('감정', '😊', [
      '😊', '🥰', '😍', '🤗', '😇', '🥺', '😢', '😤',
      '🤩', '😎', '😴', '🤔', '😋', '😌', '💪', '🙏',
      '👏', '🤭', '😳', '🫣', '🤫', '😱', '🥳', '😭',
    ]),
    _StickerCategory('여행', '✈️', [
      '✈️', '🗺️', '🏖️', '🌴', '⛰️', '🏔️', '🗼', '🎡',
      '🚗', '🚃', '🛳️', '🎒', '📸', '🧭', '⛺', '🏠',
      '🏰', '⛩️', '🛕', '🕌', '🗽', '🎢', '🎪', '🏛️',
    ]),
    _StickerCategory('학교', '📚', [
      '📚', '📖', '✏️', '🖊️', '📝', '📓', '🎓', '🏫',
      '📐', '📎', '🔖', '📌', '🖍️', '🎨', '🎵', '🎹',
      '⏰', '📅', '💡', '🔬', '🧪', '📋', '🗂️', '💻',
    ]),
    _StickerCategory('데코', '🎀', [
      '🎀', '🎗️', '🎊', '🎉', '🎈', '🎁', '🏷️', '💌',
      '✉️', '📮', '🪄', '👑', '💎', '🔑', '🗝️', '🪞',
      '🕯️', '🧲', '🎠', '🛍️', '👛', '🧵', '🪡', '🧶',
    ]),
    _StickerCategory('말풍선', '💬', [
      '💬', '💭', '🗯️', '🗨️', '📢', '📣', '🔔', '🏷️',
      '❗', '❓', '‼️', '⁉️', '💢', '💥', '💦', '💨',
      '📝', '📌', '🔖', '📎', '🖇️', '✂️', '📐', '🪧',
    ]),
    _StickerCategory('기호', '✨', [
      '⭐', '✨', '💫', '🌟', '❤️‍🔥', '🫧', '♾️', '☮️',
      '🔆', '🔅', '💠', '🔶', '🔷', '🔸', '🔹', '♠️',
      '♣️', '♥️', '♦️', '☑️', '✅', '❌', '⭕', '🔴',
    ]),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Category tabs with icons
        SizedBox(
          height: 44,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final isSelected = _selectedCategory == index;
              final cat = _categories[index];
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Pressable(
                  onTap: () => setState(() => _selectedCategory = index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(20),
                      border: isSelected
                          ? null
                          : Border.all(color: AppColors.divider, width: 0.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(cat.icon, style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 4),
                        Text(
                          cat.name,
                          style: GoogleFonts.notoSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),

        // Sticker grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: _categories[_selectedCategory].stickers.length,
            itemBuilder: (context, index) {
              final sticker =
                  _categories[_selectedCategory].stickers[index];
              return Pressable(
                onTap: () => widget.onStickerSelected(sticker),
                scaleFactor: 0.85,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child:
                        Text(sticker, style: const TextStyle(fontSize: 28)),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _StickerCategory {
  final String name;
  final String icon;
  final List<String> stickers;

  const _StickerCategory(this.name, this.icon, this.stickers);
}
