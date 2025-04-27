import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../firebase_options.dart';

import '../models/blood_unit.dart';
import '../models/inventory_item.dart';
import '../models/donor.dart';
import '../models/blood_request.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DatabaseReference _realtimeDbRef = FirebaseDatabase.instance.reference();

  // Initialize Firebase
  static Future<void> initializeFirebase() async {
    try {
      print('Starting Firebase Service initialization...');
      
      // Check if Firebase is already initialized
      if (Firebase.apps.isEmpty) {
        print('Firebase is not initialized, initializing now...');
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        print('Firebase initialized successfully with app: ${Firebase.apps.first.name}');
      } else {
        print('Firebase is already initialized');
      }
      
      // Configure Firebase Messaging
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      
      print('Firebase Messaging permission status: ${settings.authorizationStatus}');
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('User granted notification permission');
      } else {
        print('User declined or has not accepted notification permission');
      }

      // Verify Firestore is accessible
      try {
        print('Verifying Firestore connection...');
        final firestore = FirebaseFirestore.instance;
        print('Firestore instance created');
        
        // Try to access a test collection
        final testCollection = firestore.collection('test');
        print('Test collection reference created');
        
        final snapshot = await testCollection.get();
        print('Successfully accessed Firestore. Collection size: ${snapshot.docs.length}');
        
        print('Firestore connection verified successfully');
      } catch (e, stackTrace) {
        print('Error verifying Firestore connection:');
        print('Error: $e');
        print('Stack trace: $stackTrace');
        throw Exception('Firestore connection failed: $e');
      }
    } catch (e, stackTrace) {
      print('Error initializing Firebase Service:');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to initialize Firebase Service: $e');
    }
  }

  // Blood Request Methods
  Future<void> storeBloodRequest(BloodRequest request) async {
    try {
      await _firestore.collection('blood_requests').doc(request.id).set(request.toJson());
    } catch (e) {
      print('Error storing blood request: $e');
      throw Exception('Failed to store blood request: $e');
    }
  }

  // Add stream method for real-time blood requests
  Stream<List<BloodRequest>> getBloodRequestsStream() {
    try {
      return _firestore.collection('blood_requests')
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => BloodRequest.fromJson(doc.data()))
              .toList());
    } catch (e) {
      print('Error getting blood requests stream: $e');
      throw Exception('Failed to get blood requests stream: $e');
    }
  }

  Future<List<BloodRequest>> getBloodRequests() async {
    try {
      final QuerySnapshot snapshot = await _firestore.collection('blood_requests').get();
      return snapshot.docs.map((doc) => BloodRequest.fromJson(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error getting blood requests: $e');
      throw Exception('Failed to get blood requests: $e');
    }
  }

  Future<void> updateBloodRequest(BloodRequest request) async {
    try {
      await _firestore.collection('blood_requests').doc(request.id).update(request.toJson());
    } catch (e) {
      print('Error updating blood request: $e');
      throw Exception('Failed to update blood request: $e');
    }
  }

  Future<void> deleteBloodRequest(String id) async {
    try {
      await _firestore.collection('blood_requests').doc(id).delete();
    } catch (e) {
      print('Error deleting blood request: $e');
      throw Exception('Failed to delete blood request: $e');
    }
  }

  // Find Potential Donors
  Future<List<Donor>> findPotentialDonors(BloodRequest request) async {
    DatabaseEvent event = await _realtimeDbRef.child('donors').once();
    List<Donor> potentialDonors = [];
    Map<dynamic, dynamic> donors = event.snapshot.value as Map<dynamic, dynamic>;
    
    donors.forEach((key, donorData) {
      Donor donor = Donor.fromJson(donorData);
      
      // Check blood type compatibility
      if (isDonorCompatible(donor, request)) {
        // Calculate distance
        double distance = calculateDistance(
          donor.latitude, 
          donor.longitude, 
          request.latitude, 
          request.longitude
        );
        // Filter donors within 10-mile radius
        if (distance <= 10) {
          potentialDonors.add(donor);
        }
      }
    });
    
    // Sort donors by proximity
    potentialDonors.sort((a, b) {
      final aLat = (a).latitude ?? 0.0;
      final aLong = a.longitude ?? 0.0;
      final bLat = (b).latitude ?? 0.0;
      final bLong = b.longitude ?? 0.0;
      return calculateDistance(aLat, aLong, request.latitude, request.longitude)
        .compareTo(calculateDistance(bLat, bLong, request.latitude, request.longitude));
    });
    
    return potentialDonors;
  }

  // Blood Type Compatibility Check
  bool isDonorCompatible(Donor donor, BloodRequest request) {
    Map<String, List<String>> compatibilityMatrix = {
      'A+': ['A+', 'A-', 'O+', 'O-'],
      'A-': ['A-', 'O-'],
      'B+': ['B+', 'B-', 'O+', 'O-'],
      'B-': ['B-', 'O-'],
      'AB+': ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'],
      'AB-': ['A-', 'B-', 'AB-', 'O-'],
      'O+': ['O+', 'O-'],
      'O-': ['O-']
    };
    return compatibilityMatrix[request.bloodType]?.contains(donor.bloodType) ?? false;
  }

  // Distance Calculation
  double calculateDistance(double? startLatitude, double? startLongitude, 
                         double endLatitude, double endLongitude) {
    return Geolocator.distanceBetween(
      startLatitude ?? 0.0, 
      startLongitude ?? 0.0, 
      endLatitude, 
      endLongitude
    ) / 1609.344; // Convert meters to miles
  }

  // Inventory Management Methods
  Future<void> addBloodUnit(BloodUnit bloodUnit) async {
    try {
      await _firestore.collection('blood_inventory').add(bloodUnit.toJson());
    } catch (e) {
      print('Error adding blood unit: $e');
    }
  }

  Stream<List<InventoryItem>> getInventorySummary() {
    return _firestore.collection('blood_inventory')
      .snapshots()
      .map((snapshot) {
        Map<String, InventoryItem> inventoryMap = {};

        for (var doc in snapshot.docs) {
          BloodUnit unit = BloodUnit.fromJson(doc.data());
          
          if (!inventoryMap.containsKey(unit.bloodType)) {
            inventoryMap[unit.bloodType] = InventoryItem(
              bloodType: unit.bloodType,
              totalUnits: 1,
              oldestUnit: unit.donationDate,
              latestExpiryDate: unit.expiryDate,
            );
          } else {
            final currentItem = inventoryMap[unit.bloodType]!;
            inventoryMap[unit.bloodType] = InventoryItem(
              bloodType: unit.bloodType,
              totalUnits: currentItem.totalUnits + 1,
              oldestUnit: currentItem.oldestUnit.isBefore(unit.donationDate) 
                ? currentItem.oldestUnit 
                : unit.donationDate,
              latestExpiryDate: currentItem.latestExpiryDate.isAfter(unit.expiryDate) 
                ? currentItem.latestExpiryDate 
                : unit.expiryDate,
            );
          }
        }

        return inventoryMap.values.toList();
      });
  }

  Future<void> removeExpiredUnits() async {
    final now = DateTime.now();
    QuerySnapshot expiredUnits = await _firestore
      .collection('blood_inventory')
      .where('expiryDate', isLessThan: now)
      .get();

    for (var doc in expiredUnits.docs) {
      await doc.reference.delete();
    }
  }

  Future<List<Donor>> getDonorsByBloodType(String bloodType) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('donors')
          .where('bloodType', isEqualTo: bloodType)
          .get();

      return snapshot.docs.map((doc) => Donor.fromJson(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error getting donors by blood type: $e');
      return [];
    }
  }

  Future<String?> getDonorToken(String donorId) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection('donors')
          .doc(donorId)
          .get();
      
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return data['fcmToken'] as String?;
      }
      return null;
    } catch (e) {
      print('Error getting donor token: $e');
      return null;
    }
  }

  Future<void> updateRequestStatus(String requestId, String status) async {
    try {
      await _firestore
          .collection('blood_requests')
          .doc(requestId)
          .update({'status': status});
    } catch (e) {
      print('Error updating request status: $e');
    }
  }
}