import 'package:coreflow/domain/model/auth_model/register/register_request.dart';
import 'package:coreflow/routing/cf_routes.dart';
import 'package:flutter/material.dart';
import '../../../../data/repositories/auth_repository/auth_repository.dart';
import 'package:go_router/go_router.dart';

class RegisterViewModel extends ChangeNotifier {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final AuthRepository _authRepository = AuthRepository();

  final TextEditingController companyController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  bool _obscurePassword = true;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get obscurePassword => _obscurePassword;

  String? validateCompany(String? value) =>
      value?.trim().isEmpty ?? true ? 'Company name required' : null;

  String? validatePhoneNumber(String? value) {
    if (value?.trim().isEmpty ?? true) return 'Phone number required';
    final digits = value!.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length != 10) {
      return 'Enter a valid 10-digit mobile number';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value?.trim().isEmpty ?? true) return 'Confirm password required';
    if (value!.trim() != passwordController.text.trim()) {
      return 'Passwords do not match';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value?.trim().isEmpty ?? true) return 'Password required';
    if (value!.trim().length < 5) {
      return 'Password must be at least 5 characters';
    }
    if (!RegExp(r'(?=.*[a-z])(?=.*\d)').hasMatch(value.trim())) {
      return 'Password needs:\n- Lowercase (a-z)\n- Number';
    }
    return null;
  }

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  Future<void> register(BuildContext context) async {
    if (!context.mounted) return;

    final isValid = formKey.currentState?.validate() ?? false;
    if (!isValid) {
      _errorMessage = 'Please fix the highlighted fields.';
      _isLoading = false;
      notifyListeners();
      return;
    }

    _errorMessage = null;
    _successMessage = null;
    _isLoading = true;
    notifyListeners();

    try {
      final request = RegisterRequest(
        companyName: companyController.text.trim(),
        countryCode: '+91',
        phoneNumber: phoneNumberController.text.trim(),
        password: passwordController.text.trim(),
      );

      final response = await _authRepository.register(request);

      if (response != null && response.responseStatus) {
        _successMessage = response.responseMessage;
        _isLoading = false;
        notifyListeners();

        await Future.delayed(Duration(seconds: 2));
        if (context.mounted) {
          final shouldVerify = response.responseData?.emailVerificationRequired;
          final email = response.responseData?.email?.trim();
          if (shouldVerify == true && email != null && email.isNotEmpty) {
            context.go(
              '${CfRoutes.verifyBase}?email=${Uri.encodeComponent(email)}',
            );
          } else {
            context.go(CfRoutes.login);
          }
        }
      } else {
        _errorMessage = _normalizeErrorMessage(
          response?.responseMessage,
          fallback: 'Registration failed. Please try again.',
        );
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Network error. Please try again.';
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    companyController.dispose();
    confirmPasswordController.dispose();
    phoneNumberController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  String _normalizeErrorMessage(String? raw, {required String fallback}) {
    final message = raw?.trim();
    if (message == null || message.isEmpty || message == 'null') {
      return fallback;
    }
    if (message.toLowerCase() == 'bad credentials') {
      return 'Invalid phone number or password.';
    }
    return message;
  }
}
