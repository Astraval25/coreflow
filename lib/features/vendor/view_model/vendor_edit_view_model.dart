import 'package:coreflow/domain/model/vendors/create_vendors_request.dart';
import 'package:coreflow/domain/model/vendors/vendors_detail.dart';
import 'package:coreflow/domain/model/vendors/vendors_edit_request.dart';
import 'package:coreflow/domain/model/vendors/vendors_edit_response.dart';
import 'package:flutter/foundation.dart';
import 'package:coreflow/data/repositories/auth_repository.dart';

class VendorEditViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  VendorsDetailData? _vendorDetails;
  VendorsEditResponse? _editResponse;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;

  VendorEditViewModel(this._authRepository);

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get error => _error;
  VendorsDetailData? get vendorDetails => _vendorDetails;
  VendorsEditResponse? get editResponse => _editResponse;

  set vendorDetails(VendorsDetailData? value) {
    _vendorDetails = value;
    notifyListeners();
  }

  set editResponse(VendorsEditResponse? value) {
    _editResponse = value;
    notifyListeners();
  }

  Future<void> loadVendorDetails(int companyId, int vendorId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      debugPrint(
        'Loading vendor details: companyId=$companyId, vendorId=$vendorId',
      );
      final vendorDetail = await _authRepository.getVendorDetail(
        companyId,
        vendorId,
      );

      _vendorDetails = vendorDetail;
      if (vendorDetail != null) {
        debugPrint('Vendor details loaded successfully');
      } else {
        _error = 'Failed to load vendor details';
        debugPrint('Vendor details load failed');
      }
    } catch (e) {
      _error = 'Error loading vendor: $e';
      debugPrint('Vendor details error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateVendor(
    int companyId,
    int vendorId,
    VendorsEditRequest request,
  ) async {
    try {
      _isSaving = true;
      _error = null;
      notifyListeners();

      debugPrint('Updating vendor: companyId=$companyId, vendorId=$vendorId');
      final response = await _authRepository.updateVendor(
        companyId,
        vendorId,
        request,
      );

      _editResponse = response;
      if (response != null && response.responseStatus) {
        debugPrint('Vendor updated successfully: ${response.responseMessage}');
        return true;
      } else {
        _error = response?.responseMessage ?? 'Failed to update vendor';
        debugPrint('Vendor update failed: $_error');
        return false;
      }
    } catch (e) {
      _error = 'Error updating vendor: $e';
      debugPrint('Vendor update error: $e');
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> refreshVendorDetails(int companyId, int vendorId) async {
    await loadVendorDetails(companyId, vendorId);
  }

  Future<bool> createNewVendor(
    int companyId,
    CreateVendorsRequest request,
  ) async {
    try {
      _isSaving = true;
      _error = null;
      _editResponse = null;
      notifyListeners();

      debugPrint('Creating Vendor for companyId: $companyId');

      final response = await _authRepository.createVendor(companyId, request);

      _editResponse = response;

      if (response != null && response.responseStatus) {
        debugPrint('Vendor created successfully: ${response.responseMessage}');
        _vendorDetails = null;
        return true;
      } else {
        _error = response?.responseMessage ?? 'Failed to create vendor';
        return false;
      }
    } catch (e) {
      _error = 'Error creating vendor: ${e.toString()}';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
