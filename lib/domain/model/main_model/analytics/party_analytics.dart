class PartyAnalyticsEntry {
  final int partyId;
  final String partyName;
  final int totalOrders;
  final double totalQuantity;
  final double totalAmount;
  final double paidAmount;
  final double dueAmount;

  const PartyAnalyticsEntry({
    required this.partyId,
    required this.partyName,
    required this.totalOrders,
    required this.totalQuantity,
    required this.totalAmount,
    required this.paidAmount,
    required this.dueAmount,
  });

  factory PartyAnalyticsEntry.fromJson(Map<String, dynamic> json) =>
      PartyAnalyticsEntry(
        partyId: (json['partyId'] as num?)?.toInt() ?? 0,
        partyName: json['partyName'] as String? ?? '',
        totalOrders: (json['totalOrders'] as num?)?.toInt() ?? 0,
        totalQuantity: (json['totalQuantity'] as num?)?.toDouble() ?? 0,
        totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
        paidAmount: (json['paidAmount'] as num?)?.toDouble() ?? 0,
        dueAmount: (json['dueAmount'] as num?)?.toDouble() ?? 0,
      );
}
