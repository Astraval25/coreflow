class CustomerOrdersPaymentsResponse {
  final bool responseStatus;
  final int responseCode;
  final String responseMessage;
  final CustomerOrdersPaymentsData? responseData;

  CustomerOrdersPaymentsResponse({
    required this.responseStatus,
    required this.responseCode,
    required this.responseMessage,
    this.responseData,
  });

  factory CustomerOrdersPaymentsResponse.fromJson(Map<String, dynamic> json) {
    return CustomerOrdersPaymentsResponse(
      responseStatus: json['responseStatus'] == true,
      responseCode: _asInt(json['responseCode']),
      responseMessage: (json['responseMessage'] ?? '').toString(),
      responseData: json['responseData'] != null
          ? CustomerOrdersPaymentsData.fromJson(
              json['responseData'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

class CustomerOrdersPaymentsData {
  final List<CustomerOrder> orders;
  final List<CustomerPayment> payments;

  CustomerOrdersPaymentsData({required this.orders, required this.payments});

  factory CustomerOrdersPaymentsData.fromJson(Map<String, dynamic> json) {
    final ordersRaw = json['orders'];
    final paymentsRaw = json['payments'];

    return CustomerOrdersPaymentsData(
      orders: ordersRaw is List
          ? ordersRaw
                .whereType<Map<String, dynamic>>()
                .map(CustomerOrder.fromJson)
                .toList()
          : const [],
      payments: paymentsRaw is List
          ? paymentsRaw
                .whereType<Map<String, dynamic>>()
                .map(CustomerPayment.fromJson)
                .toList()
          : const [],
    );
  }
}

class CustomerOrder {
  final int orderId;
  final String orderNumber;
  final double totalAmount;
  final String orderPlatformRef;
  final double paidAmount;
  final DateTime orderDate;
  final bool isViewed;

  CustomerOrder({
    required this.orderId,
    required this.orderNumber,
    required this.totalAmount,
    required this.orderPlatformRef,
    required this.paidAmount,
    required this.orderDate,
    required this.isViewed,
  });

  double get dueAmount => totalAmount - paidAmount;

  factory CustomerOrder.fromJson(Map<String, dynamic> json) {
    return CustomerOrder(
      orderId: _asInt(json['orderId']),
      orderNumber: (json['orderNumber'] ?? '').toString(),
      totalAmount: _asDouble(json['totalAmount']),
      orderPlatformRef: (json['orderPlatformRef'] ?? '').toString(),
      paidAmount: _asDouble(json['paidAmount']),
      orderDate: _asDate(json['orderDate']),
      isViewed: json['isViewed'] == true || json['viewed'] == true,
    );
  }
}

class CustomerPayment {
  final int paymentId;
  final String paymentPlatformRef;
  final DateTime paymentDate;
  final double amount;
  final bool isViewed;

  CustomerPayment({
    required this.paymentId,
    required this.paymentPlatformRef,
    required this.paymentDate,
    required this.amount,
    required this.isViewed,
  });

  factory CustomerPayment.fromJson(Map<String, dynamic> json) {
    return CustomerPayment(
      paymentId: _asInt(json['paymentId']),
      paymentPlatformRef: (json['paymentPlatformRef'] ?? '').toString(),
      paymentDate: _asDate(json['paymentDate']),
      amount: _asDouble(json['amount']),
      isViewed: json['isViewed'] == true || json['viewed'] == true,
    );
  }
}

/// Unified entry for displaying orders and payments in a single sorted list.
class OrderPaymentEntry implements Comparable<OrderPaymentEntry> {
  final bool isOrder;
  final DateTime date;
  final CustomerOrder? order;
  final CustomerPayment? payment;

  OrderPaymentEntry.fromOrder(CustomerOrder o)
    : isOrder = true,
      date = o.orderDate,
      order = o,
      payment = null;

  OrderPaymentEntry.fromPayment(CustomerPayment p)
    : isOrder = false,
      date = p.paymentDate,
      order = null,
      payment = p;

  @override
  int compareTo(OrderPaymentEntry other) => other.date.compareTo(date); // desc
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
