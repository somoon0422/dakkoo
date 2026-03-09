import '../../domain/entities/diary_page.dart';

class DiaryPageModel {
  final String id;
  final String date;
  final String backgroundType;
  final String createdAt;
  final String updatedAt;

  const DiaryPageModel({
    required this.id,
    required this.date,
    required this.backgroundType,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DiaryPageModel.fromEntity(DiaryPage entity) {
    return DiaryPageModel(
      id: entity.id,
      date: entity.date.toIso8601String().split('T').first,
      backgroundType: entity.backgroundType.name,
      createdAt: entity.createdAt.toIso8601String(),
      updatedAt: entity.updatedAt.toIso8601String(),
    );
  }

  factory DiaryPageModel.fromMap(Map<String, dynamic> map) {
    return DiaryPageModel(
      id: map['id'] as String,
      date: map['date'] as String,
      backgroundType: map['background_type'] as String,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'background_type': backgroundType,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  DiaryPage toEntity() {
    return DiaryPage(
      id: id,
      date: DateTime.parse(date),
      backgroundType: BackgroundType.values.firstWhere(
        (e) => e.name == backgroundType,
        orElse: () => BackgroundType.notePaper,
      ),
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
    );
  }
}
