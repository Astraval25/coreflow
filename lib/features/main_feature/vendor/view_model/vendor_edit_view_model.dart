import 'package:coreflow/domain/model/main_model/vendors/create_vendors_request.dart';
import 'package:coreflow/domain/model/main_model/vendors/vendors_detail.dart';
import 'package:coreflow/domain/model/main_model/vendors/vendors_edit_request.dart';
import 'package:coreflow/domain/model/main_model/vendors/vendors_edit_response.dart';
import 'package:flutter/foundation.dart';
import 'package:coreflow/data/repositories/auth_repository.dart';

class VendorEditViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  VendorsDetailData? _vendorDetails;
  VendorsEditResponse? _editResponse;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;
  int _creationStep = 0;
  Function(int)? onStepChanged;

  VendorEditViewModel(this._authRepository);

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get error => _error;
  VendorsDetailData? get vendorDetails => _vendorDetails;
  VendorsEditResponse? get editResponse => _editResponse;
  int get creationStep => _creationStep;

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

  Future<Map<String, dynamic>> createVendorWithItems(
    int companyId,
    CreateVendorsRequest request,
    List<Map<String, dynamic>> items,
  ) async {
    try {
      _isSaving = true;
      _error = null;
      _editResponse = null;
      _creationStep = 0;
      if (onStepChanged != null) onStepChanged!(0);
      notifyListeners();

      debugPrint('Creating vendor for companyId: $companyId');

      final response = await _authRepository.createVendor(companyId, request);

      _editResponse = response;

      if (response == null || !response.responseStatus) {
        _error = response?.responseMessage ?? 'Failed to create vendor';
        return {'success': false, 'step': 0};
      }

      final vendorId = response.responseData?['vendorId'];
      if (vendorId == null) {
        _error = 'Vendor created but ID not returned';
        return {'success': false, 'step': 0};
      }

      debugPrint('Vendor created with ID: $vendorId');
      _creationStep = 1;
      if (onStepChanged != null) onStepChanged!(1);
      notifyListeners();

      if (items.isEmpty) {
        _creationStep = 2;
        if (onStepChanged != null) onStepChanged!(2);
        notifyListeners();
        return {'success': true, 'step': 2, 'vendorId': vendorId};
      }

      for (int i = 0; i < items.length; i++) {
        final item = items[i];
        debugPrint('Creating vendor item ${i + 1}/${items.length}');
        
        final itemResponse = await _authRepository.createVendorItem(
          companyId: companyId,
          vendorId: vendorId,
          itemId: item['itemId'],
          purchasePrice: item['purchasePrice'],
          purchaseDescription: item['purchaseDescription'],
        );

        if (itemResponse == null || !itemResponse.responseStatus) {
          _error = 'Failed to create vendor item ${i + 1}';
          return {'success': false, 'step': 1, 'vendorId': vendorId};
        }
      }

      debugPrint('All vendor items created successfully');
      _creationStep = 2;
      if (onStepChanged != null) onStepChanged!(2);
      notifyListeners();
      return {'success': true, 'step': 2, 'vendorId': vendorId};
    } catch (e) {
      _error = 'Error: ${e.toString()}';
      return {'success': false, 'step': 0};
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

}
