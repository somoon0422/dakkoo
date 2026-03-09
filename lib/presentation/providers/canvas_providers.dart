import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/diary_element.dart';
import '../../domain/entities/diary_page.dart';
import 'diary_providers.dart';

const _uuid = Uuid();

// Current page being edited
final currentPageProvider = StateProvider<DiaryPage?>((ref) => null);

// Elements for the current page
final pageElementsProvider =
    StateNotifierProvider<PageElementsNotifier, List<DiaryElement>>((ref) {
  return PageElementsNotifier(ref);
});

// Currently selected element
final selectedElementIdProvider = StateProvider<String?>((ref) => null);

// Drawing mode
final isDrawingModeProvider = StateProvider<bool>((ref) => false);

// Drawing color
final drawingColorProvider = StateProvider<Color>((ref) => Colors.black);

// Drawing stroke width
final drawingStrokeWidthProvider = StateProvider<double>((ref) => 3.0);

// Current drawing points (while actively drawing)
final currentDrawingPointsProvider =
    StateProvider<List<Map<String, dynamic>>>((ref) => []);

// Text font selection
final selectedFontProvider = StateProvider<String>((ref) => 'Nanum Pen Script');

class PageElementsNotifier extends StateNotifier<List<DiaryElement>> {
  final Ref _ref;

  PageElementsNotifier(this._ref) : super([]);

  Future<void> loadElements(String pageId) async {
    final repo = _ref.read(diaryRepositoryProvider);
    final elements = await repo.getElementsByPageId(pageId);
    state = elements;
  }

  Future<void> addTextElement(String pageId) async {
    final repo = _ref.read(diaryRepositoryProvider);
    final font = _ref.read(selectedFontProvider);
    final element = DiaryElement(
      id: _uuid.v4(),
      pageId: pageId,
      type: ElementType.text,
      x: 50,
      y: 100,
      width: 200,
      height: 80,
      content: jsonEncode({
        'text': '여기에 글을 쓰세요',
        'font': font,
        'fontSize': 20.0,
        'color': Colors.black.toARGB32(),
      }),
      zIndex: state.length,
      createdAt: DateTime.now(),
    );
    await repo.addElement(element);
    state = [...state, element];
  }

  Future<void> addImageElement(String pageId, String imagePath) async {
    final repo = _ref.read(diaryRepositoryProvider);
    final element = DiaryElement(
      id: _uuid.v4(),
      pageId: pageId,
      type: ElementType.image,
      x: 50,
      y: 100,
      width: 200,
      height: 200,
      content: imagePath,
      zIndex: state.length,
      createdAt: DateTime.now(),
    );
    await repo.addElement(element);
    state = [...state, element];
  }

  Future<void> addStickerElement(String pageId, String emoji) async {
    final repo = _ref.read(diaryRepositoryProvider);
    final element = DiaryElement(
      id: _uuid.v4(),
      pageId: pageId,
      type: ElementType.sticker,
      x: 100,
      y: 200,
      width: 80,
      height: 80,
      content: emoji,
      zIndex: state.length,
      createdAt: DateTime.now(),
    );
    await repo.addElement(element);
    state = [...state, element];
  }

  Future<void> addDrawingElement(
    String pageId,
    List<Map<String, dynamic>> points,
    Color color,
    double strokeWidth,
  ) async {
    if (points.isEmpty) return;

    final repo = _ref.read(diaryRepositoryProvider);

    // Calculate bounds
    double minX = double.infinity, minY = double.infinity;
    double maxX = double.negativeInfinity, maxY = double.negativeInfinity;
    for (final p in points) {
      final x = (p['x'] as num).toDouble();
      final y = (p['y'] as num).toDouble();
      if (x < minX) minX = x;
      if (y < minY) minY = y;
      if (x > maxX) maxX = x;
      if (y > maxY) maxY = y;
    }

    final padding = strokeWidth * 2;
    final element = DiaryElement(
      id: _uuid.v4(),
      pageId: pageId,
      type: ElementType.drawing,
      x: minX - padding,
      y: minY - padding,
      width: (maxX - minX) + padding * 2,
      height: (maxY - minY) + padding * 2,
      content: jsonEncode({
        'points': points
            .map((p) => {
                  'x': (p['x'] as num).toDouble() - minX + padding,
                  'y': (p['y'] as num).toDouble() - minY + padding,
                  'pressure': p['pressure'] ?? 0.5,
                })
            .toList(),
        'color': color.toARGB32(),
        'strokeWidth': strokeWidth,
      }),
      zIndex: state.length,
      createdAt: DateTime.now(),
    );
    await repo.addElement(element);
    state = [...state, element];
  }

  Future<void> updateElementPosition(
    String elementId,
    double dx,
    double dy,
  ) async {
    final index = state.indexWhere((e) => e.id == elementId);
    if (index == -1) return;

    final element = state[index];
    final updated = element.copyWith(
      x: element.x + dx,
      y: element.y + dy,
    );

    final repo = _ref.read(diaryRepositoryProvider);
    await repo.updateElement(updated);
    state = [
      ...state.sublist(0, index),
      updated,
      ...state.sublist(index + 1),
    ];
  }

  Future<void> updateElementSize(
    String elementId,
    double width,
    double height,
  ) async {
    final index = state.indexWhere((e) => e.id == elementId);
    if (index == -1) return;

    final element = state[index];
    final updated = element.copyWith(
      width: width.clamp(30.0, 2000.0),
      height: height.clamp(30.0, 2000.0),
    );

    final repo = _ref.read(diaryRepositoryProvider);
    await repo.updateElement(updated);
    state = [
      ...state.sublist(0, index),
      updated,
      ...state.sublist(index + 1),
    ];
  }

  Future<void> updateElementRotation(
    String elementId,
    double rotation,
  ) async {
    final index = state.indexWhere((e) => e.id == elementId);
    if (index == -1) return;

    final element = state[index];
    final updated = element.copyWith(rotation: rotation);

    final repo = _ref.read(diaryRepositoryProvider);
    await repo.updateElement(updated);
    state = [
      ...state.sublist(0, index),
      updated,
      ...state.sublist(index + 1),
    ];
  }

  Future<void> updateElementContent(
    String elementId,
    String content,
  ) async {
    final index = state.indexWhere((e) => e.id == elementId);
    if (index == -1) return;

    final element = state[index];
    final updated = element.copyWith(content: content);

    final repo = _ref.read(diaryRepositoryProvider);
    await repo.updateElement(updated);
    state = [
      ...state.sublist(0, index),
      updated,
      ...state.sublist(index + 1),
    ];
  }

  Future<void> deleteElement(String elementId) async {
    final repo = _ref.read(diaryRepositoryProvider);
    await repo.deleteElement(elementId);
    state = state.where((e) => e.id != elementId).toList();
  }

  Future<void> bringToFront(String elementId) async {
    final index = state.indexWhere((e) => e.id == elementId);
    if (index == -1) return;

    final maxZ = state.fold<int>(0, (max, e) => e.zIndex > max ? e.zIndex : max);
    final element = state[index];
    final updated = element.copyWith(zIndex: maxZ + 1);

    final repo = _ref.read(diaryRepositoryProvider);
    await repo.updateElement(updated);
    state = [
      ...state.sublist(0, index),
      updated,
      ...state.sublist(index + 1),
    ];
  }
}
