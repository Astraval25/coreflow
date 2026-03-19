import 'package:coreflow/domain/model/sales/sales_order_detail.dart';

class SalesOrderDetailResponse {
  final bool responseStatus;
  final int responseCode;
  final String responseMessage;
  final SalesOrderDetail responseData;

  SalesOrderDetailResponse({
    required this.responseStatus,
    required this.responseCode,
    required this.responseMessage,
    required this.responseData,
  });

  factory SalesOrderDetailResponse.fromJson(Map<String, dynamic> json) {
    return SalesOrderDetailResponse(
      responseStatus: json['responseStatus'] ?? false,
      responseCode: json['responseCode'] ?? 0,
      responseMessage: json['responseMessage'] ?? '',
      responseData: SalesOrderDetail.fromJson(json['responseData'] ?? {}),
    );
  }
}