import 'package:flutter/material.dart';
import '../../../../models/hospital_model.dart';
import 'edit_hospital_screen.dart';
import 'hospital_appointments_screen.dart';

class HospitalDetailsScreen extends StatelessWidget {
  final Hospital hospital;

  const HospitalDetailsScreen({
    super.key,
    required this.hospital,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hospital Details'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              // Navigate to edit hospital screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditHospitalScreen(hospital: hospital),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              hospital.name,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            _buildInfoRow('Address', hospital.address),
            _buildInfoRow('Contact', hospital.contactNumber),
            _buildInfoRow('Total Beds', hospital.totalBeds.toString()),
            _buildInfoRow('Available Beds', hospital.availableBeds.toString()),
            SizedBox(height: 16),
            Text(
              'Departments',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: hospital.departments
                  .map((dept) => Chip(label: Text(dept)))
                  .toList(),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HospitalAppointmentsScreen(hospitalId: hospital.id),
                  ),
                );
              },
              child: Text('View Appointments'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
} 