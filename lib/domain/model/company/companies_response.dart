import 'package:coreflow/domain/model/company/company.dart';

class CompaniesResponse {
  final bool responseStatus;
  final int responseCode;
  final String responseMessage;
  final List<Company> responseData;

  CompaniesResponse({
    required this.responseStatus,
    required this.responseCode,
    required this.responseMessage,
    required this.responseData,
  });

  factory CompaniesResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> dataList = json['responseData'] ?? [];
    final List<Company> companies = dataList
        .map((item) => Company.fromJson(item as Map<String, dynamic>))
        .where((company) => company.isActive)
        .toList();

    return CompaniesResponse(
      responseStatus: json['responseStatus'] ?? false,
      responseCode: json['responseCode'] ?? 0,
      responseMessage: json['responseMessage'] ?? '',
      responseData: companies,
    );
  }
}
