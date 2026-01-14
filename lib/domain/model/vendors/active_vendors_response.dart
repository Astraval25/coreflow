import 'package:coreflow/domain/model/customer/customer.dart';

class ActiveVendorsResponse {
  final bool responseStatus;
  final int responseCode;
  final String responseMessage;
  final List<Customer> responseData;

  ActiveVendorsResponse({
    required this.responseStatus,
    required this.responseCode,
    required this.responseMessage,
    required this.responseData,
  });

  factory ActiveVendorsResponse.fromJson(Map<String, dynamic> json) {
    var dataList = json['responseData'] as List<dynamic>? ?? [];
    List<Customer> customers = dataList
        .map((item) => Customer.fromJson(item as Map<String, dynamic>))
        .toList();

    return ActiveVendorsResponse(
      responseStatus: json['responseStatus'] ?? false,
      responseCode: json['responseCode'] ?? 0,
      responseMessage: json['responseMessage'] ?? '',
      responseData: customers,
    );
  }
}
