import 'package:coreflow/data/repositories/employee_repository/employee_repository.dart';
import 'package:coreflow/domain/model/employee_model/employee.dart';
import 'package:coreflow/domain/model/employee_model/employee_module_models.dart';
import 'package:flutter/material.dart';

class AdminWorkLogsViewModel extends ChangeNotifier {
  final EmployeeRepository _employeeRepository;

  AdminWorkLogsViewModel(this._employeeRepository);

  int _companyId = 0;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;
  String? _message;
  List<Employee> _employees = [];
  List<WorkDefinitionData> _workDefinitions = [];
  List<WorkLogData> _workLogs = [];
  List<WorkLogData> _pendingWorkLogs = [];
  String _fromDate = '';
  String _toDate = '';

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get error => _error;
  String? get message => _message;
  List<Employee> get employees => List.unmodifiable(_employees);
  List<WorkDefinitionData> get workDefinitions =>
      List.unmodifiable(_workDefinitions);
  List<WorkLogData> get workLogs => List.unmodifiable(_workLogs);
  List<WorkLogData> get pendingWorkLogs => List.unmodifiable(_pendingWorkLogs);
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
        _employeeRepository.getWorkDefinitions(_companyId, activeOnly: true),
        _employeeRepository.getWorkLogsByCompanyDateRange(
          _companyId,
          from: _fromDate,
          to: _toDate,
        ),
        _employeeRepository.getPendingWorkLogs(_companyId),
      ]);

      _employees = results[0] as List<Employee>;
      _workDefinitions = results[1] as List<WorkDefinitionData>;
      _workLogs = results[2] as List<WorkLogData>;
      _pendingWorkLogs = results[3] as List<WorkLogData>;
    } catch (e) {
      _error = 'Failed to load work logs';
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

  Future<bool> createWorkLog(CreateWorkLogRequest request) async {
    if (_companyId <= 0) return false;

    _isSaving = true;
    _error = null;
    _message = null;
    notifyListeners();

    try {
      final response = await _employeeRepository.createWorkLog(
        _companyId,
        request,
      );
      if (response?.responseStatus == true) {
        final successMessage =
            response?.responseMessage ?? 'Work log created successfully';
        await refresh();
        _message = successMessage;
        return true;
      }
      _error = response?.responseMessage ?? 'Failed to create work log';
      return false;
    } catch (e) {
      _error = 'Failed to create work log';
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
    if (_companyId <= 0) return false;

    _isSaving = true;
    _error = null;
    _message = null;
    notifyListeners();

    try {
      final response = await _employeeRepository.reviewWorkLog(
        _companyId,
        logId,
        ReviewWorkLogRequest(status: status, adminRemarks: adminRemarks),
      );
      if (response?.responseStatus == true) {
        final successMessage =
            response?.responseMessage ??
            (status.toUpperCase() == 'APPROVED'
                ? 'Work log approved successfully'
                : 'Work log rejected successfully');
        await refresh();
        _message = successMessage;
        return true;
      }
      _error = response?.responseMessage ?? 'Failed to review work log';
      return false;
    } catch (e) {
      _error = 'Failed to review work log';
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
