import 'package:flutter/material.dart';
import '../../../models/appointment_model.dart';
import '../../../services/appointment_service.dart';
import '../../../widgets/appointment_card.dart';
import 'appointment_details_screen.dart';
import 'create_appointment_screen.dart';

class AppointmentListScreen extends StatelessWidget {
  const AppointmentListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appointments'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateAppointmentScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Appointment>>(
        stream: AppointmentService().getAllAppointments(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final appointments = snapshot.data ?? [];

          if (appointments.isEmpty) {
            return Center(child: Text('No appointments found'));
          }

          return ListView.builder(
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final appointment = appointments[index];
              return AppointmentCard(
                appointment: appointment,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AppointmentDetailsScreen(appointment: appointment),
                    ),
                  );
                },
                onCancel: () async {
                  try {
                    await AppointmentService().updateAppointmentStatus(
                      appointment.id,
                      AppointmentStatus.cancelled.toString().split('.').last,
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error cancelling appointment: $e')),
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
