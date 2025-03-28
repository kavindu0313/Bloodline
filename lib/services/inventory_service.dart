// inventory_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/blood_unit.dart';

class InventoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all blood units
  Stream<List<BloodUnit>> getBloodUnits() {
    return _firestore
        .collection('blood_inventory')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BloodUnit.fromJson(doc.data()))
            .toList());
  }

  // Get blood units by type
  Stream<List<BloodUnit>> getBloodUnitsByType(String bloodType) {
    return _firestore
        .collection('blood_inventory')
        .where('bloodType', isEqualTo: bloodType)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BloodUnit.fromJson(doc.data()))
            .toList());
  }

  // Update blood unit
  Future<void> updateBloodUnit(BloodUnit bloodUnit) async {
    try {
      await _firestore
          .collection('blood_inventory')
          .doc(bloodUnit.id)
          .update(bloodUnit.toJson());
    } catch (e) {
      print('Error updating blood unit: $e');
    }
  }

  // Delete blood unit
  Future<void> deleteBloodUnit(String unitId) async {
    try {
      await _firestore.collection('blood_inventory').doc(unitId).delete();
    } catch (e) {
      print('Error deleting blood unit: $e');
    }
  }

  // Check blood unit availability
  Future<bool> isBloodUnitAvailable(String bloodType, double requiredVolume) async {
    QuerySnapshot snapshot = await _firestore
        .collection('blood_inventory')
        .where('bloodType', isEqualTo: bloodType)
        .where('volume', isGreaterThanOrEqualTo: requiredVolume)
        .get();

    return snapshot.docs.isNotEmpty;
  }
}

// blood_type_utils.dart
class BloodTypeUtils {
  // List of valid blood types
  static const List<String> bloodTypes = [
    'A+', 'A-', 'B+', 'B-', 
    'AB+', 'AB-', 'O+', 'O-'
  ];

  // Check if a blood type is valid
  static bool isValidBloodType(String bloodType) {
    return bloodTypes.contains(bloodType);
  }

  // Get compatible donor blood types
  static List<String> getCompatibleDonors(String receiverBloodType) {
    switch (receiverBloodType) {
      case 'A+':
        return ['A+', 'A-', 'O+', 'O-'];
      case 'A-':
        return ['A-', 'O-'];
      case 'B+':
        return ['B+', 'B-', 'O+', 'O-'];
      case 'B-':
        return ['B-', 'O-'];
      case 'AB+':
        return ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
      case 'AB-':
        return ['A-', 'B-', 'AB-', 'O-'];
      case 'O+':
        return ['O+', 'O-'];
      case 'O-':
        return ['O-'];
      default:
        return [];
    }
  }

  // Get compatible receiver blood types
  static List<String> getCompatibleReceivers(String donorBloodType) {
    switch (donorBloodType) {
      case 'A+':
        return ['A+', 'AB+'];
      case 'A-':
        return ['A+', 'A-', 'AB+', 'AB-'];
      case 'B+':
        return ['B+', 'AB+'];
      case 'B-':
        return ['B+', 'B-', 'AB+', 'AB-'];
      case 'AB+':
        return ['AB+'];
      case 'AB-':
        return ['AB+', 'AB-'];
      case 'O+':
        return ['A+', 'B+', 'AB+', 'O+'];
      case 'O-':
        return ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
      default:
        return [];
    }
  }
}
