import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../models/appointment_model.dart';
import '../models/hospital_model.dart';

class AppointmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all appointments for a hospital
  Stream<List<Appointment>> getHospitalAppointments(String hospitalId) {
    return _firestore
        .collection('appointments')
        .where('hospitalId', isEqualTo: hospitalId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Appointment.fromFirestore(doc.data()))
            .toList());
  }

  // Get all appointments for a user
  Stream<List<Appointment>> getUserAppointments(String userId) {
    return _firestore
        .collection('appointments')
        .where('patientId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Appointment.fromFirestore(doc.data()))
            .toList());
  }

  // Create a new appointment
  Future<Appointment> createAppointment(Appointment appointment) async {
    final docRef = await _firestore.collection('appointments').add(appointment.toFirestore());
    final doc = await docRef.get();
    return Appointment.fromFirestore(doc.data()!);
  }

  // Update appointment status
  Future<void> updateAppointmentStatus(String appointmentId, String newStatus) async {
    await _firestore
        .collection('appointments')
        .doc(appointmentId)
        .update({'status': newStatus});
  }

  // Modify appointment details
  Future<void> modifyAppointment({
    required String appointmentId,
    DateTime? newDate,
    String? newDoctorName,
    String? newDepartment,
  }) async {
    final Map<String, dynamic> updates = {};
    
    if (newDate != null) updates['appointmentDate'] = newDate;
    if (newDoctorName != null) updates['doctorName'] = newDoctorName;
    if (newDepartment != null) updates['department'] = newDepartment;

    await _firestore
        .collection('appointments')
        .doc(appointmentId)
        .update(updates);
  }

  // Delete appointment
  Future<void> deleteAppointment(String appointmentId) async {
    await _firestore
        .collection('appointments')
        .doc(appointmentId)
        .delete();
  }

  // Location-Based Hospital Search
  Future<List<Hospital>> findNearestHospitals({
    required double latitude, 
    required double longitude, 
    double maxDistance = 50.0 // kilometers
  }) async {
    try {
      // Fetch all hospitals
      QuerySnapshot hospitalSnapshot = await _firestore
          .collection('hospitals')
          .get();

      // Filter hospitals based on proximity
      List<Hospital> nearbyHospitals = [];
      for (var doc in hospitalSnapshot.docs) {
        Hospital hospital = Hospital.fromFirestore(doc.data() as Map<String, dynamic>);
        
        // Check if hospital has location data
        if (hospital.location != null) {
          double distance = Geolocator.distanceBetween(
            latitude, 
            longitude, 
            hospital.location!.latitude, 
            hospital.location!.longitude
          ) / 1000; // Convert to kilometers

          if (distance <= maxDistance) {
            nearbyHospitals.add(hospital);
          }
        }
      }

      // Sort hospitals by distance
      nearbyHospitals.sort((a, b) {
        if (a.location == null || b.location == null) return 0;
        double distanceA = Geolocator.distanceBetween(
          latitude, 
          longitude, 
          a.location!.latitude, 
          a.location!.longitude
        );
        double distanceB = Geolocator.distanceBetween(
          latitude, 
          longitude, 
          b.location!.latitude, 
          b.location!.longitude
        );
        return distanceA.compareTo(distanceB);
      });

      return nearbyHospitals;
    } catch (e) {
      print('Error finding nearby hospitals: $e');
      return [];
    }
  }

  // Emergency Appointment Handling
  Future<Appointment?> createEmergencyAppointment({
    required String userId,
    required String hospitalId,
    required String bloodType,
    required bool isEmergency,
  }) async {
    try {
      DocumentReference appointmentRef = await _firestore
          .collection('appointments')
          .add({
            'userId': userId,
            'hospitalId': hospitalId,
            'bloodType': bloodType,
            'appointmentDate': Timestamp.now(),
            'status': isEmergency 
              ? AppointmentStatus.pending.toString().split('.').last 
              : AppointmentStatus.confirmed.toString().split('.').last,
            'isEmergency': isEmergency,
            'priority': isEmergency ? 1 : 0,
            'createdAt': FieldValue.serverTimestamp(),
          });

      // Trigger hospital notification for emergency
      if (isEmergency) {
        await _sendEmergencyNotification(hospitalId, appointmentRef.id);
      }

      DocumentSnapshot appointmentSnapshot = await appointmentRef.get();
      return Appointment.fromFirestore(appointmentSnapshot.data() as Map<String, dynamic>);
    } catch (e) {
      print('Error creating emergency appointment: $e');
      return null;
    }
  }

  // Send Emergency Notification to Hospital
  Future<void> _sendEmergencyNotification(
    String hospitalId, 
    String appointmentId
  ) async {
    try {
      await _firestore
          .collection('hospital_notifications')
          .add({
            'hospitalId': hospitalId,
            'appointmentId': appointmentId,
            'type': 'emergency',
            'createdAt': FieldValue.serverTimestamp(),
            'status': 'unread'
          });
    } catch (e) {
      print('Error sending emergency notification: $e');
    }
  }

  // Get Upcoming Appointments with Advanced Filtering
  Stream<List<Appointment>> getUpcomingAppointments({
    required String userId,
    int? limit,
    bool onlyEmergency = false,
  }) {
    Query query = _firestore
        .collection('appointments')
        .where('userId', isEqualTo: userId)
        .where('appointmentDate', isGreaterThan: Timestamp.now());

    if (onlyEmergency) {
      query = query.where('isEmergency', isEqualTo: true);
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    return query
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Appointment.fromFirestore(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // Get all appointments
  Stream<List<Appointment>> getAllAppointments() {
    return _firestore
        .collection('appointments')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Appointment.fromFirestore(doc.data()))
            .toList());
  }
}