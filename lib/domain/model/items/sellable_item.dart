class SellableItem {
  final int itemId;
  final String itemName;
  final String description;
  final double price;
  final double taxRate;
  final String hsnCode;
  final String source;
  final String? fsId;

  SellableItem({
    required this.itemId,
    required this.itemName,
    required this.description,
    required this.price,
    required this.taxRate,
    required this.hsnCode,
    required this.source,
    this.fsId,
  });

  factory SellableItem.fromJson(Map<String, dynamic> json) {
    return SellableItem(
      itemId: _toInt(json['itemId']),
      itemName: (json['itemName'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      price: _toDouble(json['price']),
      taxRate: _toDouble(json['taxRate']),
      hsnCode: (json['hsnCode'] ?? '').toString(),
      source: (json['source'] ?? '').toString(),
      fsId: json['fsId']?.toString(),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
