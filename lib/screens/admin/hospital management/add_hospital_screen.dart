import 'package:flutter/material.dart';
import '../../../../models/hospital_model.dart';
import '../../../../services/hospital_service.dart';

class AddHospitalScreen extends StatefulWidget {
  const AddHospitalScreen({super.key});

  @override
  State<AddHospitalScreen> createState() => _AddHospitalScreenState();
}

class _AddHospitalScreenState extends State<AddHospitalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _contactController = TextEditingController();
  final _totalBedsController = TextEditingController();
  final _availableBedsController = TextEditingController();
  final _departmentController = TextEditingController();
  final _doctorController = TextEditingController();
  final List<String> _departments = [];
  final List<String> _doctorNames = [];

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    _totalBedsController.dispose();
    _availableBedsController.dispose();
    _departmentController.dispose();
    _doctorController.dispose();
    super.dispose();
  }

  void _addDepartment(String department) {
    if (department.isNotEmpty && !_departments.contains(department)) {
      setState(() {
        _departments.add(department);
        _departmentController.clear();
      });
    }
  }

  void _removeDepartment(String department) {
    setState(() {
      _departments.remove(department);
    });
  }

  void _addDoctor(String doctor) {
    if (doctor.isNotEmpty && !_doctorNames.contains(doctor)) {
      setState(() {
        _doctorNames.add(doctor);
        _doctorController.clear();
      });
    }
  }

  void _removeDoctor(String doctor) {
    setState(() {
      _doctorNames.remove(doctor);
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final hospital = Hospital(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        address: _addressController.text,
        contactNumber: _contactController.text,
        totalBeds: int.parse(_totalBedsController.text),
        availableBeds: int.parse(_availableBedsController.text),
        departments: _departments,
        doctorNames: _doctorNames,
      );

      try {
        await HospitalService().addHospital(hospital);
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding hospital: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Hospital')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Hospital Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter hospital name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(labelText: 'Address'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter address';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _contactController,
                decoration: InputDecoration(labelText: 'Contact Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter contact number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _totalBedsController,
                decoration: InputDecoration(labelText: 'Total Beds'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter total beds';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _availableBedsController,
                decoration: InputDecoration(labelText: 'Available Beds'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter available beds';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Text('Departments', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 8,
                children: _departments.map((dept) => Chip(
                  label: Text(dept),
                  onDeleted: () => _removeDepartment(dept),
                )).toList(),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _departmentController,
                      decoration: InputDecoration(
                        labelText: 'Add Department',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () => _addDepartment(_departmentController.text),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text('Doctors', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 8,
                children: _doctorNames.map((doctor) => Chip(
                  label: Text(doctor),
                  onDeleted: () => _removeDoctor(doctor),
                )).toList(),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _doctorController,
                      decoration: InputDecoration(
                        labelText: 'Add Doctor',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () => _addDoctor(_doctorController.text),
                  ),
                ],
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Add Hospital'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
