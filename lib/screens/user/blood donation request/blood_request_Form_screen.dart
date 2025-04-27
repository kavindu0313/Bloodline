import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import '../../../controller/Donor_Matching_Controller.dart';
import '../../../models/blood_request.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../../mixins/firebase_init_mixin.dart';
import '../../../services/firebase_service.dart';

class BloodRequestForm extends StatefulWidget {
  const BloodRequestForm({super.key});

  @override
  _BloodRequestFormState createState() => _BloodRequestFormState();
}

class _BloodRequestFormState extends State<BloodRequestForm> with FirebaseInitMixin {
  final _formKey = GlobalKey<FormState>();
  final DonorMatchingController _controller = Get.find();
  final FirebaseService _firebaseService = FirebaseService();
  bool _isSubmitting = false;

  // Regular expression for name validation (only letters and spaces)
  final RegExp _nameRegExp = RegExp(r'^[a-zA-Z\s]+$');

  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _hospitalController = TextEditingController();

  String _selectedBloodType = 'A+';
  String _selectedUrgency = 'Medium';

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _hospitalController.dispose();
    super.dispose();
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar(
        'Location Services Disabled',
        'Please enable location services to continue.',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 5),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar(
          'Location Permission Denied',
          'Location permissions are required to submit a blood request.',
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 5),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Get.dialog(
        AlertDialog(
          title: Text('Location Permission Required'),
          content: Text(
            'Location permissions are permanently denied. Please enable them in your device settings.',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text('OK'),
            ),
            TextButton(
              onPressed: () => Geolocator.openAppSettings(),
              child: Text('Open Settings'),
            ),
          ],
        ),
      );
      return;
    }
  }

  Future<Position?> _getCurrentLocation() async {
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 5),
      );
    } catch (e) {
      print('Error getting location: $e');
      Get.snackbar(
        'Location Error',
        'Unable to get current location. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Blood Donation Request'),
        centerTitle: true,
      ),
      body: _isSubmitting
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Recipient Name
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Recipient Name',
                        border: OutlineInputBorder(),
                        hintText: 'Enter recipient name (letters only)',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter recipient name';
                        }
                        if (!_nameRegExp.hasMatch(value)) {
                          return 'Please enter only letters (no numbers or special characters)';
                        }
                        return null;
                      },
                      // Prevent numeric input
                      onChanged: (value) {
                        if (value.isNotEmpty && !_nameRegExp.hasMatch(value)) {
                          _nameController.text = value.replaceAll(RegExp(r'[^a-zA-Z\s]'), '');
                          _nameController.selection = TextSelection.fromPosition(
                            TextPosition(offset: _nameController.text.length),
                          );
                        }
                      },
                      textCapitalization: TextCapitalization.words, // Capitalize each word
                    ),
                    SizedBox(height: 16),

                    // Hospital Name
                    TextFormField(
                      controller: _hospitalController,
                      decoration: InputDecoration(
                        labelText: 'Hospital Name',
                        border: OutlineInputBorder(),
                        hintText: 'Enter hospital name (letters only)',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter hospital name';
                        }
                        if (!_nameRegExp.hasMatch(value)) {
                          return 'Please enter only letters (no numbers or special characters)';
                        }
                        return null;
                      },
                      // Prevent numeric input
                      onChanged: (value) {
                        if (value.isNotEmpty && !_nameRegExp.hasMatch(value)) {
                          _hospitalController.text = value.replaceAll(RegExp(r'[^a-zA-Z\s]'), '');
                          _hospitalController.selection = TextSelection.fromPosition(
                            TextPosition(offset: _hospitalController.text.length),
                          );
                        }
                      },
                      textCapitalization: TextCapitalization.words, // Capitalize each word
                    ),
                    SizedBox(height: 16),

                    // Blood Type Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedBloodType,
                      decoration: InputDecoration(
                        labelText: 'Blood Type',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        'A+', 'A-', 'B+', 'B-', 
                        'AB+', 'AB-', 'O+', 'O-'
                      ].map((String bloodType) {
                        return DropdownMenuItem(
                          value: bloodType,
                          child: Text(bloodType),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedBloodType = newValue!;
                        });
                      },
                    ),
                    SizedBox(height: 16),

                    // Urgency Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedUrgency,
                      decoration: InputDecoration(
                        labelText: 'Urgency Level',
                        border: OutlineInputBorder(),
                      ),
                      items: ['Low', 'Medium', 'High', 'Critical']
                          .map((String urgency) {
                        return DropdownMenuItem(
                          value: urgency,
                          child: Text(urgency),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedUrgency = newValue!;
                        });
                      },
                    ),
                    SizedBox(height: 24),

                    // Submit Button
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitRequest,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text('Submit Blood Request'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void _submitRequest() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);
      try {
        // Get current location
        final position = await _getCurrentLocation();
        if (position == null) {
          setState(() => _isSubmitting = false);
          return;
        }

        // Get FCM token
        final token = await FirebaseMessaging.instance.getToken() ?? '';

        // Create Blood Request Object
        BloodRequest request = BloodRequest(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          recipientToken: token,
          recipientName: _nameController.text,
          hospitalName: _hospitalController.text,
          bloodType: _selectedBloodType,
          location: _hospitalController.text,
          urgency: _selectedUrgency,
          latitude: position.latitude,
          longitude: position.longitude,
          status: 'pending',
        );

        // Store the request in Firestore first
        await _firebaseService.storeBloodRequest(request);
        print('Blood request stored successfully with ID: ${request.id}');

        // Process the blood request for donor matching
        await _controller.processBloodRequest(request);
        print('Blood request processed for donor matching');

        // Show success dialog
        await Get.dialog(
          AlertDialog(
            title: Text('Request Submitted'),
            content: Text('Your blood request has been submitted successfully.'),
            actions: [
              TextButton(
                onPressed: () async {
                  Get.back(); // Close dialog
                  await Get.offNamed('/blood-request-management'); // Navigate to management screen using named route
                },
                child: Text('View Requests'),
              ),
              TextButton(
                onPressed: () {
                  Get.back(); // Close dialog
                  Get.back(); // Go back to previous screen
                },
                child: Text('OK'),
              ),
            ],
          ),
          barrierDismissible: false, // Prevent dismissing by tapping outside
        );
      } catch (e) {
        print('Error submitting blood request: $e');
        Get.snackbar(
          'Error',
          'Failed to submit blood request: $e',
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 5),
        );
      } finally {
        setState(() => _isSubmitting = false);
      }
    }
  }
}