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
    return SellableItem._fromJson(json, preferPurchase: false);
  }

  factory SellableItem.fromCustomerJson(Map<String, dynamic> json) {
    return SellableItem._fromJson(json, preferPurchase: false);
  }

  factory SellableItem.fromVendorJson(Map<String, dynamic> json) {
    return SellableItem._fromJson(json, preferPurchase: true);
  }

  factory SellableItem._fromJson(
    Map<String, dynamic> json, {
    required bool preferPurchase,
  }) {
    return SellableItem(
      itemId: _toInt(json['itemId']),
      itemName: (json['itemName'] ?? '').toString(),
      description: _pickDescription(json, preferPurchase: preferPurchase),
      price: _pickPrice(json, preferPurchase: preferPurchase),
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
    return _toDoubleOrNull(value) ?? 0;
  }

  static double? _toDoubleOrNull(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static double _pickPrice(
    Map<String, dynamic> json, {
    required bool preferPurchase,
  }) {
    if (preferPurchase) {
      return _toDoubleOrNull(json['purchasePrice']) ??
          _toDoubleOrNull(json['price']) ??
          _toDouble(json['salesPrice']);
    }

    return _toDoubleOrNull(json['salesPrice']) ??
        _toDoubleOrNull(json['price']) ??
        _toDouble(json['purchasePrice']);
  }

  static String _pickDescription(
    Map<String, dynamic> json, {
    required bool preferPurchase,
  }) {
    final purchaseDescription = (json['purchaseDescription'] ?? '').toString();
    final salesDescription = (json['salesDescription'] ?? '').toString();
    final description = (json['description'] ?? '').toString();

    if (preferPurchase) {
      if (purchaseDescription.trim().isNotEmpty) return purchaseDescription;
      if (description.trim().isNotEmpty) return description;
      return salesDescription;
    }

    if (salesDescription.trim().isNotEmpty) return salesDescription;
    if (description.trim().isNotEmpty) return description;
    return purchaseDescription;
  }
}
