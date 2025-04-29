import 'package:cloud_firestore/cloud_firestore.dart';

//blood inventory model class
class BloodInventoryModel {
  final String hospitalId;
  final Map<String, BloodTypeInventory> inventory;
  final DateTime lastUpdated;

  BloodInventoryModel({
    required this.hospitalId,
    required this.inventory,
    required this.lastUpdated,
  });
  //constructor

  factory BloodInventoryModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return BloodInventoryModel(
      hospitalId: doc.id,
      inventory: (data['inventory'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, BloodTypeInventory.fromJson(value)),
      ),
      lastUpdated: (data['lastUpdated'] as Timestamp).toDate(),
    );
  }
  //from firestore method

  Map<String, dynamic> toFirestore() {
    return {
      'hospitalId': hospitalId,
      'inventory': inventory.map((key, value) => MapEntry(key, value.toJson())),
      'lastUpdated': lastUpdated,
    };
  }
}

//blood type inventory class
class BloodTypeInventory {
  final int availableUnits;
  final DateTime lastCollected;
  final DateTime expiryDate;

  BloodTypeInventory({
    required this.availableUnits,
    required this.lastCollected,
    required this.expiryDate,
  });
  //constructor for blood type inventory
  factory BloodTypeInventory.fromJson(Map<String, dynamic> json) {
    return BloodTypeInventory(
      availableUnits: json['availableUnits'],
      lastCollected: (json['lastCollected'] as Timestamp).toDate(),
      expiryDate: (json['expiryDate'] as Timestamp).toDate(),
    );
  }
  //to json method
  Map<String, dynamic> toJson() {
    return {
      'availableUnits': availableUnits,
      'lastCollected': lastCollected,
      'expiryDate': expiryDate,
    };
  }
}
