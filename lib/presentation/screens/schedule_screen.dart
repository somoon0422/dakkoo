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
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String _selectedEmoji = '📅';
  String _selectedColor = '#FF6B6B';

  static const _emojiOptions = [
    '📅', '🎂', '💼', '🏃', '📚', '✈️', '🍽️', '💊',
    '🎵', '🛒', '💰', '📞', '🎮', '🎬', '💇', '🏥',
    '🐾', '🌸', '☕', '🎁', '💌', '🧹', '👶', '💪',
  ];

  static const _colorOptions = [
    '#FF6B6B', '#FF9FF3', '#FECA57', '#48DBFB', '#54A0FF',
    '#5CD85A', '#C39BD3', '#F8A5C2', '#F7D794', '#778BEB',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeData = ref.watch(currentThemeDataProvider);
    final fontData = ref.watch(currentFontDataProvider);
    final dateStr = DateFormat('M월 d일 EEEE', 'ko_KR').format(widget.date);
    final dbDateStr = DateFormat('yyyy-MM-dd').format(widget.date);

    // Watch schedules for this date
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dateStr,
                        style: getAppFont(
                            fontData.googleFontName, 18, themeData.textPrimary),
                      ),
                      Text(
                        '일정 관리',
                        style: getAppFont(fontData.googleFontName, 12,
                            themeData.textSecondary),
                      ),
                    ],
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
                    // Existing schedules
                    if (dateSchedules.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      ...dateSchedules.map(
                          (s) => _buildScheduleCard(s, themeData, fontData)),
                      const SizedBox(height: 16),
                    ],

                    // New schedule input card
                    _buildNewScheduleCard(themeData, fontData, dbDateStr),
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

  Widget _buildScheduleCard(Map<String, dynamic> schedule,
      AppThemeData themeData, AppFontData fontData) {
    final isDone = (schedule['is_done'] as int?) == 1;
    final color = _parseColor(schedule['color'] as String? ?? '#FF6B6B');

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: themeData.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border(
            left: BorderSide(color: color, width: 4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Toggle done
            Pressable(
              onTap: () async {
                final updated = Map<String, dynamic>.from(schedule);
                updated['is_done'] = isDone ? 0 : 1;
                final db = ref.read(localDatabaseProvider);
                await db.updateSchedule(updated);
                ref.invalidate(allSchedulesProvider);
              },
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: isDone ? color : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 2),
                ),
                child: isDone
                    ? const Icon(Icons.check_rounded,
                        size: 16, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Text(schedule['emoji'] as String? ?? '📅',
                style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    schedule['title'] as String? ?? '',
                    style: getAppFont(
                      fontData.googleFontName,
                      15,
                      isDone
                          ? themeData.textSecondary
                          : themeData.textPrimary,
                    ),
                  ),
                  if ((schedule['description'] as String?)?.isNotEmpty ?? false)
                    Text(
                      schedule['description'] as String,
                      style: getAppFont(fontData.googleFontName, 12,
                          themeData.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            // Delete
            Pressable(
              onTap: () async {
                final db = ref.read(localDatabaseProvider);
                await db.deleteSchedule(schedule['id'] as String);
                ref.invalidate(allSchedulesProvider);
              },
              child: Icon(Icons.close_rounded,
                  size: 18, color: themeData.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewScheduleCard(
      AppThemeData themeData, AppFontData fontData, String dbDateStr) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeData.surface,
        borderRadius: BorderRadius.circular(18),
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
            '새 일정 추가',
            style: getAppFont(fontData.googleFontName, 16, themeData.textPrimary),
          ),
          const SizedBox(height: 16),

          // Emoji picker
          Text('아이콘',
              style: getAppFont(
                  fontData.googleFontName, 12, themeData.textSecondary)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _emojiOptions.map((emoji) {
              final isSelected = emoji == _selectedEmoji;
              return Pressable(
                onTap: () => setState(() => _selectedEmoji = emoji),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? themeData.primary.withValues(alpha: 0.1)
                        : themeData.background,
                    borderRadius: BorderRadius.circular(10),
                    border: isSelected
                        ? Border.all(color: themeData.primary, width: 1.5)
                        : null,
                  ),
                  child: Center(
                      child: Text(emoji,
                          style: const TextStyle(fontSize: 20))),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Color picker
          Text('색상',
              style: getAppFont(
                  fontData.googleFontName, 12, themeData.textSecondary)),
          const SizedBox(height: 8),
          Row(
            children: _colorOptions.map((c) {
              final isSelected = c == _selectedColor;
              final color = _parseColor(c);
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Pressable(
                  onTap: () => setState(() => _selectedColor = c),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: themeData.textPrimary, width: 2.5)
                          : Border.all(
                              color: Colors.black.withValues(alpha: 0.1)),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Title input
          TextField(
            controller: _titleController,
            style: getAppFont(
                fontData.googleFontName, 16, themeData.textPrimary),
            decoration: InputDecoration(
              hintText: '일정을 입력하세요',
              hintStyle: getAppFont(fontData.googleFontName, 16,
                  themeData.textSecondary.withValues(alpha: 0.5)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: themeData.divider),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: themeData.divider),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: themeData.primary),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
          const SizedBox(height: 10),

          // Description
          TextField(
            controller: _descController,
            maxLines: 2,
            style: getAppFont(
                fontData.googleFontName, 14, themeData.textSecondary),
            decoration: InputDecoration(
              hintText: '메모 (선택)',
              hintStyle: getAppFont(fontData.googleFontName, 14,
                  themeData.textSecondary.withValues(alpha: 0.4)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: themeData.divider),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: themeData.divider),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: themeData.primary),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
          const SizedBox(height: 16),

          // Add button
          SizedBox(
            width: double.infinity,
            child: Pressable(
              onTap: () => _addSchedule(dbDateStr),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: _parseColor(_selectedColor),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    '일정 추가 ✨',
                    style: getAppFont(fontData.googleFontName, 15, Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addSchedule(String dbDateStr) async {
    if (_titleController.text.trim().isEmpty) return;

    final db = ref.read(localDatabaseProvider);
    await db.insertSchedule({
      'id': const Uuid().v4(),
      'date': dbDateStr,
      'title': _titleController.text.trim(),
      'description': _descController.text.trim(),
      'emoji': _selectedEmoji,
      'color': _selectedColor,
      'is_done': 0,
      'created_at': DateTime.now().toIso8601String(),
    });

    _titleController.clear();
    _descController.clear();
    ref.invalidate(allSchedulesProvider);
    setState(() {});
  }

  Color _parseColor(String hex) {
    final h = hex.replaceAll('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }
}
