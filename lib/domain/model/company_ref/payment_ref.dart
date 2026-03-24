class PaymentRef {
  final int companyPaymentRefId;
  final String localPaymentNumber;
  final String? internalRemarks;
  final String? internalStatus;
  final String? customReference;

  PaymentRef({
    required this.companyPaymentRefId,
    required this.localPaymentNumber,
    this.internalRemarks,
    this.internalStatus,
    this.customReference,
  });

  factory PaymentRef.fromJson(Map<String, dynamic> json) {
    return PaymentRef(
      companyPaymentRefId: (json['companyPaymentRefId'] ?? 0) as int,
      localPaymentNumber: json['localPaymentNumber']?.toString() ?? '',
      internalRemarks: json['internalRemarks']?.toString(),
      internalStatus: json['internalStatus']?.toString(),
      customReference: json['customReference']?.toString(),
    );
  }
}
