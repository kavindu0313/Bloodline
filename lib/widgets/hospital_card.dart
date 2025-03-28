import 'package:flutter/material.dart';
import '../../models/hospital_model.dart';

class HospitalCard extends StatelessWidget {
  final Hospital hospital;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const HospitalCard({
    super.key, 
    required this.hospital, 
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: Colors.red[100],
          child: Icon(
            Icons.local_hospital, 
            color: Colors.red,
          ),
        ),
        title: Text(
          hospital.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8),
            Text(
              hospital.address,
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 4),
            Text(
              'Contact: ${hospital.contactNumber}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 4),
            Text(
              'Available Beds: ${hospital.availableBeds}/${hospital.totalBeds}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: hospital.departments
                  .map((dept) => Chip(
                        label: Text(dept),
                        backgroundColor: Colors.red[50],
                      ))
                  .toList(),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onDelete != null)
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: onDelete,
              ),
            Icon(Icons.chevron_right),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}