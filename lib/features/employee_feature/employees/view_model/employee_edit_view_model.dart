import 'package:coreflow/data/repositories/employee_repository/employee_repository.dart';
import 'package:coreflow/domain/model/employee_model/create_employee_request.dart';
import 'package:coreflow/domain/model/employee_model/employee_detail.dart';
import 'package:coreflow/domain/model/employee_model/employee_edit_request.dart';
import 'package:coreflow/domain/model/employee_model/employee_edit_response.dart';
import 'package:flutter/foundation.dart';

class EmployeeEditViewModel extends ChangeNotifier {
  final EmployeeRepository _employeeRepository;

  EmployeeDetailData? _employeeDetails;
  EmployeeEditResponse? _editResponse;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;

  EmployeeEditViewModel(this._employeeRepository);

  EmployeeDetailData? get employeeDetails => _employeeDetails;
  EmployeeEditResponse? get editResponse => _editResponse;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get error => _error;

  Future<void> loadEmployeeDetails(int companyId, int employeeId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _employeeDetails = await _employeeRepository.getEmployeeDetail(
        companyId,
        employeeId,
      );
      if (_employeeDetails == null) {
        _error = 'Failed to load employee details';
      }
    } catch (e) {
      _error = 'Error loading employee details';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createEmployee(
    int companyId,
    CreateEmployeeRequest request,
  ) async {
    _isSaving = true;
    _error = null;
    _editResponse = null;
    notifyListeners();

    try {
      final response = await _employeeRepository.createEmployee(
        companyId,
        request,
      );
      _editResponse = response;
      if (response != null && response.responseStatus) {
        return true;
      }
      _error = response?.responseMessage ?? 'Failed to create employee';
      return false;
    } catch (e) {
      _error = 'Error creating employee';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> updateEmployee(
    int companyId,
    int employeeId,
    EmployeeEditRequest request,
  ) async {
    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _employeeRepository.updateEmployee(
        companyId,
        employeeId,
        request,
      );
      _editResponse = response;
      if (response != null && response.responseStatus) {
        return true;
      }
      _error = response?.responseMessage ?? 'Failed to update employee';
      return false;
    } catch (e) {
      _error = 'Error updating employee';
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
}
