import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_config.dart';
import '../../../data/services/api_services.dart';
import '../../../domain/model/advertisement/advertisement.dart';
import '../../../domain/model/company/company.dart';
import '../../../data/repositories/auth_repository.dart';

class DashboardViewModel extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  bool _isLoading = true;
  String? _userName;
  String? _email;
  String? _companyName;
  int? _companyId;

  List<Company> _availableCompanies = [];
  bool _isCompaniesLoading = false;

  bool _isCustomersExpanded = false;
  String _selectedMenu = 'badges';

  bool _hasLoadedUserData = false;
  bool _hasLoadedCompanies = false;
  Future<void>? _userDataRequest;
  Future<void>? _companiesRequest;

  int _unreadNotificationCount = 0;
  List<Advertisement> _advertisements = [];
  final Map<String, Uint8List> _adImageCache = {};
  bool _hasLoadedAppOpenData = false;

  bool get isLoading => _isLoading;
  String? get userName => _userName;
  String? get email => _email;
  String? get companyName => _companyName;
  int? get companyId => _companyId;

  List<Company> get availableCompanies => _availableCompanies;
  bool get isCompaniesLoading => _isCompaniesLoading;

  bool get isCustomersExpanded => _isCustomersExpanded;
  String get selectedMenu => _selectedMenu;

  int get unreadNotificationCount => _unreadNotificationCount;
  List<Advertisement> get advertisements => _advertisements;
  Map<String, Uint8List> get adImageCache => _adImageCache;

  DashboardViewModel() {
    _initializeData();
  }

  void _initializeData() {
    if (!_hasLoadedUserData) {
      loadUserData().then((_) {
        if (!_hasLoadedCompanies) {
          loadCompanies();
        }
        if (!_hasLoadedAppOpenData && _companyId != null) {
          _loadAppOpenData();
        }
      });
    }
  }

  Future<void> loadUserData({bool force = false}) async {
    if (_hasLoadedUserData && !force) return;
    if (_userDataRequest != null) {
      await _userDataRequest;
      return;
    }

    _userDataRequest = _loadUserDataInternal();
    await _userDataRequest;
  }

  Future<void> loadCompanies({bool force = false}) async {
    if (_hasLoadedCompanies && !force) return;
    if (_companiesRequest != null) {
      await _companiesRequest;
      return;
    }

    _companiesRequest = _loadCompaniesInternal();
    await _companiesRequest;
  }

  Future<void> refresh() async {
    await loadUserData(force: true);
    await loadCompanies(force: true);
  }

  void selectCompany(Company company) {
    _companyName = company.companyName;
    _companyId = company.companyId;
    notifyListeners();
  }

  void toggleCustomersExpanded(bool expanded) {
    _isCustomersExpanded = expanded;
    notifyListeners();
  }

  void setSelectedMenu(String menu) {
    _selectedMenu = menu;
    notifyListeners();
  }

  Future<void> logout(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    await _authRepository.clearAuthData();

    _hasLoadedUserData = false;
    _hasLoadedCompanies = false;
    _userDataRequest = null;
    _companiesRequest = null;

    if (!context.mounted) return;
    context.go('/login');
  }

  Future<void> _loadUserDataInternal() async {
    _isLoading = true;
    notifyListeners();
    var loadedSuccessfully = false;

    try {
      final data = await _authRepository.getAuthData();
      _userName = data?['userName'] as String?;
      _email = data?['email'] as String?;
      _companyName = data?['companyName'] as String?;
      _companyId = data?['companyId'] as int?;
      loadedSuccessfully = _companyId != null;
    } catch (_) {
      _userName = null;
      _email = null;
      _companyName = null;
      _companyId = null;
    } finally {
      _isLoading = false;
      _hasLoadedUserData = loadedSuccessfully;
      _userDataRequest = null;
      notifyListeners();
    }
  }

  Future<void> _loadAppOpenData() async {
    if (_hasLoadedAppOpenData || _companyId == null) return;
    _hasLoadedAppOpenData = true;

    // Load unread count and ads in parallel
    await Future.wait([
      _loadUnreadCount(),
      _loadAdvertisements(),
    ]);
  }

  Future<void> _loadUnreadCount() async {
    if (_companyId == null) return;
    try {
      _unreadNotificationCount =
          await _authRepository.getUnreadNotificationCount(_companyId!);
      notifyListeners();
    } catch (e) {
      debugPrint('Load unread count error: $e');
    }
  }

  Future<void> _loadAdvertisements() async {
    try {
      _advertisements = await _authRepository.getAdvertisements();
      notifyListeners();
      // Cache ad images
      for (final ad in _advertisements) {
        if (ad.fsId.isNotEmpty && !_adImageCache.containsKey(ad.fsId)) {
          _cacheAdImage(ad.fsId);
        }
      }
    } catch (e) {
      debugPrint('Load advertisements error: $e');
    }
  }

  Future<void> _cacheAdImage(String fsId) async {
    try {
      final apiService = ApiService();
      final url = AppConfig.getFileUrl(fsId);
      final response = await apiService.get(Uri.parse(url));
      if (response.statusCode == 200) {
        _adImageCache[fsId] = response.bodyBytes;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Cache ad image error: $e');
    }
  }

  void decrementUnreadCount() {
    if (_unreadNotificationCount > 0) {
      _unreadNotificationCount--;
      notifyListeners();
    }
  }

  void clearUnreadCount() {
    _unreadNotificationCount = 0;
    notifyListeners();
  }

  Future<void> refreshUnreadCount() async {
    await _loadUnreadCount();
  }

  Future<void> _loadCompaniesInternal() async {
    _isCompaniesLoading = true;
    notifyListeners();
    var loadedSuccessfully = false;

    try {
      final companiesData = await _authRepository.getMyCompanies();
      _availableCompanies = companiesData
          .where((company) => company.companyName.trim().isNotEmpty)
          .toList();
      loadedSuccessfully = true;

      if (_companyId != null) {
        final selectedCompany = _availableCompanies.cast<Company?>().firstWhere(
          (company) => company?.companyId == _companyId,
          orElse: () => null,
        );
        if (selectedCompany != null) {
          _companyName = selectedCompany.companyName;
        }
      }

      if (_companyId == null && _companyName != null) {
        final selectedCompany = _availableCompanies.cast<Company?>().firstWhere(
          (company) => company?.companyName == _companyName,
          orElse: () => null,
        );
        if (selectedCompany != null) {
          _companyId = selectedCompany.companyId;
          _companyName = selectedCompany.companyName;
        }
      }

      if (_companyId == null && _availableCompanies.isNotEmpty) {
        final firstCompany = _availableCompanies.first;
        _companyId = firstCompany.companyId;
        _companyName = firstCompany.companyName;
      }
    } catch (e) {
      debugPrint('Error loading companies: $e');
      if (_companyName != null) {
        _availableCompanies = [
          Company(
            companyId: _companyId ?? 0,
            companyName: _companyName!,
            industry: '',
            isActive: true,
          ),
        ];
      }
    } finally {
      _isCompaniesLoading = false;
      _hasLoadedCompanies = loadedSuccessfully;
      _companiesRequest = null;
      notifyListeners();
    }
  }
}
