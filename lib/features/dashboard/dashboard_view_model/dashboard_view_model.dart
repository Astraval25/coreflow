import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../data/repositories/auth_repository.dart';

class DashboardViewModel extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  bool _isLoading = true;
  String? _userName;
  String? _email;
  String? _companyName;

  List<String> _availableCompanies = [];
  bool _isCompaniesLoading = false;

  bool _isCustomersExpanded = false;
  bool _isVendorsExpanded = false;
  bool _isSalesExpanded = false;

  String _selectedMenu = 'badges';

  bool get isLoading => _isLoading;
  String? get userName => _userName;
  String? get email => _email;
  String? get companyName => _companyName;

  List<String> get availableCompanies => _availableCompanies;
  bool get isCompaniesLoading => _isCompaniesLoading;

  bool get isCustomersExpanded => _isCustomersExpanded;
  String get selectedMenu => _selectedMenu;

  DashboardViewModel() {
    loadUserData().then(
      (_) => loadCompanies(),
    ); 
  }

  Future<void> loadUserData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _authRepository.getAuthData();
      _userName = data?['userName'] as String?;
      _email = data?['email'] as String?;
      _companyName = data?['companyName'] as String?;
    } catch (_) {
      _userName = null;
      _email = null;
      _companyName = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCompanies() async {
    _isCompaniesLoading = true;
    notifyListeners();

    try {
      final companiesData = await _authRepository.getMyCompanies();
      _availableCompanies = companiesData
          .map((company) => company.companyName)
          .where((name) => name.isNotEmpty)
          .toList();

      if (_companyName != null &&
          !_availableCompanies.contains(_companyName!)) {
        _availableCompanies.insert(0, _companyName!);
      }
    } catch (e) {
      print('Error loading companies: $e');

      if (_companyName != null) {
        _availableCompanies = [_companyName!];
      }
    } finally {
      _isCompaniesLoading = false;
      notifyListeners();
    }
  }

  void selectCompany(String companyName) {
    _companyName = companyName;
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

    if (!context.mounted) return;

    context.go('/login');
  }
}
