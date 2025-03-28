import 'package:flutter/material.dart';
import '../../../models/appointment_model.dart';
import '../../../services/appointment_service.dart';
import 'edit_appointment_screen.dart';

class AppointmentDetailsScreen extends StatelessWidget {
  final Appointment appointment;

  const AppointmentDetailsScreen({
    super.key,
    required this.appointment,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appointment Details'),
        actions: [
          if (appointment.status != AppointmentStatus.cancelled)
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                // Navigate to edit appointment screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditAppointmentScreen(appointment: appointment),
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
            _buildInfoRow('Date', appointment.appointmentDate.toLocal().toString()),
            _buildInfoRow('Doctor', appointment.doctorName),
            _buildInfoRow('Department', appointment.department),
            _buildInfoRow('Status', appointment.status.toString().split('.').last),
            SizedBox(height: 24),
            if (appointment.status != AppointmentStatus.cancelled)
              ElevatedButton(
                onPressed: () async {
                  try {
                    await AppointmentService().updateAppointmentStatus(
                      appointment.id,
                      AppointmentStatus.cancelled.toString().split('.').last,
                    );
                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error cancelling appointment: $e')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: Text('Cancel Appointment'),
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
