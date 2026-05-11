class ExpenseAccount {
  final int expenseAccountId;
  final String accountType;
  final String accountName;
  final bool isActive;
  final String? createdDt;
  final String? lastModifiedDt;

  const ExpenseAccount({
    required this.expenseAccountId,
    required this.accountType,
    required this.accountName,
    required this.isActive,
    this.createdDt,
    this.lastModifiedDt,
  });

  factory ExpenseAccount.fromJson(Map<String, dynamic> json) {
    return ExpenseAccount(
      expenseAccountId: _toInt(json['expenseAccountId']),
      accountType: (json['accountType'] ?? '').toString(),
      accountName: (json['accountName'] ?? '').toString(),
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
}
