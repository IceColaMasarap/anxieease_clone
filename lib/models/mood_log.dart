class MoodLog {
  final String id;
  final String userId;
  final String mood;
  final int intensity;
  final String? notes;
  final List<String> tags;
  final DateTime createdAt;

  MoodLog({
    required this.id,
    required this.userId,
    required this.mood,
    required this.intensity,
    this.notes,
    required this.tags,
    required this.createdAt,
  });

  factory MoodLog.fromJson(Map<String, dynamic> json) {
    return MoodLog(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      mood: json['mood'] as String,
      intensity: json['intensity'] as int,
      notes: json['notes'] as String?,
      tags: List<String>.from(json['tags'] ?? []),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'mood': mood,
      'intensity': intensity,
      'notes': notes,
      'tags': tags,
      'created_at': createdAt.toIso8601String(),
    };
  }
} 