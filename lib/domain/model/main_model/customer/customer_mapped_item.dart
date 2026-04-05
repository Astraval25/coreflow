class CustomerMappedItem {
  final int itemId;
  final String itemName;
  final String itemType;
  final String unit;
  final double salesPrice;
  final String? salesDescription;
  final String? hsnCode;
  final double? taxRate;
  final bool isActive;
  final bool editable;
  final String? source;
  final String? fsId;

  CustomerMappedItem({
    required this.itemId,
    required this.itemName,
    required this.itemType,
    required this.unit,
    required this.salesPrice,
    this.salesDescription,
    this.hsnCode,
    this.taxRate,
    required this.isActive,
    required this.editable,
    this.source,
    this.fsId,
  });

  factory CustomerMappedItem.fromJson(Map<String, dynamic> json) {
    return CustomerMappedItem._fromJson(json, preferPurchase: false);
  }

  factory CustomerMappedItem.fromVendorJson(Map<String, dynamic> json) {
    return CustomerMappedItem._fromJson(json, preferPurchase: true);
  }

  factory CustomerMappedItem._fromJson(
    Map<String, dynamic> json, {
    required bool preferPurchase,
  }) {
    final salesPrice = _toDouble(json['salesPrice']);
    final purchasePrice = _toDouble(json['purchasePrice']);
    final salesDescription = _toStringOrNull(json['salesDescription']);
    final purchaseDescription = _toStringOrNull(
      json['purchaseDescription'],
    );
    final editable = _toBool(json['editable']);

    return CustomerMappedItem(
      itemId: _toInt(json['itemId']),
      itemName: (json['itemName'] ?? '').toString(),
      itemType: (json['itemType'] ?? '').toString(),
      unit: (json['unit'] ?? '').toString(),
      salesPrice: preferPurchase
          ? (purchasePrice ?? salesPrice ?? 0)
          : (salesPrice ?? purchasePrice ?? 0),
      salesDescription: preferPurchase
          ? (purchaseDescription ?? salesDescription)
          : (salesDescription ?? purchaseDescription),
      hsnCode: _toStringOrNull(json['hsnCode']),
      taxRate: _toDouble(json['taxRate']),
      isActive: json['isActive'] == true,
      editable: editable ?? true,
      source: _toStringOrNull(json['source']),
      fsId: _toStringOrNull(json['fsId']),
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

  static String? _toStringOrNull(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  static bool? _toBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is num) return value != 0;
    final text = value.toString().trim().toLowerCase();
    if (text.isEmpty) return null;
    if (text == 'true' || text == '1' || text == 'yes') return true;
    if (text == 'false' || text == '0' || text == 'no') return false;
    return null;
  }
}
