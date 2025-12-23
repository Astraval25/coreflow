import 'package:flutter/material.dart';

class RegisterRequest {
  final String companyName;
  final String industry;
  final String firstName;
  final String lastName;
  final String userName;
  final String email;
  final String password;

  const RegisterRequest({
    required this.companyName,
    required this.industry,
    required this.firstName,
    required this.lastName,
    required this.userName,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'companyName': companyName,
      'industry': industry,
      'firstName': firstName,
      'lastName': lastName,
      'userName': userName,
      'email': email,
      'password': password,
    };
  }
}
