class OrderFrequencyEntry {
  final String month;
  final int orderCount;

  const OrderFrequencyEntry({required this.month, required this.orderCount});

  factory OrderFrequencyEntry.fromJson(Map<String, dynamic> json) =>
      OrderFrequencyEntry(
        month: json['month'] as String? ?? '',
        orderCount: (json['orderCount'] as num?)?.toInt() ?? 0,
      );
}

class PaymentFrequencyEntry {
  final String month;
  final int paymentCount;

  const PaymentFrequencyEntry(
      {required this.month, required this.paymentCount});

  factory PaymentFrequencyEntry.fromJson(Map<String, dynamic> json) =>
      PaymentFrequencyEntry(
        month: json['month'] as String? ?? '',
        paymentCount: (json['paymentCount'] as num?)?.toInt() ?? 0,
      );
}
