import 'package:coreflow/domain/model/main_model/customer/create_customer_request.dart';
import 'package:flutter/foundation.dart';
import 'package:coreflow/data/repositories/auth_repository.dart';
import 'package:coreflow/domain/model/main_model/customer/customer_detail.dart';
import 'package:coreflow/domain/model/main_model/customer/customer_edit_request.dart';
import 'package:coreflow/domain/model/main_model/customer/customer_edit_response.dart';

class CustomerEditViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  CustomerDetailData? _customerDetails;
  CustomerEditResponse? _editResponse;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;
  int _creationStep = 0;
  Function(int)? onStepChanged;

  CustomerEditViewModel(this._authRepository);

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get error => _error;
  CustomerDetailData? get customerDetails => _customerDetails;
  CustomerEditResponse? get editResponse => _editResponse;
  int get creationStep => _creationStep;

  set customerDetails(CustomerDetailData? value) {
    _customerDetails = value;
    notifyListeners();
  }

  set editResponse(CustomerEditResponse? value) {
    _editResponse = value;
    notifyListeners();
  }

  Future<void> loadCustomerDetails(int companyId, int customerId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      debugPrint(
        'Loading customer details: companyId=$companyId, customerId=$customerId',
      );
      final customerDetail = await _authRepository.getCustomerDetail(
        companyId,
        customerId,
      );

      _customerDetails = customerDetail;
      if (customerDetail != null) {
        debugPrint('Customer details loaded successfully');
      } else {
        _error = 'Failed to load customer details';
        debugPrint('Customer details load failed');
      }
    } catch (e) {
      _error = 'Error loading customer: $e';
      debugPrint('Customer details error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateCustomer(
    int companyId,
    int customerId,
    CustomerEditRequest request,
  ) async {
    try {
      _isSaving = true;
      _error = null;
      notifyListeners();

      debugPrint(
        'Updating customer: companyId=$companyId, customerId=$customerId',
      );
      final response = await _authRepository.updateCustomer(
        companyId,
        customerId,
        request,
      );

      _editResponse = response;
      if (response != null && response.responseStatus) {
        debugPrint(
          'Customer updated successfully: ${response.responseMessage}',
        );
        return true;
      } else {
        _error = response?.responseMessage ?? 'Failed to update customer';
        debugPrint('Customer update failed: ${_error}');
        return false;
      }
    } catch (e) {
      _error = 'Error updating customer: $e';
      debugPrint('Customer update error: $e');
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> refreshCustomerDetails(int companyId, int customerId) async {
    await loadCustomerDetails(companyId, customerId);
  }

  Future<bool> createNewCustomer(
    int companyId,
    CreateCustomerRequest request,
  ) async {
    try {
      _isSaving = true;
      _error = null;
      _editResponse = null;
      notifyListeners();

      debugPrint('Creating customer for companyId: $companyId');

      final response = await _authRepository.createCustomer(companyId, request);

      _editResponse = response;

      if (response != null && response.responseStatus) {
        debugPrint(
          'Customer created successfully: ${response.responseMessage}',
        );
        _customerDetails = null;
        return true; 
      } else {
        _error = response?.responseMessage ?? 'Failed to create customer';
        return false;
      }
    } catch (e) {
      _error = 'Error creating customer: ${e.toString()}';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> createCustomerWithItems(
    int companyId,
    CreateCustomerRequest request,
    List<Map<String, dynamic>> items,
  ) async {
    try {
      _isSaving = true;
      _error = null;
      _editResponse = null;
      _creationStep = 0;
      if (onStepChanged != null) onStepChanged!(0);
      notifyListeners();

      debugPrint('Creating customer for companyId: $companyId');

      final response = await _authRepository.createCustomer(companyId, request);

      _editResponse = response;

      if (response == null || !response.responseStatus) {
        _error = response?.responseMessage ?? 'Failed to create customer';
        return {'success': false, 'step': 0};
      }

      final customerId = response.responseData?['customerId'];
      if (customerId == null) {
        _error = 'Customer created but ID not returned';
        return {'success': false, 'step': 0};
      }

      debugPrint('Customer created with ID: $customerId');
      _creationStep = 1;
      if (onStepChanged != null) onStepChanged!(1);
      notifyListeners();

      if (items.isEmpty) {
        _creationStep = 2;
        if (onStepChanged != null) onStepChanged!(2);
        notifyListeners();
        return {'success': true, 'step': 2, 'customerId': customerId};
      }

      for (int i = 0; i < items.length; i++) {
        final item = items[i];
        debugPrint('Creating customer item ${i + 1}/${items.length}');
        
        final itemResponse = await _authRepository.createCustomerItem(
          companyId: companyId,
          customerId: customerId,
          itemId: item['itemId'],
          salesPrice: item['salesPrice'],
          salesDescription: item['salesDescription'],
        );

        if (itemResponse == null || !itemResponse.responseStatus) {
          _error = 'Failed to create customer item ${i + 1}';
          return {'success': false, 'step': 1, 'customerId': customerId};
        }
      }

      debugPrint('All customer items created successfully');
      _creationStep = 2;
      if (onStepChanged != null) onStepChanged!(2);
      notifyListeners();
      return {'success': true, 'step': 2, 'customerId': customerId};
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

  @override
  void dispose() {
    super.dispose();
  }
}
