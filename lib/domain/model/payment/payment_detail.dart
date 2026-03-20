class PaymentDetail {
  final int paymentId;
  final String paymentNumber;
  final DateTime paymentDate;
  final double amount;
  final List<int> orderIds;
  final List<PaymentOrderAllocation>? _orderAllocations;

  final int customerId;
  final String customerName;

  final int vendorId;
  final String vendorName;

  final String modeOfPayment;
  final String paymentStatus;
  final String referenceNumber;
  final String notes;
  final bool isActive;
  final String? fsId;

  PaymentDetail({
    required this.paymentId,
    required this.paymentNumber,
    required this.paymentDate,
    required this.amount,
    required this.orderIds,
    List<PaymentOrderAllocation>? orderAllocations,
    required this.customerId,
    required this.customerName,
    required this.vendorId,
    required this.vendorName,
    required this.modeOfPayment,
    required this.paymentStatus,
    required this.referenceNumber,
    required this.notes,
    required this.isActive,
    this.fsId,
  }) : _orderAllocations = orderAllocations;

  List<PaymentOrderAllocation> get orderAllocations =>
      _orderAllocations ?? const [];

  factory PaymentDetail.fromJson(Map<String, dynamic> json) {
    final parsedOrderIds = _parseOrderIds(json);
    final parsedAllocations = _parseAllocations(json);

    return PaymentDetail(
      paymentId: _asInt(json['paymentId']),
      paymentNumber: json['paymentNumber']?.toString() ?? '',
      paymentDate: _asDate(json['paymentDate']),
      amount: _asDouble(json['amount']),
      orderIds: parsedOrderIds,
      orderAllocations: parsedAllocations,
      customerId: _asInt(json['customerId']),
      customerName: json['customerName']?.toString() ?? '',
      vendorId: _asInt(json['vendorId']),
      vendorName: json['vendorName']?.toString() ?? '',
      modeOfPayment: json['modeOfPayment']?.toString() ?? '',
      paymentStatus: json['paymentStatus']?.toString() ?? '',
      referenceNumber: json['referenceNumber']?.toString() ?? '',
      notes: json['notes']?.toString() ?? '',
      isActive: _asBool(json['isActive']),
      fsId: json['fsId']?.toString(),
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

  static List<PaymentOrderAllocation> _parseAllocations(
    Map<String, dynamic> json,
  ) {
    final rawAllocations = json['orderAllocations'];
    if (rawAllocations is List) {
      return rawAllocations
          .whereType<Map>()
          .map(
            (e) => PaymentOrderAllocation.fromJson(
              Map<String, dynamic>.from(e),
            ),
          )
          .toList();
    }
    return const [];
  }
}

class PaymentOrderAllocation {
  final int paymentOrderAllocationId;
  final int orderId;
  final String orderNumber;
  final double amountApplied;
  final DateTime allocationDate;
  final String allocationRemarks;
  final bool isActive;

  PaymentOrderAllocation({
    required this.paymentOrderAllocationId,
    required this.orderId,
    required this.orderNumber,
    required this.amountApplied,
    required this.allocationDate,
    required this.allocationRemarks,
    required this.isActive,
  });

  factory PaymentOrderAllocation.fromJson(Map<String, dynamic> json) {
    return PaymentOrderAllocation(
      paymentOrderAllocationId: PaymentDetail._asInt(
        json['paymentOrderAllocationId'],
      ),
      orderId: PaymentDetail._asInt(json['orderId']),
      orderNumber: json['orderNumber']?.toString() ?? '',
      amountApplied: PaymentDetail._asDouble(json['amountApplied']),
      allocationDate: PaymentDetail._asDate(json['allocationDate']),
      allocationRemarks: json['allocationRemarks']?.toString() ?? '',
      isActive: PaymentDetail._asBool(json['isActive']),
    );
  }
}
