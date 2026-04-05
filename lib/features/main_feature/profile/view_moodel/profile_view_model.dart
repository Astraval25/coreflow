import 'dart:convert';
import 'package:coreflow/data/repositories/auth_repository/auth_repository.dart';
import 'package:coreflow/routing/cf_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';

class ProfileViewModel extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  bool _isLoading = false; // ✅ FIXED: Start false to prevent UI block
  String? _errorMessage;

  // Profile data
  int? _userId;
  String? _email;
  String? _companyName;
  String? _userName;
  String? _landingUrl;
  String? _userRole;
  List<int>? _companyIds;

  // Getters
  bool get isLoading => _isLoading;
  bool get hasError => _errorMessage != null;
  String? get errorMessage => _errorMessage;

  int? get userId => _userId;
  String? get email => _email;
  String? get companyName => _companyName;
  String? get userName => _userName;
  String? get landingUrl => _landingUrl;
  String? get userRole => _userRole;
  List<int>? get companyIds => _companyIds;

  // ✅ FIXED: Complete role mapping - handles ADM + case insensitive
  String get displayRole {
    if (_userRole == null || _userRole!.isEmpty) return 'User';

    final role = _userRole!.toUpperCase();
    switch (role) {
      case 'ADM':
      case 'AMD':
        return 'Admin';
      case 'EMP':
        return 'Employee';

      default:
        return role;
    }
  }

  ProfileViewModel() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      loadProfileData();
    });
  }

  Future<void> loadProfileData() async {
    _setLoading(true);
    _clearError();

    try {
      final data = await _authRepository.getAuthData();

      if (data != null && data['token'] != null) {
        _userId = int.tryParse(data['userId']?.toString() ?? '');
        _email = data['email'] as String?;
        _userName = data['userName'] as String?;
        _companyName = data['companyName'] as String?;
        _landingUrl = data['landingUrl'] as String?;
        _userRole = data['roleCode'] as String?;

        final companyIdsJson = data['companyIds'] as String?;
        if (companyIdsJson != null && companyIdsJson.isNotEmpty) {
          try {
            _companyIds = List<int>.from(jsonDecode(companyIdsJson));
          } catch (e) {
            debugPrint('Company IDs parse error: $e');
          }
        }
      } else {
        _setError('No authentication data found');
      }
    } catch (e) {
      debugPrint('Profile load error: $e');
      _setError('Failed to load profile data');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout(BuildContext context) async {
    _setLoading(true);
    _clearError();

    try {
      await _authRepository.clearAuthData();

      if (context.mounted) {
        context.go(CfRoutes.login);
      }
    } catch (e) {
      debugPrint('Logout error: $e');
      _setError('Logout failed');
      if (context.mounted) {
        context.go(CfRoutes.login);
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshProfile() async {
    await loadProfileData();
  }

  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }
}
