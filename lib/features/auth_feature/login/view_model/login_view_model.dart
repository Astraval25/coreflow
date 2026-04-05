import 'package:coreflow/domain/model/auth_model/login/login_request.dart';
import 'package:coreflow/features/main_feature/dashboard/dashboard_view_model/dashboard_view_model.dart';
import 'package:coreflow/routing/cf_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../data/repositories/auth_repository.dart';

class LoginViewModel extends ChangeNotifier {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final AuthRepository _authRepository = AuthRepository();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  String? _landingUrl;
  bool _obscurePassword = true;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  String? get landingUrl => _landingUrl;
  bool get obscurePassword => _obscurePassword;

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    const emailRegex = r'^[^@]+@[^@]+\.[^@]+';
    if (!RegExp(emailRegex).hasMatch(value.trim()))
      return 'Enter a valid email';
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
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

    try {
      final request = LoginRequest(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      final response = await _authRepository.login(request);

      if (response != null &&
          response.responseStatus &&
          response.responseData != null) {
        await _authRepository.saveAuthData(
          response.responseData!,
          emailController.text.trim(),
        );
        _landingUrl = response.responseData!.landingUrl;
        _successMessage = response.responseMessage;
        _isLoading = false;
        notifyListeners();

        if (context.mounted) {
          await context.read<DashboardViewModel>().refresh();
        }

        final landingUrl = _landingUrl!.toLowerCase();
        if (landingUrl.contains('/verify')) {
          final email = Uri.encodeComponent(emailController.text.trim());
          await Future.delayed(Duration(milliseconds: 500));
          if (context.mounted) {
            context.go('${CfRoutes.resendOtp}?email=$email');
          }
          return;
        }

        await Future.delayed(Duration(milliseconds: 500));
        if (context.mounted) {
          final dashVm = context.read<DashboardViewModel>();
          final companyId = dashVm.companyId;
          if (companyId != null) {
            context.go(CfRoutes.dashboard(companyId));
          }
        }
      } else {
        _errorMessage = response?.responseMessage ?? '$_errorMessage';

        final errorMsg = _errorMessage!.toLowerCase();
        if (errorMsg.contains('otp') ||
            errorMsg.contains('verify') ||
            errorMsg.contains('resend')) {
          final email = Uri.encodeComponent(emailController.text.trim());
          Future.delayed(Duration(milliseconds: 1000), () {
            if (context.mounted) {
              context.go('${CfRoutes.resendOtp}?email=$email');
            }
          });
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

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
