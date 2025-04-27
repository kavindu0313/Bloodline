import 'package:cloud_firestore/cloud_firestore.dart';

class BloodUnit {
  final String id;
  final String bloodType;
  final DateTime donationDate;
  final DateTime expiryDate;
  final String donorId;
  final double volume; // in ml
  final String storageLocation;
  final String? status;

  BloodUnit({
    required this.id,
    required this.bloodType,
    required this.donationDate,
    required this.expiryDate,
    required this.donorId,
    required this.volume,
    required this.storageLocation,
    this.status,
  }) {
    print('Creating BloodUnit instance with id: $id');
  }

  Map<String, dynamic> toJson() {
    try {
      final json = {
        'id': id,
        'bloodType': bloodType,
        'donationDate': donationDate.toIso8601String(),
        'expiryDate': expiryDate.toIso8601String(),
        'donorId': donorId,
        'volume': volume,
        'storageLocation': storageLocation,
        'status': status ?? 'Available',
      };
      print('Converting BloodUnit to JSON: $json');
      return json;
    } catch (e) {
      print('Error converting BloodUnit to JSON: $e');
      rethrow;
    }
  }

  factory BloodUnit.fromJson(Map<String, dynamic> json) {
    try {
      print('Creating BloodUnit from JSON: $json');
      
      // Handle dates that might come as Timestamp or String
      DateTime parseDonationDate() {
        final date = json['donationDate'];
        if (date is Timestamp) {
          return date.toDate();
        } else if (date is String) {
          return DateTime.parse(date);
        }
        throw FormatException('Invalid donationDate format: $date');
      }

      DateTime parseExpiryDate() {
        final date = json['expiryDate'];
        if (date is Timestamp) {
          return date.toDate();
        } else if (date is String) {
          return DateTime.parse(date);
        }
        throw FormatException('Invalid expiryDate format: $date');
      }

      final bloodUnit = BloodUnit(
        id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
        bloodType: json['bloodType'] as String,
        donationDate: parseDonationDate(),
        expiryDate: parseExpiryDate(),
        donorId: json['donorId'] as String,
        volume: (json['volume'] as num).toDouble(),
        storageLocation: json['storageLocation'] as String,
        status: json['status'] as String?,
      );
      print('Successfully created BloodUnit from JSON with id: ${bloodUnit.id}');
      return bloodUnit;
    } catch (e) {
      print('Error creating BloodUnit from JSON: $e');
      print('Problematic JSON data: $json');
      rethrow;
    }
  }
}