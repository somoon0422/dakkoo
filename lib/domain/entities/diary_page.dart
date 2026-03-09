enum BackgroundType {
  notePaper,
  kraftPaper,
  vintagePaper,
  blank,
}

class DiaryPage {
  final String id;
  final DateTime date;
  final BackgroundType backgroundType;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DiaryPage({
    required this.id,
    required this.date,
    this.backgroundType = BackgroundType.notePaper,
    required this.createdAt,
    required this.updatedAt,
  });

  DiaryPage copyWith({
    String? id,
    DateTime? date,
    BackgroundType? backgroundType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DiaryPage(
      id: id ?? this.id,
      date: date ?? this.date,
      backgroundType: backgroundType ?? this.backgroundType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
