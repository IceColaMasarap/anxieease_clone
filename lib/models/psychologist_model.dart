class PsychologistModel {
  final String id;
  final String name;
  final String specialization;
  final String contactEmail;
  final String contactPhone;
  final String biography;
  final String? imageUrl;

  PsychologistModel({
    required this.id,
    required this.name,
    required this.specialization,
    required this.contactEmail,
    required this.contactPhone,
    required this.biography,
    this.imageUrl,
  });

  factory PsychologistModel.fromJson(Map<String, dynamic> json) {
    return PsychologistModel(
      id: json['id'],
      name: json['name'],
      specialization: json['specialization'],
      contactEmail: json['contact_email'],
      contactPhone: json['contact_phone'],
      biography: json['biography'],
      imageUrl: json['image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'specialization': specialization,
      'contact_email': contactEmail,
      'contact_phone': contactPhone,
      'biography': biography,
      'image_url': imageUrl,
    };
  }
}
