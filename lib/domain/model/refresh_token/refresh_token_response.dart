import 'package:flutter/material.dart';

class RefreshTokenResponse {
  final String? token;
  final String? refreshToken;
  final String? roleCode;


  RefreshTokenResponse({this.token, this.refreshToken, this.roleCode});

  factory RefreshTokenResponse.fromJson(Map<String, dynamic> json) {
    debugPrint('Parsing refresh response: ${json.keys.toList()}');
    return RefreshTokenResponse(
      token: json['token'] ?? json['accessToken'] ?? json['access_token'],
      refreshToken: json['refreshToken'] ?? json['refresh_token'],
      roleCode: json['roleCode'],
      
    );
  }
}
