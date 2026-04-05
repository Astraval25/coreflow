class RunningAmountEntry {
  final String month;
  final double cumulativeAmount;

  const RunningAmountEntry(
      {required this.month, required this.cumulativeAmount});

  factory RunningAmountEntry.fromJson(Map<String, dynamic> json) =>
      RunningAmountEntry(
        month: json['month'] as String? ?? '',
        cumulativeAmount:
            (json['cumulativeAmount'] as num?)?.toDouble() ?? 0,
      );
}
