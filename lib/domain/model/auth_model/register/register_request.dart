class RegisterRequest {
  final String companyName;
  final String? industry;
  final String? firstName;
  final String? lastName;
  final String? userName;
  final String countryCode;
  final String phoneNumber;
  final String? email;
  final String password;

  const RegisterRequest({
    required this.companyName,
    this.industry,
    this.firstName,
    this.lastName,
    this.userName,
    required this.countryCode,
    required this.phoneNumber,
    this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'companyName': companyName,
      'industry': industry ?? '',
      'firstName': firstName ?? '',
      'lastName': lastName ?? '',
      'userName': userName ?? '',
      'countryCode': countryCode,
      'phoneNumber': phoneNumber,
      'email': email ?? '',
      'password': password,
    };
  }
}
