import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'admin/inventory management/inventory_screen.dart';
import 'admin/hospital management/hospital_list_screen.dart';
import 'user/appointments/appointment_list_screen.dart';
import 'user/appointments/create_appointment_screen.dart';
import 'user/blood campaign/blood_campaign_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Blood Bank Dashboard'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Blood Inventory Section
            Text(
              'Blood Inventory',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: Icon(Icons.inventory, size: 40),
                title: Text('Blood Inventory Management'),
                subtitle: Text('View and manage blood inventory'),
                onTap: () {
                  Get.to(() => InventoryScreen());
                },
              ),
            ),
            SizedBox(height: 24),

            // Hospital Management Section
            Text(
              'Hospital Management',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: Icon(Icons.local_hospital, size: 40),
                title: Text('Manage Hospitals'),
                subtitle: Text('View and manage hospitals'),
                onTap: () {
                  Get.to(() => HospitalListScreen());
                },
              ),
            ),
            SizedBox(height: 24),

            // Appointments Section
            Text(
              'Appointments',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: Icon(Icons.calendar_today, size: 40),
                title: Text('View Appointments'),
                subtitle: Text('View all appointments'),
                onTap: () {
                  Get.to(() => AppointmentListScreen());
                },
              ),
            ),
            SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: Icon(Icons.add_circle, size: 40),
                title: Text('Create Appointment'),
                subtitle: Text('Schedule a new appointment'),
                onTap: () {
                  Get.to(() => CreateAppointmentScreen());
                },
              ),
            ),
            SizedBox(height: 24),

            // Blood Campaigns Section
            Text(
              'Blood Campaigns',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: Icon(Icons.campaign, size: 40),
                title: Text('Blood Donation Campaigns'),
                subtitle: Text('View and manage blood donation campaigns'),
                onTap: () {
                  Get.to(() => BloodCampaignScreen());
                },
              ),
            ),
            SizedBox(height: 24),

            // Blood Requests Section
            Text(
              'Blood Requests',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: Icon(Icons.bloodtype, size: 40),
                title: Text('Blood Request Form'),
                subtitle: Text('Submit a new blood donation request'),
                onTap: () {
                  Get.toNamed('/blood-request-form');
                },
              ),
            ),
            SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: Icon(Icons.list_alt, size: 40),
                title: Text('Manage Blood Requests'),
                subtitle: Text('View, edit, and delete blood requests'),
                onTap: () {
                  Get.toNamed('/blood-request-management');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
} 