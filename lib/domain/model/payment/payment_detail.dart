class PaymentDetail {
  final int paymentId;
  final String paymentNumber;
  final DateTime paymentDate;
  final double amount;
  final List<int> orderIds;

  final int customerId;
  final String customerName;

  final int vendorId;
  final String vendorName;

  final String modeOfPayment;
  final String paymentStatus;
  final String referenceNumber;
  final String notes;
  final bool isActive;

  PaymentDetail({
    required this.paymentId,
    required this.paymentNumber,
    required this.paymentDate,
    required this.amount,
    required this.orderIds,
    required this.customerId,
    required this.customerName,
    required this.vendorId,
    required this.vendorName,
    required this.modeOfPayment,
    required this.paymentStatus,
    required this.referenceNumber,
    required this.notes,
    required this.isActive,
  });

  factory PaymentDetail.fromJson(Map<String, dynamic> json) {
    final parsedOrderIds = _parseOrderIds(json);

    return PaymentDetail(
      paymentId: _asInt(json['paymentId']),
      paymentNumber: json['paymentNumber']?.toString() ?? '',
      paymentDate: _asDate(json['paymentDate']),
      amount: _asDouble(json['amount']),
      orderIds: parsedOrderIds,
      customerId: _asInt(json['customerId']),
      customerName: json['customerName']?.toString() ?? '',
      vendorId: _asInt(json['vendorId']),
      vendorName: json['vendorName']?.toString() ?? '',
      modeOfPayment: json['modeOfPayment']?.toString() ?? '',
      paymentStatus: json['paymentStatus']?.toString() ?? '',
      referenceNumber: json['referenceNumber']?.toString() ?? '',
      notes: json['notes']?.toString() ?? '',
      isActive: _asBool(json['isActive']),
    );
  }

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

  static List<int> _parseOrderIds(Map<String, dynamic> json) {
    final rawOrderIds = json['orderIds'];
    if (rawOrderIds is List) {
      return rawOrderIds
          .map((e) => int.tryParse(e.toString()))
          .whereType<int>()
          .toList();
    }

    final singleOrderId = int.tryParse(json['orderId']?.toString() ?? '');
    if (singleOrderId != null) {
      return [singleOrderId];
    }

    return const [];
  }
}
