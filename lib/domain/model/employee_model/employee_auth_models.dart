class EmployeeLoginRequest {
  final String username;
  final String password;

  const EmployeeLoginRequest({required this.username, required this.password});

  Map<String, dynamic> toJson() => {'username': username, 'password': password};
}

class EmployeeAuthResponse {
  final bool responseStatus;
  final int responseCode;
  final String responseMessage;
  final EmployeeAuthData? responseData;

  const EmployeeAuthResponse({
    required this.responseStatus,
    required this.responseCode,
    required this.responseMessage,
    this.responseData,
  });

  factory EmployeeAuthResponse.fromJson(Map<String, dynamic> json) {
    return EmployeeAuthResponse(
      responseStatus: json['responseStatus'] == true,
      responseCode: (json['responseCode'] as num?)?.toInt() ?? 0,
      responseMessage: (json['responseMessage'] ?? '').toString(),
      responseData: json['responseData'] is Map<String, dynamic>
          ? EmployeeAuthData.fromJson(
              json['responseData'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

class EmployeeAuthData {
  final String token;
  final String refreshToken;
  final int employeeId;
  final String employeeName;
  final String employeeCode;
  final int companyId;
  final String companyName;
  final String? designation;

  const EmployeeAuthData({
    required this.token,
    required this.refreshToken,
    required this.employeeId,
    required this.employeeName,
    required this.employeeCode,
    required this.companyId,
    required this.companyName,
    this.designation,
  });

  factory EmployeeAuthData.fromJson(Map<String, dynamic> json) {
    return EmployeeAuthData(
      token: (json['token'] ?? '').toString(),
      refreshToken: (json['refreshToken'] ?? '').toString(),
      employeeId: (json['employeeId'] as num?)?.toInt() ?? 0,
      employeeName: (json['employeeName'] ?? '').toString(),
      employeeCode: (json['employeeCode'] ?? '').toString(),
      companyId: (json['companyId'] as num?)?.toInt() ?? 0,
      companyName: (json['companyName'] ?? '').toString(),
      designation: json['designation']?.toString(),
    );
  }
}
