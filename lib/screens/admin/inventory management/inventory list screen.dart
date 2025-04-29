import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../../mixins/firebase_init_mixin.dart';
import '../../../services/firebase_inventory_service.dart';
import '../../../models/blood_unit.dart';

//inventory list screen class
class InventoryListScreen extends StatefulWidget {
  const InventoryListScreen({super.key});

  @override
  _InventoryListScreenState createState() => _InventoryListScreenState();
}

class _InventoryListScreenState extends State<InventoryListScreen>
    with FirebaseInitMixin {
  final FirebaseInventoryService _inventoryService = FirebaseInventoryService();

  // Regular expression for validation
  final RegExp _donorIdRegExp = RegExp(r'^\d+$');

  // Method to show update dialog
  void _showUpdateDialog(BloodUnit unit) {
    final volumeController = TextEditingController(
      text: unit.volume.toString(),
    );
    final donorIdController = TextEditingController(text: unit.donorId);
    String selectedStatus = unit.status ?? 'Available';
    String? donorIdError;
    //show dialog method
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Update Inventory Item'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Blood Type: ${unit.bloodType}'),
                    SizedBox(height: 16),
                    TextField(
                      controller: volumeController,
                      decoration: InputDecoration(
                        labelText: 'Volume (ml)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: donorIdController,
                      decoration: InputDecoration(
                        labelText: 'Donor ID',
                        border: OutlineInputBorder(),
                        hintText: 'Enter donor ID (numbers only)',
                        helperText: 'Only numbers are allowed',
                        errorText: donorIdError,
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (value) {
                        if (value.isNotEmpty &&
                            !_donorIdRegExp.hasMatch(value)) {
                          donorIdController.text = value.replaceAll(
                            RegExp(r'[^\d]'),
                            '',
                          );
                          donorIdController
                              .selection = TextSelection.fromPosition(
                            TextPosition(offset: donorIdController.text.length),
                          );
                        }
                        setState(() {
                          donorIdError =
                              value.isEmpty
                                  ? 'Please enter donor ID'
                                  : !_donorIdRegExp.hasMatch(value)
                                  ? 'Please enter only numbers'
                                  : null;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      decoration: InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                      ),
                      items:
                          ['Available', 'Reserved', 'Expired']
                              .map(
                                (status) => DropdownMenuItem(
                                  value: status,
                                  child: Text(status),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        selectedStatus = value!;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                ElevatedButton(
                  child: Text('Update'),
                  onPressed: () async {
                    // Validate input before updating
                    if (donorIdController.text.isEmpty ||
                        !_donorIdRegExp.hasMatch(donorIdController.text)) {
                      setState(() {
                        donorIdError =
                            donorIdController.text.isEmpty
                                ? 'Please enter donor ID'
                                : 'Please enter only numbers';
                      });
                      return;
                    }

                    final volume = double.tryParse(volumeController.text);
                    if (volume == null || volume <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please enter a valid volume')),
                      );
                      return;
                    }

                    final updatedUnit = BloodUnit(
                      id: unit.id,
                      bloodType: unit.bloodType,
                      donationDate: unit.donationDate,
                      expiryDate: unit.expiryDate,
                      donorId: donorIdController.text.toUpperCase(),
                      volume: volume,
                      storageLocation: unit.storageLocation,
                      status: selectedStatus,
                    );
                    await _inventoryService.updateBloodUnit(updatedUnit);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Method to delete an inventory item
  void _deleteInventoryItem(BloodUnit unit) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this inventory item?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Delete'),
              onPressed: () async {
                await _inventoryService.deleteBloodUnit(unit.id);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Method to generate CSV report
  Future<void> _generateCSVReport(List<BloodUnit> units) async {
    // Create CSV data
    List<List<dynamic>> csvData = [
      [
        'ID',
        'Blood Type',
        'Volume',
        'Donation Date',
        'Expiry Date',
        'Donor ID',
        'Status',
      ],
      ...units.map(
        (unit) => [
          unit.id,
          unit.bloodType,
          unit.volume,
          DateFormat('yyyy-MM-dd').format(unit.donationDate),
          DateFormat('yyyy-MM-dd').format(unit.expiryDate),
          unit.donorId,
          unit.status ?? 'Available',
        ],
      ),
    ];

    // Convert to CSV string
    String csv = const ListToCsvConverter().convert(csvData);

    // Get temporary directory
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/blood_inventory_report.csv');

    // Write to file
    await file.writeAsString(csv);

    // Show success dialog
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Report generated: ${file.path}')));
  }

  //build method
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Blood Inventory List'),
        actions: [
          StreamBuilder<List<BloodUnit>>(
            stream: _inventoryService.getBloodUnits(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return IconButton(
                  icon: Icon(Icons.file_download),
                  onPressed: null,
                  tooltip: 'Generate Report',
                );
              }
              return IconButton(
                icon: Icon(Icons.file_download),
                onPressed: () => _generateCSVReport(snapshot.data!),
                tooltip: 'Generate Report',
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<BloodUnit>>(
        stream: _inventoryService.getBloodUnits(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No blood units in inventory'));
          }

          final units = snapshot.data!;

          return ListView.builder(
            itemCount: units.length,
            itemBuilder: (context, index) {
              final unit = units[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text('${unit.bloodType} - ${unit.volume} ml'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Donor ID: ${unit.donorId}'),
                      Text('Status: ${unit.status ?? 'Available'}'),
                      Text(
                        'Donation Date: ${DateFormat('yyyy-MM-dd').format(unit.donationDate)}',
                      ),
                      Text(
                        'Expiry Date: ${DateFormat('yyyy-MM-dd').format(unit.expiryDate)}',
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showUpdateDialog(unit),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteInventoryItem(unit),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
