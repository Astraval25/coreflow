import 'package:coreflow/domain/model/purchase/purchase_order_detail.dart';

class PurchaseOrderDetailResponse {
  final bool responseStatus;
  final int responseCode;
  final String responseMessage;
  final PurchaseOrderDetail responseData;

  PurchaseOrderDetailResponse({
    required this.responseStatus,
    required this.responseCode,
    required this.responseMessage,
    required this.responseData,
  });

  factory PurchaseOrderDetailResponse.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderDetailResponse(
      responseStatus: json['responseStatus'] == true,
      responseCode: _asInt(json['responseCode']),
      responseMessage: json['responseMessage']?.toString() ?? '',
      responseData: PurchaseOrderDetail.fromJson(
        Map<String, dynamic>.from(json['responseData'] ?? const {}),
      ),
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
