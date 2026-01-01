import 'package:flutter/material.dart';

class RegisterResponse {
  final bool responseStatus;
  final int responseCode;
  final String responseMessage;
  final RegisterData? responseData;

  const RegisterResponse({
    required this.responseStatus,
    required this.responseCode,
    required this.responseMessage,
    this.responseData,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      responseStatus: json['responseStatus'] ?? false,
      responseCode: json['responseCode'] ?? 0,
      responseMessage: json['responseMessage'] ?? '',
      responseData: json['responseData'] != null
          ? RegisterData.fromJson(json['responseData'])
          : null,
    );
  }
}

class RegisterData {
  final String email;
  final String landingUrl;

  const RegisterData({required this.email, required this.landingUrl});

  factory RegisterData.fromJson(Map<String, dynamic> json) {
    return RegisterData(
      email: json['email'] ?? '',
      landingUrl: json['landingUrl'] ?? '',
    );
  }
}
