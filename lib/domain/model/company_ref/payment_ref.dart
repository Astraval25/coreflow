class PaymentRef {
  final int companyPaymentRefId;
  final int? paymentId;
  final String localPaymentNumber;
  final String? internalRemarks;
  final String? internalStatus;
  final String? customReference;

  PaymentRef({
    required this.companyPaymentRefId,
    this.paymentId,
    required this.localPaymentNumber,
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
}
