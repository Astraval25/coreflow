import 'dart:typed_data';
import 'package:coreflow/data/repositories/auth_repository.dart';
import 'package:coreflow/data/services/api_services.dart';
import 'package:coreflow/domain/model/main_model/items/detail_item.dart';
import 'package:flutter/foundation.dart';

class ItemDetailViewModel extends ChangeNotifier {
  final AuthRepository _repository;
  final ApiService _apiService;
  final int companyId;
  final int itemId;

  ItemResponse? _itemResponse;
  String? _currentImageUrl;
  Uint8List? _currentImageBytes;

  bool _isLoading = false;
  bool _isLoadingImage = false;
  String? _errorMessage;

  ItemResponse? get itemResponse => _itemResponse;
  Uint8List? get currentImageBytes => _currentImageBytes;
  bool get isLoading => _isLoading;
  bool get isLoadingImage => _isLoadingImage;
  String? get errorMessage => _errorMessage;

  ItemDetailViewModel({
    required this.companyId,
    required this.itemId,
    required AuthRepository repository,
    required ApiService apiService,
  }) : _repository = repository,
       _apiService = apiService;

  Future<void> loadItemDetail() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _repository.fetchItemDetail(companyId, itemId);
      _itemResponse = response;

      final item = response.responseData;

      // FIXED: Removed non-existent preferredVendorId - using only itemImage
      _currentImageUrl = item.itemImage?.isNotEmpty == true
          ? _repository.getFileUrl(item.itemImage!)
          : null;

      // Load image if available
      if (_currentImageUrl != null) {
        await _loadImageBytes();
      }
    } on Exception catch (e) {
      debugPrint('ItemDetailViewModel.loadItemDetail error: $e');
      _errorMessage = e.toString();
      _currentImageUrl = null;
      _currentImageBytes = null;
    } catch (e, s) {
      debugPrint('ItemDetailViewModel.loadItemDetail unexpected error: $e\n$s');
      _errorMessage = 'Something went wrong';
      _currentImageUrl = null;
      _currentImageBytes = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshImage() async {
    if (_itemResponse == null) return;

    final item = _itemResponse!.responseData;

    // FIXED: Simplified - using only itemImage
    _currentImageUrl = item.itemImage?.isNotEmpty == true
        ? _repository.getFileUrl(item.itemImage!)
        : null;

    _currentImageBytes = null;
    notifyListeners();

    if (_currentImageUrl != null) {
      await _loadImageBytes();
    }
  }

  Future<void> _loadImageBytes() async {
    if (_currentImageUrl == null) return;

    _isLoadingImage = true;
    notifyListeners();

    try {
      final imageResponse = await _apiService.get(Uri.parse(_currentImageUrl!));
      if (imageResponse.statusCode == 200) {
        _currentImageBytes = imageResponse.bodyBytes;
      } else {
        debugPrint('Image load failed: ${imageResponse.statusCode}');
        _currentImageBytes = null;
      }
    } catch (e) {
      debugPrint('Image load error: $e');
      _currentImageBytes = null;
    } finally {
      _isLoadingImage = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await loadItemDetail();
  }

  Future<bool> activateItem() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _repository.activateItem(companyId, itemId);
      if (response != null && response.responseStatus) {
        return true;
      } else {
        _errorMessage = response?.responseMessage ?? 'Failed to activate item';
      }
    } catch (e) {
      debugPrint('ItemDetailViewModel.activateItem error: $e');
      _errorMessage = 'Failed to activate item';
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    return false;
  }

  Future<bool> deactivateItem() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _repository.deactivateItem(companyId, itemId);
      if (response != null && response.responseStatus) {
        return true;
      } else {
        _errorMessage = response?.responseMessage ?? 'Failed to deactivate item';
      }
    } catch (e) {
      debugPrint('ItemDetailViewModel.deactivateItem error: $e');
      _errorMessage = 'Failed to deactivate item';
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    return false;
  }

  @override
  void dispose() {
    _currentImageBytes = null;
    _itemResponse = null;
    super.dispose();
  }
}
