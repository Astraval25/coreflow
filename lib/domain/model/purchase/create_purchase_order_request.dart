class CreatePurchaseOrderRequest {
  final int vendorId;
  final DateTime orderDate;
  final double? taxAmount;
  final double? discountAmount;
  final double? deliveryCharge;
  final bool hasBill;
  final List<PurchaseOrderItemRequest> orderItems;

  CreatePurchaseOrderRequest({
    required this.vendorId,
    required this.orderDate,
    this.taxAmount,
    this.discountAmount,
    this.deliveryCharge,
    required this.hasBill,
    required this.orderItems,
  });

  Map<String, dynamic> toJson() {
    return {
      'vendorId': vendorId,
      'orderDate': orderDate.toIso8601String(),
      'taxAmount': taxAmount ?? 0.0,
      'discountAmount': discountAmount ?? 0,
      'deliveryCharge': deliveryCharge ?? 0.0,
      'hasBill': hasBill,
      'orderItems': orderItems.map((item) => item.toJson()).toList(),
    };
  }
}

class PurchaseOrderItemRequest {
  final int itemId;
  final String? itemDescription;
  final double quantity;
  final double updatedPrice;

  PurchaseOrderItemRequest({
    required this.itemId,
    this.itemDescription,
    required this.quantity,
    required this.updatedPrice,
  });

  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      if (itemDescription != null && itemDescription!.trim().isNotEmpty)
        'itemDescription': itemDescription!.trim(),
      'quantity': quantity,
      'updatedPrice': updatedPrice,
    };
  }
}
