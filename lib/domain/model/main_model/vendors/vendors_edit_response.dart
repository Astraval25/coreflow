class VendorsEditResponse {
  final bool responseStatus;
  final int? responseCode;
  final String? responseMessage;
  final dynamic responseData;

  VendorsEditResponse({
    required this.responseStatus,
    this.responseCode,
    this.responseMessage,
    this.responseData,
  });

  factory VendorsEditResponse.fromJson(Map<String, dynamic> json) {
    return VendorsEditResponse(
      responseStatus: json['responseStatus'] ?? false,
      responseCode: json['responseCode'],
      responseMessage: json['responseMessage'] ?? '',
      responseData: json['responseData'],
    );
  }
}
