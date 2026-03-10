class Schedule {
  final String id;
  final DateTime date;
  final String title;
  final String? description;
  final String emoji; // 카테고리 이모지 (📅, 🎂, 💼 등)
  final String color; // hex color string
  final bool isDone;
  final DateTime createdAt;

  const Schedule({
    required this.id,
    required this.date,
    required this.title,
    this.description,
    this.emoji = '📅',
    this.color = '#FF6B6B',
    this.isDone = false,
    required this.createdAt,
  });

  Schedule copyWith({
    String? id,
    DateTime? date,
    String? title,
    String? description,
    String? emoji,
    String? color,
    bool? isDone,
    DateTime? createdAt,
  }) {
    return Schedule(
      id: id ?? this.id,
      date: date ?? this.date,
      title: title ?? this.title,
      description: description ?? this.description,
      emoji: emoji ?? this.emoji,
      color: color ?? this.color,
      isDone: isDone ?? this.isDone,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
