import 'package:coreflow/domain/model/vendors/vendors.dart';

class ActiveVendorsResponse {
  final bool responseStatus;
  final int responseCode;
  final String responseMessage;
  final List<Vendor> responseData;

  ActiveVendorsResponse({
    required this.responseStatus,
    required this.responseCode,
    required this.responseMessage,
    required this.responseData,
  });

  factory ActiveVendorsResponse.fromJson(Map<String, dynamic> json) {
    var dataList = json['responseData'] as List<dynamic>? ?? [];
    List<Vendor> vendors = dataList
        .map((item) => Vendor.fromJson(item as Map<String, dynamic>))
        .toList();

    return ActiveVendorsResponse(
      responseStatus: json['responseStatus'] ?? false,
      responseCode: json['responseCode'] ?? 0,
      responseMessage: json['responseMessage'] ?? '',
      responseData: vendors,
    );
  }
}