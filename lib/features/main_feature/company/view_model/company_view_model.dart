import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../data/repositories/main_repository/company_repository.dart';
import '../../../../domain/model/main_model/company/company.dart';

class CompanyViewModel extends ChangeNotifier {
  final CompanyRepository _companyRepo = CompanyRepository();

  List<Company> _companies = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _isSaving = false;
  bool _isUploadingLogo = false;

  List<Company> get companies => _companies;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isSaving => _isSaving;
  bool get isUploadingLogo => _isUploadingLogo;

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

  Future<Company?> getCompanyById(int companyId) async {
    try {
      return await _companyRepo.getCompanyById(companyId);
    } catch (e) {
      debugPrint('Get company detail error: $e');
      return null;
    }
  }

  Future<bool> createCompany({
    required String companyName,
    required String industry,
    String? pan,
    String? gstNo,
    String? hsnCode,
    String? shortName,
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
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = _buildCompanyPayload(
        companyName: companyName,
        industry: industry,
        pan: pan,
        gstNo: gstNo,
        hsnCode: hsnCode,
        shortName: shortName,
        contactPerson: contactPerson,
        contactEmail: contactEmail,
        contactPhone: contactPhone,
        website: website,
        addressLine1: addressLine1,
        addressLine2: addressLine2,
        city: city,
        state: state,
        country: country,
        postalCode: postalCode,
        publicDescription: publicDescription,
      );
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
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = _buildCompanyPayload(
        companyName: companyName,
        industry: industry,
        pan: pan,
        gstNo: gstNo,
        hsnCode: hsnCode,
        shortName: shortName,
        contactPerson: contactPerson,
        contactEmail: contactEmail,
        contactPhone: contactPhone,
        website: website,
        addressLine1: addressLine1,
        addressLine2: addressLine2,
        city: city,
        state: state,
        country: country,
        postalCode: postalCode,
        publicDescription: publicDescription,
      );
      final success = await _companyRepo.updateCompany(companyId, data);
      if (success) {
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

  Future<String?> uploadCompanyLogo(int companyId, File file) async {
    _isUploadingLogo = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fsId = await _companyRepo.uploadCompanyLogo(companyId, file);
      if (fsId != null) {
        await loadCompanies();
        return fsId;
      }
      _errorMessage = 'Failed to upload logo';
      return null;
    } catch (e) {
      _errorMessage = 'Failed to upload logo';
      debugPrint('Upload logo error: $e');
      return null;
    } finally {
      _isUploadingLogo = false;
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

  Map<String, dynamic> _buildCompanyPayload({
    required String companyName,
    required String industry,
    String? pan,
    String? gstNo,
    String? hsnCode,
    String? shortName,
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
  }) {
    final payload = <String, dynamic>{
      'companyName': companyName,
      'industry': industry,
    };

    void addIfNotBlank(String key, String? value) {
      if (value == null) return;
      final trimmed = value.trim();
      if (trimmed.isNotEmpty) payload[key] = trimmed;
    }

    addIfNotBlank('pan', pan);
    addIfNotBlank('gstNo', gstNo);
    addIfNotBlank('hsnCode', hsnCode);
    addIfNotBlank('shortName', shortName);
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

    return payload;
  }
}
