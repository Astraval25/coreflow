class PaymentModeEntry {
  final String mode;
  final double totalAmount;
  final int transactionCount;
  final double percentage;

  const PaymentModeEntry({
    required this.mode,
    required this.totalAmount,
    required this.transactionCount,
    required this.percentage,
  });

  factory PaymentModeEntry.fromJson(Map<String, dynamic> json) =>
      PaymentModeEntry(
        mode: json['mode'] as String? ?? '',
        totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
        transactionCount: (json['transactionCount'] as num?)?.toInt() ?? 0,
        percentage: (json['percentage'] as num?)?.toDouble() ?? 0,
      );
}
