import 'package:coreflow/domain/model/register/register_request.dart';
import 'package:flutter/material.dart';
import '../../../data/repositories/auth_repository.dart';
import 'package:go_router/go_router.dart';

class RegisterViewModel extends ChangeNotifier {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final AuthRepository _authRepository = AuthRepository();

  final TextEditingController companyController = TextEditingController();
  final TextEditingController industryController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  bool _obscurePassword = true;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get obscurePassword => _obscurePassword;

  final List<String> industryOptions = [
    'IT & Software',
    'Healthcare',
    'Finance',
    'Education',
    'Manufacturing',
    'Retail',
    'Logistics',
    'Real Estate',
    'Marketing',
    'Other',
  ];

  String? _selectedIndustry;
  String? get selectedIndustry => _selectedIndustry;

  void setIndustry(String value) {
    _selectedIndustry = value;
    industryController.text = value;
    notifyListeners();
  }

  String? validateCompany(String? value) =>
      value?.trim().isEmpty ?? true ? 'Company name required' : null;

  String? validateIndustry(String? value) =>
      _selectedIndustry?.isEmpty ?? true ? 'Industry required' : null;

  String? validateFirstName(String? value) =>
      value?.trim().isEmpty ?? true ? 'First name required' : null;

  String? validateLastName(String? value) =>
      value?.trim().isEmpty ?? true ? 'Last name required' : null;

  String? validateUserName(String? value) =>
      value?.trim().isEmpty ?? true ? 'Username required' : null;

  String? validateEmail(String? value) {
    if (value?.trim().isEmpty ?? true) return 'Email required';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!.trim())) {
      return 'Enter valid email';
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
    if (value!.trim().length < 8){
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(
      r'(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])',
    ).hasMatch(value.trim())) {
      return 'Password needs:\n• Uppercase\n• Lowercase\n• Number\n• Special char';
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
      _errorMessage = 'currentState';
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
        industry: industryController.text.trim(),
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        userName: userNameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final response = await _authRepository.register(request);

      if (response != null && response.responseStatus) {
        _successMessage = response.responseMessage;
        _isLoading = false;
        notifyListeners();

        await Future.delayed(const Duration(seconds: 2));
        if (context.mounted) {
          final email = emailController.text.trim();
          context.go('/verify?email=${Uri.encodeComponent(email)}');
        }
      } else {
        _errorMessage = response?.responseMessage ?? '$_errorMessage';
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
    industryController.dispose();
    confirmPasswordController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    userNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
