// services/hospital_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../models/hospital_model.dart';
import '../../../../models/appointment_model.dart';

class HospitalService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Hospital Management Methods
  Future<void> addHospital(Hospital hospital) async {
    try {
      await _firestore
          .collection('hospitals')
          .doc(hospital.id)
          .set(hospital.toFirestore());
    } catch (e) {
      print('Error adding hospital: $e');
    }
  }

  Future<Hospital?> getHospitalById(String hospitalId) async {
    try {
      final doc = await _firestore.collection('hospitals').doc(hospitalId).get();
      return doc.exists ? Hospital.fromFirestore(doc.data()!) : null;
    } catch (e) {
      print('Error fetching hospital: $e');
      return null;
    }
  }

  // Appointment Management Methods
  Future<void> bookAppointment(Appointment appointment) async {
    try {
      await _firestore
          .collection('appointments')
          .doc(appointment.id)
          .set(appointment.toFirestore());
    } catch (e) {
      print('Error booking appointment: $e');
    }
  }

  Stream<List<Appointment>> getUserAppointments(String patientId) {
    return _firestore
        .collection('appointments')
        .where('patientId', isEqualTo: patientId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Appointment.fromFirestore(doc.data()))
            .toList());
  }

  Future<void> updateAppointmentStatus(
      String appointmentId, String newStatus) async {
    try {
      await _firestore
          .collection('appointments')
          .doc(appointmentId)
          .update({'status': newStatus});
    } catch (e) {
      print('Error updating appointment status: $e');
    }
  }
}