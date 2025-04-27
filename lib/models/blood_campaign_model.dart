import 'package:cloud_firestore/cloud_firestore.dart';

class BloodCampaign {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String location;
  final String status;

  BloodCampaign({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.location,
    required this.status,
  });

  factory BloodCampaign.fromJson(Map<String, dynamic> json, String id) {
    return BloodCampaign(
      id: id,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      date: (json['date'] as Timestamp).toDate(),
      location: json['location'] ?? '',
      status: json['status'] ?? 'active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'date': date,
      'location': location,
      'status': status,
    };
  }
}