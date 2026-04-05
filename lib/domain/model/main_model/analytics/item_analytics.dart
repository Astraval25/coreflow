class ItemAnalyticsEntry {
  final int itemId;
  final String itemName;
  final double totalQuantity;
  final double totalAmount;

  const ItemAnalyticsEntry({
    required this.itemId,
    required this.itemName,
    required this.totalQuantity,
    required this.totalAmount,
  });

  factory ItemAnalyticsEntry.fromJson(Map<String, dynamic> json) =>
      ItemAnalyticsEntry(
        itemId: (json['itemId'] as num?)?.toInt() ?? 0,
        itemName: json['itemName'] as String? ?? '',
        totalQuantity: (json['totalQuantity'] as num?)?.toDouble() ?? 0,
        totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
      );
}

class ProfitByItemEntry {
  final int itemId;
  final String itemName;
  final double totalSalesAmount;
  final double totalPurchaseAmount;
  final double profit;
  final double profitMargin;

  const ProfitByItemEntry({
    required this.itemId,
    required this.itemName,
    required this.totalSalesAmount,
    required this.totalPurchaseAmount,
    required this.profit,
    required this.profitMargin,
  });

  factory ProfitByItemEntry.fromJson(Map<String, dynamic> json) =>
      ProfitByItemEntry(
        itemId: (json['itemId'] as num?)?.toInt() ?? 0,
        itemName: json['itemName'] as String? ?? '',
        totalSalesAmount: (json['totalSalesAmount'] as num?)?.toDouble() ?? 0,
        totalPurchaseAmount:
            (json['totalPurchaseAmount'] as num?)?.toDouble() ?? 0,
        profit: (json['profit'] as num?)?.toDouble() ?? 0,
        profitMargin: (json['profitMargin'] as num?)?.toDouble() ?? 0,
      );
}
