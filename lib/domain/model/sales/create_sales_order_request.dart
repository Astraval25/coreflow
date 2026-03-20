class CreateSalesOrderRequest {
  final int customerId;
  final double? taxAmount;
  final double? discountAmount;
  final double? deliveryCharge;
  final bool hasBill;
  final List<OrderItemRequest> orderItems;

  CreateSalesOrderRequest({
    required this.customerId,
    this.taxAmount,
    this.discountAmount,
    this.deliveryCharge,
    required this.hasBill,
    required this.orderItems,
  });

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'taxAmount': taxAmount ?? 0.0,
      'discountAmount': discountAmount ?? 0,
      'deliveryCharge': deliveryCharge ?? 0.0,
      'hasBill': hasBill,
      'orderItems': orderItems.map((item) => item.toJson()).toList(),
    };
  }
}

class OrderItemRequest {
  final int itemId;
  final String? itemDescription;
  final double quantity;
  final double updatedPrice;

  OrderItemRequest({
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
