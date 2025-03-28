class InventoryItem {
  final String bloodType;
  final int totalUnits;
  final DateTime oldestUnit;
  final DateTime latestExpiryDate;

  InventoryItem({
    required this.bloodType,
    required this.totalUnits,
    required this.oldestUnit,
    required this.latestExpiryDate,
  });
}