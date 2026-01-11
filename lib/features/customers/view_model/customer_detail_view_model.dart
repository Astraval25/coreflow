import 'package:flutter/foundation.dart';
import 'package:coreflow/data/repositories/auth_repository.dart';
import 'package:coreflow/domain/model/customer/customer_detail.dart';

enum CustomerViewState { initial, loading, loaded, error, noData }

class CustomerDetailViewModel extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  CustomerViewState _state = CustomerViewState.initial;
  CustomerDetailData? _customer;
  String? _errorMessage;
  final int _companyId;
  final int _customerId;

  CustomerDetailViewModel({required int companyId, required int customerId})
    : _companyId = companyId,
      _customerId = customerId {
    loadCustomerDetail(); 
  }

  CustomerViewState get state => _state;
  CustomerDetailData? get customer => _customer;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == CustomerViewState.loading;
  bool get hasData => _state == CustomerViewState.loaded;
  bool get isError => _state == CustomerViewState.error;
  bool get isNoData => _state == CustomerViewState.noData;


  int get companyId => _companyId;
  int get customerId => _customerId;

  Future<void> loadCustomerDetail() async {
    _updateState(CustomerViewState.loading, null);

    try {
      debugPrint(
        'Loading customer: companyId=$_companyId, customerId=$_customerId',
      );
      final customerData = await _authRepository.getCustomerDetail(
        _companyId,
        _customerId,
      );

      if (customerData != null) {
        _customer = customerData;
        _updateState(CustomerViewState.loaded, null);
        debugPrint('Customer loaded successfully');
      } else {
        _updateState(CustomerViewState.noData, 'No customer data found');
        debugPrint('No customer data found');
      }
    } catch (e) {
      _updateState(CustomerViewState.error, 'Failed to load customer: $e');
      debugPrint('Customer load error: $e');
    }
  }

  Future<void> refreshData() async {
    await loadCustomerDetail();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _updateState(CustomerViewState state, String? error) {
    _state = state;
    _errorMessage = error;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
