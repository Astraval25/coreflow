class CreateEmployeeRequest {
  final String employeeCode;
  final String employeeName;
  final String? phone;
  final String? email;
  final String? designation;
  final String? joinedDt;
  final String salaryType;
  final double? monthlyAmount;

  CreateEmployeeRequest({
    required this.employeeCode,
    required this.employeeName,
    this.phone,
    this.email,
    this.designation,
    this.joinedDt,
    required this.salaryType,
    this.monthlyAmount,
  });

  Map<String, dynamic> toJson() => {
    'employeeCode': employeeCode,
    'employeeName': employeeName,
    if (phone != null) 'phone': phone,
    if (email != null) 'email': email,
    if (designation != null) 'designation': designation,
    if (joinedDt != null) 'joinedDt': joinedDt,
    'salaryType': salaryType,
    if (monthlyAmount != null) 'monthlyAmount': monthlyAmount,
  };
}
