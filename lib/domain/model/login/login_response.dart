class LoginResponse {
  final bool responseStatus;
  final int responseCode;
  final String? responseMessage;
  final LoginData? responseData;

  LoginResponse({
    required this.responseStatus,
    required this.responseCode,
    this.responseMessage,
    this.responseData,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      responseStatus: json['responseStatus'] ?? false,
      responseCode: json['responseCode'] ?? 0,
      responseMessage: json['responseMessage'],
      responseData: json['responseData'] != null
          ? LoginData.fromJson(json['responseData'])
          : null,
    );
  }
}

class LoginData {
  final int? companyId;
  final List<int>? companyIds;
  final String? companyName;
  final String landingUrl;
  final String? refreshToken;
  final String? roleCode;
  final String? token;
  final int userId;

  LoginData({
    this.companyId,
    this.companyIds,
    this.companyName,
    required this.landingUrl,
    this.refreshToken,
    this.roleCode,
    this.token,
    required this.userId,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      companyId: json['companyId'],
      companyIds: json['companyIds'] != null
          ? List<int>.from(json['companyIds'])
          : null,
      companyName: json['companyName'],
      landingUrl: json['landingUrl'] ?? '',
      refreshToken: json['refreshToken'],
      roleCode: json['roleCode'],
      token: json['token'],
      userId: json['userId'] ?? 0,
    );
  }
}
