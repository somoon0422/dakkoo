import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        surface: AppColors.surface,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.nanumPenScript(
          fontSize: 24,
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w400,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      textTheme: GoogleFonts.nanumPenScriptTextTheme().copyWith(
        headlineLarge: GoogleFonts.nanumPenScript(
          fontSize: 32,
          color: AppColors.textPrimary,
        ),
        headlineMedium: GoogleFonts.nanumPenScript(
          fontSize: 28,
          color: AppColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.nanumPenScript(
          fontSize: 20,
          color: AppColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.nanumPenScript(
          fontSize: 18,
          color: AppColors.textSecondary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}
