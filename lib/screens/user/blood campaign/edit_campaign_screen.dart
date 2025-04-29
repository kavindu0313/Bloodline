import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/blood_campaign_controller.dart';
import '../../../models/blood_campaign_model.dart';
import '../../../services/blood_campaign_service.dart';

class EditCampaignScreen extends StatefulWidget {
  const EditCampaignScreen({super.key});

  @override
  _EditCampaignScreenState createState() => _EditCampaignScreenState();
}

class _EditCampaignScreenState extends State<EditCampaignScreen> {
  final _formKey = GlobalKey<FormState>();
  final BloodCampaignController _controller = Get.find();
  final BloodCampaignService _service = BloodCampaignService();
  bool _isLoading = false;

  // Form controllers
  /// TextEditingController for each field
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late DateTime _selectedDate;
  late BloodCampaign _campaign;

  @override
  void initState() {
    super.initState();
    _campaign = Get.arguments as BloodCampaign;
    _titleController = TextEditingController(text: _campaign.title);
    _descriptionController = TextEditingController(text: _campaign.description);
    _locationController = TextEditingController(text: _campaign.location);
    _selectedDate = _campaign.date;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }
/// Function to select a date
  /// This function opens a date picker dialog and updates the selected date.
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
/// Function to submit the form
  /// This function validates the form, updates the campaign, and shows a success or error message.
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final updatedCampaign = BloodCampaign(
          id: _campaign.id,
          title: _titleController.text,
          description: _descriptionController.text,
          date: _selectedDate,
          location: _locationController.text,
          status: _campaign.status,
        );

        await _service.updateCampaign(updatedCampaign);
        Get.back(result: true);
        Get.snackbar(
          'Success',
          'Campaign updated successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
      } catch (e) {
        Get.snackbar(
          'Error',
          'Failed to update campaign',
          snackPosition: SnackPosition.BOTTOM,
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Blood Campaign'),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Campaign Title',
                        border: OutlineInputBorder(),
                        hintText: 'Enter campaign title',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),

                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                        hintText: 'Enter campaign description',
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),

                    // Date
                    InkWell(
                      onTap: () => _selectDate(context),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Campaign Date',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Location
                    TextFormField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        labelText: 'Location',
                        border: OutlineInputBorder(),
                        hintText: 'Enter campaign location',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a location';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 24),

                    // Submit Button
                    ElevatedButton(
                      onPressed: _submitForm,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Text('Update Campaign'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
} 