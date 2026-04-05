class EmployeeEditResponse {
  final bool responseStatus;
  final int? responseCode;
  final String? responseMessage;
  final dynamic responseData;

  EmployeeEditResponse({
    required this.responseStatus,
    this.responseCode,
    this.responseMessage,
    this.responseData,
  });

  factory EmployeeEditResponse.fromJson(Map<String, dynamic> json) {
    return EmployeeEditResponse(
      responseStatus: json['responseStatus'] ?? false,
      responseCode: json['responseCode'],
      responseMessage: json['responseMessage'] ?? '',
      responseData: json['responseData'],
    );
  }
}
