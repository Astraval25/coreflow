class EmployeeAnalyticsOverviewEntry {
  final int employeeId;
  final String employeeCode;
  final String employeeName;
  final int approvedWorkLogCount;
  final double approvedWorkQuantity;
  final double approvedWorkAmount;
  final int approvedLeaveCount;
  final double approvedLeaveDays;
  final int pendingWorkLogCount;
  final int pendingLeaveLogCount;

  const EmployeeAnalyticsOverviewEntry({
    required this.employeeId,
    required this.employeeCode,
    required this.employeeName,
    required this.approvedWorkLogCount,
    required this.approvedWorkQuantity,
    required this.approvedWorkAmount,
    required this.approvedLeaveCount,
    required this.approvedLeaveDays,
    required this.pendingWorkLogCount,
    required this.pendingLeaveLogCount,
  });

  factory EmployeeAnalyticsOverviewEntry.fromJson(Map<String, dynamic> json) {
    return EmployeeAnalyticsOverviewEntry(
      employeeId: (json['employeeId'] as num?)?.toInt() ?? 0,
      employeeCode: (json['employeeCode'] ?? '').toString(),
      employeeName: (json['employeeName'] ?? '').toString(),
      approvedWorkLogCount:
          (json['approvedWorkLogCount'] as num?)?.toInt() ?? 0,
      approvedWorkQuantity:
          (json['approvedWorkQuantity'] as num?)?.toDouble() ?? 0,
      approvedWorkAmount: (json['approvedWorkAmount'] as num?)?.toDouble() ?? 0,
      approvedLeaveCount: (json['approvedLeaveCount'] as num?)?.toInt() ?? 0,
      approvedLeaveDays: (json['approvedLeaveDays'] as num?)?.toDouble() ?? 0,
      pendingWorkLogCount: (json['pendingWorkLogCount'] as num?)?.toInt() ?? 0,
      pendingLeaveLogCount:
          (json['pendingLeaveLogCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class EmployeeDailyAnalyticsEntry {
  final DateTime day;
  final double approvedWorkQuantity;
  final double approvedWorkAmount;
  final double approvedLeaveDays;

  const EmployeeDailyAnalyticsEntry({
    required this.day,
    required this.approvedWorkQuantity,
    required this.approvedWorkAmount,
    required this.approvedLeaveDays,
  });

  factory EmployeeDailyAnalyticsEntry.fromJson(Map<String, dynamic> json) {
    return EmployeeDailyAnalyticsEntry(
      day: DateTime.tryParse((json['day'] ?? '').toString()) ?? DateTime(1970),
      approvedWorkQuantity:
          (json['approvedWorkQuantity'] as num?)?.toDouble() ?? 0,
      approvedWorkAmount: (json['approvedWorkAmount'] as num?)?.toDouble() ?? 0,
      approvedLeaveDays: (json['approvedLeaveDays'] as num?)?.toDouble() ?? 0,
    );
  }
}
