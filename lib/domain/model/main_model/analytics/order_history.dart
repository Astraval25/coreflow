class OrderHistoryEntry {
  final int orderId;
  final String orderType;
  final DateTime orderDate;
  final String localOrderNumber;
  final String orderStatus;
  final double totalItemQuantity;
  final double totalAmount;
  final int paidPercentage;

  const OrderHistoryEntry({
    required this.orderId,
    required this.orderType,
    required this.orderDate,
    required this.localOrderNumber,
    required this.orderStatus,
    required this.totalItemQuantity,
    required this.totalAmount,
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

    return OrderHistoryEntry(
      orderId: parseInt(json['orderId']),
      orderType: (json['orderType'] ?? '').toString(),
      orderDate: parseDate(json['orderDate']),
      localOrderNumber: (json['localOrderNumber'] ?? '').toString(),
      orderStatus: (json['orderStatus'] ?? '').toString(),
      totalItemQuantity: parseDouble(json['totalItemQuantity']),
      totalAmount: parseDouble(json['totalAmount']),
      paidPercentage: parseInt(json['paidPercentage']),
    );
  }
}
