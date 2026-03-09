import '../../domain/entities/diary_element.dart';

class ElementModel {
  final String id;
  final String pageId;
  final String type;
  final double x;
  final double y;
  final double width;
  final double height;
  final double rotation;
  final String content;
  final int zIndex;
  final String createdAt;

  const ElementModel({
    required this.id,
    required this.pageId,
    required this.type,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.rotation,
    required this.content,
    required this.zIndex,
    required this.createdAt,
  });

  factory ElementModel.fromEntity(DiaryElement entity) {
    return ElementModel(
      id: entity.id,
      pageId: entity.pageId,
      type: entity.type.name,
      x: entity.x,
      y: entity.y,
      width: entity.width,
      height: entity.height,
      rotation: entity.rotation,
      content: entity.content,
      zIndex: entity.zIndex,
      createdAt: entity.createdAt.toIso8601String(),
    );
  }

  factory ElementModel.fromMap(Map<String, dynamic> map) {
    return ElementModel(
      id: map['id'] as String,
      pageId: map['page_id'] as String,
      type: map['type'] as String,
      x: (map['x'] as num).toDouble(),
      y: (map['y'] as num).toDouble(),
      width: (map['width'] as num).toDouble(),
      height: (map['height'] as num).toDouble(),
      rotation: (map['rotation'] as num).toDouble(),
      content: map['content'] as String,
      zIndex: map['z_index'] as int,
      createdAt: map['created_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'page_id': pageId,
      'type': type,
      'x': x,
      'y': y,
      'width': width,
      'height': height,
      'rotation': rotation,
      'content': content,
      'z_index': zIndex,
      'created_at': createdAt,
    };
  }

  DiaryElement toEntity() {
    return DiaryElement(
      id: id,
      pageId: pageId,
      type: ElementType.values.firstWhere(
        (e) => e.name == type,
        orElse: () => ElementType.text,
      ),
      x: x,
      y: y,
      width: width,
      height: height,
      rotation: rotation,
      content: content,
      zIndex: zIndex,
      createdAt: DateTime.parse(createdAt),
    );
  }
}
