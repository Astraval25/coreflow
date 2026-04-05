class ItemStatusResponse {
  final bool responseStatus;
  final int responseCode;
  final String responseMessage;
  final dynamic responseData;

  ItemStatusResponse({
    required this.responseStatus,
    required this.responseCode,
    required this.responseMessage,
    this.responseData,
  });

  factory ItemStatusResponse.fromJson(Map<String, dynamic> json) {
    return ItemStatusResponse(
      responseStatus: json['responseStatus'] ?? false,
      responseCode: json['responseCode'] ?? 0,
      responseMessage: json['responseMessage'] ?? '',
      responseData: json['responseData'],
    );
  }
}
