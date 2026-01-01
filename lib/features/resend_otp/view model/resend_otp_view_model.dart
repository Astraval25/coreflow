import 'dart:async';
import 'package:coreflow/data/repositories/auth_repository.dart';
import 'package:coreflow/domain/model/resend_otp/resend_otp_request.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ResendOtpViewModel extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  final TextEditingController emailController = TextEditingController();

  bool _isLoading = false;
  bool _isResending = false;
  String? _errorMessage;
  String? _successMessage;

  bool get isLoading => _isLoading || _isResending;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  void setEmail(String email) {
    emailController.text = Uri.decodeComponent(email);
    _errorMessage = null;
    notifyListeners();
  }

  String? validateEmail(String? value) {
    if (value?.isEmpty ?? true) return 'Email required';
    const emailRegex = r'^[^@]+@[^@]+\.[^@]+';
    if (!RegExp(emailRegex).hasMatch(value!.trim())) return 'Enter valid email';
    return null;
  }

  Future<void> resendOtp(BuildContext context) async {
    if (_isResending || _isLoading) return;

    final emailError = validateEmail(emailController.text.trim());
    if (emailError != null) {
      _errorMessage = emailError;
      notifyListeners();
      return;
    }

    _isResending = true;
    _errorMessage = null;
    _successMessage = null;
    _isLoading = true;
    notifyListeners();

    try {
      final request = ResendOtpRequest(email: emailController.text.trim());

      final response = await _authRepository
          .resendOtp(request)
          .timeout(
            const Duration(seconds: 8),
            onTimeout: () => throw TimeoutException(
              'Request timeout',
              const Duration(seconds: 4),
            ),
          );

      if (response != null && response.responseStatus) {
        _successMessage = response.responseMessage ?? 'OTP resent successfully';
        notifyListeners();

        await Future.delayed(const Duration(seconds: 1));
        if (context.mounted) {
          final email = Uri.encodeComponent(emailController.text.trim());
          context.go('/verify?email=$email');
        }
        return;
      } else {
        _errorMessage = response?.responseMessage ?? 'Failed to resend OTP';
      }
    } on TimeoutException {
      _errorMessage = 'Request timeout. Please check your connection.';
    } catch (e) {
      _errorMessage = 'Network error. Please try again.';
    } finally {
      _isLoading = false;
      _isResending = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }
}
