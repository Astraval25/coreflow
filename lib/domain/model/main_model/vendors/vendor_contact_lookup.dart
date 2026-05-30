class VendorContactLookupResponse {
  final bool responseStatus;
  final int responseCode;
  final String responseMessage;
  final List<VendorContactLookupResult> responseData;

  VendorContactLookupResponse({
    required this.responseStatus,
    required this.responseCode,
    required this.responseMessage,
    required this.responseData,
  });

  factory VendorContactLookupResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['responseData'];
    final dataList = rawData is List ? rawData : const [];
    return VendorContactLookupResponse(
      responseStatus: json['responseStatus'] == true,
      responseCode: json['responseCode'] ?? 0,
      responseMessage: json['responseMessage']?.toString() ?? '',
      responseData: dataList
          .whereType<Map<String, dynamic>>()
          .map(VendorContactLookupResult.fromJson)
          .toList(growable: false),
    );
  }
}

class VendorContactLookupResult {
  final String? inputPhone;
  final String? phoneKey;
  final bool validPhone;
  final bool hasAccount;
  final int? accountCompanyId;
  final String? accountCompanyName;
  final int? existingVendorId;

  VendorContactLookupResult({
    this.inputPhone,
    this.phoneKey,
    required this.validPhone,
    required this.hasAccount,
    this.accountCompanyId,
    this.accountCompanyName,
    this.existingVendorId,
  });

  factory VendorContactLookupResult.fromJson(Map<String, dynamic> json) {
    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      return int.tryParse(value.toString());
    }

    return VendorContactLookupResult(
      inputPhone: json['inputPhone']?.toString(),
      phoneKey: json['phoneKey']?.toString(),
      validPhone: json['validPhone'] == true,
      hasAccount: json['hasAccount'] == true,
      accountCompanyId: parseInt(json['accountCompanyId']),
      accountCompanyName: json['accountCompanyName']?.toString(),
      existingVendorId: parseInt(json['existingVendorId']),
    );
  }
}
