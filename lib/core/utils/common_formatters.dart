String formatPaymentDate(DateTime? date) {
  if (date == null) return '';
  return formatDate(date);
}

String formatDate(DateTime date) {
  const months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final month = months[(date.month - 1).clamp(0, 11)];
  return '$month ${date.day}, ${date.year}';
}

String formatMoney(double value) => ' ${value.toStringAsFixed(2)}';

int overdueDays(DateTime orderDate) {
  final now = DateTime.now();
  final diff = now.difference(orderDate).inDays;
  return diff < 0 ? 0 : diff;
}
