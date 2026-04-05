class EmployeeStatusResponse {
  final bool responseStatus;
  final int responseCode;
  final String responseMessage;
  final dynamic responseData;

  EmployeeStatusResponse({
    required this.responseStatus,
    required this.responseCode,
    required this.responseMessage,
    this.responseData,
  });

  factory EmployeeStatusResponse.fromJson(Map<String, dynamic> json) {
    return EmployeeStatusResponse(
      responseStatus: json['responseStatus'] ?? false,
      responseCode: json['responseCode'] ?? 0,
      responseMessage: json['responseMessage'] ?? '',
      responseData: json['responseData'],
    );
  }
}
