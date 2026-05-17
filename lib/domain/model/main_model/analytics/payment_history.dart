class PaymentHistoryEntry {
  final int paymentId;
  final String paymentType;
  final DateTime paymentDate;
  final String partyName;
  final String localPaymentNumber;
  final String paymentStatus;
  final String modeOfPayment;
  final double quantity;
  final double totalAmount;
  final double paidAmount;
  final double amount;

  const PaymentHistoryEntry({
    required this.paymentId,
    required this.paymentType,
    required this.paymentDate,
    this.partyName = '',
    required this.localPaymentNumber,
    required this.paymentStatus,
    required this.modeOfPayment,
    this.quantity = 0,
    this.totalAmount = 0,
    this.paidAmount = 0,
    required this.amount,
  });

  factory PaymentHistoryEntry.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) {
      if (value is DateTime) return value;
      if (value is String && value.trim().isNotEmpty) {
        return DateTime.tryParse(value) ??
            DateTime.fromMillisecondsSinceEpoch(0);
      }
      return DateTime.fromMillisecondsSinceEpoch(0);
    }

    int parseInt(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    double parseDouble(dynamic value) {
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '') ?? 0;
    }

    String firstText(List<dynamic> values) {
      for (final value in values) {
        final text = (value ?? '').toString().trim();
        if (text.isNotEmpty) return text;
      }
      return '';
    }

    final amount = parseDouble(json['amount']);
    final totalAmount = parseDouble(
      json['totalAmount'] ?? json['invoiceAmount'] ?? json['orderTotalAmount'],
    );
    final paidAmount = parseDouble(
      json['paidAmount'] ?? json['totalPaid'] ?? json['amountPaid'] ?? amount,
    );
    final quantity = parseDouble(
      json['totalItemQuantity'] ??
          json['quantity'] ??
          json['itemQuantity'] ??
          json['orderCount'],
    );

    return PaymentHistoryEntry(
      paymentId: parseInt(json['paymentId']),
      paymentType: (json['paymentType'] ?? '').toString(),
      paymentDate: parseDate(json['paymentDate']),
      partyName: firstText([
        json['partyName'],
        json['customerName'],
        json['vendorName'],
        json['counterpartyName'],
        json['partyDisplayName'],
      ]),
      localPaymentNumber: (json['localPaymentNumber'] ?? '').toString(),
      paymentStatus: (json['paymentStatus'] ?? '').toString(),
      modeOfPayment: (json['modeOfPayment'] ?? '').toString(),
      quantity: quantity,
      totalAmount: totalAmount > 0 ? totalAmount : amount,
      paidAmount: paidAmount,
      amount: amount,
    );
  }
}
