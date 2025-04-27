import 'package:flutter/material.dart';
import '../../../models/appointment_model.dart';
import '../../../services/appointment_service.dart';

class EditAppointmentScreen extends StatefulWidget {
  final Appointment appointment;

  const EditAppointmentScreen({
    super.key,
    required this.appointment,
  });

  @override
  State<EditAppointmentScreen> createState() => _EditAppointmentScreenState();
}

class _EditAppointmentScreenState extends State<EditAppointmentScreen> {
  late final TextEditingController _doctorController;
  late final TextEditingController _departmentController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _doctorController = TextEditingController(text: widget.appointment.doctorName);
    _departmentController = TextEditingController(text: widget.appointment.department);
    _selectedDate = widget.appointment.appointmentDate;
  }

  @override
  void dispose() {
    _doctorController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    try {
      await AppointmentService().modifyAppointment(
        appointmentId: widget.appointment.id,
        newDate: _selectedDate,
        newDoctorName: _doctorController.text,
        newDepartment: _departmentController.text,
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating appointment: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Appointment')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _doctorController,
              decoration: InputDecoration(labelText: 'Doctor Name'),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _departmentController,
              decoration: InputDecoration(labelText: 'Department'),
            ),
            SizedBox(height: 16),
            ListTile(
              title: Text('Appointment Date'),
              subtitle: Text(_selectedDate.toLocal().toString()),
              trailing: Icon(Icons.calendar_today),
              onTap: () => _selectDate(context),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitForm,
              child: Text('Update Appointment'),
            ),
          ],
        ),
      ),
    );
  }
} 