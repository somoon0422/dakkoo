import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 앱 테마 종류
enum AppThemeType {
  warm, // 따뜻한 브라운 (기본)
  cherry, // 체리블로썸 핑크
  ocean, // 오션 블루
  forest, // 포레스트 그린
  lavender, // 라벤더
  midnight, // 미드나이트 (다크)
}

/// 앱 폰트 종류
enum AppFontType {
  nanumPen, // 나눔 손글씨 펜
  gaegu, // 개구
  poorStory, // 푸어스토리
  gamja, // 감자꽃마을
  dokdo, // 독도
  singleDay, // 싱글데이
  eastSeaDokdo, // 동해독도
  gothicA1, // 고딕 A1
}

/// 테마 데이터
class AppThemeData {
  final String name;
  final Color primary;
  final Color background;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final Color notePaper;
  final Color toolbarBg;
  final Color divider;
  final Color accent;
  final Brightness brightness;

  const AppThemeData({
    required this.name,
    required this.primary,
    required this.background,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.notePaper,
    required this.toolbarBg,
    required this.divider,
    required this.accent,
    this.brightness = Brightness.light,
  });
}

/// 폰트 데이터
class AppFontData {
  final String name;
  final String googleFontName;

  const AppFontData({
    required this.name,
    required this.googleFontName,
  });
}

// 테마 목록
const themeDataMap = {
  AppThemeType.warm: AppThemeData(
    name: '따뜻한 브라운',
    primary: Color(0xFFD4A574),
    background: Color(0xFFFAF5EF),
    surface: Color(0xFFFFF8F0),
    textPrimary: Color(0xFF3C2F1E),
    textSecondary: Color(0xFF7A6B5D),
    notePaper: Color(0xFFFFFEF5),
    toolbarBg: Color(0xFFF5EDE3),
    divider: Color(0xFFE0D5C8),
    accent: Color(0xFFE8A87C),
  ),
  AppThemeType.cherry: AppThemeData(
    name: '체리블로썸',
    primary: Color(0xFFE8829A),
    background: Color(0xFFFFF5F7),
    surface: Color(0xFFFFF0F3),
    textPrimary: Color(0xFF4A2832),
    textSecondary: Color(0xFF8A6070),
    notePaper: Color(0xFFFFF8F9),
    toolbarBg: Color(0xFFFEE8ED),
    divider: Color(0xFFF0D0D8),
    accent: Color(0xFFF4A4B8),
  ),
  AppThemeType.ocean: AppThemeData(
    name: '오션 블루',
    primary: Color(0xFF5B9BD5),
    background: Color(0xFFF0F5FA),
    surface: Color(0xFFF5F8FD),
    textPrimary: Color(0xFF1E3248),
    textSecondary: Color(0xFF5A7088),
    notePaper: Color(0xFFF8FAFF),
    toolbarBg: Color(0xFFE3EDF5),
    divider: Color(0xFFD0DCE8),
    accent: Color(0xFF7EB4D8),
  ),
  AppThemeType.forest: AppThemeData(
    name: '포레스트',
    primary: Color(0xFF6BA87A),
    background: Color(0xFFF2F8F4),
    surface: Color(0xFFF5FAF7),
    textPrimary: Color(0xFF1E3825),
    textSecondary: Color(0xFF5A7862),
    notePaper: Color(0xFFF8FDF9),
    toolbarBg: Color(0xFFE3F0E7),
    divider: Color(0xFFCCDDD0),
    accent: Color(0xFF95C4A1),
  ),
  AppThemeType.lavender: AppThemeData(
    name: '라벤더',
    primary: Color(0xFF9B8EC0),
    background: Color(0xFFF5F2FA),
    surface: Color(0xFFF8F5FD),
    textPrimary: Color(0xFF2E2542),
    textSecondary: Color(0xFF6E5F88),
    notePaper: Color(0xFFFAF8FF),
    toolbarBg: Color(0xFFEBE5F5),
    divider: Color(0xFFD8D0E5),
    accent: Color(0xFFB8A8D8),
  ),
  AppThemeType.midnight: AppThemeData(
    name: '미드나이트',
    primary: Color(0xFF8B7FD4),
    background: Color(0xFF1A1828),
    surface: Color(0xFF252336),
    textPrimary: Color(0xFFE8E4F0),
    textSecondary: Color(0xFFA098B8),
    notePaper: Color(0xFF2A2840),
    toolbarBg: Color(0xFF201E30),
    divider: Color(0xFF3A3850),
    accent: Color(0xFFB8A8D8),
    brightness: Brightness.dark,
  ),
};

// 폰트 목록
const fontDataMap = {
  AppFontType.nanumPen: AppFontData(
    name: '나눔 손글씨 펜',
    googleFontName: 'Nanum Pen Script',
  ),
  AppFontType.gaegu: AppFontData(
    name: '개구',
    googleFontName: 'Gaegu',
  ),
  AppFontType.poorStory: AppFontData(
    name: '푸어스토리',
    googleFontName: 'Poor Story',
  ),
  AppFontType.gamja: AppFontData(
    name: '감자꽃마을',
    googleFontName: 'Gamja Flower',
  ),
  AppFontType.dokdo: AppFontData(
    name: '독도',
    googleFontName: 'Dokdo',
  ),
  AppFontType.singleDay: AppFontData(
    name: '싱글데이',
    googleFontName: 'Single Day',
  ),
  AppFontType.eastSeaDokdo: AppFontData(
    name: '동해독도',
    googleFontName: 'East Sea Dokdo',
  ),
  AppFontType.gothicA1: AppFontData(
    name: '고딕 A1',
    googleFontName: 'Gothic A1',
  ),
};

// Riverpod providers
final appThemeTypeProvider =
    StateProvider<AppThemeType>((ref) => AppThemeType.warm);

final appFontTypeProvider =
    StateProvider<AppFontType>((ref) => AppFontType.nanumPen);

// Derived providers
final currentThemeDataProvider = Provider<AppThemeData>((ref) {
  final type = ref.watch(appThemeTypeProvider);
  return themeDataMap[type]!;
});

final currentFontDataProvider = Provider<AppFontData>((ref) {
  final type = ref.watch(appFontTypeProvider);
  return fontDataMap[type]!;
});
