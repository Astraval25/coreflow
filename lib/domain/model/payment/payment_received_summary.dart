class PaymentReceivedSummary {
  final int paymentId;
  final DateTime paymentDate;
  final List<int>? orderIds;
  final String? paymentNumber;
  final double amount;
  final String customerName;
  final String modeOfPayment;
  final String paymentStatus;
  final bool isActive;
  final String? referenceNumber;
  final String? platformRef;

  PaymentReceivedSummary({
    required this.paymentId,
    required this.paymentDate,
    required this.orderIds,
    required this.paymentNumber,
    required this.amount,
    required this.customerName,
    required this.modeOfPayment,
    required this.paymentStatus,
    required this.isActive,
    required this.referenceNumber,
    this.platformRef,
  });

  factory PaymentReceivedSummary.fromJson(Map<String, dynamic> json) {
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

    return PaymentReceivedSummary(
      paymentId: (json['paymentId'] ?? 0) as int,
      paymentDate: parsedDate,
      orderIds: parsedOrderIds,
      paymentNumber: json['paymentNumber']?.toString(),
      amount: (json['amount'] ?? 0).toDouble(),
      customerName: json['customerName']?.toString() ?? '',
      modeOfPayment: json['modeOfPayment']?.toString() ?? '',
      paymentStatus: json['paymentStatus']?.toString() ?? '',
      isActive: (json['isActive'] ?? false) as bool,
      referenceNumber: json['referenceNumber']?.toString(),
      platformRef: json['platformRef']?.toString(),
    );
  }
}

