import 'dart:async';

import 'package:coreflow/data/repositories/employee_repository/employee_repository.dart';
import 'package:coreflow/domain/model/employee_model/employee_detail.dart';
import 'package:coreflow/domain/model/employee_model/employee_module_models.dart';
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
  bool _isTogglingStatus = false;
  PortalUserData? _portalUser;
  bool _isLoadingPortal = false;
  bool _isPortalBusy = false;

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
  bool get isTogglingStatus => _isTogglingStatus;
  PortalUserData? get portalUser => _portalUser;
  bool get isLoadingPortal => _isLoadingPortal;
  bool get isPortalBusy => _isPortalBusy;
  bool get hasPortalUser => _portalUser != null;

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
      // Best-effort fetch portal user — don't block detail load on it.
      unawaited(loadPortalUser());
    } catch (e) {
      _setState(
        EmployeeDetailState.error,
        error: 'Failed to load employee details',
      );
    }
  }

  Future<void> loadPortalUser() async {
    _isLoadingPortal = true;
    notifyListeners();
    try {
      _portalUser = await _employeeRepository.getPortalUser(
        _companyId,
        _employeeId,
      );
    } catch (_) {
      _portalUser = null;
    } finally {
      _isLoadingPortal = false;
      notifyListeners();
    }
  }

  Future<bool> activateEmployee() async {
    return _toggleEmployeeStatus(activate: true);
  }

  Future<bool> _toggleEmployeeStatus({required bool activate}) async {
    if (_isTogglingStatus || _isDeactivating) return false;
    _isTogglingStatus = true;
    _isDeactivating = !activate;
    notifyListeners();
    try {
      final response = activate
          ? await _employeeRepository.activateEmployee(_companyId, _employeeId)
          : await _employeeRepository.deactivateEmployee(
              _companyId,
              _employeeId,
            );
      if (response?.responseStatus == true) {
        final successMessage = response?.responseMessage ??
            (activate
                ? 'Employee activated successfully'
                : 'Employee deactivated successfully');
        await loadEmployeeDetail();
        _message = successMessage;
        return true;
      }
      _errorMessage = response?.responseMessage ??
          (activate
              ? 'Failed to activate employee'
              : 'Failed to deactivate employee');
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = activate
          ? 'Failed to activate employee'
          : 'Failed to deactivate employee';
      notifyListeners();
      return false;
    } finally {
      _isTogglingStatus = false;
      _isDeactivating = false;
      notifyListeners();
    }
  }

  Future<bool> createPortalUser({
    required String username,
    required String password,
  }) async {
    if (_isPortalBusy) return false;
    _isPortalBusy = true;
    notifyListeners();
    try {
      final response = await _employeeRepository.createPortalUser(
        _companyId,
        _employeeId,
        CreatePortalUserRequest(username: username, password: password),
      );
      if (response?.responseStatus == true) {
        _message = response?.responseMessage ?? 'Portal user created';
        await loadPortalUser();
        return true;
      }
      _errorMessage =
          response?.responseMessage ?? 'Failed to create portal user';
      return false;
    } catch (_) {
      _errorMessage = 'Failed to create portal user';
      return false;
    } finally {
      _isPortalBusy = false;
      notifyListeners();
    }
  }

  Future<bool> resetPortalPassword(String password) async {
    if (_isPortalBusy) return false;
    _isPortalBusy = true;
    notifyListeners();
    try {
      final response = await _employeeRepository.resetPortalUserPassword(
        _companyId,
        _employeeId,
        ResetPortalPasswordRequest(password: password),
      );
      if (response?.responseStatus == true) {
        _message = response?.responseMessage ?? 'Password reset';
        return true;
      }
      _errorMessage = response?.responseMessage ?? 'Failed to reset password';
      return false;
    } catch (_) {
      _errorMessage = 'Failed to reset password';
      return false;
    } finally {
      _isPortalBusy = false;
      notifyListeners();
    }
  }

  Future<bool> togglePortalAccess() async {
    if (_isPortalBusy || _portalUser == null) return false;
    final activate = !(_portalUser!.isActive);
    _isPortalBusy = true;
    notifyListeners();
    try {
      final response = activate
          ? await _employeeRepository.activatePortalUser(
              _companyId,
              _employeeId,
            )
          : await _employeeRepository.deactivatePortalUser(
              _companyId,
              _employeeId,
            );
      if (response?.responseStatus == true) {
        _message = response?.responseMessage ??
            (activate ? 'Portal access activated' : 'Portal access deactivated');
        await loadPortalUser();
        return true;
      }
      _errorMessage = response?.responseMessage ??
          (activate
              ? 'Failed to activate portal access'
              : 'Failed to deactivate portal access');
      return false;
    } catch (_) {
      _errorMessage = activate
          ? 'Failed to activate portal access'
          : 'Failed to deactivate portal access';
      return false;
    } finally {
      _isPortalBusy = false;
      notifyListeners();
    }
  }

  Future<bool> deactivateEmployee() => _toggleEmployeeStatus(activate: false);

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
