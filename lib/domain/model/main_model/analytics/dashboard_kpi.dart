class DashboardKpi {
  final double totalRevenue;
  final double totalExpense;
  final double netProfit;
  final int totalSalesOrders;
  final int totalPurchaseOrders;
  final int totalPaymentsReceived;
  final int totalPaymentsMade;
  final double avgOrderValue;
  final double outstandingReceivables;
  final double outstandingPayables;

  const DashboardKpi({
    required this.totalRevenue,
    required this.totalExpense,
    required this.netProfit,
    required this.totalSalesOrders,
    required this.totalPurchaseOrders,
    required this.totalPaymentsReceived,
    required this.totalPaymentsMade,
    required this.avgOrderValue,
    required this.outstandingReceivables,
    required this.outstandingPayables,
  });

  factory DashboardKpi.fromJson(Map<String, dynamic> json) {
    return DashboardKpi(
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
      totalExpense: (json['totalExpense'] as num?)?.toDouble() ?? 0.0,
      netProfit: (json['netProfit'] as num?)?.toDouble() ?? 0.0,
      totalSalesOrders: (json['totalSalesOrders'] as num?)?.toInt() ?? 0,
      totalPurchaseOrders: (json['totalPurchaseOrders'] as num?)?.toInt() ?? 0,
      totalPaymentsReceived:
          (json['totalPaymentsReceived'] as num?)?.toInt() ?? 0,
      totalPaymentsMade: (json['totalPaymentsMade'] as num?)?.toInt() ?? 0,
      avgOrderValue: (json['avgOrderValue'] as num?)?.toDouble() ?? 0.0,
      outstandingReceivables:
          (json['outstandingReceivables'] as num?)?.toDouble() ?? 0.0,
      outstandingPayables:
          (json['outstandingPayables'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
