class PaymentProofData {
  final String fsId;
  final String? transactionId;
  final double? amount;
  final String? extractedText;

  PaymentProofData({
    required this.fsId,
    this.transactionId,
    this.amount,
    this.extractedText,
  });

  factory PaymentProofData.fromJson(Map<String, dynamic> json) {
    return PaymentProofData(
      fsId: json['fsId'] ?? '',
      transactionId: json['transactionId'],
      amount: json['amount'] != null ? (json['amount'] as num).toDouble() : null,
      extractedText: json['extractedText'],
    );
  }
}

class PaymentProofResponse {
  final bool responseStatus;
  final int responseCode;
  final String responseMessage;
  final PaymentProofData? responseData;

  PaymentProofResponse({
    required this.responseStatus,
    required this.responseCode,
    required this.responseMessage,
    this.responseData,
  });

  factory PaymentProofResponse.fromJson(Map<String, dynamic> json) {
    return PaymentProofResponse(
      responseStatus: json['responseStatus'] ?? false,
      responseCode: json['responseCode'] ?? 0,
      responseMessage: json['responseMessage'] ?? '',
      responseData: json['responseData'] != null
          ? PaymentProofData.fromJson(json['responseData'] as Map<String, dynamic>)
          : null,
    );
  }
}
