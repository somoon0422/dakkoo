import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'presentation/providers/theme_providers.dart';
import 'presentation/screens/home_screen.dart';

class DakkooApp extends ConsumerWidget {
  const DakkooApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeData = ref.watch(currentThemeDataProvider);
    final fontData = ref.watch(currentFontDataProvider);

    return MaterialApp(
      title: '다꾸',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(themeData, fontData),
      home: const HomeScreen(),
    );
  }

  ThemeData _buildTheme(AppThemeData themeData, AppFontData fontData) {
    final textTheme = TextTheme(
      headlineLarge: _getFont(fontData.googleFontName, 32, themeData.textPrimary),
      headlineMedium: _getFont(fontData.googleFontName, 28, themeData.textPrimary),
      bodyLarge: _getFont(fontData.googleFontName, 20, themeData.textPrimary),
      bodyMedium: _getFont(fontData.googleFontName, 18, themeData.textSecondary),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: themeData.brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: themeData.primary,
        brightness: themeData.brightness,
        surface: themeData.surface,
      ),
      scaffoldBackgroundColor: themeData.background,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: _getFont(
          fontData.googleFontName,
          24,
          themeData.textPrimary,
        ),
        iconTheme: IconThemeData(color: themeData.textPrimary),
      ),
      textTheme: textTheme,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: themeData.primary,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: themeData.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  static TextStyle _getFont(String fontName, double size, Color color,
      {double? height}) {
    switch (fontName) {
      case 'Gowun Batang':
        return GoogleFonts.gowunBatang(
            fontSize: size, color: color, height: height);
      case 'Gowun Dodum':
        return GoogleFonts.gowunDodum(
            fontSize: size, color: color, height: height);
      case 'Nanum Pen Script':
        return GoogleFonts.nanumPenScript(
            fontSize: size, color: color, height: height);
      case 'Nanum Brush Script':
        return GoogleFonts.nanumBrushScript(
            fontSize: size, color: color, height: height);
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
      case 'Noto Sans KR':
        return GoogleFonts.notoSans(
            fontSize: size, color: color, height: height);
      case 'Noto Serif KR':
        return GoogleFonts.notoSerif(
            fontSize: size, color: color, height: height);
      case 'IBM Plex Sans KR':
        return GoogleFonts.ibmPlexSansKr(
            fontSize: size, color: color, height: height);
      case 'Nanum Myeongjo':
        return GoogleFonts.nanumMyeongjo(
            fontSize: size, color: color, height: height);
      case 'Nanum Gothic':
        return GoogleFonts.nanumGothic(
            fontSize: size, color: color, height: height);
      case 'Do Hyeon':
        return GoogleFonts.doHyeon(
            fontSize: size, color: color, height: height);
      case 'Jua':
        return GoogleFonts.jua(fontSize: size, color: color, height: height);
      case 'Black Han Sans':
        return GoogleFonts.blackHanSans(
            fontSize: size, color: color, height: height);
      case 'Sunflower':
        return GoogleFonts.sunflower(
            fontSize: size, color: color, height: height);
      default:
        return GoogleFonts.gowunBatang(
            fontSize: size, color: color, height: height);
    }
  }
}

/// Utility to get font style by google font name — used across the app
TextStyle getAppFont(String fontName, double size, Color color,
    {double? height, FontWeight? fontWeight}) {
  return DakkooApp._getFont(fontName, size, color, height: height);
}
