class ResendOtpResponse {
  final bool responseStatus;
  final int responseCode;
  final String? responseMessage;
  final String? responseData;

  const ResendOtpResponse({
    required this.responseStatus,
    required this.responseCode,
    required this.responseMessage,
    required this.responseData,
  });
  factory ResendOtpResponse.fromJson(Map<String, dynamic> json) {
    return ResendOtpResponse(
      responseStatus: json['responseStatus'] ?? false,
      responseCode: json['responseCode'] ?? 0,
      responseMessage: json['responseMessage'] ?? '',
      responseData: json['responseData'],
    );
  }
}
