class Expense {
  final int expenseId;
  final String expenseDate;
  final String paymentMode;
  final double amount;
  final int expenseAccountId;
  final String? expenseAccountName;
  final String? expenseAccountType;
  final String? invoiceNo;
  final int? vendorId;
  final String? vendorName;
  final int? customerId;
  final String? customerName;
  final String? remark;
  final int? salaryPeriodId;
  final bool isActive;
  final String? createdDt;
  final String? lastModifiedDt;

  const Expense({
    required this.expenseId,
    required this.expenseDate,
    required this.paymentMode,
    required this.amount,
    required this.expenseAccountId,
    this.expenseAccountName,
    this.expenseAccountType,
    this.invoiceNo,
    this.vendorId,
    this.vendorName,
    this.customerId,
    this.customerName,
    this.remark,
    this.salaryPeriodId,
    required this.isActive,
    this.createdDt,
    this.lastModifiedDt,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      expenseId: _toInt(json['expenseId']),
      expenseDate: (json['expenseDate'] ?? '').toString(),
      paymentMode: (json['paymentMode'] ?? '').toString(),
      amount: _toDouble(json['amount']),
      expenseAccountId: _toInt(json['expenseAccountId']),
      expenseAccountName: json['expenseAccountName']?.toString(),
      expenseAccountType: json['expenseAccountType']?.toString(),
      invoiceNo: json['invoiceNo']?.toString(),
      vendorId: _toIntOrNull(json['vendorId']),
      vendorName: json['vendorName']?.toString(),
      customerId: _toIntOrNull(json['customerId']),
      customerName: json['customerName']?.toString(),
      remark: json['remark']?.toString(),
      salaryPeriodId: _toIntOrNull(json['salaryPeriodId']),
      isActive: json['isActive'] == true,
      createdDt: json['createdDt']?.toString(),
      lastModifiedDt: json['lastModifiedDt']?.toString(),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? _toIntOrNull(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
