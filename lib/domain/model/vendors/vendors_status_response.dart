class VendorsStatusResponse {
  final bool responseStatus;
  final int responseCode;
  final String responseMessage;
  final dynamic responseData;

  VendorsStatusResponse({
    required this.responseStatus,
    required this.responseCode,
    required this.responseMessage,
    this.responseData,
  });

  factory VendorsStatusResponse.fromJson(Map<String, dynamic> json) {
    return VendorsStatusResponse(
      responseStatus: json['responseStatus'] ?? false,
      responseCode: json['responseCode'] ?? 0,
      responseMessage: json['responseMessage'] ?? '',
      responseData: json['responseData'],
    );
  }
}
