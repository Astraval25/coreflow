import 'package:flutter/material.dart';
import '../../../../data/repositories/main_repository/company_repository.dart';
import '../../../../domain/model/main_model/company/company.dart';

class CompanyViewModel extends ChangeNotifier {
  final CompanyRepository _companyRepo = CompanyRepository();

  List<Company> _companies = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _isSaving = false;

  List<Company> get companies => _companies;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isSaving => _isSaving;

  Future<void> loadCompanies() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _companies = await _companyRepo.getMyCompanies();
    } catch (e) {
      _errorMessage = 'Failed to load companies';
      debugPrint('Load companies error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createCompany({
    required String companyName,
    required String industry,
    String? pan,
    String? gstNo,
    String? hsnCode,
    String? shortName,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = {
        'companyName': companyName,
        'industry': industry,
        if (pan != null && pan.isNotEmpty) 'pan': pan,
        if (gstNo != null && gstNo.isNotEmpty) 'gstNo': gstNo,
        if (hsnCode != null && hsnCode.isNotEmpty) 'hsnCode': hsnCode,
        if (shortName != null && shortName.isNotEmpty) 'shortName': shortName,
      };
      final result = await _companyRepo.createCompany(data);
      if (result != null) {
        await loadCompanies();
        return true;
      }
      _errorMessage = 'Failed to create company';
      return false;
    } catch (e) {
      _errorMessage = 'Failed to create company';
      debugPrint('Create company error: $e');
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> updateCompany({
    required int companyId,
    required String companyName,
    required String industry,
    String? pan,
    String? gstNo,
    String? hsnCode,
    String? shortName,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = {
        'companyName': companyName,
        'industry': industry,
        if (pan != null && pan.isNotEmpty) 'pan': pan,
        if (gstNo != null && gstNo.isNotEmpty) 'gstNo': gstNo,
        if (hsnCode != null && hsnCode.isNotEmpty) 'hsnCode': hsnCode,
        if (shortName != null && shortName.isNotEmpty) 'shortName': shortName,
      };
      final result = await _companyRepo.updateCompany(companyId, data);
      if (result != null) {
        await loadCompanies();
        return true;
      }
      _errorMessage = 'Failed to update company';
      return false;
    } catch (e) {
      _errorMessage = 'Failed to update company';
      debugPrint('Update company error: $e');
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> toggleCompanyStatus(Company company) async {
    _errorMessage = null;
    notifyListeners();

    try {
      bool success;
      if (company.isActive) {
        success = await _companyRepo.deactivateCompany(company.companyId);
      } else {
        success = await _companyRepo.activateCompany(company.companyId);
      }
      if (success) {
        await loadCompanies();
        return true;
      }
      _errorMessage = 'Failed to update company status';
      return false;
    } catch (e) {
      _errorMessage = 'Failed to update company status';
      debugPrint('Toggle company status error: $e');
      return false;
    }
  }
}
