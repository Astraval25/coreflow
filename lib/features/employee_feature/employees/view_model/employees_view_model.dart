import 'package:coreflow/data/repositories/employee_repository/employee_repository.dart';
import 'package:coreflow/domain/model/employee_model/employee.dart';
import 'package:flutter/material.dart';

class EmployeesViewModel extends ChangeNotifier {
  final EmployeeRepository _employeeRepository;

  EmployeesViewModel(this._employeeRepository);

  int _companyId = 0;

  final List<Employee> _activeEmployees = [];
  final List<Employee> _inactiveEmployees = [];

  bool _isLoading = false;
  String? _error;
  bool _showActiveOnly = true;

  bool get isLoading => _isLoading;
  bool get hasError => _error != null;
  String? get error => _error;

  bool get showActiveOnly => _showActiveOnly;

  List<Employee> get employees => _showActiveOnly
      ? List.unmodifiable(_activeEmployees)
      : List.unmodifiable(_inactiveEmployees);

  bool get hasData =>
      _activeEmployees.isNotEmpty || _inactiveEmployees.isNotEmpty;

  int get activeEmployeesCount => _activeEmployees.length;
  int get inactiveEmployeesCount => _inactiveEmployees.length;
  List<Employee> get activeEmployees => List.unmodifiable(_activeEmployees);
  List<Employee> get inactiveEmployees => List.unmodifiable(_inactiveEmployees);

  Future<void> loadEmployees(int companyId) async {
    _companyId = companyId;
    _setLoading(true);
    _clearError();

    try {
      final allEmployees = await _employeeRepository.getEmployees(companyId);

      _activeEmployees
        ..clear()
        ..addAll(allEmployees.where((e) => e.isActive));

      _inactiveEmployees
        ..clear()
        ..addAll(allEmployees.where((e) => !e.isActive));
    } catch (e) {
      _setError('Failed to load employees');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deactivateEmployee(int employeeId) async {
    if (_companyId == 0) return false;

    _setLoading(true);
    _clearError();

    try {
      final response = await _employeeRepository.deactivateEmployee(
        _companyId,
        employeeId,
      );

      if (response?.responseStatus == true) {
        await loadEmployees(_companyId);
        return true;
      }

      _setError(response?.responseMessage ?? 'Operation failed');
      return false;
    } catch (e) {
      _setError('Failed to deactivate employee');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void toggleActiveFilter() {
    _showActiveOnly = !_showActiveOnly;
    notifyListeners();
  }

  Future<void> refresh() async {
    if (_companyId > 0) {
      await loadEmployees(_companyId);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}
