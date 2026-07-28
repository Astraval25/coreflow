class LoginRequest {
  final String countryCode;
  final String phoneNumber;
  final String password;

  const LoginRequest({
    required this.countryCode,
    required this.phoneNumber,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'countryCode': countryCode,
      'phoneNumber': phoneNumber,
      'password': password,
    };
  }
}
