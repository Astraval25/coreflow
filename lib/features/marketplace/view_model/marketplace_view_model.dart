import 'package:coreflow/data/repositories/auth_repository.dart';
import 'package:coreflow/domain/model/company/marketplace_company.dart';
import 'package:flutter/material.dart';

class MarketplaceViewModel extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  List<MarketplaceCompany> _companies = [];
  bool _isLoading = false;
  String? _error;

  List<MarketplaceCompany> get companies => List.unmodifiable(_companies);
  bool get isLoading => _isLoading;
  bool get hasError => _error != null;
  String? get error => _error;
  bool get hasData => _companies.isNotEmpty;

  Future<void> loadCompanies() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _companies = await _authRepository.getAllCompanies();
    } catch (e) {
      _error = 'Failed to load companies';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
