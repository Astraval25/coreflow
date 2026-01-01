import 'package:coreflow/data/repositories/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfileViewModel extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  bool _isLoading = true;
  int? _userId;
  String? _email;
  String? _companyName;
  String? _userRole;

  bool get isLoading => _isLoading;
  int? get userId => _userId;
  String? get email => _email;
  String? get companyName => _companyName;
  String? get userRole => _userRole;

  ProfileViewModel() {
    loadProfileData();
  }

  Future<void> loadProfileData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _authRepository.getAuthData();

      if (data != null) {
        _userId = data['userId'] as int?;
        _email = data['email'] as String?;
        _companyName = data['companyName'] as String?;

        String? rawRole = data['roleCode'] as String?;
        _userRole = rawRole ?? 'User';

        switch (_userRole) {
          case 'AMD':
            _userRole = 'Admin';
            break;
          case 'EMP':
            _userRole = 'Employee';
            break;
          default:
            _userRole = _userRole;
        }
      }
    } catch (e) {
      print('Profile load error: $e');
      _userId = null;
      _email = null;
      _companyName = null;
      _userRole = 'User';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    await _authRepository.clearAuthData();
    if (!context.mounted) return;

    context.go('/login');
  }
}
