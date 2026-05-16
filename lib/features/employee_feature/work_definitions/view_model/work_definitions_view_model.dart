import 'package:coreflow/data/repositories/employee_repository/employee_repository.dart';
import 'package:coreflow/domain/model/employee_model/employee_module_models.dart';
import 'package:flutter/material.dart';

class WorkDefinitionsViewModel extends ChangeNotifier {
  final EmployeeRepository _employeeRepository;

  WorkDefinitionsViewModel(this._employeeRepository);

  int _companyId = 0;
  final List<WorkDefinitionData> _activeWorkDefinitions = [];
  final List<WorkDefinitionData> _inactiveWorkDefinitions = [];

  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;
  String? _message;
  bool _showActiveOnly = true;

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  bool get hasError => _error != null;
  String? get error => _error;
  String? get message => _message;
  bool get showActiveOnly => _showActiveOnly;

  List<WorkDefinitionData> get workDefinitions => _showActiveOnly
      ? List.unmodifiable(_activeWorkDefinitions)
      : List.unmodifiable(_inactiveWorkDefinitions);

  bool get hasData =>
      _activeWorkDefinitions.isNotEmpty || _inactiveWorkDefinitions.isNotEmpty;

  Future<void> loadWorkDefinitions(int companyId) async {
    _companyId = companyId;
    _isLoading = true;
    _error = null;
    _message = null;
    notifyListeners();

    try {
      final allDefinitions = await _employeeRepository.getWorkDefinitions(
        companyId,
      );

      _activeWorkDefinitions
        ..clear()
        ..addAll(allDefinitions.where((definition) => definition.isActive));

      _inactiveWorkDefinitions
        ..clear()
        ..addAll(allDefinitions.where((definition) => !definition.isActive));
    } catch (e) {
      _error = 'Failed to load work definitions';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleActiveFilter() {
    _showActiveOnly = !_showActiveOnly;
    notifyListeners();
  }

  Future<void> refresh() async {
    if (_companyId > 0) {
      await loadWorkDefinitions(_companyId);
    }
  }

  Future<bool> createWorkDefinition(CreateWorkDefinitionRequest request) async {
    if (_companyId <= 0) return false;

    _isSaving = true;
    _error = null;
    _message = null;
    notifyListeners();

    try {
      final response = await _employeeRepository.createWorkDefinition(
        _companyId,
        request,
      );
      if (response?.responseStatus == true) {
        final successMessage =
            response?.responseMessage ?? 'Work definition created successfully';
        await loadWorkDefinitions(_companyId);
        _message = successMessage;
        return true;
      }
      _error = response?.responseMessage ?? 'Failed to create work definition';
      return false;
    } catch (e) {
      _error = 'Failed to create work definition';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> updateWorkDefinition(
    int workDefId,
    UpdateWorkDefinitionRequest request,
  ) async {
    if (_companyId <= 0) return false;

    _isSaving = true;
    _error = null;
    _message = null;
    notifyListeners();

    try {
      final response = await _employeeRepository.updateWorkDefinition(
        _companyId,
        workDefId,
        request,
      );
      if (response?.responseStatus == true) {
        final successMessage =
            response?.responseMessage ?? 'Work definition updated successfully';
        await loadWorkDefinitions(_companyId);
        _message = successMessage;
        return true;
      }
      _error = response?.responseMessage ?? 'Failed to update work definition';
      return false;
    } catch (e) {
      _error = 'Failed to update work definition';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> deactivateWorkDefinition(int workDefId) async {
    if (_companyId <= 0) return false;

    _isSaving = true;
    _error = null;
    _message = null;
    notifyListeners();

    try {
      final response = await _employeeRepository.deactivateWorkDefinition(
        _companyId,
        workDefId,
      );
      if (response?.responseStatus == true) {
        final successMessage =
            response?.responseMessage ??
            'Work definition deactivated successfully';
        await loadWorkDefinitions(_companyId);
        _message = successMessage;
        return true;
      }
      _error =
          response?.responseMessage ?? 'Failed to deactivate work definition';
      return false;
    } catch (e) {
      _error = 'Failed to deactivate work definition';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<List<RateHistoryData>> getRateHistory(int workDefId) {
    return _employeeRepository.getRateHistory(_companyId, workDefId);
  }
}
