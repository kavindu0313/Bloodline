import 'package:flutter/material.dart';
import '../../../../models/hospital_model.dart';
import '../../../../services/hospital_service.dart';

class EditHospitalScreen extends StatefulWidget {
  final Hospital hospital;

  const EditHospitalScreen({
    super.key,
    required this.hospital,
  });

  @override
  State<EditHospitalScreen> createState() => _EditHospitalScreenState();
}

class _EditHospitalScreenState extends State<EditHospitalScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _contactController;
  late final TextEditingController _totalBedsController;
  late final TextEditingController _availableBedsController;
  late final TextEditingController _departmentController;
  late final TextEditingController _doctorController;
  late List<String> _departments;
  late List<String> _doctorNames;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.hospital.name);
    _addressController = TextEditingController(text: widget.hospital.address);
    _contactController = TextEditingController(text: widget.hospital.contactNumber);
    _totalBedsController = TextEditingController(text: widget.hospital.totalBeds.toString());
    _availableBedsController = TextEditingController(text: widget.hospital.availableBeds.toString());
    _departmentController = TextEditingController();
    _doctorController = TextEditingController();
    _departments = List.from(widget.hospital.departments);
    _doctorNames = List.from(widget.hospital.doctorNames);
  }

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
    final updatedHospital = Hospital(
      id: widget.hospital.id,
      name: _nameController.text,
      address: _addressController.text,
      contactNumber: _contactController.text,
      totalBeds: int.parse(_totalBedsController.text),
      availableBeds: int.parse(_availableBedsController.text),
      departments: _departments,
      doctorNames: _doctorNames,
    );

    try {
      await HospitalService().updateHospital(updatedHospital);
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating hospital: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Hospital')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Hospital Name'),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(labelText: 'Address'),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _contactController,
              decoration: InputDecoration(labelText: 'Contact Number'),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _totalBedsController,
              decoration: InputDecoration(labelText: 'Total Beds'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _availableBedsController,
              decoration: InputDecoration(labelText: 'Available Beds'),
              keyboardType: TextInputType.number,
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
              child: Text('Update Hospital'),
            ),
          ],
        ),
      ),
    );
  }
} 