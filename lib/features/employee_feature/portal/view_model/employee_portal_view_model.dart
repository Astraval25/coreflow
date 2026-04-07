import 'dart:typed_data';

import 'package:coreflow/core/storage/token_storage.dart';
import 'package:coreflow/data/repositories/auth_repository/auth_repository.dart';
import 'package:coreflow/data/repositories/employee_repository/employee_repository.dart';
import 'package:coreflow/domain/model/employee_model/employee_detail.dart';
import 'package:coreflow/domain/model/employee_model/employee_module_models.dart';
import 'package:flutter/material.dart';

class EmployeePortalViewModel extends ChangeNotifier {
  final EmployeeRepository _employeeRepository;
  final AuthRepository _authRepository;

  EmployeePortalViewModel({
    EmployeeRepository? employeeRepository,
    AuthRepository? authRepository,
  }) : _employeeRepository = employeeRepository ?? EmployeeRepository(),
       _authRepository = authRepository ?? AuthRepository() {
    loadPortal();
  }

  bool _isLoading = true;
  bool _isSalaryLoading = false;
  bool _isSubmitting = false;
  String? _error;
  String? _message;
  int? _companyId;
  int? _employeeId;
  EmployeeDetailData? _profile;
  List<WorkDefinitionData> _workDefinitions = [];
  List<WorkLogData> _workLogs = [];
  List<LeaveLogData> _leaveLogs = [];
  List<SalaryPeriodSummary> _salaryPeriods = [];
  SalaryReportData? _salaryReport;
  String _salaryReportFromDate = '';
  String _salaryReportToDate = '';

  bool get isLoading => _isLoading;
  bool get isSalaryLoading => _isSalaryLoading;
  bool get isSubmitting => _isSubmitting;
  String? get error => _error;
  String? get message => _message;
  int? get companyId => _companyId;
  int? get employeeId => _employeeId;
  EmployeeDetailData? get profile => _profile;
  List<WorkDefinitionData> get workDefinitions =>
      List.unmodifiable(_workDefinitions);
  List<WorkLogData> get workLogs => List.unmodifiable(_workLogs);
  List<LeaveLogData> get leaveLogs => List.unmodifiable(_leaveLogs);
  List<SalaryPeriodSummary> get salaryPeriods =>
      List.unmodifiable(_salaryPeriods);
  SalaryReportData? get salaryReport => _salaryReport;
  String get salaryReportFromDate => _salaryReportFromDate;
  String get salaryReportToDate => _salaryReportToDate;

  bool get isWorkBased =>
      _profile?.currentSalaryType?.toUpperCase() == 'WORK_BASED';
  bool get isMonthly => _profile?.currentSalaryType?.toUpperCase() == 'MONTHLY';

  Future<void> loadPortal() async {
    _isLoading = true;
    _error = null;
    _message = null;
    notifyListeners();

    try {
      final authData = await TokenStorage.getFullAuthData();
      _companyId = authData?['companyId'] as int?;
      _employeeId =
          authData?['employeeId'] as int? ??
          int.tryParse(authData?['userId']?.toString() ?? '');
      _ensureDefaultSalaryReportRange();

      final profile = await _employeeRepository.getMyProfile();
      _profile = profile;

      final results = await Future.wait([
        _employeeRepository.getEmployeeVisibleWorkDefinitions(
          companyId: _companyId,
          activeOnly: true,
        ),
        _employeeRepository.getMyWorkLogs(),
        _employeeRepository.getMyLeaveLogs(),
        _employeeRepository.getMySalaryPeriods(),
        _employeeRepository.getMySalaryReport(
          from: _salaryReportFromDate,
          to: _salaryReportToDate,
        ),
      ]);

      _workDefinitions = results[0] as List<WorkDefinitionData>;
      _workLogs = results[1] as List<WorkLogData>;
      _leaveLogs = results[2] as List<LeaveLogData>;
      _salaryPeriods = results[3] as List<SalaryPeriodSummary>;
      _salaryReport = results[4] as SalaryReportData?;
    } catch (e) {
      _error = 'Failed to load employee portal';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createWorkLog({
    required int workDefId,
    required String logDate,
    required double quantity,
    String? remarks,
  }) async {
    _isSubmitting = true;
    _error = null;
    _message = null;
    notifyListeners();

    try {
      final response = await _employeeRepository.createMyWorkLog(
        CreateWorkLogRequest(
          employeeId: _employeeId,
          workDefId: workDefId,
          logDate: logDate,
          quantity: quantity,
          employeeRemarks: remarks,
        ),
        companyId: _companyId,
      );

      if (response?.responseStatus == true) {
        _message = response?.responseMessage ?? 'Work log submitted successfully';
        _workLogs = await _employeeRepository.getMyWorkLogs();
        notifyListeners();
        return true;
      }

      _error = response?.responseMessage ?? 'Failed to create work log';
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to create work log';
      notifyListeners();
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> createLeaveLog({
    required String leaveDate,
    required String leaveType,
    required String leaveCategory,
    String? reason,
  }) async {
    _isSubmitting = true;
    _error = null;
    _message = null;
    notifyListeners();

    try {
      final response = await _employeeRepository.createMyLeaveLog(
        CreateLeaveLogRequest(
          employeeId: _employeeId,
          leaveDate: leaveDate,
          leaveType: leaveType,
          leaveCategory: leaveCategory,
          reason: reason,
        ),
        companyId: _companyId,
      );

      if (response?.responseStatus == true) {
        _message =
            response?.responseMessage ?? 'Leave request submitted successfully';
        _leaveLogs = await _employeeRepository.getMyLeaveLogs();
        notifyListeners();
        return true;
      }

      _error = response?.responseMessage ?? 'Failed to request leave';
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to request leave';
      notifyListeners();
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<SalaryPeriodDetailData?> getSalaryDetail(int salaryPeriodId) {
    return _employeeRepository.getMySalaryDetail(salaryPeriodId);
  }

  Future<Uint8List?> downloadSalarySlip(int salaryPeriodId) {
    return _employeeRepository.downloadMySalarySlip(salaryPeriodId);
  }

  Future<void> updateSalaryReportRange({
    required String fromDate,
    required String toDate,
  }) async {
    _salaryReportFromDate = fromDate;
    _salaryReportToDate = toDate;
    _isSalaryLoading = true;
    _error = null;
    notifyListeners();

    try {
      _salaryReport = await _employeeRepository.getMySalaryReport(
        from: fromDate,
        to: toDate,
      );
    } catch (e) {
      _error = 'Failed to load salary report';
    } finally {
      _isSalaryLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authRepository.clearAuthData();
  }

  void _ensureDefaultSalaryReportRange() {
    if (_salaryReportFromDate.isNotEmpty && _salaryReportToDate.isNotEmpty) {
      return;
    }

    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0);
    _salaryReportFromDate = _formatDate(monthStart);
    _salaryReportToDate = _formatDate(monthEnd);
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
