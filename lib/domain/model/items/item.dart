class Item {
  final int itemId;
  final String itemName;
  final String itemType;
  final String unit;
  final double salesPrice;
  final int? preferredCustomerId;
  final String? preferredCustomerName;
  final double? purchasePrice;
  final int? preferredVendorId;
  final String? preferredVendorName;
  final bool isActive;

  Item({
    required this.itemId,
    required this.itemName,
    required this.itemType,
    required this.unit,
    required this.salesPrice,
    this.preferredCustomerId,
    this.preferredCustomerName,
    this.purchasePrice,
    this.preferredVendorId,
    this.preferredVendorName,
    required this.isActive,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      itemId: json['itemId'],
      itemName: json['itemName'],
      itemType: json['itemType'],
      unit: json['unit'],
      salesPrice: (json['salesPrice'] as num).toDouble(),
      preferredCustomerId: json['preferredCustomerId'],
      preferredCustomerName: json['preferredCustomerName'],
      purchasePrice: json['purchasePrice'] != null
          ? (json['purchasePrice'] as num).toDouble()
          : null,
      preferredVendorId: json['preferredVendorId'],
      preferredVendorName: json['preferredVendorName'],
      isActive: json['isActive'],
    );
  }
}
