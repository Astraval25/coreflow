class VerifyOtpResponse {
  final bool responseStatus;
  final int responseCode;
  final String responseMessage;
  final String? responseData;

  const VerifyOtpResponse({
    required this.responseStatus,
    required this.responseCode,
    required this.responseMessage,
    required this.responseData,
  });

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResponse(
      responseStatus: json['responseStatus'] ?? false,
      responseCode: json['responseCode'] ?? 0,
      responseMessage: json['responseMessage'] ?? '',
      responseData: json['responseData'],
    );
  }
}
