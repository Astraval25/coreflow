class SalaryConfigHistory {
  final int configId;
  final String salaryType;
  final double? monthlyAmount;
  final String effectiveFrom;
  final String? effectiveTo;

  SalaryConfigHistory({
    required this.configId,
    required this.salaryType,
    this.monthlyAmount,
    required this.effectiveFrom,
    this.effectiveTo,
  });

  factory SalaryConfigHistory.fromJson(Map<String, dynamic> json) {
    return SalaryConfigHistory(
      configId: json['configId'] ?? 0,
      salaryType: json['salaryType'] ?? '',
      monthlyAmount: _parseDouble(json['monthlyAmount']),
      effectiveFrom: json['effectiveFrom'] ?? '',
      effectiveTo: json['effectiveTo'],
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}

class EmployeeDetailResponse {
  final bool responseStatus;
  final int responseCode;
  final String responseMessage;
  final EmployeeDetailData? responseData;

  EmployeeDetailResponse({
    required this.responseStatus,
    required this.responseCode,
    required this.responseMessage,
    this.responseData,
  });

  factory EmployeeDetailResponse.fromJson(Map<String, dynamic> json) {
    return EmployeeDetailResponse(
      responseStatus: json['responseStatus'] ?? false,
      responseCode: json['responseCode'] ?? 0,
      responseMessage: json['responseMessage'] ?? '',
      responseData: json['responseData'] != null
          ? EmployeeDetailData.fromJson(json['responseData'])
          : null,
    );
  }
}

class EmployeeDetailData {
  final int employeeId;
  final String employeeCode;
  final String employeeName;
  final String? phone;
  final String? email;
  final String? designation;
  final String? joinedDt;
  final bool isActive;
  final String? currentSalaryType;
  final double? currentMonthlyAmount;
  final List<SalaryConfigHistory> salaryConfigHistory;
  final int? createdBy;
  final String? createdDt;
  final int? lastModifiedBy;
  final String? lastModifiedDt;

  EmployeeDetailData({
    required this.employeeId,
    required this.employeeCode,
    required this.employeeName,
    this.phone,
    this.email,
    this.designation,
    this.joinedDt,
    required this.isActive,
    this.currentSalaryType,
    this.currentMonthlyAmount,
    this.salaryConfigHistory = const [],
    this.createdBy,
    this.createdDt,
    this.lastModifiedBy,
    this.lastModifiedDt,
  });

  factory EmployeeDetailData.fromJson(Map<String, dynamic> json) {
    return EmployeeDetailData(
      employeeId: json['employeeId'] ?? 0,
      employeeCode: json['employeeCode'] ?? '',
      employeeName: json['employeeName'] ?? '',
      phone: json['phone'],
      email: json['email'],
      designation: json['designation'],
      joinedDt: json['joinedDt'],
      isActive: json['isActive'] ?? false,
      currentSalaryType: json['currentSalaryType'],
      currentMonthlyAmount: _parseDouble(json['currentMonthlyAmount']),
      salaryConfigHistory: (json['salaryConfigHistory'] as List<dynamic>?)
              ?.map((e) => SalaryConfigHistory.fromJson(e))
              .toList() ??
          [],
      createdBy: json['createdBy'],
      createdDt: json['createdDt'],
      lastModifiedBy: json['lastModifiedBy'],
      lastModifiedDt: json['lastModifiedDt'],
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
