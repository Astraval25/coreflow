import 'package:coreflow/domain/model/sales/sales_order_item.dart';

class SalesOrderDetail {
  final int orderId;
  final String orderNumber;
  final String? platformRef;
  final DateTime orderDate;

  final int sellerCompanyId;
  final String sellerCompanyName;

  final int buyerCompanyId;
  final String buyerCompanyName;

  final int customerId;
  final String customerName;
  final String customerDisplayName;

  final int vendorId;
  final String vendorName;
  final String vendorDisplayName;

  final double orderAmount;
  final double taxAmount;
  final double discountAmount;
  final double deliveryCharge;
  final double totalAmount;
  final double paidAmount;

  final String orderStatus;
  final bool hasBill;
  final bool isActive;

  final List<SalesOrderItem> orderItems;

  SalesOrderDetail({
    required this.orderId,
    required this.orderNumber,
    this.platformRef,
    required this.orderDate,
    required this.sellerCompanyId,
    required this.sellerCompanyName,
    required this.buyerCompanyId,
    required this.buyerCompanyName,
    required this.customerId,
    required this.customerName,
    required this.customerDisplayName,
    required this.vendorId,
    required this.vendorName,
    required this.vendorDisplayName,
    required this.orderAmount,
    required this.taxAmount,
    required this.discountAmount,
    required this.deliveryCharge,
    required this.totalAmount,
    required this.paidAmount,
    required this.orderStatus,
    required this.hasBill,
    required this.isActive,
    required this.orderItems,
  });

  factory SalesOrderDetail.fromJson(Map<String, dynamic> json) {
    return SalesOrderDetail(
      orderId: json['orderId'] ?? 0,
      orderNumber: json['orderNumber'] ?? '',
      platformRef: json['platformRef']?.toString(),
      orderDate: DateTime.tryParse(json['orderDate'] ?? '') ?? DateTime.now(),

      sellerCompanyId: json['sellerCompanyId'] ?? 0,
      sellerCompanyName: json['sellerCompanyName'] ?? '',

      buyerCompanyId: json['buyerCompanyId'] ?? 0,
      buyerCompanyName: json['buyerCompanyName'] ?? '',

      customerId: json['customerId'] ?? 0,
      customerName: json['customerName'] ?? '',
      customerDisplayName: json['customerDisplayName'] ?? '',

      vendorId: json['vendorId'] ?? 0,
      vendorName: json['vendorName'] ?? '',
      vendorDisplayName: json['vendorDisplayName'] ?? '',

      orderAmount: (json['orderAmount'] ?? 0).toDouble(),
      taxAmount: (json['taxAmount'] ?? 0).toDouble(),
      discountAmount: (json['discountAmount'] ?? 0).toDouble(),
      deliveryCharge: (json['deliveryCharge'] ?? 0).toDouble(),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      paidAmount: (json['paidAmount'] ?? 0).toDouble(),

      orderStatus: json['orderStatus'] ?? '',
      hasBill: json['hasBill'] ?? false,
      isActive: json['isActive'] ?? false,

      orderItems: (json['orderItems'] as List<dynamic>?)
              ?.map((e) => SalesOrderItem.fromJson(e))
              .toList() ??
          [],
    );
  }

  // ✅ UI Helper
  bool get isPaid => paidAmount >= totalAmount;

  double get pendingAmount => totalAmount - paidAmount;
}