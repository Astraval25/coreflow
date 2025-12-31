import 'dart:async';
import 'package:coreflow/domain/model/resend_otp/resend_otp_request.dart';
import 'package:coreflow/domain/model/verify_otp/verify_otp_request.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../data/repositories/auth_repository.dart';

class VerifyOtpViewModel extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  final TextEditingController otpController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  String? _userPath;
  String? _email;

  bool _isLoading = false;
  bool _isResendLoading = false;
  String? _errorMessage;
  String? _successMessage;

  int _resendTimer = 30;
  bool _canResend = false;
  Timer? _timer;

  bool get isLoading => _isLoading;
  bool get isResendLoading => _isResendLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  String? get userPath => _userPath;
  String? get email => _email;
  int get resendTimer => _resendTimer;
  bool get canResend => _canResend;

  VerifyOtpViewModel() {
    _startResendTimer();
  }

  void setUserPath(String userPath) {
    final decodedPath = Uri.decodeComponent(userPath);
    _userPath = decodedPath;
    _email = decodedPath;
    emailController.text = decodedPath;
    notifyListeners();
  }

  Future<void> verifyOtp(BuildContext context) async {
    if (otpController.text.length != 6) {
      _errorMessage = 'Please enter full 6-digit OTP';
      notifyListeners();
      return;
    }

    _errorMessage = null;
    _successMessage = null;
    _isLoading = true;
    notifyListeners();

    try {
      final emailToUse = _userPath ?? '';
      if (emailToUse.isEmpty) {
        _errorMessage = 'Email not found. Please login again.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final request = VerifyOtpRequest(
        email: emailToUse,
        otp: otpController.text.trim(),
      );

      final response = await _authRepository.verifyOtp(request);

      if (response != null && response.responseStatus) {
        _successMessage = response.responseMessage ?? '$_successMessage';
        notifyListeners();
        await Future.delayed(const Duration(milliseconds: 100));
        if (context.mounted) {
          context.go('/login');
        }
        return;
      } else {
        otpController.clear();
        _errorMessage = response?.responseMessage ?? '$_errorMessage';
      }
    } catch (e) {
      _errorMessage = 'Network error. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resendOtp() async {
    if (_email == null || _email!.isEmpty) {
      _errorMessage = 'Email not set';
      notifyListeners();
      return;
    }

    _errorMessage = null;
    _successMessage = null;
    _isResendLoading = true;
    notifyListeners();

    try {
      final request = ResendOtpRequest(email: _email!);
      final response = await _authRepository.resendOtp(request);

      if (response != null && response.responseStatus) {
        _successMessage = response.responseMessage ?? '$_successMessage';
        otpController.clear();
        _startResendTimer();
      } else {
        _errorMessage = response?.responseMessage ?? '$_errorMessage';
      }
    } catch (e) {
      _errorMessage = 'Network error. Please try again.';
    } finally {
      _isResendLoading = false;
      notifyListeners();
    }
  }

  void _startResendTimer() {
    _resendTimer = 30;
    _canResend = false;
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimer > 0) {
        _resendTimer--;
        notifyListeners();
      } else {
        _canResend = true;
        notifyListeners();
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    otpController.dispose();
    emailController.dispose();
    _timer?.cancel();
    super.dispose();
  }
}
