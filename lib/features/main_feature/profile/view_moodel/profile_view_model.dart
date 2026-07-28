import 'dart:convert';
import 'dart:io';

import 'package:coreflow/core/storage/token_storage.dart';
import 'package:coreflow/data/repositories/auth_repository/auth_repository.dart';
import 'package:coreflow/data/repositories/main_repository/company_repository.dart';
import 'package:coreflow/data/services/push_notification_service.dart';
import 'package:coreflow/domain/model/main_model/company/company.dart';
import 'package:coreflow/routing/cf_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';

class ProfileViewModel extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  final CompanyRepository _companyRepository = CompanyRepository();

  bool _isLoading = false;
  bool _isSavingProfile = false;
  bool _isSavingCompany = false;
  bool _isUploadingLogo = false;
  String? _errorMessage;

  int? _userId;
  int? _companyId;
  String? _email;
  String? _companyName;
  String? _userName;
  String? _firstName;
  String? _lastName;
  String? _contactNo;
  String? _landingUrl;
  String? _userRole;
  List<int> _companyIds = [];
  Company? _companyDetail;

  bool get isLoading => _isLoading;
  bool get isSavingProfile => _isSavingProfile;
  bool get isSavingCompany => _isSavingCompany;
  bool get hasError => _errorMessage != null;
  String? get errorMessage => _errorMessage;

  int? get userId => _userId;
  int? get companyId => _companyId;
  String? get email => _email;
  String? get companyName => _companyName;
  String? get userName => _userName;
  String? get firstName => _firstName;
  String? get lastName => _lastName;
  String? get contactNo => _contactNo;
  String? get landingUrl => _landingUrl;
  String? get userRole => _userRole;
  List<int> get companyIds => List.unmodifiable(_companyIds);
  Company? get companyDetail => _companyDetail;
  bool get isUploadingLogo => _isUploadingLogo;

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
      if (data == null || data['token'] == null) {
        _setError('No authentication data found');
        return;
      }

      _userId = int.tryParse(data['userId']?.toString() ?? '');
      _companyId = _parseInt(data['companyId']);
      _email = data['email'] as String?;
      _userName = data['userName'] as String?;
      _companyName = data['companyName'] as String?;
      _landingUrl = data['landingUrl'] as String?;
      _userRole = data['roleCode'] as String?;
      _companyIds = _parseCompanyIds(data['companyIds']);

      final profileResponse = await _authRepository.getMyUserProfile();
      if (profileResponse != null) {
        _userId = _parseInt(profileResponse['userId']) ?? _userId;
        _userName = _asTrimmed(profileResponse['userName']) ?? _userName;
        _firstName = _asTrimmed(profileResponse['firstName']);
        _lastName = _asTrimmed(profileResponse['lastName']);
        _email = _asTrimmed(profileResponse['email']) ?? _email;
        _contactNo = _asTrimmed(profileResponse['contactNo']);
      }

      if (_companyId != null) {
        _companyDetail = await _authRepository.getCompanyById(_companyId!);
        _companyName = _companyDetail?.companyName ?? _companyName;
      } else {
        _companyDetail = null;
      }
    } catch (e) {
      debugPrint('Profile load error: $e');
      _setError('Failed to load profile data');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateProfile({
    required String userName,
    required String firstName,
    required String lastName,
    required String email,
  }) async {
    final trimmedUserName = userName.trim();
    if (trimmedUserName.isEmpty) {
      _setError('Username is required');
      return false;
    }

    _isSavingProfile = true;
    _clearError();
    notifyListeners();

    try {
      final response = await _authRepository.updateMyUserProfile({
        'userName': trimmedUserName,
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'email': email.trim(),
      });

      if (response == null) {
        _setError('Failed to update profile');
        return false;
      }

      _userId = _parseInt(response['userId']) ?? _userId;
      _userName = _asTrimmed(response['userName']) ?? _userName;
      _firstName = _asTrimmed(response['firstName']);
      _lastName = _asTrimmed(response['lastName']);
      _email = _asTrimmed(response['email']) ?? _email;
      _contactNo = _asTrimmed(response['contactNo']) ?? _contactNo;

      await _persistAuthCache();
      return true;
    } catch (e) {
      debugPrint('Profile update error: $e');
      _setError('Failed to update profile');
      return false;
    } finally {
      _isSavingProfile = false;
      notifyListeners();
    }
  }

  Future<bool> updateCompanyInfo({
    required String companyName,
    required String industry,
    String? shortName,
    String? pan,
    String? gstNo,
    String? hsnCode,
    String? contactPerson,
    String? contactEmail,
    String? contactPhone,
    String? website,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? country,
    String? postalCode,
    String? publicDescription,
  }) async {
    if (_companyId == null) {
      _setError('No active company found');
      return false;
    }

    final trimmedCompanyName = companyName.trim();
    final trimmedIndustry = industry.trim();
    if (trimmedCompanyName.isEmpty || trimmedIndustry.isEmpty) {
      _setError('Company name and industry are required');
      return false;
    }

    _isSavingCompany = true;
    _clearError();
    notifyListeners();

    try {
      final payload = <String, dynamic>{
        'companyName': trimmedCompanyName,
        'industry': trimmedIndustry,
      };

      void addIfNotBlank(String key, String? value) {
        if (value == null) return;
        final trimmed = value.trim();
        if (trimmed.isNotEmpty) {
          payload[key] = trimmed;
        }
      }

      addIfNotBlank('shortName', shortName);
      addIfNotBlank('pan', pan);
      addIfNotBlank('gstNo', gstNo);
      addIfNotBlank('hsnCode', hsnCode);
      addIfNotBlank('contactPerson', contactPerson);
      addIfNotBlank('contactEmail', contactEmail);
      addIfNotBlank('contactPhone', contactPhone);
      addIfNotBlank('website', website);
      addIfNotBlank('addressLine1', addressLine1);
      addIfNotBlank('addressLine2', addressLine2);
      addIfNotBlank('city', city);
      addIfNotBlank('state', state);
      addIfNotBlank('country', country);
      addIfNotBlank('postalCode', postalCode);
      addIfNotBlank('publicDescription', publicDescription);

      final success = await _authRepository.updateCompany(_companyId!, payload);
      if (!success) {
        _setError('Failed to update company information');
        return false;
      }

      _companyDetail = await _authRepository.getCompanyById(_companyId!);
      _companyName = _companyDetail?.companyName ?? _companyName;

      if (_companyName != null && _companyName!.trim().isNotEmpty) {
        await TokenStorage.saveSelectedCompany(
          _companyId!,
          _companyName!.trim(),
        );
      }
      await _persistAuthCache();
      return true;
    } catch (e) {
      debugPrint('Company update error: $e');
      _setError('Failed to update company information');
      return false;
    } finally {
      _isSavingCompany = false;
      notifyListeners();
    }
  }

  Future<bool> uploadCompanyLogo(File file) async {
    if (_companyId == null) {
      _setError('No active company found');
      return false;
    }

    _isUploadingLogo = true;
    _clearError();
    notifyListeners();

    try {
      final fsId = await _companyRepository.uploadCompanyLogo(_companyId!, file);
      if (fsId == null) {
        _setError('Failed to upload company logo');
        return false;
      }

      _companyDetail = await _companyRepository.getCompanyById(_companyId!);
      return true;
    } catch (e) {
      debugPrint('Company logo upload error: $e');
      _setError('Failed to upload company logo');
      return false;
    } finally {
      _isUploadingLogo = false;
      notifyListeners();
    }
  }

  Future<void> logout(BuildContext context) async {
    _setLoading(true);
    _clearError();

    try {
      await PushNotificationService().deregisterToken();
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

  Future<void> _persistAuthCache() async {
    final authData = await TokenStorage.getFullAuthData();
    if (authData == null) return;

    final token = authData['token']?.toString() ?? '';
    final refreshToken = authData['refreshToken']?.toString() ?? '';
    final userId = _userId?.toString() ?? authData['userId']?.toString() ?? '';
    final landingUrl = _landingUrl ?? authData['landingUrl']?.toString() ?? '';
    final roleCode = _userRole ?? authData['roleCode']?.toString();
    final companyId = _companyId ?? _parseInt(authData['companyId']);
    final companyName = _companyName ?? authData['companyName']?.toString();
    final companyIds = _companyIds.isNotEmpty
        ? _companyIds
        : _parseCompanyIds(authData['companyIds']);
    final email = (_email ?? authData['email']?.toString() ?? '').trim();
    final userName = (_userName ?? authData['userName']?.toString() ?? '')
        .trim();

    if (token.isEmpty ||
        refreshToken.isEmpty ||
        userId.isEmpty ||
        landingUrl.isEmpty ||
        email.isEmpty ||
        userName.isEmpty) {
      return;
    }

    await TokenStorage.saveFullAuthData(
      userId: userId,
      companyId: companyId,
      companyIds: companyIds.isEmpty ? null : companyIds,
      companyName: companyName,
      token: token,
      refreshToken: refreshToken,
      roleCode: roleCode,
      landingUrl: landingUrl,
      email: email,
      userName: userName,
      employeeId: _parseInt(authData['employeeId']),
      employeeCode: authData['employeeCode']?.toString(),
      designation: authData['designation']?.toString(),
      authType: authData['authType']?.toString(),
    );
  }

  List<int> _parseCompanyIds(dynamic rawValue) {
    if (rawValue == null) return const [];

    if (rawValue is List) {
      return rawValue.map(_parseInt).whereType<int>().toList(growable: false);
    }

    if (rawValue is String && rawValue.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(rawValue);
        if (decoded is List) {
          return decoded
              .map(_parseInt)
              .whereType<int>()
              .toList(growable: false);
        }
      } catch (_) {}
    }

    return const [];
  }

  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  String? _asTrimmed(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
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

  void dismissError() {
    _clearError();
  }
}
