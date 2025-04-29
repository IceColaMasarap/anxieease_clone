enum AppointmentStatus {
  pending,
  accepted,
  denied,
  confirmed,
  completed,
  cancelled,
}

class AppointmentModel {
  final String id;
  final String psychologistId;
  final String userId;
  final DateTime appointmentDate;
  final String reason;
  final AppointmentStatus status;
  final DateTime createdAt;
  final String? responseMessage;

  AppointmentModel({
    required this.id,
    required this.psychologistId,
    required this.userId,
    required this.appointmentDate,
    required this.reason,
    required this.status,
    required this.createdAt,
    this.responseMessage,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'],
      psychologistId: json['psychologist_id'],
      userId: json['user_id'],
      appointmentDate: DateTime.parse(json['appointment_date']),
      reason: json['reason'],
      status: AppointmentStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => AppointmentStatus.pending,
      ),
      createdAt: DateTime.parse(json['created_at']),
      responseMessage: json['response_message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'psychologist_id': psychologistId,
      'user_id': userId,
      'appointment_date': appointmentDate.toIso8601String(),
      'reason': reason,
      'status': status.toString().split('.').last,
      'created_at': createdAt.toIso8601String(),
      if (responseMessage != null) 'response_message': responseMessage,
    };
  }

  String get statusText {
    switch (status) {
      case AppointmentStatus.pending:
        return 'Pending';
      case AppointmentStatus.accepted:
        return 'Accepted';
      case AppointmentStatus.denied:
        return 'Denied';
      case AppointmentStatus.confirmed:
        return 'Confirmed';
      case AppointmentStatus.completed:
        return 'Completed';
      case AppointmentStatus.cancelled:
        return 'Cancelled';
    }
  }
}
