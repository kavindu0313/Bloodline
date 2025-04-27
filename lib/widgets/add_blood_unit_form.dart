// add_blood_unit_form.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/blood_unit.dart';
import '../services/firebase_inventory_service.dart';
import '../utils/blood_type_utils.dart';

class AddBloodUnitForm extends StatefulWidget {
  const AddBloodUnitForm({super.key});

  @override
  _AddBloodUnitFormState createState() => _AddBloodUnitFormState();
}

class _AddBloodUnitFormState extends State<AddBloodUnitForm> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseInventoryService _inventoryService = FirebaseInventoryService();

  String _selectedBloodType = 'A+';
  final TextEditingController _volumeController = TextEditingController();
  final TextEditingController _donorIdController = TextEditingController();
  final TextEditingController _storageLocationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Blood Unit'),
      ),
      body: Padding(
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
                items: BloodTypeUtils.bloodTypes
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
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
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter volume';
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
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter donor ID';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Storage Location Input
              TextFormField(
                controller: _storageLocationController,
                decoration: InputDecoration(
                  labelText: 'Storage Location',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter storage location';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),

              // Submit Button
              ElevatedButton(
                onPressed: _submitBloodUnit,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text('Add Blood Unit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitBloodUnit() {
    if (_formKey.currentState!.validate()) {
      final bloodUnit = BloodUnit(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // Unique ID
        bloodType: _selectedBloodType,
        donationDate: DateTime.now(),
        expiryDate: DateTime.now().add(Duration(days: 42)), // 6 weeks standard expiry
        donorId: _donorIdController.text,
        volume: double.parse(_volumeController.text),
        storageLocation: _storageLocationController.text,
      );

      _inventoryService.addBloodUnit(bloodUnit);

      // Show success dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Success'),
          content: Text('Blood unit added to inventory'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Return to previous screen
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    _volumeController.dispose();
    _donorIdController.dispose();
    _storageLocationController.dispose();
    super.dispose();
  }
}