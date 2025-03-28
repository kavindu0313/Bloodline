import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String bloodType;
  final String phoneNumber;
  final DateTime? dateOfBirth;
  final String? profileImageUrl;
  final List<String>? medicalHistory;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.bloodType,
    required this.phoneNumber,
    this.dateOfBirth,
    this.profileImageUrl,
    this.medicalHistory,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      bloodType: data['bloodType'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      dateOfBirth: (data['dateOfBirth'] as Timestamp?)?.toDate(),
      profileImageUrl: data['profileImageUrl'],
      medicalHistory: List<String>.from(data['medicalHistory'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'bloodType': bloodType,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth != null ? Timestamp.fromDate(dateOfBirth!) : null,
      'profileImageUrl': profileImageUrl,
      'medicalHistory': medicalHistory,
    };
  }
}