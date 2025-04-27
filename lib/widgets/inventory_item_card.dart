
// inventory_item_card.dart
import 'package:flutter/material.dart';
import '../models/inventory_item.dart';

class InventoryItemCard extends StatelessWidget {
  final InventoryItem inventoryItem;
  final VoidCallback? onTap;

  const InventoryItemCard({
    super.key,
    required this.inventoryItem,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Text(
          'Blood Type: ${inventoryItem.bloodType}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8),
            _buildInfoRow('Total Units', '${inventoryItem.totalUnits}'),
            _buildInfoRow('Oldest Unit', inventoryItem.oldestUnit.toString().split(' ')[0]),
            _buildInfoRow('Expiry Date', inventoryItem.latestExpiryDate.toString().split(' ')[0]),
          ],
        ),
        trailing: Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}