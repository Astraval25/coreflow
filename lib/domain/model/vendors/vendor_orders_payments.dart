class VendorOrdersPaymentsResponse {
  final bool responseStatus;
  final int responseCode;
  final String responseMessage;
  final VendorOrdersPaymentsData? responseData;

  VendorOrdersPaymentsResponse({
    required this.responseStatus,
    required this.responseCode,
    required this.responseMessage,
    this.responseData,
  });

  factory VendorOrdersPaymentsResponse.fromJson(Map<String, dynamic> json) {
    final data = json['responseData'];
    return VendorOrdersPaymentsResponse(
      responseStatus: json['responseStatus'] == true,
      responseCode: _asInt(json['responseCode']),
      responseMessage: (json['responseMessage'] ?? '').toString(),
      responseData: data is Map<String, dynamic>
          ? VendorOrdersPaymentsData.fromJson(data)
          : null,
    );
  }
}

class VendorOrdersPaymentsData {
  final List<VendorOrder> orders;
  final List<VendorPayment> payments;

  VendorOrdersPaymentsData({
    required this.orders,
    required this.payments,
  });

  factory VendorOrdersPaymentsData.fromJson(Map<String, dynamic> json) {
    final ordersRaw = json['orders'];
    final paymentsRaw = json['payments'];

    return VendorOrdersPaymentsData(
      orders: ordersRaw is List
          ? ordersRaw
                .whereType<Map<String, dynamic>>()
                .map(VendorOrder.fromJson)
                .toList()
          : const [],
      payments: paymentsRaw is List
          ? paymentsRaw
                .whereType<Map<String, dynamic>>()
                .map(VendorPayment.fromJson)
                .toList()
          : const [],
    );
  }
}

class VendorOrder {
  final int orderId;
  final String orderNumber;
  final double totalAmount;
  final String orderPlatformRef;
  final double paidAmount;
  final DateTime orderDate;

  VendorOrder({
    required this.orderId,
    required this.orderNumber,
    required this.totalAmount,
    required this.orderPlatformRef,
    required this.paidAmount,
    required this.orderDate,
  });

  double get dueAmount => totalAmount - paidAmount;

  factory VendorOrder.fromJson(Map<String, dynamic> json) {
    return VendorOrder(
      orderId: _asInt(json['orderId']),
      orderNumber: _firstNonEmpty(
        json['orderNumber'],
        json['purchaseOrderNumber'],
        json['localOrderNumber'],
      ),
      totalAmount: _asDouble(json['totalAmount']),
      orderPlatformRef: _firstNonEmpty(
        json['orderPlatformRef'],
        json['orderRef'],
      ),
      paidAmount: _asDouble(json['paidAmount']),
      orderDate: _asDate(json['orderDate'] ?? json['createdDt']),
    );
  }
}

class VendorPayment {
  final int paymentId;
  final String paymentPlatformRef;
  final DateTime paymentDate;
  final double amount;

  VendorPayment({
    required this.paymentId,
    required this.paymentPlatformRef,
    required this.paymentDate,
    required this.amount,
  });

  factory VendorPayment.fromJson(Map<String, dynamic> json) {
    return VendorPayment(
      paymentId: _asInt(json['paymentId']),
      paymentPlatformRef: _firstNonEmpty(
        json['paymentPlatformRef'],
        json['paymentNumber'],
        json['localPaymentNumber'],
      ),
      paymentDate: _asDate(json['paymentDate'] ?? json['createdDt']),
      amount: _asDouble(json['amount']),
    );
  }
}

class VendorOrderPaymentEntry implements Comparable<VendorOrderPaymentEntry> {
  final bool isOrder;
  final DateTime date;
  final VendorOrder? order;
  final VendorPayment? payment;

  VendorOrderPaymentEntry.fromOrder(VendorOrder o)
      : isOrder = true,
        date = o.orderDate,
        order = o,
        payment = null;

  VendorOrderPaymentEntry.fromPayment(VendorPayment p)
      : isOrder = false,
        date = p.paymentDate,
        order = null,
        payment = p;

  @override
  int compareTo(VendorOrderPaymentEntry other) => other.date.compareTo(date);
}

double _asDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0.0;
}

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

DateTime _asDate(dynamic value) {
  if (value is DateTime) return value;
  return DateTime.tryParse(value?.toString() ?? '') ?? DateTime(1970);
}

String _firstNonEmpty(dynamic a, [dynamic b, dynamic c]) {
  final values = [a, b, c];
  for (final value in values) {
    final text = (value ?? '').toString().trim();
    if (text.isNotEmpty) return text;
  }
  return '';
}
