// add_blood_unit_form.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../../../services/firebase_inventory_service.dart';
import '../../../models/blood_unit.dart';
import '../../../utils/blood_type_utils.dart';
import '../../../mixins/firebase_init_mixin.dart';

//add blood unit form class
class AddBloodUnitForm extends StatefulWidget {
  const AddBloodUnitForm({super.key});

  @override
  _AddBloodUnitFormState createState() => _AddBloodUnitFormState();
}

class _AddBloodUnitFormState extends State<AddBloodUnitForm>
    with FirebaseInitMixin {
  final _formKey = GlobalKey<FormState>();
  final FirebaseInventoryService _inventoryService = FirebaseInventoryService();
  bool _isLoading = false;

  final RegExp _locationRegExp = RegExp(r'^[a-zA-Z\s]+$');
  final RegExp _donorIdRegExp = RegExp(r'^\d+$');

  String _selectedBloodType = 'A+';
  String _selectedStatus = 'Available';
  final TextEditingController _volumeController = TextEditingController();
  final TextEditingController _donorIdController = TextEditingController();
  final TextEditingController _storageLocationController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Blood Unit')),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Padding(
                padding: EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      // Blood Type Dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedBloodType,
                        decoration: InputDecoration(
                          labelText: 'Blood Type',
                          border: OutlineInputBorder(),
                        ),
                        items:
                            BloodTypeUtils.bloodTypes
                                .map(
                                  (type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(type),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedBloodType = value!;
                          });
                        },
                      ),
                      SizedBox(height: 16),

                      // Volume Input
                      TextFormField(
                        controller: _volumeController,
                        decoration: InputDecoration(
                          labelText: 'Volume (ml)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter volume';
                          }
                          final volume = double.tryParse(value);
                          if (volume == null || volume <= 0) {
                            return 'Please enter a valid volume';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),

                      // Donor ID Input
                      TextFormField(
                        controller: _donorIdController,
                        decoration: InputDecoration(
                          labelText: 'Donor ID',
                          border: OutlineInputBorder(),
                          hintText: 'Enter donor ID (numbers only)',
                          helperText: 'Only numbers are allowed',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter donor ID';
                          }
                          if (!_donorIdRegExp.hasMatch(value)) {
                            return 'Please enter only numbers';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          if (value.isNotEmpty &&
                              !_donorIdRegExp.hasMatch(value)) {
                            _donorIdController.text = value.replaceAll(
                              RegExp(r'[^\d]'),
                              '',
                            );
                            _donorIdController
                                .selection = TextSelection.fromPosition(
                              TextPosition(
                                offset: _donorIdController.text.length,
                              ),
                            );
                          }
                        },
                      ),
                      SizedBox(height: 16),

                      // Storage Location Input
                      TextFormField(
                        controller: _storageLocationController,
                        decoration: InputDecoration(
                          labelText: 'Storage Location',
                          border: OutlineInputBorder(),
                          hintText: 'Enter storage location (letters only)',
                          helperText: 'Only letters and spaces are allowed',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter storage location';
                          }
                          if (!_locationRegExp.hasMatch(value)) {
                            return 'Please enter only letters (no numbers or special characters)';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          if (value.isNotEmpty &&
                              !_locationRegExp.hasMatch(value)) {
                            _storageLocationController.text = value.replaceAll(
                              RegExp(r'[^a-zA-Z\s]'),
                              '',
                            );
                            _storageLocationController
                                .selection = TextSelection.fromPosition(
                              TextPosition(
                                offset: _storageLocationController.text.length,
                              ),
                            );
                          }
                        },
                        textCapitalization: TextCapitalization.words,
                      ),
                      SizedBox(height: 16),

                      // Status Dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        decoration: InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(),
                        ),
                        items:
                            ['Available', 'Reserved', 'Expired']
                                .map(
                                  (status) => DropdownMenuItem(
                                    value: status,
                                    child: Text(status),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value!;
                          });
                        },
                      ),
                      SizedBox(height: 24),

                      // Submit Button
                      ElevatedButton(
                        onPressed: _isLoading ? null : _submitBloodUnit,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          _isLoading ? 'Adding...' : 'Add Blood Unit',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  //submit blood unit method
  void _submitBloodUnit() async {
    if (!isFirebaseInitialized) {
      print('Firebase is not initialized yet');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Firebase is not initialized yet. Please wait...'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      int retryCount = 0;
      const maxRetries = 3;
      const timeoutDuration = Duration(seconds: 30);

      while (retryCount < maxRetries) {
        try {
          print('Creating blood unit with following details:');
          print('Blood Type: $_selectedBloodType');
          print('Volume: ${_volumeController.text}');
          print('Donor ID: ${_donorIdController.text}');
          print('Storage Location: ${_storageLocationController.text}');
          print('Status: $_selectedStatus');

          final bloodUnit = BloodUnit(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            bloodType: _selectedBloodType,
            donationDate: DateTime.now(),
            expiryDate: DateTime.now().add(Duration(days: 42)),
            donorId: _donorIdController.text,
            volume: double.parse(_volumeController.text),
            storageLocation: _storageLocationController.text,
            status: _selectedStatus,
          );

          print('Blood unit object created successfully');
          print('Blood unit JSON: ${bloodUnit.toJson()}');

          print(
            'Submitting blood unit to Firebase... (Attempt ${retryCount + 1}/$maxRetries)',
          );

          await _inventoryService
              .addBloodUnit(bloodUnit)
              .timeout(
                timeoutDuration,
                onTimeout: () {
                  throw TimeoutException(
                    'Operation timed out. Please check your connection and try again.',
                  );
                },
              );
          print('Blood unit added successfully to Firebase');

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Blood unit added successfully'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
            Navigator.pop(context); // Return to previous screen
          }
          return; // Success, exit the retry loop
        } catch (e, stackTrace) {
          print(
            'Error adding blood unit (Attempt ${retryCount + 1}/$maxRetries):',
          );
          print('Error: $e');
          print('Stack trace: $stackTrace');
          retryCount++;

          if (retryCount >= maxRetries) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });

              String errorMessage = 'Failed to add blood unit';
              if (e.toString().contains('PERMISSION_DENIED')) {
                errorMessage =
                    'Firebase Firestore is not enabled. Please contact administrator.';
              } else if (e is TimeoutException) {
                errorMessage =
                    'Operation timed out after multiple attempts. Please check your connection and try again.';
              } else if (e.toString().contains('network')) {
                errorMessage =
                    'Network error. Please check your internet connection and try again.';
              } else if (e.toString().contains('null')) {
                errorMessage =
                    'Firebase service is not properly initialized. Please restart the app.';
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(errorMessage),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 4),
                  action: SnackBarAction(
                    label: 'Dismiss',
                    textColor: Colors.white,
                    onPressed: () {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    },
                  ),
                ),
              );
            }
          } else {
            // Wait before retrying
            print('Waiting ${2 * retryCount} seconds before retrying...');
            await Future.delayed(Duration(seconds: 2 * retryCount));
          }
        }
      }
    }
  }

  //dispose method
  @override
  void dispose() {
    _volumeController.dispose();
    _donorIdController.dispose();
    _storageLocationController.dispose();
    super.dispose();
  }
}
