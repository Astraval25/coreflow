class Employee {
  final int employeeId;
  final String employeeCode;
  final String employeeName;
  final String? phone;
  final String? designation;
  final bool isActive;
  final String? currentSalaryType;
  final double? currentMonthlyAmount;
  final int unreadCount;
  final int pendingWorkLogCount;
  final int pendingLeaveLogCount;
  final int pendingTotalCount;

  Employee({
    required this.employeeId,
    required this.employeeCode,
    required this.employeeName,
    this.phone,
    this.designation,
    this.isActive = true,
    this.currentSalaryType,
    this.currentMonthlyAmount,
    this.unreadCount = 0,
    this.pendingWorkLogCount = 0,
    this.pendingLeaveLogCount = 0,
    this.pendingTotalCount = 0,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      employeeId: json['employeeId'] ?? 0,
      employeeCode: json['employeeCode'] ?? '',
      employeeName: json['employeeName'] ?? '',
      phone: json['phone'],
      designation: json['designation'],
      isActive: json['isActive'] ?? true,
      currentSalaryType: json['currentSalaryType'],
      currentMonthlyAmount: _parseDouble(json['currentMonthlyAmount']),
      unreadCount: json['unreadCount'] ?? 0,
      pendingWorkLogCount: json['pendingWorkLogCount'] ?? 0,
      pendingLeaveLogCount: json['pendingLeaveLogCount'] ?? 0,
      pendingTotalCount: json['pendingTotalCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employeeId': employeeId,
      'employeeCode': employeeCode,
      'employeeName': employeeName,
      'phone': phone,
      'designation': designation,
      'isActive': isActive,
      'currentSalaryType': currentSalaryType,
      'currentMonthlyAmount': currentMonthlyAmount,
      'unreadCount': unreadCount,
      'pendingWorkLogCount': pendingWorkLogCount,
      'pendingLeaveLogCount': pendingLeaveLogCount,
      'pendingTotalCount': pendingTotalCount,
    };
  }

  Employee copyWith({
    int? employeeId,
    String? employeeCode,
    String? employeeName,
    String? phone,
    String? designation,
    bool? isActive,
    String? currentSalaryType,
    double? currentMonthlyAmount,
    int? unreadCount,
    int? pendingWorkLogCount,
    int? pendingLeaveLogCount,
    int? pendingTotalCount,
  }) {
    return Employee(
      employeeId: employeeId ?? this.employeeId,
      employeeCode: employeeCode ?? this.employeeCode,
      employeeName: employeeName ?? this.employeeName,
      phone: phone ?? this.phone,
      designation: designation ?? this.designation,
      isActive: isActive ?? this.isActive,
      currentSalaryType: currentSalaryType ?? this.currentSalaryType,
      currentMonthlyAmount: currentMonthlyAmount ?? this.currentMonthlyAmount,
      unreadCount: unreadCount ?? this.unreadCount,
      pendingWorkLogCount: pendingWorkLogCount ?? this.pendingWorkLogCount,
      pendingLeaveLogCount: pendingLeaveLogCount ?? this.pendingLeaveLogCount,
      pendingTotalCount: pendingTotalCount ?? this.pendingTotalCount,
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
