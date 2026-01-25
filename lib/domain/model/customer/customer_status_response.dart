class CustomerStatusResponse {
  final bool responseStatus;
  final int responseCode;
  final String responseMessage;
  final dynamic responseData;

  CustomerStatusResponse({
    required this.responseStatus,
    required this.responseCode,
    required this.responseMessage,
    this.responseData,
  });

  factory CustomerStatusResponse.fromJson(Map<String, dynamic> json) {
    return CustomerStatusResponse(
      responseStatus: json['responseStatus'] ?? false,
      responseCode: json['responseCode'] ?? 0,
      responseMessage: json['responseMessage'] ?? '',
      responseData: json['responseData'],
    );
  }
}
