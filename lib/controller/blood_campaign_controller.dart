import 'package:get/get.dart';
import '../models/blood_campaign_model.dart';
import '../services/blood_campaign_service.dart';

class BloodCampaignController extends GetxController {
  final BloodCampaignService _service = BloodCampaignService();
  final RxList<BloodCampaign> campaigns = <BloodCampaign>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchActiveCampaigns();
  }

  Future<void> fetchActiveCampaigns() async {
    isLoading.value = true;
    try {
      campaigns.bindStream(_service.getActiveCampaigns());
    } catch (e) {
      print('Error fetching campaigns: $e');
      Get.snackbar('Error', 'Failed to load campaigns',
          snackPosition: SnackPosition.BOTTOM);
    }
    isLoading.value = false;
  }

  Future<void> deleteCampaign(String campaignId) async {
    try {
      await _service.deleteCampaign(campaignId);
      Get.snackbar('Success', 'Campaign deleted successfully',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      print('Error deleting campaign: $e');
      Get.snackbar('Error', 'Failed to delete campaign',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> updateCampaign(BloodCampaign campaign) async {
    try {
      await _service.updateCampaign(campaign);
      Get.snackbar('Success', 'Campaign updated successfully',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      print('Error updating campaign: $e');
      Get.snackbar('Error', 'Failed to update campaign',
          snackPosition: SnackPosition.BOTTOM);
    }
  }
} 