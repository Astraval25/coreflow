class RevenueExpenseEntry {
  final String month;
  final double revenue;
  final double expense;
  final double netProfit;
  final double runningRevenue;
  final double runningExpense;
  final double runningNetProfit;

  const RevenueExpenseEntry({
    required this.month,
    required this.revenue,
    required this.expense,
    required this.netProfit,
    required this.runningRevenue,
    required this.runningExpense,
    required this.runningNetProfit,
  });

  factory RevenueExpenseEntry.fromJson(Map<String, dynamic> json) {
    return RevenueExpenseEntry(
      month: json['month'] as String? ?? '',
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0.0,
      expense: (json['expense'] as num?)?.toDouble() ?? 0.0,
      netProfit: (json['netProfit'] as num?)?.toDouble() ?? 0.0,
      runningRevenue: (json['runningRevenue'] as num?)?.toDouble() ?? 0.0,
      runningExpense: (json['runningExpense'] as num?)?.toDouble() ?? 0.0,
      runningNetProfit: (json['runningNetProfit'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
