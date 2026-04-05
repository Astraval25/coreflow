import 'package:coreflow/core/storage/vendor_pin_storage.dart';
import 'package:coreflow/data/repositories/auth_repository.dart';
import 'package:coreflow/domain/model/vendors/vendors.dart';
import 'package:flutter/material.dart';

class ActiveVendorViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  ActiveVendorViewModel(this._authRepository);

  int _companyId = 0;

  final List<Vendor> _activeVendor = [];
  final List<Vendor> _inactiveVendor = [];

  bool _isLoading = false;
  String? _error;
  bool _showActiveOnly = true;
  Set<int> _pinnedVendorIds = <int>{};


  bool get isLoading => _isLoading;
  bool get hasError => _error != null;
  String? get error => _error;

  bool get showActiveOnly => _showActiveOnly;

  List<Vendor> get vendor => _sortVendorsByPinned(
    _showActiveOnly ? _activeVendor : _inactiveVendor,
  );

  bool get hasData => _activeVendor.isNotEmpty || _inactiveVendor.isNotEmpty;

  int get activeVendorCount => _activeVendor.length;
  int get inactiveVendorCount => _inactiveVendor.length;

  List<Vendor> get activeVendor => List.unmodifiable(_activeVendor);
  List<Vendor> get inactiveVendor => List.unmodifiable(_inactiveVendor);
  Set<int> get pinnedVendorIds => Set.unmodifiable(_pinnedVendorIds);

  bool isVendorPinned(int vendorId) => _pinnedVendorIds.contains(vendorId);


  Future<void> loadVendor(int companyId) async {
    _companyId = companyId;
    _setLoading(true);
    _clearError();

    try {
      _pinnedVendorIds = await VendorPinStorage.loadPinnedVendorIds(companyId);
      final allVendor = await _authRepository.getActiveVendors(companyId);

      _activeVendor
        ..clear()
        ..addAll(allVendor.where((v) => v.isActive));

      _inactiveVendor
        ..clear()
        ..addAll(allVendor.where((v) => !v.isActive));

      final validIds = allVendor.map((v) => v.vendorId).toSet();
      final stalePins = _pinnedVendorIds.difference(validIds);
      if (stalePins.isNotEmpty) {
        _pinnedVendorIds.removeAll(stalePins);
        await VendorPinStorage.savePinnedVendorIds(_companyId, _pinnedVendorIds);
      }
    } catch (e) {
      _setError('Failed to load Vendor');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> toggleVendorStatus(int vendorId) async {
    if (_companyId == 0) return false;

    _setLoading(true);
    _clearError();

    try {
      final isActive = _activeVendor.any((v) => v.vendorId == vendorId);

      final response = isActive
          ? await _authRepository.deactivateVendor(_companyId, vendorId)
          : await _authRepository.activateVendor(_companyId, vendorId);

      if (response?.responseStatus == true) {
        await loadVendor(_companyId);
        return true;
      }

      _setError(response?.responseMessage ?? 'Operation failed');
      return false;
    } catch (e) {
      _setError('Failed to update vendor status');
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
      await loadVendor(_companyId);
    }
  }

  Future<void> togglePinVendor(int vendorId) async {
    if (_companyId == 0) return;

    if (_pinnedVendorIds.contains(vendorId)) {
      _pinnedVendorIds.remove(vendorId);
    } else {
      _pinnedVendorIds.add(vendorId);
    }

    await VendorPinStorage.savePinnedVendorIds(_companyId, _pinnedVendorIds);
    notifyListeners();
  }

  List<Vendor> _sortVendorsByPinned(List<Vendor> source) {
    final sorted = List<Vendor>.from(source);
    sorted.sort((a, b) {
      final aPinned = _pinnedVendorIds.contains(a.vendorId);
      final bPinned = _pinnedVendorIds.contains(b.vendorId);
      if (aPinned != bPinned) return aPinned ? -1 : 1;
      return a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase());
    });
    return sorted;
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
    notifyListeners();
  }
}
