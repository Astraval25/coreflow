class PartyOrderPaymentTrendEntry {
  final DateTime day;
  final double totalQuantity;
  final double orderAmount;
  final double paidAmount;

  const PartyOrderPaymentTrendEntry({
    required this.day,
    required this.totalQuantity,
    required this.orderAmount,
    required this.paidAmount,
  });

  factory PartyOrderPaymentTrendEntry.fromJson(Map<String, dynamic> json) {
    return PartyOrderPaymentTrendEntry(
      day: DateTime.tryParse((json['day'] ?? '').toString()) ?? DateTime(1970),
      totalQuantity: (json['totalQuantity'] as num?)?.toDouble() ?? 0,
      orderAmount: (json['orderAmount'] as num?)?.toDouble() ?? 0,
      paidAmount: (json['paidAmount'] as num?)?.toDouble() ?? 0,
    );
  }
}
