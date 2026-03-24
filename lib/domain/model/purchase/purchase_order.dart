class PurchaseOrder {
  final int orderId;
  final String orderNumber;
  final DateTime orderDate;
  final String sellerCompanyName;
  final String customerName;
  final double totalAmount;
  final double paidAmount;
  final String orderStatus;
  final bool isActive;
  final String? platformRef;

  PurchaseOrder({
    required this.orderId,
    required this.orderNumber,
    required this.orderDate,
    required this.sellerCompanyName,
    required this.customerName,
    required this.totalAmount,
    required this.paidAmount,
    required this.orderStatus,
    required this.isActive,
    this.platformRef,
  });

  factory PurchaseOrder.fromJson(Map<String, dynamic> json) {
    final rawDate = json['orderDate']?.toString();
    final parsedDate = rawDate == null || rawDate.isEmpty
        ? DateTime.fromMillisecondsSinceEpoch(0)
        : DateTime.tryParse(rawDate) ?? DateTime.fromMillisecondsSinceEpoch(0);

    return PurchaseOrder(
      orderId: (json['orderId'] ?? 0) as int,
      orderNumber: json['orderNumber']?.toString() ?? '',
      orderDate: parsedDate,
      sellerCompanyName: json['sellerCompanyName']?.toString() ?? '',
      customerName: json['customerName']?.toString() ?? '',
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      paidAmount: (json['paidAmount'] ?? 0).toDouble(),
      orderStatus: json['orderStatus']?.toString() ?? '',
      isActive: (json['isActive'] ?? false) as bool,
      platformRef: json['platformRef']?.toString(),
    );
  }
}

