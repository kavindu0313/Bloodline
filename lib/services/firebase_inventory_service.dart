import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/blood_unit.dart';
import '../models/inventory_item.dart';

class FirebaseInventoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = 'blood_inventory';

  Future<void> addBloodUnit(BloodUnit bloodUnit) async {
    try {
      print('Starting to add blood unit to Firestore...');
      print('Collection name: $collectionName');
      print('Blood unit data: ${bloodUnit.toJson()}');

      // Get collection reference
      final CollectionReference collection = _firestore.collection(collectionName);
      print('Got collection reference');

      // Add document
      final DocumentReference docRef = await collection.add(bloodUnit.toJson());
      print('Document added with ID: ${docRef.id}');

      // Update the document with its ID
      await docRef.update({'id': docRef.id});
      print('Document ID updated');

      // Verify document was created
      final DocumentSnapshot doc = await docRef.get();
      if (!doc.exists) {
        throw Exception('Document was not created');
      }
      print('Document verified. Data: ${doc.data()}');

    } catch (e, stackTrace) {
      print('Error in addBloodUnit:');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to add blood unit: $e');
    }
  }

  Stream<List<BloodUnit>> getBloodUnits() {
    print('Starting getBloodUnits stream...');
    return _firestore
        .collection(collectionName)
        .snapshots()
        .map((snapshot) {
          print('Received snapshot with ${snapshot.docs.length} documents');
          return snapshot.docs.map((doc) {
            try {
              final data = doc.data();
              data['id'] = doc.id; // Add document ID to the data
              print('Processing document ${doc.id}: $data');
              return BloodUnit.fromJson(data);
            } catch (e) {
              print('Error processing document ${doc.id}: $e');
              rethrow;
            }
          }).toList();
        });
  }

  Future<void> updateBloodUnit(BloodUnit bloodUnit) async {
    try {
      await _firestore
          .collection(collectionName)
          .doc(bloodUnit.id)
          .update(bloodUnit.toJson());
      print('Blood unit updated successfully: ${bloodUnit.id}');
    } catch (e) {
      print('Error updating blood unit: $e');
      throw Exception('Failed to update blood unit: $e');
    }
  }

  Future<void> deleteBloodUnit(String id) async {
    try {
      await _firestore.collection(collectionName).doc(id).delete();
      print('Blood unit deleted successfully: $id');
    } catch (e) {
      print('Error deleting blood unit: $e');
      throw Exception('Failed to delete blood unit: $e');
    }
  }

  Stream<List<InventoryItem>> getInventorySummary() {
    print('Starting getInventorySummary stream...');
    return _firestore
        .collection(collectionName)
        .snapshots()
        .map((snapshot) {
          print('Processing inventory summary for ${snapshot.docs.length} documents');
          Map<String, InventoryItem> inventoryMap = {};

          for (var doc in snapshot.docs) {
            try {
              final data = doc.data();
              print('Processing document for summary: ${doc.id}');
              BloodUnit unit = BloodUnit.fromJson(data);
              
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
            } catch (e) {
              print('Error processing document for summary ${doc.id}: $e');
            }
          }

          print('Inventory summary generated: ${inventoryMap.length} blood types');
          return inventoryMap.values.toList();
        });
  }

  Future<void> removeExpiredUnits() async {
    final now = DateTime.now();
    try {
      print('Starting to remove expired units...');
      QuerySnapshot expiredUnits = await _firestore
        .collection(collectionName)
        .where('expiryDate', isLessThan: now.toIso8601String())
        .get();

      print('Found ${expiredUnits.docs.length} expired units');
      for (var doc in expiredUnits.docs) {
        await doc.reference.delete();
        print('Deleted expired unit: ${doc.id}');
      }
    } catch (e) {
      print('Error removing expired units: $e');
      throw Exception('Failed to remove expired units: $e');
    }
  }
} 