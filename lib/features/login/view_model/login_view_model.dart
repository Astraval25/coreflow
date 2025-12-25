import 'package:coreflow/domain/model/login_request.dart';
import 'package:flutter/material.dart';
import '../../../data/repositories/auth_repository.dart'; 
import 'package:go_router/go_router.dart';

class LoginViewModel extends ChangeNotifier {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final AuthRepository _authRepository = AuthRepository();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get obscurePassword => _obscurePassword;

  String? validateEmail(String? value) {
    if (value?.isEmpty ?? true) return 'Email is required';
    if (!value!.contains('@')) return 'Enter valid email';
    return null;
  }

  String? validatePassword(String? value) {
    if (value?.isEmpty ?? true) return 'Password is required';
    return null;
  }

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  Future<void> login(BuildContext context) async {
    if (formKey.currentState?.validate() == false) {
      _errorMessage = 'Please fix form errors';
      notifyListeners();
      return;
    }

    _errorMessage = null;
    _isLoading = true;
    notifyListeners();

    try {
      final request = LoginRequest(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      final response = await _authRepository.login(request);

      if (response != null && response.responseStatus) {
    if (context.mounted) {
          context.go('/dashboard');
        }
        return;
      } else {
         _errorMessage =
            response?.responseMessage ??
            'Login failed. Please check credentials.';
      }
    } catch (e) {
     
      _errorMessage = 'Network error: $e';
    } finally {
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
