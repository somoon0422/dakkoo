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
    final textTheme = _getFontTextTheme(fontData.googleFontName, themeData);

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

  TextTheme _getFontTextTheme(String fontName, AppThemeData themeData) {
    return TextTheme(
      headlineLarge: _getFont(fontName, 32, themeData.textPrimary),
      headlineMedium: _getFont(fontName, 28, themeData.textPrimary),
      bodyLarge: _getFont(fontName, 20, themeData.textPrimary),
      bodyMedium: _getFont(fontName, 18, themeData.textSecondary),
    );
  }

  TextStyle _getFont(String fontName, double size, Color color) {
    switch (fontName) {
      case 'Gaegu':
        return GoogleFonts.gaegu(fontSize: size, color: color);
      case 'Poor Story':
        return GoogleFonts.poorStory(fontSize: size, color: color);
      case 'Gamja Flower':
        return GoogleFonts.gamjaFlower(fontSize: size, color: color);
      case 'Dokdo':
        return GoogleFonts.dokdo(fontSize: size, color: color);
      case 'Single Day':
        return GoogleFonts.singleDay(fontSize: size, color: color);
      case 'East Sea Dokdo':
        return GoogleFonts.eastSeaDokdo(fontSize: size, color: color);
      case 'Gothic A1':
        return GoogleFonts.gothicA1(fontSize: size, color: color);
      default:
        return GoogleFonts.nanumPenScript(fontSize: size, color: color);
    }
  }
}
