class EmergencyGuide {
  final String id;
  final String title;
  final String category;
  final String summary;
  final String iconName;
  final String assetPath;
  final int readTimeMinutes;
  final String lastUpdated;
  final String? content;

  const EmergencyGuide({
    required this.id,
    required this.title,
    required this.category,
    required this.summary,
    required this.iconName,
    required this.assetPath,
    required this.readTimeMinutes,
    required this.lastUpdated,
    this.content,
  });

  EmergencyGuide copyWith({
    String? id,
    String? title,
    String? category,
    String? summary,
    String? iconName,
    String? assetPath,
    int? readTimeMinutes,
    String? lastUpdated,
    String? content,
  }) {
    return EmergencyGuide(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      summary: summary ?? this.summary,
      iconName: iconName ?? this.iconName,
      assetPath: assetPath ?? this.assetPath,
      readTimeMinutes: readTimeMinutes ?? this.readTimeMinutes,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      content: content ?? this.content,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'summary': summary,
      'iconName': iconName,
      'assetPath': assetPath,
      'readTimeMinutes': readTimeMinutes,
      'lastUpdated': lastUpdated,
      'content': content,
    };
  }

  factory EmergencyGuide.fromMap(Map<String, dynamic> map) {
    return EmergencyGuide(
      id: map['id'] as String,
      title: map['title'] as String,
      category: map['category'] as String,
      summary: map['summary'] as String,
      iconName: map['iconName'] as String,
      assetPath: map['assetPath'] as String,
      readTimeMinutes: (map['readTimeMinutes'] as num).toInt(),
      lastUpdated: map['lastUpdated'] as String,
      content: map['content'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmergencyGuide &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          category == other.category &&
          summary == other.summary &&
          iconName == other.iconName &&
          assetPath == other.assetPath &&
          readTimeMinutes == other.readTimeMinutes &&
          lastUpdated == other.lastUpdated &&
          content == other.content;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      category.hashCode ^
      summary.hashCode ^
      iconName.hashCode ^
      assetPath.hashCode ^
      readTimeMinutes.hashCode ^
      lastUpdated.hashCode ^
      (content?.hashCode ?? 0);
}

