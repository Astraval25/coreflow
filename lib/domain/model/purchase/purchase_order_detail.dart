import 'package:coreflow/domain/model/purchase/purchase_order_item.dart';

class PurchaseOrderDetail {
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

  final List<PurchaseOrderItem> orderItems;

  PurchaseOrderDetail({
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

  factory PurchaseOrderDetail.fromJson(Map<String, dynamic> json) {
    final rawOrderItems = json['orderItems'];
    final items = rawOrderItems is List
        ? rawOrderItems
              .whereType<Map>()
              .map(
                (e) => PurchaseOrderItem.fromJson(Map<String, dynamic>.from(e)),
              )
              .toList()
        : <PurchaseOrderItem>[];

    return PurchaseOrderDetail(
      orderId: _asInt(json['orderId']),
      orderNumber: json['orderNumber']?.toString() ?? '',
      platformRef: json['platformRef']?.toString(),
      orderDate: _asDate(json['orderDate']),
      sellerCompanyId: _asInt(json['sellerCompanyId']),
      sellerCompanyName: json['sellerCompanyName']?.toString() ?? '',
      buyerCompanyId: _asInt(json['buyerCompanyId']),
      buyerCompanyName: json['buyerCompanyName']?.toString() ?? '',
      customerId: _asInt(json['customerId']),
      customerName: json['customerName']?.toString() ?? '',
      customerDisplayName: json['customerDisplayName']?.toString() ?? '',
      vendorId: _asInt(json['vendorId']),
      vendorName: json['vendorName']?.toString() ?? '',
      vendorDisplayName: json['vendorDisplayName']?.toString() ?? '',
      orderAmount: _asDouble(json['orderAmount']),
      taxAmount: _asDouble(json['taxAmount']),
      discountAmount: _asDouble(json['discountAmount']),
      deliveryCharge: _asDouble(json['deliveryCharge']),
      totalAmount: _asDouble(json['totalAmount']),
      paidAmount: _asDouble(json['paidAmount']),
      orderStatus: json['orderStatus']?.toString() ?? '',
      hasBill: _asBool(json['hasBill']),
      isActive: _asBool(json['isActive']),
      orderItems: items,
    );
  }

  bool get isPaid => paidAmount >= totalAmount;
  double get pendingAmount => totalAmount - paidAmount;

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

  static DateTime _asDate(dynamic value) {
    final raw = value?.toString();
    if (raw == null || raw.isEmpty) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }
    return DateTime.tryParse(raw) ?? DateTime.fromMillisecondsSinceEpoch(0);
  }
}
