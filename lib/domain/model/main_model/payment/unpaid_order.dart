class UnpaidOrder {
  final int orderId;
  final String orderNumber;
  final DateTime orderDate;
  final String orderStatus;
  final String companyName;
  final String vendorDisplayName;
  final int sellerCompanyId;
  final bool hasBill;
  final double orderAmount;
  final double totalAmount;
  final double paidAmount;
  final bool isActive;

  UnpaidOrder({
    required this.orderId,
    required this.orderNumber,
    required this.orderDate,
    required this.orderStatus,
    required this.companyName,
    required this.vendorDisplayName,
    required this.sellerCompanyId,
    required this.hasBill,
    required this.orderAmount,
    required this.totalAmount,
    required this.paidAmount,
    required this.isActive,
  });

  double get balanceAmount => totalAmount - paidAmount;

  factory UnpaidOrder.fromJson(Map<String, dynamic> json) {
    return UnpaidOrder(
      orderId: json['orderId'] ?? 0,
      orderNumber: json['orderNumber'] ?? '',
      orderDate: DateTime.parse(json['orderDate']),
      orderStatus: json['orderStatus'] ?? '',
      companyName: json['companyName'] ?? '',
      vendorDisplayName: json['vendorDisplayName'] ?? '',
      sellerCompanyId: json['sellerCompanyId'] ?? 0,
      hasBill: json['hasBill'] ?? false,
      orderAmount: (json['orderAmount'] ?? 0).toDouble(),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      paidAmount: (json['paidAmount'] ?? 0).toDouble(),
      isActive: json['isActive'] ?? true,
    );
  }
}
