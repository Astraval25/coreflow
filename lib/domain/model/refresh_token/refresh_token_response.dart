class RefreshTokenResponse {
  final String token;
  final String refreshToken;
  final String? roleCode;
  final int? expiresIn; 

  RefreshTokenResponse({
    required this.token,
    required this.refreshToken,
    this.roleCode,
    this.expiresIn, 
  });

  factory RefreshTokenResponse.fromJson(Map<String, dynamic> json) {
    return RefreshTokenResponse(
      token: json['token'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      roleCode: json['roleCode'],
      expiresIn: json['expiresIn'], 
    );
  }
}
