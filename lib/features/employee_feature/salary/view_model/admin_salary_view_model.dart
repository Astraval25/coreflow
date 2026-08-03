import 'dart:typed_data';

import 'package:coreflow/data/repositories/main_repository/expense_repository.dart';
import 'package:coreflow/data/repositories/employee_repository/employee_repository.dart';
import 'package:coreflow/domain/model/employee_model/employee.dart';
import 'package:coreflow/domain/model/employee_model/employee_module_models.dart';
import 'package:coreflow/domain/model/main_model/expense/expense_account.dart';
import 'package:coreflow/domain/model/main_model/expense/expense_requests.dart';
import 'package:flutter/material.dart';

class AdminSalaryViewModel extends ChangeNotifier {
  final EmployeeRepository _employeeRepository;
  final ExpenseRepository _expenseRepository;

  AdminSalaryViewModel(
    this._employeeRepository, {
    ExpenseRepository? expenseRepository,
  }) : _expenseRepository = expenseRepository ?? ExpenseRepository();

  int _companyId = 0;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;
  String? _message;
  List<Employee> _employees = [];
  List<SalaryPeriodSummary> _salaryPeriods = [];
  List<ExpenseAccount> _activeExpenseAccounts = [];
  List<String> _expenseAccountTypes = [];
  SalaryReportData? _salaryReport;
  String _selectedPeriod = '';
  String _fromDate = '';
  String _toDate = '';

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get error => _error;
  String? get message => _message;
  List<Employee> get employees => List.unmodifiable(_employees);
  List<SalaryPeriodSummary> get salaryPeriods =>
      List.unmodifiable(_salaryPeriods);
  List<ExpenseAccount> get activeExpenseAccounts =>
      List.unmodifiable(_activeExpenseAccounts);
  List<String> get expenseAccountTypes =>
      List.unmodifiable(_expenseAccountTypes);
  SalaryReportData? get salaryReport => _salaryReport;
  String get selectedPeriod => _selectedPeriod;
  String get fromDate => _fromDate;
  String get toDate => _toDate;

  Future<void> loadInitial(int companyId) async {
    _companyId = companyId;
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0);
    _selectedPeriod = _formatPeriod(monthStart);
    _fromDate = _formatDate(monthStart);
    _toDate = _formatDate(monthEnd);
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
        _employeeRepository.getSalaryPeriods(_companyId),
        _employeeRepository.getSalaryReport(
          _companyId,
          from: _fromDate,
          to: _toDate,
        ),
        _expenseRepository.getExpenseAccounts(_companyId, activeOnly: true),
        _expenseRepository.getExpenseAccountTypes(_companyId),
      ]);

      _employees = results[0] as List<Employee>;
      _salaryPeriods = results[1] as List<SalaryPeriodSummary>;
      _salaryReport = results[2] as SalaryReportData?;
      _activeExpenseAccounts = results[3] as List<ExpenseAccount>;
      _expenseAccountTypes = results[4] as List<String>;
    } catch (e) {
      _error = 'Failed to load salary details';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updatePeriod(DateTime month) async {
    final monthStart = DateTime(month.year, month.month, 1);
    final monthEnd = DateTime(month.year, month.month + 1, 0);
    _selectedPeriod = _formatPeriod(monthStart);
    _fromDate = _formatDate(monthStart);
    _toDate = _formatDate(monthEnd);
    await refresh();
  }

  Future<void> updateReportRange({
    required String fromDate,
    required String toDate,
  }) async {
    _fromDate = fromDate;
    _toDate = toDate;
    await refresh();
  }

  Future<bool> calculateSalary(CalculateSalaryRequest request) async {
    if (_companyId <= 0) return false;

    _isSaving = true;
    _error = null;
    _message = null;
    notifyListeners();

    try {
      final response = await _employeeRepository.calculateSalary(
        _companyId,
        request,
      );
      if (response?.responseStatus == true) {
        final successMessage =
            response?.responseMessage ?? 'Salary calculated successfully';
        await refresh();
        _message = successMessage;
        return true;
      }
      _error = response?.responseMessage ?? 'Failed to calculate salary';
      return false;
    } catch (e) {
      _error = 'Failed to calculate salary';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<SalaryPeriodDetailData?> getSalaryPeriodDetail(int salaryPeriodId) {
    return _employeeRepository.getSalaryPeriodDetail(
      _companyId,
      salaryPeriodId,
    );
  }

  Future<Uint8List?> downloadSalarySlip(int salaryPeriodId) {
    return _employeeRepository.downloadSalarySlip(_companyId, salaryPeriodId);
  }

  Future<bool> approveSalaryPeriod(int salaryPeriodId) async {
    if (_companyId <= 0) return false;

    _isSaving = true;
    _error = null;
    _message = null;
    notifyListeners();

    try {
      final response = await _employeeRepository.approveSalaryPeriod(
        _companyId,
        salaryPeriodId,
      );
      if (response?.responseStatus == true) {
        final successMessage =
            response?.responseMessage ?? 'Salary period approved successfully';
        await refresh();
        _message = successMessage;
        return true;
      }
      _error = response?.responseMessage ?? 'Failed to approve salary period';
      return false;
    } catch (e) {
      _error = 'Failed to approve salary period';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> recordSalaryPayment({
    required SalaryPeriodSummary period,
    required int expenseAccountId,
    required String paymentMode,
    required double amount,
    String? invoiceNo,
    String? remark,
    String? paymentRef,
    DateTime? expenseDate,
  }) async {
    if (_companyId <= 0) return false;

    _isSaving = true;
    _error = null;
    _message = null;
    notifyListeners();

    try {
      final expenseDateValue = _formatDate(expenseDate ?? DateTime.now());
      final mergedRemark = _mergeRemarkWithRef(
        remark: remark,
        paymentRef: paymentRef,
      );

      final result = await _expenseRepository.createExpense(
        _companyId,
        ExpenseRequest(
          expenseDate: expenseDateValue,
          paymentMode: paymentMode,
          amount: amount,
          expenseAccountId: expenseAccountId,
          invoiceNo: invoiceNo,
          remark: mergedRemark,
          salaryPeriodId: period.salaryPeriodId,
        ),
      );

      if (result.success) {
        await refresh();
        _message = result.message;
        return true;
      }
      _error = result.message;
      return false;
    } catch (e) {
      _error = 'Failed to record salary payment';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  int? findDefaultSalaryExpenseAccountId() {
    if (_activeExpenseAccounts.isEmpty) return null;

    for (final account in _activeExpenseAccounts) {
      final name = account.accountName.toLowerCase();
      if (name.contains('salary')) return account.expenseAccountId;
    }

    for (final account in _activeExpenseAccounts) {
      if (account.accountType.toLowerCase() == 'expense') {
        return account.expenseAccountId;
      }
    }

    return _activeExpenseAccounts.first.expenseAccountId;
  }

  String _mergeRemarkWithRef({String? remark, String? paymentRef}) {
    final trimmedRemark = remark?.trim();
    final trimmedRef = paymentRef?.trim();

    if ((trimmedRef ?? '').isEmpty) {
      return trimmedRemark ?? '';
    }
    if ((trimmedRemark ?? '').isEmpty) {
      return 'Payment Ref: $trimmedRef';
    }
    return '$trimmedRemark (Payment Ref: $trimmedRef)';
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  String _formatPeriod(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$year$month';
  }
}
