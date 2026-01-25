class CustomerEditResponse {
  final bool responseStatus;
  final int? responseCode;
  final String? responseMessage;
  final dynamic responseData;

  CustomerEditResponse({
    required this.responseStatus,
    this.responseCode,
    this.responseMessage,
    this.responseData,
  });

  factory CustomerEditResponse.fromJson(Map<String, dynamic> json) {
    return CustomerEditResponse(
      responseStatus: json['responseStatus'] ?? false,
      responseCode: json['responseCode'],
      responseMessage: json['responseMessage'] ?? '',
      responseData: json['responseData'],
    );
  }
}
