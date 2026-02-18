import 'package:coreflow/data/repositories/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:coreflow/domain/model/items/item.dart';

class ItemsViewModel extends ChangeNotifier {
  final AuthRepository _repository;
  final int companyId;

  ItemsViewModel({required AuthRepository repository, required this.companyId})
    : _repository = repository;

  List<Item> _items = [];
  List<Item> _filteredItems = [];

  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  bool _showActiveOnly = true;

  List<Item> get items => List.unmodifiable(_items);
  List<Item> get filteredItems => List.unmodifiable(_filteredItems);

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  bool get showActiveOnly => _showActiveOnly;

  int get activeItemCount => _items.where((item) => item.isActive).length;
  int get inactiveItemCount => _items.where((item) => !item.isActive).length;

  void toggleActiveFilter() {
    _showActiveOnly = !_showActiveOnly;
    _applyFilter();
    notifyListeners();
  }

  Future<void> fetchItems() async {
    _setLoading(true);
    _setError(null);

    try {
      final fetchedItems = await _repository.getItems(companyId);
      _items = fetchedItems;
      _applyFilter();
    } catch (e, stack) {
      debugPrint('fetchItems failed: $e\n$stack');
      _setError('Failed to load items. Please try again.');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refresh() async {
    await fetchItems();
  }

  Future<void> toggleItemStatus(int itemId, bool currentStatus) async {
    _setError(null);
    try {
      final response = currentStatus
          ? await _repository.deactivateItem(companyId, itemId)
          : await _repository.activateItem(companyId, itemId);

      if (response != null && response.responseStatus) {
        await fetchItems(); // Refresh the list
      } else {
        _setError(response?.responseMessage ?? 'Failed to update status');
      }
    } catch (e) {
      debugPrint('toggleItemStatus error: $e');
      _setError('Failed to update status');
    }
  }

  void filterItems(String query) {
    _searchQuery = query.trim().toLowerCase();
    _applyFilter();
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    // 1. Filter by status
    Iterable<Item> list = _items.where((item) => item.isActive == _showActiveOnly);

    // 2. Filter by search query if present
    if (_searchQuery.isNotEmpty) {
      list = list.where((item) {
        final nameMatch = item.itemName.toLowerCase().contains(_searchQuery);
        final idMatch = item.itemId.toString().contains(_searchQuery);
        final unitMatch = item.unit.toLowerCase().contains(_searchQuery);
        final typeMatch = item.itemType.toLowerCase().contains(_searchQuery);
        return nameMatch || idMatch || unitMatch || typeMatch;
      });
    }

    _filteredItems = list.toList();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }
}
