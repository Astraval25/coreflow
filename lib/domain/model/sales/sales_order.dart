class SalesOrder {
  final int orderId;
  final String orderNumber;
  final DateTime orderDate;
  final String buyerCompanyName;
  final String vendorName;
  final double totalAmount;
  final double paidAmount;
  final String orderStatus;
  final bool isActive;
  final String? platformRef;

  SalesOrder({
    required this.orderId,
    required this.orderNumber,
    required this.orderDate,
    required this.buyerCompanyName,
    required this.vendorName,
    required this.totalAmount,
    required this.paidAmount,
    required this.orderStatus,
    required this.isActive,
    this.platformRef,
  });

  factory SalesOrder.fromJson(Map<String, dynamic> json) {
    String asString(dynamic value) {
      if (value == null) return '';
      return value.toString();
    }

    int asInt(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    double asDouble(dynamic value) {
      if (value is double) return value;
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '') ?? 0;
    }

    DateTime asDate(dynamic value) {
      if (value is DateTime) return value;
      if (value is String && value.trim().isNotEmpty) {
        return DateTime.tryParse(value) ??
            DateTime.fromMillisecondsSinceEpoch(0);
      }
      return DateTime.fromMillisecondsSinceEpoch(0);
    }

    bool asBool(dynamic value) {
      if (value is bool) return value;
      if (value is num) return value != 0;
      final normalized = value?.toString().toLowerCase().trim();
      return normalized == 'true' || normalized == '1';
    }

    return SalesOrder(
      orderId: asInt(json['orderId']),
      orderNumber: asString(json['orderNumber']),
      orderDate: asDate(json['orderDate']),
      buyerCompanyName: asString(json['buyerCompanyName']),
      vendorName: asString(json['vendorName']),
      totalAmount: asDouble(json['totalAmount']),
      paidAmount: asDouble(json['paidAmount']),
      orderStatus: asString(json['orderStatus']),
      isActive: asBool(json['isActive']),
      platformRef: json['platformRef']?.toString(),
    );
  }
}
