class SalesSummary {
  final int totalOrders;
  final double totalAmount;
  final double totalPaid;
  final double totalDue;
  final double avgOrderValue;

  const SalesSummary({
    required this.totalOrders,
    required this.totalAmount,
    required this.totalPaid,
    required this.totalDue,
    required this.avgOrderValue,
  });

  factory SalesSummary.fromJson(Map<String, dynamic> json) => SalesSummary(
        totalOrders: (json['totalOrders'] as num?)?.toInt() ?? 0,
        totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
        totalPaid: (json['totalPaid'] as num?)?.toDouble() ?? 0,
        totalDue: (json['totalDue'] as num?)?.toDouble() ?? 0,
        avgOrderValue: (json['avgOrderValue'] as num?)?.toDouble() ?? 0,
      );
}

class PurchaseSummary {
  final int totalOrders;
  final double totalAmount;
  final double totalPaid;
  final double totalDue;
  final double avgOrderValue;

  const PurchaseSummary({
    required this.totalOrders,
    required this.totalAmount,
    required this.totalPaid,
    required this.totalDue,
    required this.avgOrderValue,
  });

  factory PurchaseSummary.fromJson(Map<String, dynamic> json) =>
      PurchaseSummary(
        totalOrders: (json['totalOrders'] as num?)?.toInt() ?? 0,
        totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
        totalPaid: (json['totalPaid'] as num?)?.toDouble() ?? 0,
        totalDue: (json['totalDue'] as num?)?.toDouble() ?? 0,
        avgOrderValue: (json['avgOrderValue'] as num?)?.toDouble() ?? 0,
      );
}
