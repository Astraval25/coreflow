class PaymentSentSummary {
  final int paymentId;
  final DateTime paymentDate;
  final List<int>? orderIds;
  final String? paymentNumber;
  final double amount;
  final String vendorName;
  final String modeOfPayment;
  final String paymentStatus;
  final bool isActive;
  final String? referenceNumber;

  PaymentSentSummary({
    required this.paymentId,
    required this.paymentDate,
    required this.orderIds,
    required this.paymentNumber,
    required this.amount,
    required this.vendorName,
    required this.modeOfPayment,
    required this.paymentStatus,
    required this.isActive,
    required this.referenceNumber,
  });

  factory PaymentSentSummary.fromJson(Map<String, dynamic> json) {
    final rawDate = json['paymentDate']?.toString();
    final parsedDate = rawDate == null || rawDate.isEmpty
        ? DateTime.fromMillisecondsSinceEpoch(0)
        : DateTime.tryParse(rawDate) ?? DateTime.fromMillisecondsSinceEpoch(0);

    final rawOrderIds = json['orderIds'];
    List<int>? parsedOrderIds;
    if (rawOrderIds is List) {
      parsedOrderIds = rawOrderIds
          .map((e) => int.tryParse(e.toString()))
          .whereType<int>()
          .toList();
    }

    return PaymentSentSummary(
      paymentId: (json['paymentId'] ?? 0) as int,
      paymentDate: parsedDate,
      orderIds: parsedOrderIds,
      paymentNumber: json['paymentNumber']?.toString(),
      amount: (json['amount'] ?? 0).toDouble(),
      vendorName: json['vendorName']?.toString() ?? '',
      modeOfPayment: json['modeOfPayment']?.toString() ?? '',
      paymentStatus: json['paymentStatus']?.toString() ?? '',
      isActive: (json['isActive'] ?? false) as bool,
      referenceNumber: json['referenceNumber']?.toString(),
    );
  }
}
