class Donor {
  final String id;
  final String bloodType;
  final double? latitude;
  final double? longitude;

  Donor({
    required this.id,
    required this.bloodType,
    this.latitude,
    this.longitude,
  });

  factory Donor.fromJson(Map<String, dynamic> json) {
    return Donor(
      id: json['id'],
      bloodType: json['bloodType'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bloodType': bloodType,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
} 