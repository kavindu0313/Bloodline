class AppConstants {
  // Blood Types
  static const List<String> bloodTypes = [
    'A+', 'A-', 'B+', 'B-', 
    'O+', 'O-', 'AB+', 'AB-'
  ];

  // Donation Eligibility Criteria
  static const int minDonorAge = 18;
  static const int maxDonorAge = 65;
  static const int minWeightKg = 50;

  // Appointment Status Colors
  static const Map<String, int> statusColors = {
    'pending': 0xFFFFC107,   // Amber
    'confirmed': 0xFF4CAF50, // Green
    'completed': 0xFF2196F3, // Blue
    'cancelled': 0xFFF44336, // Red
  };

  // Firebase Collection Names
  static const String usersCollection = 'users';
  static const String hospitalsCollection = 'hospitals';
  static const String appointmentsCollection = 'appointments';

  // Error Messages
  static const String genericErrorMessage = 
    'An unexpected error occurred. Please try again.';
}