class OrderHistoryEntry {
  final int orderId;
  final String orderType;
  final DateTime orderDate;
  final String partyName;
  final String localOrderNumber;
  final String orderStatus;
  final double totalItemQuantity;
  final double totalAmount;
  final double paidAmount;
  final int paidPercentage;

  const OrderHistoryEntry({
    required this.orderId,
    required this.orderType,
    required this.orderDate,
    this.partyName = '',
    required this.localOrderNumber,
    required this.orderStatus,
    required this.totalItemQuantity,
    required this.totalAmount,
    this.paidAmount = 0,
    required this.paidPercentage,
  });

  factory OrderHistoryEntry.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) {
      if (value is DateTime) return value;
      if (value is String && value.trim().isNotEmpty) {
        return DateTime.tryParse(value) ??
            DateTime.fromMillisecondsSinceEpoch(0);
      }
      return DateTime.fromMillisecondsSinceEpoch(0);
    }

    double parseDouble(dynamic value) {
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '') ?? 0.0;
    }

    int parseInt(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    String firstText(List<dynamic> values) {
      for (final value in values) {
        final text = (value ?? '').toString().trim();
        if (text.isNotEmpty) return text;
      }
      return '';
    }

    final totalAmount = parseDouble(json['totalAmount']);
    final paidPercentage = parseInt(json['paidPercentage']);
    final explicitPaidAmount = parseDouble(
      json['paidAmount'] ?? json['totalPaid'] ?? json['amountPaid'],
    );
    final computedPaidAmount = (totalAmount * paidPercentage) / 100;

    return OrderHistoryEntry(
      orderId: parseInt(json['orderId']),
      orderType: (json['orderType'] ?? '').toString(),
      orderDate: parseDate(json['orderDate']),
      partyName: firstText([
        json['partyName'],
        json['customerName'],
        json['vendorName'],
        json['counterpartyName'],
        json['partyDisplayName'],
      ]),
      localOrderNumber: (json['localOrderNumber'] ?? '').toString(),
      orderStatus: (json['orderStatus'] ?? '').toString(),
      totalItemQuantity: parseDouble(json['totalItemQuantity']),
      totalAmount: totalAmount,
      paidAmount: explicitPaidAmount > 0
          ? explicitPaidAmount
          : computedPaidAmount,
      paidPercentage: paidPercentage,
    );
  }
}
