import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/theme_providers.dart';
import '../widgets/common/pressable.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeData = ref.watch(currentThemeDataProvider);
    final fontData = ref.watch(currentFontDataProvider);
    final currentTheme = ref.watch(appThemeTypeProvider);
    final currentFont = ref.watch(appFontTypeProvider);

    return Scaffold(
      backgroundColor: themeData.background,
      appBar: AppBar(
        backgroundColor: themeData.toolbarBg,
        elevation: 1,
        leading: Pressable(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back_ios,
              size: 20, color: themeData.textPrimary),
        ),
        title: Text(
          '설정',
          style: _getFont(fontData.googleFontName, 24, themeData.textPrimary),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 테마 선택
            Text(
              '테마',
              style: _getFont(
                  fontData.googleFontName, 22, themeData.textPrimary),
            ),
            const SizedBox(height: 12),
            _buildThemeGrid(ref, currentTheme, themeData, fontData),
            const SizedBox(height: 32),

            // 폰트 선택
            Text(
              '폰트',
              style: _getFont(
                  fontData.googleFontName, 22, themeData.textPrimary),
            ),
            const SizedBox(height: 12),
            _buildFontList(ref, currentFont, themeData, fontData),

            const SizedBox(height: 32),

            // 미리보기
            Text(
              '미리보기',
              style: _getFont(
                  fontData.googleFontName, 22, themeData.textPrimary),
            ),
            const SizedBox(height: 12),
            _buildPreview(themeData, fontData),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeGrid(WidgetRef ref, AppThemeType currentTheme,
      AppThemeData themeData, AppFontData fontData) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: AppThemeType.values.map((type) {
        final data = themeDataMap[type]!;
        final isSelected = type == currentTheme;

        return Pressable(
          onTap: () => ref.read(appThemeTypeProvider.notifier).state = type,
          child: Container(
            width: 100,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: data.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? data.primary : data.divider,
                width: isSelected ? 2.5 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: data.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                      )
                    ]
                  : null,
            ),
            child: Column(
              children: [
                // Color dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _colorDot(data.primary, 16),
                    const SizedBox(width: 4),
                    _colorDot(data.background, 16),
                    const SizedBox(width: 4),
                    _colorDot(data.accent, 16),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  data.name,
                  style: _getFont(
                    fontData.googleFontName,
                    14,
                    isSelected ? data.primary : themeData.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _colorDot(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.1),
          width: 0.5,
        ),
      ),
    );
  }

  Widget _buildFontList(WidgetRef ref, AppFontType currentFont,
      AppThemeData themeData, AppFontData currentFontData) {
    return Column(
      children: AppFontType.values.map((type) {
        final data = fontDataMap[type]!;
        final isSelected = type == currentFont;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Pressable(
            onTap: () => ref.read(appFontTypeProvider.notifier).state = type,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? themeData.primary.withValues(alpha: 0.1)
                    : themeData.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? themeData.primary : themeData.divider,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${data.name} - 오늘의 일기',
                      style: _getFont(
                        data.googleFontName,
                        20,
                        themeData.textPrimary,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Icon(Icons.check_circle,
                        color: themeData.primary, size: 22),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPreview(AppThemeData themeData, AppFontData fontData) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeData.notePaper,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: themeData.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '2026년 3월의 어느 날',
            style: _getFont(fontData.googleFontName, 24, themeData.textPrimary),
          ),
          const SizedBox(height: 12),
          Container(
            height: 80,
            width: double.infinity,
            decoration: BoxDecoration(
              color: themeData.divider.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.image, size: 32, color: themeData.textSecondary),
          ),
          const SizedBox(height: 12),
          Text(
            '오늘 하루도 소중한 추억을 기록합니다.\n작은 행복들이 모여 큰 이야기가 되는 나의 다꾸.',
            style: _getFont(
                fontData.googleFontName, 18, themeData.textPrimary,
                height: 1.8),
          ),
          const SizedBox(height: 8),
          Text(
            '😊 ✨ 🌸',
            style: const TextStyle(fontSize: 20),
          ),
        ],
      ),
    );
  }

  TextStyle _getFont(String fontName, double size, Color color,
      {double? height}) {
    switch (fontName) {
      case 'Gaegu':
        return GoogleFonts.gaegu(fontSize: size, color: color, height: height);
      case 'Poor Story':
        return GoogleFonts.poorStory(
            fontSize: size, color: color, height: height);
      case 'Gamja Flower':
        return GoogleFonts.gamjaFlower(
            fontSize: size, color: color, height: height);
      case 'Dokdo':
        return GoogleFonts.dokdo(fontSize: size, color: color, height: height);
      case 'Single Day':
        return GoogleFonts.singleDay(
            fontSize: size, color: color, height: height);
      case 'East Sea Dokdo':
        return GoogleFonts.eastSeaDokdo(
            fontSize: size, color: color, height: height);
      case 'Gothic A1':
        return GoogleFonts.gothicA1(
            fontSize: size, color: color, height: height);
      default:
        return GoogleFonts.nanumPenScript(
            fontSize: size, color: color, height: height);
    }
  }
}
