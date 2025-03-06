class Psychologist {
  final String id;
  final String email;
  final String fullName;
  final int? age;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isEmailVerified;
  final DateTime? lastLogin;

  Psychologist({
    required this.id,
    required this.email,
    required this.fullName,
    this.age,
    required this.createdAt,
    required this.updatedAt,
    required this.isEmailVerified,
    this.lastLogin,
  });

  factory Psychologist.fromJson(Map<String, dynamic> json) {
    return Psychologist(
      id: json['id'],
      email: json['email'],
      fullName: json['full_name'],
      age: json['age'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      isEmailVerified: json['is_email_verified'] ?? false,
      lastLogin: json['last_login'] != null ? DateTime.parse(json['last_login']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'age': age,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_email_verified': isEmailVerified,
      'last_login': lastLogin?.toIso8601String(),
    };
  }
} 