enum ElementType {
  text,
  image,
  sticker,
  drawing,
}

class DiaryElement {
  final String id;
  final String pageId;
  final ElementType type;
  final double x;
  final double y;
  final double width;
  final double height;
  final double rotation;
  final String content; // JSON string for type-specific data
  final int zIndex;
  final DateTime createdAt;

  const DiaryElement({
    required this.id,
    required this.pageId,
    required this.type,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.rotation = 0.0,
    required this.content,
    this.zIndex = 0,
    required this.createdAt,
  });

  DiaryElement copyWith({
    String? id,
    String? pageId,
    ElementType? type,
    double? x,
    double? y,
    double? width,
    double? height,
    double? rotation,
    String? content,
    int? zIndex,
    DateTime? createdAt,
  }) {
    return DiaryElement(
      id: id ?? this.id,
      pageId: pageId ?? this.pageId,
      type: type ?? this.type,
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      rotation: rotation ?? this.rotation,
      content: content ?? this.content,
      zIndex: zIndex ?? this.zIndex,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
