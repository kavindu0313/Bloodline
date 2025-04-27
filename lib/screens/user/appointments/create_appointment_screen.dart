import 'package:flutter/material.dart';
import '../../../models/appointment_model.dart';
import '../../../models/hospital_model.dart';
import '../../../services/appointment_service.dart';
import '../../../services/hospital_service.dart';

class CreateAppointmentScreen extends StatefulWidget {
  const CreateAppointmentScreen({super.key});

  @override
  _CreateAppointmentScreenState createState() => _CreateAppointmentScreenState();
}

class _CreateAppointmentScreenState extends State<CreateAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _appointmentService = AppointmentService();
  final _hospitalService = HospitalService();
  
  String? _selectedHospitalId;
  String? _selectedHospitalName;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Appointment'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Hospital Selection
                    Text(
                      'Select Hospital',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 8),
                    StreamBuilder<List<Hospital>>(
                      stream: _hospitalService.getAllHospitals(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }

                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        }

                        final hospitals = snapshot.data ?? [];
                        return DropdownButtonFormField<String>(
                          value: _selectedHospitalId,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                          items: hospitals.map((hospital) {
                            return DropdownMenuItem(
                              value: hospital.id,
                              child: Text(hospital.name),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedHospitalId = value;
                              _selectedHospitalName = hospitals
                                  .firstWhere((h) => h.id == value)
                                  .name;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a hospital';
                            }
                            return null;
                          },
                        );
                      },
                    ),
                    SizedBox(height: 32),

                    // Date Selection
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Appointment Date',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: 8),
                        InkWell(
                          onTap: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(Duration(days: 30)),
                            );
                            if (picked != null) {
                              setState(() {
                                _selectedDate = picked;
                              });
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _selectedDate.toString().split(' ')[0],
                                  style: TextStyle(fontSize: 16),
                                ),
                                Icon(Icons.calendar_today),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 32),

                    // Create Button
                    ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        backgroundColor: Colors.purple,
                      ),
                      child: Text(
                        'Create Appointment',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final appointment = Appointment(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          patientId: 'current_user_id', // TODO: Get actual user ID
          hospitalId: _selectedHospitalId!,
          doctorName: 'TBD', // Will be assigned by hospital
          appointmentDate: _selectedDate,
          department: 'TBD', // Will be assigned by hospital
          status: AppointmentStatus.pending,
        );

        await _appointmentService.createAppointment(appointment);
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating appointment: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }
}
