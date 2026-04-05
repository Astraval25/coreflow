class SalesOrderItem {
  final int orderItemId;
  final int itemId;
  final String itemName;
  final String? itemDescription;
  final double quantity;
  final double unitPrice;
  final double itemTotal;
  final double readyStatus;
  final bool isActive;

  SalesOrderItem({
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

  factory SalesOrderItem.fromJson(Map<String, dynamic> json) {
    return SalesOrderItem(
      orderItemId: json['orderItemId'] ?? 0,
      itemId: json['itemId'] ?? 0,
      itemName: json['itemName'] ?? '',
      itemDescription: json['itemDescription'],
      quantity: (json['quantity'] ?? 0).toDouble(),
      unitPrice: (json['updatedPrice'] ?? 0).toDouble(),
      itemTotal: (json['itemTotal'] ?? 0).toDouble(),
      readyStatus: (json['readyStatus'] ?? 0).toDouble(),
      isActive: json['isActive'] ?? false,
    );
  }
}