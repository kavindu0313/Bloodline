import 'package:flutter/material.dart';
import '../../../../models/appointment_model.dart';
import '../../../../services/appointment_service.dart';
import '../../../../widgets/appointment_card.dart';
import '../../../../screens/user/appointments/appointment_details_screen.dart';

class HospitalAppointmentsScreen extends StatelessWidget {
  final String hospitalId;

  const HospitalAppointmentsScreen({
    super.key,
    required this.hospitalId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Hospital Appointments')),
      body: StreamBuilder<List<Appointment>>(
        stream: AppointmentService().getHospitalAppointments(hospitalId),
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
                  // Navigate to appointment details screen
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