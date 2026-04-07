import 'package:coreflow/data/repositories/employee_repository/employee_repository.dart';
import 'package:coreflow/domain/model/employee_model/employee_detail.dart';
import 'package:flutter/material.dart';

enum EmployeeDetailState { initial, loading, loaded, error, noData }

class EmployeeDetailViewModel extends ChangeNotifier {
  final EmployeeRepository _employeeRepository;
  final int _companyId;
  final int _employeeId;

  EmployeeDetailState _state = EmployeeDetailState.initial;
  EmployeeDetailData? _employee;
  String? _errorMessage;
  String? _message;
  bool _isDeactivating = false;

  EmployeeDetailViewModel({
    required EmployeeRepository employeeRepository,
    required int companyId,
    required int employeeId,
  }) : _employeeRepository = employeeRepository,
       _companyId = companyId,
       _employeeId = employeeId {
    loadEmployeeDetail();
  }

  EmployeeDetailState get state => _state;
  EmployeeDetailData? get employee => _employee;
  String? get errorMessage => _errorMessage;
  String? get message => _message;
  bool get isDeactivating => _isDeactivating;

  int get companyId => _companyId;
  int get employeeId => _employeeId;

  bool get isLoading => _state == EmployeeDetailState.loading;
  bool get isError => _state == EmployeeDetailState.error;
  bool get isNoData => _state == EmployeeDetailState.noData;
  bool get isActive => _employee?.isActive ?? false;

  Future<void> loadEmployeeDetail() async {
    _setState(EmployeeDetailState.loading);

    try {
      final detail = await _employeeRepository.getEmployeeDetail(
        _companyId,
        _employeeId,
      );

      if (detail == null) {
        _setState(EmployeeDetailState.noData, error: 'Employee data not found');
        return;
      }

      _employee = detail;
      _setState(EmployeeDetailState.loaded);
    } catch (e) {
      _setState(
        EmployeeDetailState.error,
        error: 'Failed to load employee details',
      );
    }
  }

  Future<bool> deactivateEmployee() async {
    if (_isDeactivating) return false;

    _isDeactivating = true;
    notifyListeners();

    try {
      final response = await _employeeRepository.deactivateEmployee(
        _companyId,
        _employeeId,
      );
      if (response?.responseStatus == true) {
        final successMessage =
            response?.responseMessage ?? 'Employee deactivated successfully';
        await loadEmployeeDetail();
        _message = successMessage;
        return true;
      }
      _errorMessage =
          response?.responseMessage ?? 'Failed to deactivate employee';
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Failed to deactivate employee';
      notifyListeners();
      return false;
    } finally {
      _isDeactivating = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    _message = null;
    notifyListeners();
  }

  void _setState(EmployeeDetailState state, {String? error}) {
    _state = state;
    _errorMessage = error;
    if (state != EmployeeDetailState.loaded) {
      _message = null;
    }
    notifyListeners();
  }
}
