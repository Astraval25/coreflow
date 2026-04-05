class MonthlyTrendEntry {
  final String month;
  final double salesAmount;
  final double purchaseAmount;
  final double paymentReceived;
  final double paymentMade;

  const MonthlyTrendEntry({
    required this.month,
    required this.salesAmount,
    required this.purchaseAmount,
    required this.paymentReceived,
    required this.paymentMade,
  });

  factory MonthlyTrendEntry.fromJson(Map<String, dynamic> json) =>
      MonthlyTrendEntry(
        month: json['month'] as String? ?? '',
        salesAmount: (json['salesAmount'] as num?)?.toDouble() ?? 0,
        purchaseAmount: (json['purchaseAmount'] as num?)?.toDouble() ?? 0,
        paymentReceived: (json['paymentReceived'] as num?)?.toDouble() ?? 0,
        paymentMade: (json['paymentMade'] as num?)?.toDouble() ?? 0,
      );
}
