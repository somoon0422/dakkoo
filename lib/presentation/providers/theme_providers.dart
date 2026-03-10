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
  // 손글씨
  gowunBatang,
  nanumPen,
  nanumBrush,
  gaegu,
  poorStory,
  gamja,
  singleDay,
  hiMelody,
  cuteFont,
  yeongdeok,

  // 명조
  notoSerifKr,
  nanumMyeongjo,
  songMyung,

  // 고딕
  gowunDodum,
  gothicA1,
  notoSansKr,
  ibmPlexSansKr,
  nanumGothic,
  sunflower,

  // 디스플레이
  dokdo,
  eastSeaDokdo,
  doHyeon,
  jua,
  blackHanSans,
  gugi,
  stylish,
  yeonSung,
  kirangHaerang,
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
  final String category; // 손글씨, 고딕, 명조, 디스플레이

  const AppFontData({
    required this.name,
    required this.googleFontName,
    required this.category,
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

// 폰트 목록 — 카테고리별 정리 (28개)
const fontDataMap = {
  // ── 손글씨 ──
  AppFontType.gowunBatang: AppFontData(
    name: '고운 바탕',
    googleFontName: 'Gowun Batang',
    category: '손글씨',
  ),
  AppFontType.nanumPen: AppFontData(
    name: '나눔 손글씨 펜',
    googleFontName: 'Nanum Pen Script',
    category: '손글씨',
  ),
  AppFontType.nanumBrush: AppFontData(
    name: '나눔 붓글씨',
    googleFontName: 'Nanum Brush Script',
    category: '손글씨',
  ),
  AppFontType.gaegu: AppFontData(
    name: '개구',
    googleFontName: 'Gaegu',
    category: '손글씨',
  ),
  AppFontType.poorStory: AppFontData(
    name: '푸어스토리',
    googleFontName: 'Poor Story',
    category: '손글씨',
  ),
  AppFontType.gamja: AppFontData(
    name: '감자꽃마을',
    googleFontName: 'Gamja Flower',
    category: '손글씨',
  ),
  AppFontType.singleDay: AppFontData(
    name: '싱글데이',
    googleFontName: 'Single Day',
    category: '손글씨',
  ),
  AppFontType.hiMelody: AppFontData(
    name: '하이멜로디',
    googleFontName: 'Hi Melody',
    category: '손글씨',
  ),
  AppFontType.cuteFont: AppFontData(
    name: '큐트폰트',
    googleFontName: 'Cute Font',
    category: '손글씨',
  ),
  AppFontType.yeongdeok: AppFontData(
    name: '연성',
    googleFontName: 'Yeon Sung',
    category: '손글씨',
  ),

  // ── 명조 ──
  AppFontType.notoSerifKr: AppFontData(
    name: 'Noto Serif KR',
    googleFontName: 'Noto Serif KR',
    category: '명조',
  ),
  AppFontType.nanumMyeongjo: AppFontData(
    name: '나눔 명조',
    googleFontName: 'Nanum Myeongjo',
    category: '명조',
  ),
  AppFontType.songMyung: AppFontData(
    name: '송명',
    googleFontName: 'Song Myung',
    category: '명조',
  ),

  // ── 고딕 ──
  AppFontType.gowunDodum: AppFontData(
    name: '고운 돋움',
    googleFontName: 'Gowun Dodum',
    category: '고딕',
  ),
  AppFontType.gothicA1: AppFontData(
    name: '고딕 A1',
    googleFontName: 'Gothic A1',
    category: '고딕',
  ),
  AppFontType.notoSansKr: AppFontData(
    name: 'Noto Sans KR',
    googleFontName: 'Noto Sans KR',
    category: '고딕',
  ),
  AppFontType.ibmPlexSansKr: AppFontData(
    name: 'IBM Plex Sans KR',
    googleFontName: 'IBM Plex Sans KR',
    category: '고딕',
  ),
  AppFontType.nanumGothic: AppFontData(
    name: '나눔 고딕',
    googleFontName: 'Nanum Gothic',
    category: '고딕',
  ),
  AppFontType.sunflower: AppFontData(
    name: '해바라기',
    googleFontName: 'Sunflower',
    category: '고딕',
  ),

  // ── 디스플레이 / 개성 ──
  AppFontType.dokdo: AppFontData(
    name: '독도',
    googleFontName: 'Dokdo',
    category: '디스플레이',
  ),
  AppFontType.eastSeaDokdo: AppFontData(
    name: '동해독도',
    googleFontName: 'East Sea Dokdo',
    category: '디스플레이',
  ),
  AppFontType.doHyeon: AppFontData(
    name: '도현',
    googleFontName: 'Do Hyeon',
    category: '디스플레이',
  ),
  AppFontType.jua: AppFontData(
    name: '주아',
    googleFontName: 'Jua',
    category: '디스플레이',
  ),
  AppFontType.blackHanSans: AppFontData(
    name: '블랙한산스',
    googleFontName: 'Black Han Sans',
    category: '디스플레이',
  ),
  AppFontType.gugi: AppFontData(
    name: '구기',
    googleFontName: 'Gugi',
    category: '디스플레이',
  ),
  AppFontType.stylish: AppFontData(
    name: '스타일리시',
    googleFontName: 'Stylish',
    category: '디스플레이',
  ),
  AppFontType.yeonSung: AppFontData(
    name: '연성체',
    googleFontName: 'Yeon Sung',
    category: '디스플레이',
  ),
  AppFontType.kirangHaerang: AppFontData(
    name: '기랑해랑',
    googleFontName: 'Kirang Haerang',
    category: '디스플레이',
  ),
};

// Riverpod providers
final appThemeTypeProvider =
    StateProvider<AppThemeType>((ref) => AppThemeType.warm);

final appFontTypeProvider =
    StateProvider<AppFontType>((ref) => AppFontType.gowunBatang);

// Derived providers
final currentThemeDataProvider = Provider<AppThemeData>((ref) {
  final type = ref.watch(appThemeTypeProvider);
  return themeDataMap[type]!;
});

final currentFontDataProvider = Provider<AppFontData>((ref) {
  final type = ref.watch(appFontTypeProvider);
  return fontDataMap[type]!;
});
