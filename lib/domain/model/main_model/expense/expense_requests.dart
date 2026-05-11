class ExpenseAccountRequest {
  final String accountType;
  final String accountName;

  const ExpenseAccountRequest({
    required this.accountType,
    required this.accountName,
  });

  Map<String, dynamic> toJson() => {
    'accountType': accountType,
    'accountName': accountName,
  };
}

class ExpenseRequest {
  final String expenseDate;
  final String paymentMode;
  final double amount;
  final int expenseAccountId;
  final String? invoiceNo;
  final int? vendorId;
  final int? customerId;
  final String? remark;
  final int? salaryPeriodId;

  const ExpenseRequest({
    required this.expenseDate,
    required this.paymentMode,
    required this.amount,
    required this.expenseAccountId,
    this.invoiceNo,
    this.vendorId,
    this.customerId,
    this.remark,
    this.salaryPeriodId,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'expenseDate': expenseDate,
      'paymentMode': paymentMode,
      'amount': amount,
      'expenseAccountId': expenseAccountId,
    };

    void addIfNotBlank(String key, String? value) {
      if (value == null) return;
      final trimmed = value.trim();
      if (trimmed.isNotEmpty) data[key] = trimmed;
    }

    addIfNotBlank('invoiceNo', invoiceNo);
    addIfNotBlank('remark', remark);

    if (vendorId != null) data['vendorId'] = vendorId;
    if (customerId != null) data['customerId'] = customerId;
    if (salaryPeriodId != null) data['salaryPeriodId'] = salaryPeriodId;

    return data;
  }
}
