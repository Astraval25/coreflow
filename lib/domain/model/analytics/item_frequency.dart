class ItemFrequencyEntry {
  final int itemId;
  final String itemName;
  final double totalQuantity;
  final int orderCount;

  const ItemFrequencyEntry({
    required this.itemId,
    required this.itemName,
    required this.totalQuantity,
    required this.orderCount,
  });

  factory ItemFrequencyEntry.fromJson(Map<String, dynamic> json) =>
      ItemFrequencyEntry(
        itemId: (json['itemId'] as num?)?.toInt() ?? 0,
        itemName: json['itemName'] as String? ?? '',
        totalQuantity: (json['totalQuantity'] as num?)?.toDouble() ?? 0,
        orderCount: (json['orderCount'] as num?)?.toInt() ?? 0,
      );
}
