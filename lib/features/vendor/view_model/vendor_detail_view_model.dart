import 'package:coreflow/domain/model/vendors/vendors_detail.dart';
import 'package:flutter/foundation.dart';
import 'package:coreflow/data/repositories/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum VendorViewState { initial, loading, loaded, error, noData }

class VendorDetailViewModel extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  VendorViewState _state = VendorViewState.initial;
  VendorsDetailData? _vendor;
  String? _errorMessage;

  final int _companyId;
  final int _vendorId;

  VendorDetailViewModel({required int companyId, required int vendorId})
    : _companyId = companyId,
      _vendorId = vendorId {
    loadVendorDetail();
  }

  // ───── Getters ─────
  VendorViewState get state => _state;
  VendorsDetailData? get vendor => _vendor; 
  String? get errorMessage => _errorMessage;

  bool get isLoading => _state == VendorViewState.loading;
  bool get hasData => _state == VendorViewState.loaded;
  bool get isError => _state == VendorViewState.error;
  bool get isNoData => _state == VendorViewState.noData;

  int get companyId => _companyId;
  int get vendorId => _vendorId;

  bool get isActive => _vendor?.isActive ?? false;

  Future<void> loadVendorDetail() async {
    _updateState(VendorViewState.loading);

    try {
      final vendorData = await _authRepository.getVendorDetail(
        _companyId,
        _vendorId,
      );

      if (vendorData != null) {
        _vendor = vendorData;
        _updateState(VendorViewState.loaded);
      } else {
        _updateState(VendorViewState.noData, error: 'No Vendor data found');
      }
    } catch (e) {
      _updateState(VendorViewState.error, error: 'Failed to load Vendor: $e');
    }
  }

  Future<void> activateVendor(BuildContext context) async {
    _updateState(VendorViewState.loading);

    try {
      final response = await _authRepository.activateVendor(
        _companyId,
        _vendorId,
      );

      if (response != null && response.responseStatus == true) {
        await loadVendorDetail();
        if (context.mounted) {
          context.pop(true);
        }
      } else {
        _updateState(
          VendorViewState.error,
          error: response?.responseMessage ?? 'Activate failed',
        );
      }
    } catch (e) {
      _updateState(VendorViewState.error, error: 'Activate error: $e');
    }
  }

  Future<void> deactivateVendor(BuildContext context) async {
    _updateState(VendorViewState.loading);

    try {
      final response = await _authRepository.deactivateVendor(
        _companyId,
        _vendorId,
      );

      if (response != null && response.responseStatus == true) {
        await loadVendorDetail();
        if (context.mounted) {
          context.pop(true);
        }
      } else {
        _updateState(
          VendorViewState.error,
          error: response?.responseMessage ?? 'Deactivate failed',
        );
      }
    } catch (e) {
      _updateState(VendorViewState.error, error: 'Deactivate error: $e');
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _updateState(VendorViewState state, {String? error}) {
    _state = state;
    _errorMessage = error;
    notifyListeners();
  }
}
