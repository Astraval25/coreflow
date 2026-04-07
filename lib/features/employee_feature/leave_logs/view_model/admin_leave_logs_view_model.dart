import 'package:coreflow/data/repositories/employee_repository/employee_repository.dart';
import 'package:coreflow/domain/model/employee_model/employee.dart';
import 'package:coreflow/domain/model/employee_model/employee_module_models.dart';
import 'package:flutter/material.dart';

class AdminLeaveLogsViewModel extends ChangeNotifier {
  final EmployeeRepository _employeeRepository;

  AdminLeaveLogsViewModel(this._employeeRepository);

  int _companyId = 0;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;
  String? _message;
  List<Employee> _employees = [];
  List<LeaveLogData> _leaveLogs = [];
  List<LeaveLogData> _pendingLeaveLogs = [];
  String _fromDate = '';
  String _toDate = '';

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get error => _error;
  String? get message => _message;
  List<Employee> get employees => List.unmodifiable(_employees);
  List<LeaveLogData> get leaveLogs => List.unmodifiable(_leaveLogs);
  List<LeaveLogData> get pendingLeaveLogs => List.unmodifiable(_pendingLeaveLogs);
  String get fromDate => _fromDate;
  String get toDate => _toDate;

  Future<void> loadInitial(int companyId) async {
    _companyId = companyId;
    final now = DateTime.now();
    _fromDate = _formatDate(DateTime(now.year, now.month, 1));
    _toDate = _formatDate(DateTime(now.year, now.month + 1, 0));
    await refresh();
  }

  Future<void> refresh() async {
    if (_companyId <= 0) return;
    _isLoading = true;
    _error = null;
    _message = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _employeeRepository.getEmployees(_companyId, activeOnly: true),
        _employeeRepository.getLeaveLogsByCompanyDateRange(
          _companyId,
          from: _fromDate,
          to: _toDate,
        ),
        _employeeRepository.getPendingLeaveLogs(_companyId),
      ]);

      _employees = results[0] as List<Employee>;
      _leaveLogs = results[1] as List<LeaveLogData>;
      _pendingLeaveLogs = results[2] as List<LeaveLogData>;
    } catch (e) {
      _error = 'Failed to load leave requests';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateDateRange({
    required String fromDate,
    required String toDate,
  }) async {
    _fromDate = fromDate;
    _toDate = toDate;
    await refresh();
  }

  Future<bool> createLeaveLog(CreateLeaveLogRequest request) async {
    if (_companyId <= 0) return false;

    _isSaving = true;
    _error = null;
    _message = null;
    notifyListeners();

    try {
      final response = await _employeeRepository.createLeaveLog(
        _companyId,
        request,
      );
      if (response?.responseStatus == true) {
        final successMessage =
            response?.responseMessage ?? 'Leave request created successfully';
        await refresh();
        _message = successMessage;
        return true;
      }
      _error = response?.responseMessage ?? 'Failed to create leave request';
      return false;
    } catch (e) {
      _error = 'Failed to create leave request';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> reviewLeaveLog({
    required int leaveId,
    required String status,
  }) async {
    if (_companyId <= 0) return false;

    _isSaving = true;
    _error = null;
    _message = null;
    notifyListeners();

    try {
      final response = await _employeeRepository.reviewLeaveLog(
        _companyId,
        leaveId,
        ReviewLeaveLogRequest(status: status),
      );
      if (response?.responseStatus == true) {
        final successMessage =
            response?.responseMessage ??
            (status.toUpperCase() == 'APPROVED'
                ? 'Leave request approved successfully'
                : 'Leave request rejected successfully');
        await refresh();
        _message = successMessage;
        return true;
      }
      _error = response?.responseMessage ?? 'Failed to review leave request';
      return false;
    } catch (e) {
      _error = 'Failed to review leave request';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
