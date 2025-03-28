import 'package:get/get.dart';
import 'dart:math';
import '../services/firebase_service.dart';
import '../services/notification_service.dart';
import '../models/blood_request.dart';
import '../models/donor.dart';

class DonorMatchingController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();
  final NotificationService _notificationService = NotificationService();

  Future<void> processBloodRequest(BloodRequest request) async {
    try {
      // Store the blood request
      await _firebaseService.storeBloodRequest(request);

      // Find potential donors
      List<Donor> potentialDonors = await _firebaseService.findPotentialDonors(request);

      // Send notifications to top 5 donors
      for (int i = 0; i < min(5, potentialDonors.length); i++) {
        Donor donor = potentialDonors[i];
        
        await _notificationService.sendDonorNotification(
          donor, 
          request,
          message: "Urgent: ${request.bloodType} blood needed at ${request.hospitalName}. Can you help?"
        );
      }
    } catch (e) {
      // Handle errors
      print('Error processing blood request: $e');
    }
  }

  // Method to handle donor response
  Future<void> handleDonorResponse(Donor donor, BloodRequest request, bool accepted) async {
    if (accepted) {
      // Update request status
      await _firebaseService.updateRequestStatus(request.id, 'MATCHED');
      
      // Notify recipient about matched donor
      await _notificationService.sendRecipientNotification(
        request.recipientToken, 
        message: "Donor found for your blood request!"
      );
    }
  }
}