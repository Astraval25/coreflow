class Employee {
  final int employeeId;
  final String employeeCode;
  final String employeeName;
  final String? phone;
  final String? designation;
  final bool isActive;
  final String? currentSalaryType;
  final double? currentMonthlyAmount;

  Employee({
    required this.employeeId,
    required this.employeeCode,
    required this.employeeName,
    this.phone,
    this.designation,
    this.isActive = true,
    this.currentSalaryType,
    this.currentMonthlyAmount,
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
