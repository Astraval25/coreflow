import 'package:coreflow/data/services/push_notification_service.dart';
import 'package:coreflow/domain/model/auth_model/login/login_request.dart';
import 'package:coreflow/domain/model/employee_model/employee_auth_models.dart';
import 'package:coreflow/features/main_feature/dashboard/dashboard_view_model/dashboard_view_model.dart';
import 'package:coreflow/routing/cf_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../data/repositories/auth_repository/auth_repository.dart';

enum LoginMode { admin, employee }

class LoginViewModel extends ChangeNotifier {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final AuthRepository _authRepository = AuthRepository();

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController identifierController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  String? _landingUrl;
  bool _obscurePassword = true;
  LoginMode _loginMode = LoginMode.admin;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  String? get landingUrl => _landingUrl;
  bool get obscurePassword => _obscurePassword;
  LoginMode get loginMode => _loginMode;
  bool get isEmployeeLogin => _loginMode == LoginMode.employee;

  void setLoginMode(LoginMode mode) {
    if (_loginMode == mode) return;
    _loginMode = mode;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  String? validateIdentifier(String? value) {
    if (isEmployeeLogin && (value == null || value.trim().isEmpty)) {
      return 'Username is required';
    }
    return null;
  }

  String? validatePhoneNumber(String? value) {
    if (!isEmployeeLogin && (value == null || value.trim().isEmpty)) {
      return 'Phone number is required';
    }

    final digitsOnly = (value ?? '').replaceAll(RegExp(r'[^0-9]'), '');
    if (!isEmployeeLogin && digitsOnly.length != 10) {
      return 'Enter a valid 10-digit mobile number';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 5) return 'Password must be at least 5 characters';
    return null;
  }

  Future<void> login(BuildContext context) async {
    if (!context.mounted) return;

    final isValid = formKey.currentState?.validate() ?? false;
    if (!isValid) {
      _errorMessage = 'Please fix the form errors above';
      notifyListeners();
      return;
    }

    _errorMessage = null;
    _successMessage = null;
    _isLoading = true;
    notifyListeners();

    if (isEmployeeLogin) {
      await _loginEmployee(context);
    } else {
      await _loginAdmin(context);
    }
  }

  Future<void> _loginAdmin(BuildContext context) async {
    try {
      final request = LoginRequest(
        countryCode: '+91',
        phoneNumber: phoneController.text.trim(),
        password: passwordController.text,
      );

      final response = await _authRepository.login(request);

      if (response != null &&
          response.responseStatus &&
          response.responseData != null) {
        await _authRepository.saveAuthData(
          response.responseData!,
          '+91${phoneController.text.trim()}',
        );
        _landingUrl = response.responseData!.landingUrl;
        _successMessage = response.responseMessage;
        _isLoading = false;
        notifyListeners();

        // Register FCM token with backend
        await PushNotificationService().registerTokenWithBackend();

        if (context.mounted) {
          await context.read<DashboardViewModel>().refresh();
        }

        final landingUrl = _landingUrl!.toLowerCase();
        if (landingUrl.contains('/verify')) {
          final emailForVerification = response.responseData?.email?.trim();
          if (emailForVerification != null && emailForVerification.isNotEmpty) {
            final email = Uri.encodeComponent(emailForVerification);
            await Future.delayed(const Duration(milliseconds: 500));
            if (context.mounted) {
              context.go('${CfRoutes.resendOtp}?email=$email');
            }
            return;
          }
          _errorMessage = 'Email verification is pending for this account.';
          _isLoading = false;
          notifyListeners();
          return;
        }

        await Future.delayed(const Duration(milliseconds: 500));
        if (context.mounted) {
          final dashVm = context.read<DashboardViewModel>();
          final companyId = dashVm.companyId;
          if (companyId != null) {
            context.go(CfRoutes.dashboard(companyId));
          }
        }
      } else {
        _errorMessage = _normalizeErrorMessage(
          response?.responseMessage,
          fallback:
              'Login failed. Please check your phone number and password.',
        );

        final errorMsg = _errorMessage!.toLowerCase();
        if (errorMsg.contains('otp') ||
            errorMsg.contains('verify') ||
            errorMsg.contains('resend')) {
          final emailForVerification = response?.responseData?.email?.trim();
          if (emailForVerification != null && emailForVerification.isNotEmpty) {
            final email = Uri.encodeComponent(emailForVerification);
            Future.delayed(const Duration(milliseconds: 1000), () {
              if (context.mounted) {
                context.go('${CfRoutes.resendOtp}?email=$email');
              }
            });
          }
        }

        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Network error. Please try again.';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loginEmployee(BuildContext context) async {
    try {
      final request = EmployeeLoginRequest(
        username: identifierController.text.trim(),
        password: passwordController.text,
      );

      final response = await _authRepository.employeeLogin(request);

      if (response != null &&
          response.responseStatus &&
          response.responseData != null) {
        await _authRepository.saveEmployeeAuthData(
          response.responseData,
          identifierController.text.trim(),
        );
        _landingUrl = CfRoutes.employeePortalHome;
        _successMessage = response.responseMessage;
        _isLoading = false;
        notifyListeners();

        // Register FCM token with backend
        await PushNotificationService().registerTokenWithBackend();

        await Future.delayed(const Duration(milliseconds: 300));
        if (context.mounted) {
          context.go(CfRoutes.employeePortalHome);
        }
      } else {
        _errorMessage = response?.responseMessage.isNotEmpty == true
            ? response!.responseMessage
            : 'Employee login failed';
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
    phoneController.dispose();
    identifierController.dispose();
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
