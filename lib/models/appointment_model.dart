import 'package:cloud_firestore/cloud_firestore.dart';

enum AppointmentStatus {
  pending,
  confirmed,
  completed,
  cancelled
}

// models/appointment_model.dart
class Appointment {
  final String id;
  final String patientId;
  final String hospitalId;
  final String doctorName;
  final DateTime appointmentDate;
  final String department;
  final AppointmentStatus status;

  Appointment({
    required this.id,
    required this.patientId,
    required this.hospitalId,
    required this.doctorName,
    required this.appointmentDate,
    required this.department,
    required this.status,
  });

  factory Appointment.fromFirestore(Map<String, dynamic> firestore) {
    return Appointment(
      id: firestore['id'] ?? '',
      patientId: firestore['patientId'] ?? '',
      hospitalId: firestore['hospitalId'] ?? '',
      doctorName: firestore['doctorName'] ?? '',
      appointmentDate: (firestore['appointmentDate'] as Timestamp).toDate(),
      department: firestore['department'] ?? '',
      status: AppointmentStatus.values.firstWhere(
        (e) => e.toString().split('.').last == firestore['status'],
        orElse: () => AppointmentStatus.pending,
      ),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'patientId': patientId,
      'hospitalId': hospitalId,
      'doctorName': doctorName,
      'appointmentDate': appointmentDate,
      'department': department,
      'status': status.toString().split('.').last,
    };
  }
}