import 'dart:typed_data';

import 'package:coreflow/core/storage/token_storage.dart';
import 'package:coreflow/data/repositories/auth_repository/auth_repository.dart';
import 'package:coreflow/data/services/push_notification_service.dart';
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
  bool _isActivityLoading = false;
  bool _isSalaryLoading = false;
  bool _isSubmitting = false;
  bool _isTodayLocked = false;
  String? _lockedMessage;
  String? _error;
  String? _message;
  int? _companyId;
  int? _employeeId;
  EmployeeDetailData? _profile;
  List<WorkDefinitionData> _workDefinitions = [];
  List<WorkLogData> _todayWorkLogs = [];
  List<LeaveLogData> _todayLeaveLogs = [];
  List<WorkLogData> _workLogs = [];
  List<LeaveLogData> _leaveLogs = [];
  List<SalaryPeriodSummary> _salaryPeriods = [];
  SalaryReportData? _salaryReport;
  DateTime _salaryDayCursor = DateTime.now();
  List<WorkLogData> _salaryDayWorkLogs = [];
  bool _isSalaryDayLoading = false;
  String _activityFromDate = '';
  String _activityToDate = '';
  String _salaryReportFromDate = '';
  String _salaryReportToDate = '';

  bool get isLoading => _isLoading;
  bool get isActivityLoading => _isActivityLoading;
  bool get isSalaryLoading => _isSalaryLoading;
  bool get isSalaryDayLoading => _isSalaryDayLoading;
  bool get isSubmitting => _isSubmitting;
  bool get isTodayLocked => _isTodayLocked;
  String? get lockedMessage => _lockedMessage;

  String get today {
    final now = DateTime.now();
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  WorkLogData? findLogForToday(int workDefId) {
    final t = today;
    for (final log in _todayWorkLogs) {
      if (log.workDefId == workDefId && log.logDate == t) return log;
    }
    return null;
  }

  LeaveLogData? findLeaveForToday() {
    final t = today;
    for (final log in _todayLeaveLogs) {
      if (log.leaveDate == t) return log;
    }
    return null;
  }

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
  List<WorkLogData> get salaryDayWorkLogs =>
      List.unmodifiable(_salaryDayWorkLogs);
  String get salaryDayDate => _formatDate(_salaryDayCursor);
  bool get canGoToNextSalaryDay =>
      _dateOnly(_salaryDayCursor).isBefore(_dateOnly(DateTime.now()));
  double get salaryDayTotalEarned =>
      _salaryDayWorkLogs.fold(0.0, (sum, log) => sum + _workLogEarned(log));
  String get activityFromDate => _activityFromDate;
  String get activityToDate => _activityToDate;
  String get salaryReportFromDate => _salaryReportFromDate;
  String get salaryReportToDate => _salaryReportToDate;

  bool get isWorkBased =>
      _profile?.currentSalaryType?.toUpperCase() == 'WORK_BASED';
  bool get isMonthly => _profile?.currentSalaryType?.toUpperCase() == 'MONTHLY';

  Future<void> loadPortal() async {
    _isLoading = true;
    _isSalaryDayLoading = false;
    _error = null;
    _message = null;
    notifyListeners();

    try {
      final authData = await TokenStorage.getFullAuthData();
      _companyId = authData?['companyId'] as int?;
      _employeeId =
          authData?['employeeId'] as int? ??
          int.tryParse(authData?['userId']?.toString() ?? '');
      _ensureDefaultRanges();
      _salaryDayCursor = _clampToToday(_salaryDayCursor);
      final selectedSalaryDay = _formatDate(_salaryDayCursor);

      final profile = await _employeeRepository.getMyProfile();
      _profile = profile;

      final results = await Future.wait([
        _employeeRepository.getEmployeeVisibleWorkDefinitions(
          companyId: _companyId,
          activeOnly: true,
        ),
        _employeeRepository.getMyWorkLogs(
          from: _activityFromDate,
          to: _activityToDate,
        ),
        _employeeRepository.getMyLeaveLogs(
          from: _activityFromDate,
          to: _activityToDate,
        ),
        _employeeRepository.getMyWorkLogs(from: today, to: today),
        _employeeRepository.getMyLeaveLogs(from: today, to: today),
        _employeeRepository.getMySalaryPeriods(),
        _employeeRepository.getMySalaryReport(
          from: _salaryReportFromDate,
          to: _salaryReportToDate,
        ),
        _employeeRepository.getMyWorkLogs(
          from: selectedSalaryDay,
          to: selectedSalaryDay,
        ),
      ]);

      _workDefinitions = results[0] as List<WorkDefinitionData>;
      _workLogs = results[1] as List<WorkLogData>;
      _leaveLogs = results[2] as List<LeaveLogData>;
      _todayWorkLogs = results[3] as List<WorkLogData>;
      _todayLeaveLogs = results[4] as List<LeaveLogData>;
      _salaryPeriods = results[5] as List<SalaryPeriodSummary>;
      _salaryReport = results[6] as SalaryReportData?;
      _salaryDayWorkLogs = results[7] as List<WorkLogData>;
    } catch (e) {
      _error = 'Failed to load employee portal';
    } finally {
      _isLoading = false;
      _isSalaryDayLoading = false;
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
        _message =
            response?.responseMessage ?? 'Work log submitted successfully';
        await _reloadTodayActivity();
        await _reloadActivityData();
        notifyListeners();
        return true;
      }

      _error = response?.responseMessage ?? 'Failed to create work log';
      _maybeMarkLocked(_error, logDate);
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
        await _reloadTodayActivity();
        await _reloadActivityData();
        notifyListeners();
        return true;
      }

      _error = response?.responseMessage ?? 'Failed to request leave';
      _maybeMarkLocked(_error, leaveDate);
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

  Future<bool> updateWorkLog({
    required int workDefId,
    required String logDate,
    required double quantity,
    String? remarks,
  }) async {
    if (_companyId == null || _employeeId == null) return false;
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _employeeRepository.updateMyWorkLog(
        CreateWorkLogRequest(
          employeeId: _employeeId,
          workDefId: workDefId,
          logDate: logDate,
          quantity: quantity,
          employeeRemarks: remarks,
        ),
        companyId: _companyId!,
      );

      if (response?.responseStatus == true) {
        _message = response?.responseMessage ?? 'Work log updated';
        await _reloadTodayActivity();
        await _reloadActivityData();
        notifyListeners();
        return true;
      }
      _error = response?.responseMessage ?? 'Failed to update work log';
      _maybeMarkLocked(_error, logDate);
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to update work log';
      notifyListeners();
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> updateLeaveLog({
    required String leaveDate,
    required String leaveType,
    required String leaveCategory,
    String? reason,
  }) async {
    if (_companyId == null || _employeeId == null) return false;
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _employeeRepository.updateMyLeaveLog(
        CreateLeaveLogRequest(
          employeeId: _employeeId,
          leaveDate: leaveDate,
          leaveType: leaveType,
          leaveCategory: leaveCategory,
          reason: reason,
        ),
        companyId: _companyId!,
      );

      if (response?.responseStatus == true) {
        _message = response?.responseMessage ?? 'Leave updated';
        await _reloadTodayActivity();
        await _reloadActivityData();
        notifyListeners();
        return true;
      }
      _error = response?.responseMessage ?? 'Failed to update leave';
      _maybeMarkLocked(_error, leaveDate);
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to update leave';
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

  Future<void> updateActivityRange({
    required String fromDate,
    required String toDate,
  }) async {
    _activityFromDate = fromDate;
    _activityToDate = toDate;
    _isActivityLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _reloadActivityData();
    } catch (e) {
      _error = 'Failed to load activity';
    } finally {
      _isActivityLoading = false;
      notifyListeners();
    }
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
      await _reloadSalaryData();
    } catch (e) {
      _error = 'Failed to load salary report';
    } finally {
      _isSalaryLoading = false;
      notifyListeners();
    }
  }

  Future<void> goToPreviousSalaryDay() async {
    await _shiftSalaryDayBy(-1);
  }

  Future<void> goToNextSalaryDay() async {
    await _shiftSalaryDayBy(1);
  }

  Future<void> logout() async {
    await PushNotificationService().deregisterToken();
    await _authRepository.clearAuthData();
  }

  void _maybeMarkLocked(String? message, String date) {
    if (message == null) return;
    final lower = message.toLowerCase();
    if (lower.contains('salary is already calculated') ||
        lower.contains('already calculated')) {
      _lockedMessage = message;
      if (date == today) _isTodayLocked = true;
    }
  }

  void _ensureDefaultRanges() {
    if (_activityFromDate.isNotEmpty &&
        _activityToDate.isNotEmpty &&
        _salaryReportFromDate.isNotEmpty &&
        _salaryReportToDate.isNotEmpty) {
      return;
    }

    final todayDate = _dateOnly(DateTime.now());
    final fromDate = todayDate.subtract(const Duration(days: 29));
    _activityFromDate = _formatDate(fromDate);
    _activityToDate = _formatDate(todayDate);
    _salaryReportFromDate = _formatDate(fromDate);
    _salaryReportToDate = _formatDate(todayDate);
  }

  Future<void> _reloadTodayActivity() async {
    final results = await Future.wait([
      _employeeRepository.getMyWorkLogs(from: today, to: today),
      _employeeRepository.getMyLeaveLogs(from: today, to: today),
    ]);

    _todayWorkLogs = results[0] as List<WorkLogData>;
    _todayLeaveLogs = results[1] as List<LeaveLogData>;
    if (salaryDayDate == today) {
      _salaryDayWorkLogs = List<WorkLogData>.from(_todayWorkLogs);
    }
  }

  Future<void> _reloadActivityData() async {
    final results = await Future.wait([
      _employeeRepository.getMyWorkLogs(
        from: _activityFromDate,
        to: _activityToDate,
      ),
      _employeeRepository.getMyLeaveLogs(
        from: _activityFromDate,
        to: _activityToDate,
      ),
    ]);

    _workLogs = results[0] as List<WorkLogData>;
    _leaveLogs = results[1] as List<LeaveLogData>;
  }

  Future<void> _reloadSalaryData() async {
    final results = await Future.wait([
      _employeeRepository.getMySalaryPeriods(),
      _employeeRepository.getMySalaryReport(
        from: _salaryReportFromDate,
        to: _salaryReportToDate,
      ),
    ]);

    _salaryPeriods = results[0] as List<SalaryPeriodSummary>;
    _salaryReport = results[1] as SalaryReportData?;
  }

  Future<void> _shiftSalaryDayBy(int dayOffset) async {
    final targetDate = _clampToToday(
      _dateOnly(_salaryDayCursor).add(Duration(days: dayOffset)),
    );
    if (_dateOnly(targetDate) == _dateOnly(_salaryDayCursor)) return;

    _salaryDayCursor = targetDate;
    _isSalaryDayLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _reloadSalaryDayData();
    } catch (e) {
      _error = 'Failed to load day-wise earnings';
    } finally {
      _isSalaryDayLoading = false;
      notifyListeners();
    }
  }

  Future<void> _reloadSalaryDayData() async {
    _salaryDayWorkLogs = await _employeeRepository.getMyWorkLogs(
      from: salaryDayDate,
      to: salaryDayDate,
    );
  }

  DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  DateTime _clampToToday(DateTime date) {
    final normalized = _dateOnly(date);
    final todayDate = _dateOnly(DateTime.now());
    if (normalized.isAfter(todayDate)) return todayDate;
    return normalized;
  }

  double _workLogEarned(WorkLogData log) {
    if (log.status.toUpperCase() == 'REJECTED') return 0;
    final amountEarned = log.amountEarned;
    if (amountEarned != null) return amountEarned;
    final quantity = log.quantity;
    final rate = log.rateSnapshot;
    if (quantity == null || rate == null) return 0;
    return quantity * rate;
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
