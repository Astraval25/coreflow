class PurchaseOrderItem {
  final int orderItemId;
  final int itemId;
  final String itemName;
  final String? itemDescription;
  final double quantity;
  final double unitPrice;
  final double itemTotal;
  final double readyStatus;
  final bool isActive;

  PurchaseOrderItem({
    required this.orderItemId,
    required this.itemId,
    required this.itemName,
    this.itemDescription,
    required this.quantity,
    required this.unitPrice,
    required this.itemTotal,
    required this.readyStatus,
    required this.isActive,
  });

  factory PurchaseOrderItem.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderItem(
      orderItemId: _asInt(json['orderItemId']),
      itemId: _asInt(json['itemId']),
      itemName: json['itemName']?.toString() ?? '',
      itemDescription: json['itemDescription']?.toString(),
      quantity: _asDouble(json['quantity']),
      unitPrice: _asDouble(
        json['updatedPrice'] ?? json['purchasePrice'] ?? json['unitPrice'],
      ),
      itemTotal: _asDouble(json['itemTotal']),
      readyStatus: _asDouble(json['readyStatus']),
      isActive: _asBool(json['isActive']),
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static bool _asBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final normalized = value?.toString().toLowerCase().trim();
    return normalized == 'true' || normalized == '1' || normalized == 'yes';
  }
}
