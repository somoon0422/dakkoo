import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../app.dart';
import '../providers/diary_providers.dart';
import '../providers/theme_providers.dart';
import '../widgets/common/pressable.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  final DateTime date;

  const ScheduleScreen({super.key, required this.date});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  final _newItemController = TextEditingController();
  final _newItemFocus = FocusNode();
  bool _isAddingNew = false;
  String _newItemEmoji = '';

  // Quick emoji options for schedule items
  static const _quickEmojis = [
    '📅', '💼', '🎂', '🏃', '📚', '✈️', '🍽️', '💊',
    '🎵', '🛒', '☕', '📞', '🎁', '💌', '🧹', '💪',
  ];

  @override
  void dispose() {
    _newItemController.dispose();
    _newItemFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeData = ref.watch(currentThemeDataProvider);
    final fontData = ref.watch(currentFontDataProvider);
    final dateStr = DateFormat('M월 d일 EEEE', 'ko_KR').format(widget.date);
    final dbDateStr = DateFormat('yyyy-MM-dd').format(widget.date);

    final schedulesAsync = ref.watch(allSchedulesProvider);
    final dateSchedules = schedulesAsync.when(
      data: (map) => map[dbDateStr] ?? [],
      loading: () => <Map<String, dynamic>>[],
      error: (_, _) => <Map<String, dynamic>>[],
    );

    return Scaffold(
      backgroundColor: themeData.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Pressable(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: themeData.surface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.arrow_back_ios_new_rounded,
                          size: 18, color: themeData.textPrimary),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      dateStr,
                      style: getAppFont(
                          fontData.googleFontName, 18, themeData.textPrimary),
                    ),
                  ),
                ],
              ),
            ),

            // Schedule list
            Expanded(
              child: GestureDetector(
                onTap: () {
                  // Tap empty area to start adding
                  if (!_isAddingNew) {
                    setState(() => _isAddingNew = true);
                    Future.delayed(const Duration(milliseconds: 100), () {
                      _newItemFocus.requestFocus();
                    });
                  }
                },
                behavior: HitTestBehavior.opaque,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    const SizedBox(height: 8),

                    // Existing items
                    ...dateSchedules.map(
                        (s) => _ScheduleItem(
                          schedule: s,
                          themeData: themeData,
                          fontData: fontData,
                          quickEmojis: _quickEmojis,
                          onToggle: () => _toggleDone(s),
                          onDelete: () => _deleteSchedule(s),
                          onEmojiChanged: (emoji) => _updateEmoji(s, emoji),
                          onTitleChanged: (title) => _updateTitle(s, title),
                        ),
                    ),

                    // New item input
                    if (_isAddingNew)
                      _buildNewItemInput(themeData, fontData, dbDateStr),

                    // Add button
                    if (!_isAddingNew)
                      Padding(
                        padding: const EdgeInsets.only(top: 4, bottom: 8),
                        child: Pressable(
                          onTap: () {
                            setState(() => _isAddingNew = true);
                            Future.delayed(const Duration(milliseconds: 100), () {
                              _newItemFocus.requestFocus();
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: themeData.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: themeData.divider,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.add_rounded,
                                    size: 20,
                                    color: themeData.textSecondary
                                        .withValues(alpha: 0.5)),
                                const SizedBox(width: 10),
                                Text(
                                  '터치해서 일정 추가',
                                  style: getAppFont(
                                    fontData.googleFontName,
                                    14,
                                    themeData.textSecondary
                                        .withValues(alpha: 0.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    // Empty state
                    if (dateSchedules.isEmpty && !_isAddingNew)
                      Padding(
                        padding: const EdgeInsets.only(top: 60),
                        child: Column(
                          children: [
                            const Text('📋',
                                style: TextStyle(fontSize: 48)),
                            const SizedBox(height: 12),
                            Text(
                              '아직 일정이 없어요',
                              style: getAppFont(fontData.googleFontName, 16,
                                  themeData.textSecondary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '화면을 터치하면 바로 일정을 추가할 수 있어요',
                              style: getAppFont(fontData.googleFontName, 12,
                                  themeData.textSecondary.withValues(alpha: 0.6)),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewItemInput(
      AppThemeData themeData, AppFontData fontData, String dbDateStr) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: themeData.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: themeData.primary, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: themeData.primary.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text input row
            Row(
              children: [
                // Selected emoji or default
                Pressable(
                  onTap: () => _showEmojiRow(),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: themeData.background,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        _newItemEmoji.isEmpty ? '✏️' : _newItemEmoji,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _newItemController,
                    focusNode: _newItemFocus,
                    style: getAppFont(
                        fontData.googleFontName, 15, themeData.textPrimary),
                    decoration: InputDecoration(
                      hintText: '일정을 입력하세요',
                      hintStyle: getAppFont(fontData.googleFontName, 15,
                          themeData.textSecondary.withValues(alpha: 0.4)),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _saveNewItem(dbDateStr),
                  ),
                ),
                // Save button
                Pressable(
                  onTap: () => _saveNewItem(dbDateStr),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: themeData.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '저장',
                      style:
                          getAppFont(fontData.googleFontName, 13, Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Quick emoji row
            SizedBox(
              height: 32,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _quickEmojis.length,
                itemBuilder: (context, index) {
                  final emoji = _quickEmojis[index];
                  final isSelected = emoji == _newItemEmoji;
                  return Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Pressable(
                      onTap: () {
                        setState(() {
                          _newItemEmoji = isSelected ? '' : emoji;
                        });
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? themeData.primary.withValues(alpha: 0.12)
                              : themeData.background,
                          borderRadius: BorderRadius.circular(8),
                          border: isSelected
                              ? Border.all(
                                  color: themeData.primary, width: 1.5)
                              : null,
                        ),
                        child: Center(
                          child: Text(emoji,
                              style: const TextStyle(fontSize: 16)),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEmojiRow() {
    // Already showing inline, no separate dialog needed
  }

  Future<void> _saveNewItem(String dbDateStr) async {
    final text = _newItemController.text.trim();
    if (text.isEmpty) {
      setState(() => _isAddingNew = false);
      return;
    }

    final db = ref.read(localDatabaseProvider);
    await db.insertSchedule({
      'id': const Uuid().v4(),
      'date': dbDateStr,
      'title': text,
      'description': '',
      'emoji': _newItemEmoji.isEmpty ? '📅' : _newItemEmoji,
      'color': '#FF6B6B',
      'is_done': 0,
      'created_at': DateTime.now().toIso8601String(),
    });

    _newItemController.clear();
    _newItemEmoji = '';
    ref.invalidate(allSchedulesProvider);

    // Keep input open for adding more items
    setState(() {});
    _newItemFocus.requestFocus();
  }

  Future<void> _toggleDone(Map<String, dynamic> schedule) async {
    final isDone = (schedule['is_done'] as int?) == 1;
    final updated = Map<String, dynamic>.from(schedule);
    updated['is_done'] = isDone ? 0 : 1;
    final db = ref.read(localDatabaseProvider);
    await db.updateSchedule(updated);
    ref.invalidate(allSchedulesProvider);
  }

  Future<void> _deleteSchedule(Map<String, dynamic> schedule) async {
    final db = ref.read(localDatabaseProvider);
    await db.deleteSchedule(schedule['id'] as String);
    ref.invalidate(allSchedulesProvider);
  }

  Future<void> _updateEmoji(
      Map<String, dynamic> schedule, String emoji) async {
    final updated = Map<String, dynamic>.from(schedule);
    updated['emoji'] = emoji;
    final db = ref.read(localDatabaseProvider);
    await db.updateSchedule(updated);
    ref.invalidate(allSchedulesProvider);
  }

  Future<void> _updateTitle(
      Map<String, dynamic> schedule, String title) async {
    if (title.trim().isEmpty) return;
    final updated = Map<String, dynamic>.from(schedule);
    updated['title'] = title.trim();
    final db = ref.read(localDatabaseProvider);
    await db.updateSchedule(updated);
    ref.invalidate(allSchedulesProvider);
  }
}

/// Individual schedule item — inline editable
class _ScheduleItem extends StatefulWidget {
  final Map<String, dynamic> schedule;
  final AppThemeData themeData;
  final AppFontData fontData;
  final List<String> quickEmojis;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final Function(String) onEmojiChanged;
  final Function(String) onTitleChanged;

  const _ScheduleItem({
    required this.schedule,
    required this.themeData,
    required this.fontData,
    required this.quickEmojis,
    required this.onToggle,
    required this.onDelete,
    required this.onEmojiChanged,
    required this.onTitleChanged,
  });

  @override
  State<_ScheduleItem> createState() => _ScheduleItemState();
}

class _ScheduleItemState extends State<_ScheduleItem> {
  bool _isEditing = false;
  bool _showEmojiPicker = false;
  late TextEditingController _editController;

  @override
  void initState() {
    super.initState();
    _editController = TextEditingController(
        text: widget.schedule['title'] as String? ?? '');
  }

  @override
  void didUpdateWidget(covariant _ScheduleItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.schedule['title'] != widget.schedule['title']) {
      _editController.text = widget.schedule['title'] as String? ?? '';
    }
  }

  @override
  void dispose() {
    _editController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDone = (widget.schedule['is_done'] as int?) == 1;
    final emoji = widget.schedule['emoji'] as String? ?? '📅';
    final themeData = widget.themeData;
    final fontData = widget.fontData;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Dismissible(
        key: Key(widget.schedule['id'] as String),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => widget.onDelete(),
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(Icons.delete_outline_rounded,
              color: Colors.red.withValues(alpha: 0.7)),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: themeData.surface,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  // Checkbox
                  Pressable(
                    onTap: widget.onToggle,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isDone
                            ? themeData.primary.withValues(alpha: 0.8)
                            : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDone
                              ? themeData.primary
                              : themeData.textSecondary.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: isDone
                          ? const Icon(Icons.check_rounded,
                              size: 14, color: Colors.white)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Emoji (tappable)
                  Pressable(
                    onTap: () {
                      setState(() => _showEmojiPicker = !_showEmojiPicker);
                    },
                    child: Text(emoji, style: const TextStyle(fontSize: 20)),
                  ),
                  const SizedBox(width: 10),
                  // Title (tap to edit)
                  Expanded(
                    child: _isEditing
                        ? TextField(
                            controller: _editController,
                            autofocus: true,
                            style: getAppFont(
                              fontData.googleFontName,
                              15,
                              themeData.textPrimary,
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                              hintText: '일정 입력',
                              hintStyle: getAppFont(
                                fontData.googleFontName,
                                15,
                                themeData.textSecondary
                                    .withValues(alpha: 0.4),
                              ),
                            ),
                            onSubmitted: (val) {
                              widget.onTitleChanged(val);
                              setState(() => _isEditing = false);
                            },
                            onTapOutside: (_) {
                              widget
                                  .onTitleChanged(_editController.text);
                              setState(() => _isEditing = false);
                            },
                          )
                        : GestureDetector(
                            onTap: () =>
                                setState(() => _isEditing = true),
                            child: Text(
                              widget.schedule['title'] as String? ?? '',
                              style: getAppFont(
                                fontData.googleFontName,
                                15,
                                isDone
                                    ? themeData.textSecondary
                                    : themeData.textPrimary,
                              ).copyWith(
                                decoration: isDone
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                          ),
                  ),
                  // Swipe hint or delete
                  Pressable(
                    onTap: widget.onDelete,
                    child: Icon(Icons.close_rounded,
                        size: 16,
                        color:
                            themeData.textSecondary.withValues(alpha: 0.4)),
                  ),
                ],
              ),
              // Inline emoji picker
              if (_showEmojiPicker)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: SizedBox(
                    height: 34,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.quickEmojis.length,
                      itemBuilder: (context, index) {
                        final e = widget.quickEmojis[index];
                        final isSel = e == emoji;
                        return Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Pressable(
                            onTap: () {
                              widget.onEmojiChanged(e);
                              setState(() => _showEmojiPicker = false);
                            },
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: isSel
                                    ? themeData.primary
                                        .withValues(alpha: 0.12)
                                    : themeData.background,
                                borderRadius: BorderRadius.circular(8),
                                border: isSel
                                    ? Border.all(
                                        color: themeData.primary,
                                        width: 1.5)
                                    : null,
                              ),
                              child: Center(
                                child: Text(e,
                                    style: const TextStyle(fontSize: 18)),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
