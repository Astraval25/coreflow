class PaymentRef {
  final int companyPaymentRefId;
  final int? paymentId;
  final String localPaymentNumber;
  final double? amount;
  final DateTime? paymentDate;
  final String? internalRemarks;
  final String? internalStatus;
  final String? customReference;

  PaymentRef({
    required this.companyPaymentRefId,
    this.paymentId,
    required this.localPaymentNumber,
    this.amount,
    this.paymentDate,
    this.internalRemarks,
    this.internalStatus,
    this.customReference,
  });

  factory PaymentRef.fromJson(Map<String, dynamic> json) {
    return PaymentRef(
      companyPaymentRefId: _asInt(json['companyPaymentRefId']),
      paymentId: _asNullableInt(json['paymentId']),
      localPaymentNumber:
          json['localPaymentNumber']?.toString() ??
          json['paymentNumber']?.toString() ??
          '',
      amount: _asNullableDouble(json['amount']),
      paymentDate: _asNullableDate(json['paymentDate']),
      internalRemarks: json['internalRemarks']?.toString(),
      internalStatus: json['internalStatus']?.toString(),
      customReference: json['customReference']?.toString(),
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? _asNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static double? _asNullableDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static DateTime? _asNullableDate(dynamic value) {
    final raw = value?.toString();
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }
}
