import 'package:flutter/material.dart';
import '../../../../models/hospital_model.dart';
import '../../../../services/hospital_service.dart';
import '../../../../widgets/hospital_card.dart';
import 'add_hospital_screen.dart';
import 'hospital_details_screen.dart';

class HospitalListScreen extends StatelessWidget {
  const HospitalListScreen({super.key});

  Future<void> _deleteHospital(BuildContext context, Hospital hospital) async {
    try {
      await HospitalService().deleteHospital(hospital.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hospital deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting hospital: $e')),
      );
    }
  }

  void _showDeleteConfirmation(BuildContext context, Hospital hospital) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete ${hospital.name}?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteHospital(context, hospital);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hospitals'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddHospitalScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Hospital>>(
        stream: HospitalService().getAllHospitals(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final hospitals = snapshot.data ?? [];

          if (hospitals.isEmpty) {
            return Center(child: Text('No hospitals found'));
          }

          return ListView.builder(
            itemCount: hospitals.length,
            itemBuilder: (context, index) {
              final hospital = hospitals[index];
              return HospitalCard(
                hospital: hospital,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HospitalDetailsScreen(hospital: hospital),
                    ),
                  );
                },
                onDelete: () => _showDeleteConfirmation(context, hospital),
              );
            },
          );
        },
      ),
    );
  }
}
