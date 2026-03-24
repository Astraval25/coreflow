class OrderRef {
  final int companyOrderRefId;
  final String localOrderNumber;
  final String? internalRemarks;
  final String? internalStatus;
  final String? internalTags;
  final String? customReference;

  OrderRef({
    required this.companyOrderRefId,
    required this.localOrderNumber,
    this.internalRemarks,
    this.internalStatus,
    this.internalTags,
    this.customReference,
  });

  factory OrderRef.fromJson(Map<String, dynamic> json) {
    return OrderRef(
      companyOrderRefId: (json['companyOrderRefId'] ?? 0) as int,
      localOrderNumber: json['localOrderNumber']?.toString() ?? '',
      internalRemarks: json['internalRemarks']?.toString(),
      internalStatus: json['internalStatus']?.toString(),
      internalTags: json['internalTags']?.toString(),
      customReference: json['customReference']?.toString(),
    );
  }
}
