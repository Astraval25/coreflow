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
    final today = _formatDate(DateTime.now());
    _fromDate = today;
    _toDate = today;
    await refresh();
  }

  Future<void> shiftDay(int days) async {
    final base = DateTime.tryParse(_fromDate) ?? DateTime.now();
    final next = base.add(Duration(days: days));
    final str = _formatDate(next);
    _fromDate = str;
    _toDate = str;
    await refresh();
  }

  Future<void> goToToday() async {
    final today = _formatDate(DateTime.now());
    _fromDate = today;
    _toDate = today;
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

  Future<bool> createWorkLogsBatch(
    List<CreateWorkLogRequest> requests, {
    required bool autoApprove,
  }) async {
    if (_companyId <= 0 || requests.isEmpty) return false;

    _isSaving = true;
    _error = null;
    _message = null;
    notifyListeners();

    var createdCount = 0;
    var approvedCount = 0;
    final failedMessages = <String>[];

    try {
      for (final request in requests) {
        final response = await _employeeRepository.createWorkLog(
          _companyId,
          request,
        );
        if (response?.responseStatus == true) {
          createdCount++;
          continue;
        }
        failedMessages.add(
          response?.responseMessage ?? 'Failed to create a work log',
        );
      }

      if (autoApprove && createdCount > 0) {
        approvedCount = await _approvePendingCreatedLogs(requests);
      }

      await refresh();

      if (createdCount == requests.length) {
        _message = autoApprove
            ? 'Saved $createdCount work logs and approved $approvedCount'
            : 'Saved $createdCount work logs';
        return true;
      }

      final partialMessage = failedMessages.isNotEmpty
          ? 'Saved $createdCount of ${requests.length} work logs. ${failedMessages.first}'
          : 'Saved $createdCount of ${requests.length} work logs';
      _message = partialMessage;
      _error = partialMessage;
      return createdCount > 0;
    } catch (e) {
      _error = 'Failed to save work logs';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<int> _approvePendingCreatedLogs(
    List<CreateWorkLogRequest> requests,
  ) async {
    var approvedCount = 0;
    final grouped = <String, List<CreateWorkLogRequest>>{};

    for (final request in requests) {
      final employeeId = request.employeeId;
      if (employeeId == null) continue;
      final key = '$employeeId|${request.logDate}';
      grouped.putIfAbsent(key, () => <CreateWorkLogRequest>[]).add(request);
    }

    for (final entry in grouped.entries) {
      final parts = entry.key.split('|');
      final employeeId = int.tryParse(parts.first);
      final logDate = parts.length > 1 ? parts[1] : '';
      if (employeeId == null || logDate.isEmpty) continue;

      final createdWorkDefIds = entry.value
          .map((request) => request.workDefId)
          .toSet();
      final logs = await _employeeRepository.getWorkLogsByEmployeeDateRange(
        _companyId,
        employeeId,
        from: logDate,
        to: logDate,
      );

      for (final log in logs) {
        if (!createdWorkDefIds.contains(log.workDefId)) continue;
        if (log.status.toUpperCase() != 'PENDING') continue;
        final response = await _employeeRepository.reviewWorkLog(
          _companyId,
          log.logId,
          const ReviewWorkLogRequest(
            status: 'APPROVED',
            adminRemarks: 'Auto approved by admin',
          ),
        );
        if (response?.responseStatus == true) approvedCount++;
      }
    }

    return approvedCount;
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
