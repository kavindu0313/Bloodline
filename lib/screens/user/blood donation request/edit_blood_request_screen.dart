import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/blood_request.dart';
import '../../../services/firebase_service.dart';

class EditBloodRequestScreen extends StatefulWidget {
  const EditBloodRequestScreen({super.key});

  @override
  _EditBloodRequestScreenState createState() => _EditBloodRequestScreenState();
}

class _EditBloodRequestScreenState extends State<EditBloodRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseService _firebaseService = FirebaseService();
  late BloodRequest _request;
  bool _isLoading = false;

  // Regular expression for name validation (only letters and spaces)
  final RegExp _nameRegExp = RegExp(r'^[a-zA-Z\s]+$');

  // Form controllers
  late TextEditingController _nameController;
  late TextEditingController _hospitalController;
  late String _selectedBloodType;
  late String _selectedUrgency;

  @override
  void initState() {
    super.initState();
    _request = Get.arguments as BloodRequest;
    _nameController = TextEditingController(text: _request.recipientName);
    _hospitalController = TextEditingController(text: _request.hospitalName);
    _selectedBloodType = _request.bloodType;
    _selectedUrgency = _request.urgency;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _hospitalController.dispose();
    super.dispose();
  }

  Future<void> _updateRequest() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final updatedRequest = BloodRequest(
          id: _request.id,
          recipientToken: _request.recipientToken,
          recipientName: _nameController.text,
          hospitalName: _hospitalController.text,
          bloodType: _selectedBloodType,
          location: _hospitalController.text,
          urgency: _selectedUrgency,
          latitude: _request.latitude,
          longitude: _request.longitude,
          status: _request.status,
        );

        await _firebaseService.updateBloodRequest(updatedRequest);
        Get.back(result: true);
        Get.snackbar(
          'Success',
          'Blood request updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 3),
        );
      } catch (e) {
        print('Error updating blood request: $e');
        Get.snackbar(
          'Error',
          'Failed to update blood request: $e',
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 5),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Blood Request'),
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
                    // Recipient Name
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Recipient Name',
                        border: OutlineInputBorder(),
                        hintText: 'Enter recipient name (letters only)',
                        helperText: 'Only letters and spaces are allowed',
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
                        helperText: 'Only letters and spaces are allowed',
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

                    // Status Display
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _getStatusColor(_request.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _getStatusColor(_request.status),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _getStatusIcon(_request.status),
                            color: _getStatusColor(_request.status),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Status: ${_request.status.toUpperCase()}',
                            style: TextStyle(
                              color: _getStatusColor(_request.status),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),

                    // Update Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _updateRequest,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 2,
                        ),
                        child: _isLoading
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Updating...',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                'Update Blood Request',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: 20), // Add some padding at the bottom
                  ],
                ),
              ),
            ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'matched':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.pending;
      case 'matched':
        return Icons.check_circle;
      case 'completed':
        return Icons.done_all;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }
} 