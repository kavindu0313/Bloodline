import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/blood_campaign_controller.dart';
import '../../../models/blood_campaign_model.dart';
import '../../../widgets/campaign_card.dart';

class BloodCampaignScreen extends StatelessWidget {
  final BloodCampaignController controller = Get.put(BloodCampaignController());

   BloodCampaignScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Blood Donation Campaigns'), #Blood Donation Campaigns
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }
        //No active blood donation campaigns
        if (controller.campaigns.isEmpty) {
          return Center(
            child: Text(
              'No active blood donation campaigns',
              style: TextStyle(fontSize: 18),
            ),
          );
        }

        return ListView.builder(
          itemCount: controller.campaigns.length,
          itemBuilder: (context, index) {
            BloodCampaign campaign = controller.campaigns[index];
            return CampaignCard(
              campaign: campaign,
              onTap: () {
                // Navigate to campaign details.
                Get.toNamed('/campaign-details', arguments: campaign);
              },
              onEdit: () async {
                // Navigate to edit screen.
                final result = await Get.toNamed(
                  '/edit-campaign',
                  arguments: campaign,
                );
                if (result == true) {
                  controller.fetchActiveCampaigns();
                }
              },
              onDelete: () {
                Get.dialog(
                  AlertDialog(
                    title: Text('Delete Campaign'), //Delete Campaign
                    content: Text('Are you sure you want to delete this campaign?'),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          Get.back();
                          await controller.deleteCampaign(campaign.id);
                          controller.fetchActiveCampaigns();
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navigate to create campaign screen
          final result = await Get.toNamed('/create-campaign');
          if (result == true) {
            controller.fetchActiveCampaigns();
          }
        },
        tooltip: 'Create New Campaign',
        child: Icon(Icons.add),
      ),
    );
  }
}