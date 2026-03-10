import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app.dart';
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
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Pressable(
                    onTap: () => Navigator.pop(context),
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
                  const SizedBox(width: 16),
                  Text(
                    '설정',
                    style: GoogleFonts.notoSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: themeData.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // 테마 선택
                    _sectionTitle('테마', themeData),
                    const SizedBox(height: 12),
                    _buildThemeGrid(ref, currentTheme, themeData),
                    const SizedBox(height: 32),

                    // 폰트 선택
                    _sectionTitle('폰트', themeData),
                    const SizedBox(height: 12),
                    _buildFontList(ref, currentFont, themeData),

                    const SizedBox(height: 32),

                    // 미리보기
                    _sectionTitle('미리보기', themeData),
                    const SizedBox(height: 12),
                    _buildPreview(themeData, fontData),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, AppThemeData themeData) {
    return Text(
      title,
      style: GoogleFonts.notoSans(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: themeData.textPrimary,
        letterSpacing: -0.3,
      ),
    );
  }

  Widget _buildThemeGrid(
      WidgetRef ref, AppThemeType currentTheme, AppThemeData themeData) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.1,
      children: AppThemeType.values.map((type) {
        final data = themeDataMap[type]!;
        final isSelected = type == currentTheme;

        return Pressable(
          onTap: () => ref.read(appThemeTypeProvider.notifier).state = type,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: data.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? data.primary : data.divider,
                width: isSelected ? 2.5 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: data.primary.withValues(alpha: 0.25),
                        blurRadius: 10,
                      )
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _colorDot(data.primary, 14),
                    const SizedBox(width: 4),
                    _colorDot(data.background, 14),
                    const SizedBox(width: 4),
                    _colorDot(data.accent, 14),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  data.name,
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? data.primary : themeData.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
          color: Colors.black.withValues(alpha: 0.08),
          width: 0.5,
        ),
      ),
    );
  }

  Widget _buildFontList(
      WidgetRef ref, AppFontType currentFont, AppThemeData themeData) {
    // Group fonts by category
    final categories = ['손글씨', '명조', '고딕', '디스플레이'];
    final grouped = <String, List<MapEntry<AppFontType, AppFontData>>>{};
    for (final cat in categories) {
      grouped[cat] = fontDataMap.entries
          .where((e) => e.value.category == cat)
          .toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: categories.where((cat) => grouped[cat]!.isNotEmpty).map((cat) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8, top: 4),
              child: Text(
                cat,
                style: GoogleFonts.notoSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: themeData.textSecondary,
                  letterSpacing: 1,
                ),
              ),
            ),
            ...grouped[cat]!.map((entry) {
              final type = entry.key;
              final data = entry.value;
              final isSelected = type == currentFont;

              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Pressable(
                  onTap: () =>
                      ref.read(appFontTypeProvider.notifier).state = type,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? themeData.primary.withValues(alpha: 0.08)
                          : themeData.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? themeData.primary
                            : themeData.divider,
                        width: isSelected ? 1.5 : 0.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${data.name} — 오늘의 일기',
                            style: getAppFont(
                              data.googleFontName,
                              18,
                              themeData.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isSelected)
                          Icon(Icons.check_circle_rounded,
                              color: themeData.primary, size: 20),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
          ],
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
        border: Border.all(color: themeData.divider, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '2026년 3월의 어느 날',
            style: getAppFont(fontData.googleFontName, 22, themeData.textPrimary),
          ),
          const SizedBox(height: 14),
          Container(
            height: 70,
            width: double.infinity,
            decoration: BoxDecoration(
              color: themeData.divider.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.image_rounded,
                size: 28, color: themeData.textSecondary),
          ),
          const SizedBox(height: 14),
          Text(
            '오늘 하루도 소중한 추억을 기록합니다.\n작은 행복들이 모여 큰 이야기가 되는 나의 다꾸.',
            style: getAppFont(fontData.googleFontName, 16, themeData.textPrimary,
                height: 1.8),
          ),
        ],
      ),
    );
  }
}
