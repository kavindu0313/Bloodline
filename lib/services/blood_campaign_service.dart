import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/blood_campaign_model.dart';

class BloodCampaignService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new blood campaign
  Future<String> createCampaign(BloodCampaign campaign) async {
    try {
      final docRef = await _firestore.collection('blood_campaigns').add(
        campaign.toJson()
      );
      return docRef.id;
    } catch (e) {
      print('Error creating campaign: $e');
      rethrow;
    }
  }

  // Get all active blood campaigns
  Stream<List<BloodCampaign>> getActiveCampaigns() {
    return _firestore
      .collection('blood_campaigns')
      .where('status', isEqualTo: 'active')
      .snapshots()
      .map((snapshot) => snapshot.docs
        .map((doc) => BloodCampaign.fromJson(doc.data(), doc.id))
        .toList()
      );
  }

  // Get campaign by ID
  Future<BloodCampaign?> getCampaignById(String id) async {
    try {
      final doc = await _firestore.collection('blood_campaigns').doc(id).get();
      return doc.exists 
        ? BloodCampaign.fromJson(doc.data()!, doc.id) 
        : null;
    } catch (e) {
      print('Error fetching campaign: $e');
      return null;
    }
  }

  // Update campaign status
  Future<void> updateCampaignStatus(String id, String status) async {
    await _firestore
      .collection('blood_campaigns')
      .doc(id)
      .update({'status': status});
  }

  // Delete campaign
  Future<void> deleteCampaign(String id) async {
    try {
      await _firestore.collection('blood_campaigns').doc(id).delete();
    } catch (e) {
      print('Error deleting campaign: $e');
      rethrow;
    }
  }

  // Update campaign
  Future<void> updateCampaign(BloodCampaign campaign) async {
    try {
      await _firestore
        .collection('blood_campaigns')
        .doc(campaign.id)
        .update(campaign.toJson());
    } catch (e) {
      print('Error updating campaign: $e');
      rethrow;
    }
  }
}