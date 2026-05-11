double? employeeParseDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

int? employeeParseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

class CreateSalaryConfigRequest {
  final String salaryType;
  final double? monthlyAmount;
  final String effectiveFrom;

  const CreateSalaryConfigRequest({
    required this.salaryType,
    this.monthlyAmount,
    required this.effectiveFrom,
  });

  Map<String, dynamic> toJson() => {
    'salaryType': salaryType,
    if (monthlyAmount != null) 'monthlyAmount': monthlyAmount,
    'effectiveFrom': effectiveFrom,
  };
}

class SalaryConfigData {
  final int configId;
  final String salaryType;
  final double? monthlyAmount;
  final String effectiveFrom;
  final String? effectiveTo;

  const SalaryConfigData({
    required this.configId,
    required this.salaryType,
    this.monthlyAmount,
    required this.effectiveFrom,
    this.effectiveTo,
  });

  factory SalaryConfigData.fromJson(Map<String, dynamic> json) {
    return SalaryConfigData(
      configId: employeeParseInt(json['configId']) ?? 0,
      salaryType: (json['salaryType'] ?? '').toString(),
      monthlyAmount: employeeParseDouble(json['monthlyAmount']),
      effectiveFrom: (json['effectiveFrom'] ?? '').toString(),
      effectiveTo: json['effectiveTo']?.toString(),
    );
  }
}

class CreatePortalUserRequest {
  final String username;
  final String password;

  const CreatePortalUserRequest({
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toJson() => {'username': username, 'password': password};
}

class ResetPortalPasswordRequest {
  final String password;

  const ResetPortalPasswordRequest({required this.password});

  Map<String, dynamic> toJson() => {'password': password};
}

class PortalUserData {
  final int portalUserId;
  final int employeeId;
  final String username;
  final bool isActive;
  final String? lastLoginDt;

  const PortalUserData({
    required this.portalUserId,
    required this.employeeId,
    required this.username,
    required this.isActive,
    this.lastLoginDt,
  });

  factory PortalUserData.fromJson(Map<String, dynamic> json) {
    return PortalUserData(
      portalUserId: employeeParseInt(json['portalUserId']) ?? 0,
      employeeId: employeeParseInt(json['employeeId']) ?? 0,
      username: (json['username'] ?? '').toString(),
      isActive: json['isActive'] == true,
      lastLoginDt: json['lastLoginDt']?.toString(),
    );
  }
}

class CreateWorkDefinitionRequest {
  final String workName;
  final String workCode;
  final String? description;
  final double ratePerUnit;
  final String unit;

  const CreateWorkDefinitionRequest({
    required this.workName,
    required this.workCode,
    this.description,
    required this.ratePerUnit,
    required this.unit,
  });

  Map<String, dynamic> toJson() => {
    'workName': workName,
    'workCode': workCode,
    if (description != null && description!.trim().isNotEmpty)
      'description': description,
    'ratePerUnit': ratePerUnit,
    'unit': unit,
  };
}

class UpdateWorkDefinitionRequest {
  final String workName;
  final String? description;
  final double ratePerUnit;
  final String unit;

  const UpdateWorkDefinitionRequest({
    required this.workName,
    this.description,
    required this.ratePerUnit,
    required this.unit,
  });

  Map<String, dynamic> toJson() => {
    'workName': workName,
    if (description != null && description!.trim().isNotEmpty)
      'description': description,
    'ratePerUnit': ratePerUnit,
    'unit': unit,
  };
}

class WorkDefinitionData {
  final int workDefId;
  final String workName;
  final String workCode;
  final String? description;
  final double? ratePerUnit;
  final String unit;
  final bool isActive;

  const WorkDefinitionData({
    required this.workDefId,
    required this.workName,
    required this.workCode,
    this.description,
    this.ratePerUnit,
    required this.unit,
    required this.isActive,
  });

  factory WorkDefinitionData.fromJson(Map<String, dynamic> json) {
    return WorkDefinitionData(
      workDefId: employeeParseInt(json['workDefId']) ?? 0,
      workName: (json['workName'] ?? '').toString(),
      workCode: (json['workCode'] ?? '').toString(),
      description: json['description']?.toString(),
      ratePerUnit: employeeParseDouble(json['ratePerUnit']),
      unit: (json['unit'] ?? '').toString(),
      isActive: json['isActive'] == true,
    );
  }
}

class RateHistoryData {
  final int rateHistoryId;
  final double? ratePerUnit;
  final String unit;
  final String effectiveFrom;
  final String? effectiveTo;

  const RateHistoryData({
    required this.rateHistoryId,
    this.ratePerUnit,
    required this.unit,
    required this.effectiveFrom,
    this.effectiveTo,
  });

  factory RateHistoryData.fromJson(Map<String, dynamic> json) {
    return RateHistoryData(
      rateHistoryId: employeeParseInt(json['rateHistoryId']) ?? 0,
      ratePerUnit: employeeParseDouble(json['ratePerUnit']),
      unit: (json['unit'] ?? '').toString(),
      effectiveFrom: (json['effectiveFrom'] ?? '').toString(),
      effectiveTo: json['effectiveTo']?.toString(),
    );
  }
}

class CreateWorkLogRequest {
  final int? employeeId;
  final int workDefId;
  final String logDate;
  final double quantity;
  final String? employeeRemarks;

  const CreateWorkLogRequest({
    this.employeeId,
    required this.workDefId,
    required this.logDate,
    required this.quantity,
    this.employeeRemarks,
  });

  Map<String, dynamic> toJson() => {
    if (employeeId != null) 'employeeId': employeeId,
    'workDefId': workDefId,
    'logDate': logDate,
    'quantity': quantity,
    if (employeeRemarks != null && employeeRemarks!.trim().isNotEmpty)
      'employeeRemarks': employeeRemarks,
  };
}

class ReviewWorkLogRequest {
  final String status;
  final String? adminRemarks;

  const ReviewWorkLogRequest({required this.status, this.adminRemarks});

  Map<String, dynamic> toJson() => {
    'status': status,
    if (adminRemarks != null && adminRemarks!.trim().isNotEmpty)
      'adminRemarks': adminRemarks,
  };
}

class WorkLogData {
  final int logId;
  final int employeeId;
  final String employeeName;
  final int workDefId;
  final String workName;
  final String logDate;
  final double? quantity;
  final String unit;
  final double? rateSnapshot;
  final double? amountEarned;
  final String? employeeRemarks;
  final String status;
  final int? reviewedBy;
  final String? reviewedDt;
  final String? adminRemarks;

  const WorkLogData({
    required this.logId,
    required this.employeeId,
    required this.employeeName,
    required this.workDefId,
    required this.workName,
    required this.logDate,
    this.quantity,
    required this.unit,
    this.rateSnapshot,
    this.amountEarned,
    this.employeeRemarks,
    required this.status,
    this.reviewedBy,
    this.reviewedDt,
    this.adminRemarks,
  });

  factory WorkLogData.fromJson(Map<String, dynamic> json) {
    return WorkLogData(
      logId: employeeParseInt(json['logId']) ?? 0,
      employeeId: employeeParseInt(json['employeeId']) ?? 0,
      employeeName: (json['employeeName'] ?? '').toString(),
      workDefId: employeeParseInt(json['workDefId']) ?? 0,
      workName: (json['workName'] ?? '').toString(),
      logDate: (json['logDate'] ?? '').toString(),
      quantity: employeeParseDouble(json['quantity']),
      unit: (json['unit'] ?? '').toString(),
      rateSnapshot: employeeParseDouble(json['rateSnapshot']),
      amountEarned: employeeParseDouble(json['amountEarned']),
      employeeRemarks: json['employeeRemarks']?.toString(),
      status: (json['status'] ?? '').toString(),
      reviewedBy: employeeParseInt(json['reviewedBy']),
      reviewedDt: json['reviewedDt']?.toString(),
      adminRemarks: json['adminRemarks']?.toString(),
    );
  }
}

class CreateLeaveLogRequest {
  final int? employeeId;
  final String leaveDate;
  final String leaveType;
  final String leaveCategory;
  final String? reason;

  const CreateLeaveLogRequest({
    this.employeeId,
    required this.leaveDate,
    required this.leaveType,
    required this.leaveCategory,
    this.reason,
  });

  Map<String, dynamic> toJson() => {
    if (employeeId != null) 'employeeId': employeeId,
    'leaveDate': leaveDate,
    'leaveType': leaveType,
    'leaveCategory': leaveCategory,
    if (reason != null && reason!.trim().isNotEmpty) 'reason': reason,
  };
}

class ReviewLeaveLogRequest {
  final String status;

  const ReviewLeaveLogRequest({required this.status});

  Map<String, dynamic> toJson() => {'status': status};
}

class LeaveLogData {
  final int leaveId;
  final int employeeId;
  final String employeeName;
  final String leaveDate;
  final String leaveType;
  final String leaveCategory;
  final String? reason;
  final String status;
  final int? approvedBy;
  final String? approvedDt;

  const LeaveLogData({
    required this.leaveId,
    required this.employeeId,
    required this.employeeName,
    required this.leaveDate,
    required this.leaveType,
    required this.leaveCategory,
    this.reason,
    required this.status,
    this.approvedBy,
    this.approvedDt,
  });

  factory LeaveLogData.fromJson(Map<String, dynamic> json) {
    return LeaveLogData(
      leaveId: employeeParseInt(json['leaveId']) ?? 0,
      employeeId: employeeParseInt(json['employeeId']) ?? 0,
      employeeName: (json['employeeName'] ?? '').toString(),
      leaveDate: (json['leaveDate'] ?? '').toString(),
      leaveType: (json['leaveType'] ?? '').toString(),
      leaveCategory: (json['leaveCategory'] ?? '').toString(),
      reason: json['reason']?.toString(),
      status: (json['status'] ?? '').toString(),
      approvedBy: employeeParseInt(json['approvedBy']),
      approvedDt: json['approvedDt']?.toString(),
    );
  }
}

class CalculateSalaryRequest {
  final String fromDate;
  final String toDate;
  final int? employeeId;

  const CalculateSalaryRequest({
    required this.fromDate,
    required this.toDate,
    this.employeeId,
  });

  Map<String, dynamic> toJson() => {
    'fromDate': fromDate,
    'toDate': toDate,
    if (employeeId != null) 'employeeId': employeeId,
  };
}

class SalaryPeriodSummary {
  final int salaryPeriodId;
  final int employeeId;
  final String employeeName;
  final String employeeCode;
  final String period;
  final String fromDate;
  final String toDate;
  final String salaryType;
  final double? grossAmount;
  final double? netAmount;
  final double? paidAmount;
  final double? balanceAmount;
  final int? paymentCount;
  final String status;

  const SalaryPeriodSummary({
    required this.salaryPeriodId,
    required this.employeeId,
    required this.employeeName,
    required this.employeeCode,
    required this.period,
    required this.fromDate,
    required this.toDate,
    required this.salaryType,
    this.grossAmount,
    this.netAmount,
    this.paidAmount,
    this.balanceAmount,
    this.paymentCount,
    required this.status,
  });

  factory SalaryPeriodSummary.fromJson(Map<String, dynamic> json) {
    return SalaryPeriodSummary(
      salaryPeriodId: employeeParseInt(json['salaryPeriodId']) ?? 0,
      employeeId: employeeParseInt(json['employeeId']) ?? 0,
      employeeName: (json['employeeName'] ?? '').toString(),
      employeeCode: (json['employeeCode'] ?? '').toString(),
      period: (json['period'] ?? '').toString(),
      fromDate: (json['fromDate'] ?? '').toString(),
      toDate: (json['toDate'] ?? '').toString(),
      salaryType: (json['salaryType'] ?? '').toString(),
      grossAmount: employeeParseDouble(json['grossAmount']),
      netAmount: employeeParseDouble(json['netAmount']),
      paidAmount: employeeParseDouble(json['paidAmount']),
      balanceAmount: employeeParseDouble(json['balanceAmount']),
      paymentCount: employeeParseInt(json['paymentCount']),
      status: (json['status'] ?? '').toString(),
    );
  }
}

class SalaryLineData {
  final int lineId;
  final String lineType;
  final String description;
  final double? totalQty;
  final String? unit;
  final double? rateUsed;
  final double? amount;
  final int? workDefId;
  final String? workName;

  const SalaryLineData({
    required this.lineId,
    required this.lineType,
    required this.description,
    this.totalQty,
    this.unit,
    this.rateUsed,
    this.amount,
    this.workDefId,
    this.workName,
  });

  factory SalaryLineData.fromJson(Map<String, dynamic> json) {
    return SalaryLineData(
      lineId: employeeParseInt(json['lineId']) ?? 0,
      lineType: (json['lineType'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      totalQty: employeeParseDouble(json['totalQty']),
      unit: json['unit']?.toString(),
      rateUsed: employeeParseDouble(json['rateUsed']),
      amount: employeeParseDouble(json['amount']),
      workDefId: employeeParseInt(json['workDefId']),
      workName: json['workName']?.toString(),
    );
  }
}

class SalaryPaymentData {
  final int? expenseId;
  final String expenseDate;
  final String paymentMode;
  final double? amount;
  final String? invoiceNo;
  final String? remark;

  const SalaryPaymentData({
    this.expenseId,
    required this.expenseDate,
    required this.paymentMode,
    this.amount,
    this.invoiceNo,
    this.remark,
  });

  factory SalaryPaymentData.fromJson(Map<String, dynamic> json) {
    return SalaryPaymentData(
      expenseId: employeeParseInt(json['expenseId']),
      expenseDate: (json['expenseDate'] ?? '').toString(),
      paymentMode: (json['paymentMode'] ?? '').toString(),
      amount: employeeParseDouble(json['amount']),
      invoiceNo: json['invoiceNo']?.toString(),
      remark: json['remark']?.toString(),
    );
  }
}

class SalaryPeriodDetailData {
  final int salaryPeriodId;
  final int employeeId;
  final String employeeName;
  final String employeeCode;
  final String period;
  final String fromDate;
  final String toDate;
  final String salaryType;
  final int? workingDaysInMonth;
  final double? daysPresent;
  final double? daysAbsent;
  final double? lopDays;
  final double? grossAmount;
  final double? lopDeduction;
  final double? otherDeductions;
  final double? netAmount;
  final double? paidAmount;
  final double? balanceAmount;
  final int? paymentCount;
  final String status;
  final int? approvedBy;
  final String? approvedDt;
  final String? paidDt;
  final String? paymentRef;
  final String? computedDt;
  final List<SalaryPaymentData> payments;
  final List<SalaryLineData> lines;

  const SalaryPeriodDetailData({
    required this.salaryPeriodId,
    required this.employeeId,
    required this.employeeName,
    required this.employeeCode,
    required this.period,
    required this.fromDate,
    required this.toDate,
    required this.salaryType,
    this.workingDaysInMonth,
    this.daysPresent,
    this.daysAbsent,
    this.lopDays,
    this.grossAmount,
    this.lopDeduction,
    this.otherDeductions,
    this.netAmount,
    this.paidAmount,
    this.balanceAmount,
    this.paymentCount,
    required this.status,
    this.approvedBy,
    this.approvedDt,
    this.paidDt,
    this.paymentRef,
    this.computedDt,
    this.payments = const [],
    this.lines = const [],
  });

  factory SalaryPeriodDetailData.fromJson(Map<String, dynamic> json) {
    return SalaryPeriodDetailData(
      salaryPeriodId: employeeParseInt(json['salaryPeriodId']) ?? 0,
      employeeId: employeeParseInt(json['employeeId']) ?? 0,
      employeeName: (json['employeeName'] ?? '').toString(),
      employeeCode: (json['employeeCode'] ?? '').toString(),
      period: (json['period'] ?? '').toString(),
      fromDate: (json['fromDate'] ?? '').toString(),
      toDate: (json['toDate'] ?? '').toString(),
      salaryType: (json['salaryType'] ?? '').toString(),
      workingDaysInMonth: employeeParseInt(json['workingDaysInMonth']),
      daysPresent: employeeParseDouble(json['daysPresent']),
      daysAbsent: employeeParseDouble(json['daysAbsent']),
      lopDays: employeeParseDouble(json['lopDays']),
      grossAmount: employeeParseDouble(json['grossAmount']),
      lopDeduction: employeeParseDouble(json['lopDeduction']),
      otherDeductions: employeeParseDouble(json['otherDeductions']),
      netAmount: employeeParseDouble(json['netAmount']),
      paidAmount: employeeParseDouble(json['paidAmount']),
      balanceAmount: employeeParseDouble(json['balanceAmount']),
      paymentCount: employeeParseInt(json['paymentCount']),
      status: (json['status'] ?? '').toString(),
      approvedBy: employeeParseInt(json['approvedBy']),
      approvedDt: json['approvedDt']?.toString(),
      paidDt: json['paidDt']?.toString(),
      paymentRef: json['paymentRef']?.toString(),
      computedDt: json['computedDt']?.toString(),
      payments: (json['payments'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(SalaryPaymentData.fromJson)
          .toList(),
      lines: (json['lines'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(SalaryLineData.fromJson)
          .toList(),
    );
  }
}

class MarkSalaryPaidRequest {
  final String? paymentRef;

  const MarkSalaryPaidRequest({this.paymentRef});

  Map<String, dynamic> toJson() => {
    if (paymentRef != null && paymentRef!.trim().isNotEmpty)
      'paymentRef': paymentRef,
  };
}

class SalaryReportData {
  final String fromDate;
  final String toDate;
  final int totalEmployees;
  final double? totalGrossAmount;
  final double? totalDeductions;
  final double? totalNetAmount;
  final List<SalaryPeriodDetailData> salaryDetails;

  const SalaryReportData({
    required this.fromDate,
    required this.toDate,
    required this.totalEmployees,
    this.totalGrossAmount,
    this.totalDeductions,
    this.totalNetAmount,
    this.salaryDetails = const [],
  });

  factory SalaryReportData.fromJson(Map<String, dynamic> json) {
    return SalaryReportData(
      fromDate: (json['fromDate'] ?? '').toString(),
      toDate: (json['toDate'] ?? '').toString(),
      totalEmployees: employeeParseInt(json['totalEmployees']) ?? 0,
      totalGrossAmount: employeeParseDouble(json['totalGrossAmount']),
      totalDeductions: employeeParseDouble(json['totalDeductions']),
      totalNetAmount: employeeParseDouble(json['totalNetAmount']),
      salaryDetails: (json['salaryDetails'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(SalaryPeriodDetailData.fromJson)
          .toList(),
    );
  }
}
