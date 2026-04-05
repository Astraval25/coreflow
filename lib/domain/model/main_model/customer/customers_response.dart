import 'package:coreflow/domain/model/main_model/customer/customer.dart';

class ActiveCustomersResponse {
  final bool responseStatus;
  final int responseCode;
  final String responseMessage;
  final List<Customer> responseData;

  ActiveCustomersResponse({
    required this.responseStatus,
    required this.responseCode,
    required this.responseMessage,
    required this.responseData,
  });

  factory ActiveCustomersResponse.fromJson(Map<String, dynamic> json) {
    var dataList = json['responseData'] as List<dynamic>? ?? [];
    List<Customer> customers = dataList
        .map((item) => Customer.fromJson(item as Map<String, dynamic>))
        .toList();

    return ActiveCustomersResponse(
      responseStatus: json['responseStatus'] ?? false,
      responseCode: json['responseCode'] ?? 0,
      responseMessage: json['responseMessage'] ?? '',
      responseData: customers,
    );
  }
}
