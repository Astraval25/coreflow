class MarketplaceItem {
  final int itemId;
  final String itemName;
  final String? itemType;
  final String? unit;
  final String? salesDescription;
  final double? salesPrice;
  final double? taxRate;
  final String? hsnCode;
  final String? fsId;

  const MarketplaceItem({
    required this.itemId,
    required this.itemName,
    this.itemType,
    this.unit,
    this.salesDescription,
    this.salesPrice,
    this.taxRate,
    this.hsnCode,
    this.fsId,
  });

  factory MarketplaceItem.fromJson(Map<String, dynamic> json) {
    return MarketplaceItem(
      itemId: _toInt(json['itemId']),
      itemName: (json['itemName'] ?? '').toString(),
      itemType: json['itemType']?.toString(),
      unit: json['unit']?.toString(),
      salesDescription: json['salesDescription']?.toString(),
      salesPrice: _toDoubleOrNull(json['salesPrice']),
      taxRate: _toDoubleOrNull(json['taxRate']),
      hsnCode: json['hsnCode']?.toString(),
      fsId: json['fsId']?.toString(),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double? _toDoubleOrNull(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}
