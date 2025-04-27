import 'package:flutter/material.dart';
import '../../../services/firebase_inventory_service.dart';
import '../../../models/inventory_item.dart';
import 'inventory list screen.dart';
import 'add_blood_unit_screen.dart';
import '../../../mixins/firebase_init_mixin.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  _InventoryScreenState createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> with FirebaseInitMixin {
  final FirebaseInventoryService _inventoryService = FirebaseInventoryService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Blood Inventory'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => _inventoryService.removeExpiredUnits(),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => InventoryListScreen()),
                    );
                  },
                  icon: Icon(Icons.list),
                  label: Text('View Inventory List'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddBloodUnitForm()),
                    );
                  },
                  icon: Icon(Icons.add),
                  label: Text('Add Blood Unit'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<InventoryItem>>(
              stream: _inventoryService.getInventorySummary(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No blood units in inventory'));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final inventoryItem = snapshot.data![index];
                    return Card(
                      child: ListTile(
                        title: Text('Blood Type: ${inventoryItem.bloodType}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Total Units: ${inventoryItem.totalUnits}'),
                            Text('Oldest Unit: ${inventoryItem.oldestUnit}'),
                            Text('Expiry Date: ${inventoryItem.latestExpiryDate}'),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}