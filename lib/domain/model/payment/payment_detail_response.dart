import 'package:coreflow/domain/model/payment/payment_detail.dart';

class PaymentDetailResponse {
  final bool responseStatus;
  final int responseCode;
  final String responseMessage;
  final PaymentDetail responseData;

  PaymentDetailResponse({
    required this.responseStatus,
    required this.responseCode,
    required this.responseMessage,
    required this.responseData,
  });

  factory PaymentDetailResponse.fromJson(Map<String, dynamic> json) {
    return PaymentDetailResponse(
      responseStatus: json['responseStatus'] == true,
      responseCode: _asInt(json['responseCode']),
      responseMessage: json['responseMessage']?.toString() ?? '',
      responseData: PaymentDetail.fromJson(
        Map<String, dynamic>.from(json['responseData'] ?? const {}),
      ),
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
