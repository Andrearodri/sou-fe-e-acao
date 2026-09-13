class PrayerEntry {
  const PrayerEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    required this.answeredAt,
    required this.isAnswered,
  });

  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? answeredAt;
  final bool isAnswered;

  PrayerEntry copyWith({
    String? title,
    String? content,
    DateTime? updatedAt,
    DateTime? answeredAt,
    bool? isAnswered,
    bool clearAnsweredAt = false,
  }) {
    return PrayerEntry(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      answeredAt: clearAnsweredAt ? null : (answeredAt ?? this.answeredAt),
      isAnswered: isAnswered ?? this.isAnswered,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'answeredAt': answeredAt?.toIso8601String(),
        'isAnswered': isAnswered,
      };

  factory PrayerEntry.fromJson(Map<String, dynamic> json) {
    return PrayerEntry(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      answeredAt: (json['answeredAt'] as String?) == null
          ? null
          : DateTime.parse(json['answeredAt'] as String),
      isAnswered: json['isAnswered'] as bool? ?? false,
    );
  }
}
