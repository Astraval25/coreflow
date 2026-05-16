class PaymentHistoryEntry {
  final int paymentId;
  final String paymentType;
  final DateTime paymentDate;
  final String localPaymentNumber;
  final String paymentStatus;
  final String modeOfPayment;
  final double amount;

  const PaymentHistoryEntry({
    required this.paymentId,
    required this.paymentType,
    required this.paymentDate,
    required this.localPaymentNumber,
    required this.paymentStatus,
    required this.modeOfPayment,
    required this.amount,
  });

  factory PaymentHistoryEntry.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) {
      if (value is DateTime) return value;
      if (value is String && value.trim().isNotEmpty) {
        return DateTime.tryParse(value) ??
            DateTime.fromMillisecondsSinceEpoch(0);
      }
      return DateTime.fromMillisecondsSinceEpoch(0);
    }

    int parseInt(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    double parseDouble(dynamic value) {
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '') ?? 0;
    }

    return PaymentHistoryEntry(
      paymentId: parseInt(json['paymentId']),
      paymentType: (json['paymentType'] ?? '').toString(),
      paymentDate: parseDate(json['paymentDate']),
      localPaymentNumber: (json['localPaymentNumber'] ?? '').toString(),
      paymentStatus: (json['paymentStatus'] ?? '').toString(),
      modeOfPayment: (json['modeOfPayment'] ?? '').toString(),
      amount: parseDouble(json['amount']),
    );
  }
}
