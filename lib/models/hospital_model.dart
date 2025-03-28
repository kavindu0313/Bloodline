// models/hospital_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Hospital {
  final String id;
  final String name;
  final String address;
  final String contactNumber;
  final int totalBeds;
  final int availableBeds;
  final List<String> departments;
  final List<String> doctorNames;
  final GeoPoint? location;

  Hospital({
    required this.id,
    required this.name,
    required this.address,
    required this.contactNumber,
    required this.totalBeds,
    required this.availableBeds,
    required this.departments,
    required this.doctorNames,
    this.location,
  });

  factory Hospital.fromFirestore(Map<String, dynamic> firestore) {
    return Hospital(
      id: firestore['id'] ?? '',
      name: firestore['name'] ?? '',
      address: firestore['address'] ?? '',
      contactNumber: firestore['contactNumber'] ?? '',
      totalBeds: firestore['totalBeds'] ?? 0,
      availableBeds: firestore['availableBeds'] ?? 0,
      departments: List<String>.from(firestore['departments'] ?? []),
      doctorNames: List<String>.from(firestore['doctorNames'] ?? []),
      location: firestore['location'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'contactNumber': contactNumber,
      'totalBeds': totalBeds,
      'availableBeds': availableBeds,
      'departments': departments,
      'doctorNames': doctorNames,
      'location': location,
    };
  }
}