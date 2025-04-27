class BloodRequest {
  final String id;
  final String recipientName;
  final String hospitalName;
  final String bloodType;
  final String location;
  final String urgency;
  final double latitude;
  final double longitude;
  final String recipientToken;
  final String status;

  BloodRequest({
    required this.id,
    required this.recipientName,
    required this.hospitalName,
    required this.bloodType,
    required this.location,
    required this.urgency,
    required this.latitude,
    required this.longitude,
    required this.recipientToken,
    this.status = 'pending',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recipientName': recipientName,
      'hospitalName': hospitalName,
      'bloodType': bloodType,
      'location': location,
      'urgency': urgency,
      'latitude': latitude,
      'longitude': longitude,
      'recipientToken': recipientToken,
      'status': status,
    };
  }

  factory BloodRequest.fromJson(Map<dynamic, dynamic> json) {
    return BloodRequest(
      id: json['id'] as String,
      recipientName: json['recipientName'] as String,
      hospitalName: json['hospitalName'] as String,
      bloodType: json['bloodType'] as String,
      location: json['location'] as String,
      urgency: json['urgency'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      recipientToken: json['recipientToken'] as String,
      status: json['status'] as String? ?? 'pending',
    );
  }
} 