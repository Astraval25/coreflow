class EmployeeEditRequest {
  final String employeeName;
  final String? phone;
  final String? email;
  final String? designation;
  final String? joinedDt;

  EmployeeEditRequest({
    required this.employeeName,
    this.phone,
    this.email,
    this.designation,
    this.joinedDt,
  });

  Map<String, dynamic> toJson() => {
    'employeeName': employeeName,
    if (phone != null) 'phone': phone,
    if (email != null) 'email': email,
    if (designation != null) 'designation': designation,
    if (joinedDt != null) 'joinedDt': joinedDt,
  };
}
