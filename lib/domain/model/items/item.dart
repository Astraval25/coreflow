class Item {
  final int itemId;
  final String itemName;
  final String itemType;
  final String unit;
  final double baseSalesPrice;
  final double? basePurchasePrice;
  final String? salesDescription;
  final String? purchaseDescription;
  final String? hsnCode;
  final double? taxRate;
  final bool isActive;
  final bool isSellable;
  final bool isPurchasable;

  Item({
    required this.itemId,
    required this.itemName,
    required this.itemType,
    required this.unit,
    required this.baseSalesPrice,
    this.basePurchasePrice,
    this.salesDescription,
    this.purchaseDescription,
    this.hsnCode,
    this.taxRate,
    required this.isActive,
    required this.isSellable,
    required this.isPurchasable,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      itemId: _toInt(json['itemId']),
      itemName: (json['itemName'] ?? '').toString(),
      itemType: (json['itemType'] ?? '').toString(),
      unit: (json['unit'] ?? '').toString(),
      baseSalesPrice: _toDouble(json['baseSalesPrice']) ?? 0,
      basePurchasePrice: _toDouble(json['basePurchasePrice']),
      salesDescription: _toNullableString(json['salesDescription']),
      purchaseDescription: _toNullableString(json['purchaseDescription']),
      hsnCode: _toNullableString(json['hsnCode']),
      taxRate: _toDouble(json['taxRate']),
      isActive: json['isActive'] == true,
      isSellable: json['isSellable'] == true,
      isPurchasable: json['isPurchasable'] == true,
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static String? _toNullableString(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }
}
