import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/blood_campaign_controller.dart';
import '../../../models/blood_campaign_model.dart';
import '../../../services/blood_campaign_service.dart';
//CreateCampaignScreen
class CreateCampaignScreen extends StatefulWidget {
  const CreateCampaignScreen({super.key});

  @override
  _CreateCampaignScreenState createState() => _CreateCampaignScreenState();
}

class _CreateCampaignScreenState extends State<CreateCampaignScreen> {
  final _formKey = GlobalKey<FormState>();
  final BloodCampaignController _controller = Get.find();
  final BloodCampaignService _service = BloodCampaignService();
  bool _isLoading = false;

  // Form controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

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

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Create a new BloodCampaign object
        final campaign = BloodCampaign(
          id: '', // ID will be assigned by Firestore
          title: _titleController.text,
          description: _descriptionController.text,
          date: _selectedDate,
          location: _locationController.text,
          status: 'active',
        );
        //if Campaign created successfully
        await _service.createCampaign(campaign);
        Get.back(result: true);
        Get.snackbar(
          'Success',
          'Campaign created successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
      } catch (e) {
        // Handle error
        Get.snackbar(
          'Error',
          'Failed to create campaign',
          snackPosition: SnackPosition.BOTTOM,
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
 /// Build the UI
  /// This method builds the UI for the Create Campaign screen.
  /// It includes a form with fields for the campaign title, description, date, and location.
  /// It also includes a button to submit the form and create the campaign.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Blood Campaign'),
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
                    // Campaign Title
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

                    // Description.
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
                    // Campaign Date
                    // This field allows the user to select a date for the campaign.
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
                        child: Text('Create Campaign'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
} 