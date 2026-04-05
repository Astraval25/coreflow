class CashFlowEntry {
  final String month;
  final double openingBalance;
  final double incoming;
  final double outgoing;
  final double closingBalance;

  const CashFlowEntry({
    required this.month,
    required this.openingBalance,
    required this.incoming,
    required this.outgoing,
    required this.closingBalance,
  });

  factory CashFlowEntry.fromJson(Map<String, dynamic> json) {
    return CashFlowEntry(
      month: json['month'] as String? ?? '',
      openingBalance: (json['openingBalance'] as num?)?.toDouble() ?? 0.0,
      incoming: (json['incoming'] as num?)?.toDouble() ?? 0.0,
      outgoing: (json['outgoing'] as num?)?.toDouble() ?? 0.0,
      closingBalance: (json['closingBalance'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
