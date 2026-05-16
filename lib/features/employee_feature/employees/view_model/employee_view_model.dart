import 'package:coreflow/data/repositories/employee_repository/employee_repository.dart';
import 'package:coreflow/domain/model/employee_model/employee_detail.dart';
import 'package:coreflow/domain/model/employee_model/employee_module_models.dart';
import 'package:flutter/material.dart';

class EmployeeViewModel extends ChangeNotifier {
  final EmployeeRepository _repository;
  final int companyId;
  final int employeeId;
  final Future<void> Function()? _refreshUnreadCount;

  EmployeeViewModel({
    required EmployeeRepository repository,
    required this.companyId,
    required this.employeeId,
    Future<void> Function()? refreshUnreadCount,
  }) : _repository = repository,
       _refreshUnreadCount = refreshUnreadCount;

  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;
  String? _message;
  EmployeeDetailData? _employee;
  List<WorkDefinitionData> _workDefinitions = const [];
  List<WorkLogData> _workLogs = const [];
  List<LeaveLogData> _leaveLogs = const [];
  bool _hasClearedUnreadActivity = false;

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get error => _error;
  String? get message => _message;
  EmployeeDetailData? get employee => _employee;
  List<WorkDefinitionData> get workDefinitions =>
      List.unmodifiable(_workDefinitions);
  List<WorkLogData> get workLogs => List.unmodifiable(_workLogs);
  List<LeaveLogData> get leaveLogs => List.unmodifiable(_leaveLogs);

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    _message = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.getEmployeeDetail(companyId, employeeId),
        _repository.getWorkDefinitions(companyId, activeOnly: true),
        _repository.getEmployeeActivityLogs(companyId, employeeId),
      ]);
      _employee = results[0] as EmployeeDetailData?;
      _workDefinitions = results[1] as List<WorkDefinitionData>;
      final activity = results[2] as EmployeeActivityLogsData?;
      _workLogs = activity?.workLogs ?? const [];
      _leaveLogs = activity?.leaveLogs ?? const [];
      if (_employee == null) {
        _error = 'Employee details not found';
      } else {
        await _clearUnreadActivityIfNeeded();
      }
    } catch (_) {
      _error = 'Failed to load employee view';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => load();

  Future<bool> activateEmployee() async {
    return _toggleEmployeeStatus(activate: true);
  }

  Future<bool> deactivateEmployee() async {
    return _toggleEmployeeStatus(activate: false);
  }

  Future<bool> _toggleEmployeeStatus({required bool activate}) async {
    _isSaving = true;
    _error = null;
    _message = null;
    notifyListeners();
    try {
      final response = activate
          ? await _repository.activateEmployee(companyId, employeeId)
          : await _repository.deactivateEmployee(companyId, employeeId);
      if (response?.responseStatus == true) {
        _message = response?.responseMessage;
        await load();
        return true;
      }
      _error = response?.responseMessage ?? 'Failed to update employee status';
      return false;
    } catch (_) {
      _error = 'Failed to update employee status';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> reviewWorkLog({
    required int logId,
    required String status,
    String? adminRemarks,
  }) async {
    return _saveAndRefresh(() async {
      final response = await _repository.reviewWorkLog(
        companyId,
        logId,
        ReviewWorkLogRequest(status: status, adminRemarks: adminRemarks),
      );
      if (response?.responseStatus != true) {
        _error = response?.responseMessage ?? 'Failed to review work log';
        return false;
      }
      _message = response?.responseMessage ?? 'Work log reviewed successfully';
      return true;
    });
  }

  Future<bool> updateWorkLog({
    required int logId,
    required int workDefId,
    required String logDate,
    required double quantity,
    String? employeeRemarks,
  }) async {
    return _saveAndRefresh(() async {
      final response = await _repository.updateWorkLogByAdmin(
        companyId,
        logId,
        CreateWorkLogRequest(
          employeeId: employeeId,
          workDefId: workDefId,
          logDate: logDate,
          quantity: quantity,
          employeeRemarks: employeeRemarks,
        ),
      );
      if (response?.responseStatus != true) {
        _error = response?.responseMessage ?? 'Failed to update work log';
        return false;
      }
      _message = response?.responseMessage ?? 'Work log updated successfully';
      return true;
    });
  }

  Future<bool> deleteWorkLog(int logId) async {
    return _saveAndRefresh(() async {
      final response = await _repository.deleteWorkLogByAdmin(companyId, logId);
      if (response?.responseStatus != true) {
        _error = response?.responseMessage ?? 'Failed to delete work log';
        return false;
      }
      _message = response?.responseMessage ?? 'Work log deleted successfully';
      return true;
    });
  }

  Future<bool> reviewLeaveLog({
    required int leaveId,
    required String status,
  }) async {
    return _saveAndRefresh(() async {
      final response = await _repository.reviewLeaveLog(
        companyId,
        leaveId,
        ReviewLeaveLogRequest(status: status),
      );
      if (response?.responseStatus != true) {
        _error = response?.responseMessage ?? 'Failed to review leave log';
        return false;
      }
      _message = response?.responseMessage ?? 'Leave log reviewed successfully';
      return true;
    });
  }

  Future<bool> updateLeaveLog({
    required int leaveId,
    required String leaveDate,
    required String leaveType,
    required String leaveCategory,
    String? reason,
  }) async {
    return _saveAndRefresh(() async {
      final response = await _repository.updateLeaveLogByAdmin(
        companyId,
        leaveId,
        CreateLeaveLogRequest(
          employeeId: employeeId,
          leaveDate: leaveDate,
          leaveType: leaveType,
          leaveCategory: leaveCategory,
          reason: reason,
        ),
      );
      if (response?.responseStatus != true) {
        _error = response?.responseMessage ?? 'Failed to update leave log';
        return false;
      }
      _message = response?.responseMessage ?? 'Leave log updated successfully';
      return true;
    });
  }

  Future<bool> deleteLeaveLog(int leaveId) async {
    return _saveAndRefresh(() async {
      final response = await _repository.deleteLeaveLogByAdmin(
        companyId,
        leaveId,
      );
      if (response?.responseStatus != true) {
        _error = response?.responseMessage ?? 'Failed to delete leave log';
        return false;
      }
      _message = response?.responseMessage ?? 'Leave log deleted successfully';
      return true;
    });
  }

  Future<bool> createWorkLogs({
    required String logDate,
    required Map<int, double> quantityByWorkDefId,
    String? employeeRemarks,
  }) async {
    return _saveAndRefresh(() async {
      if (quantityByWorkDefId.isEmpty) {
        _error = 'Please enter at least one quantity';
        return false;
      }

      var successCount = 0;
      String? firstError;
      for (final entry in quantityByWorkDefId.entries) {
        if (entry.value <= 0) continue;
        final response = await _repository.createWorkLog(
          companyId,
          CreateWorkLogRequest(
            employeeId: employeeId,
            workDefId: entry.key,
            logDate: logDate,
            quantity: entry.value,
            employeeRemarks: employeeRemarks,
          ),
        );
        if (response?.responseStatus == true) {
          successCount++;
        } else {
          firstError ??= response?.responseMessage;
        }
      }

      if (successCount == 0) {
        _error = firstError ?? 'Failed to create work logs';
        return false;
      }

      _message = firstError == null
          ? 'Work logs saved successfully'
          : 'Saved $successCount work logs. $firstError';
      return true;
    });
  }

  Future<bool> createLeaveLog({
    required String leaveDate,
    required String leaveType,
    required String leaveCategory,
    String? reason,
  }) async {
    return _saveAndRefresh(() async {
      final response = await _repository.createLeaveLog(
        companyId,
        CreateLeaveLogRequest(
          employeeId: employeeId,
          leaveDate: leaveDate,
          leaveType: leaveType,
          leaveCategory: leaveCategory,
          reason: reason,
        ),
      );
      if (response?.responseStatus != true) {
        _error = response?.responseMessage ?? 'Failed to create leave log';
        return false;
      }
      _message = response?.responseMessage ?? 'Leave log saved successfully';
      return true;
    });
  }

  Future<bool> _saveAndRefresh(Future<bool> Function() run) async {
    _isSaving = true;
    _error = null;
    _message = null;
    notifyListeners();
    try {
      final ok = await run();
      if (ok) {
        await _refreshActivity();
      }
      return ok;
    } catch (_) {
      _error = 'Failed to save changes';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> _refreshActivity() async {
    final activity = await _repository.getEmployeeActivityLogs(
      companyId,
      employeeId,
    );
    _workLogs = activity?.workLogs ?? const [];
    _leaveLogs = activity?.leaveLogs ?? const [];
  }

  Future<void> _clearUnreadActivityIfNeeded() async {
    if (_hasClearedUnreadActivity) return;

    await _repository.markEmployeeNotificationsRead(companyId, employeeId);
    _hasClearedUnreadActivity = true;
    await _refreshUnreadCount?.call();
  }
}
