import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:coreflow/core/config/app_config.dart';
import 'package:coreflow/data/services/api_services.dart';
import 'package:coreflow/domain/model/items/item.dart';

class ItemsViewModel extends ChangeNotifier {
  final ApiService _apiService;
  final int companyId;

  ItemsViewModel({required ApiService apiService, required this.companyId})
    : _apiService = apiService;

  List<Item> _items = [];
  List<Item> _filteredItems = [];

  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  List<Item> get items => List.unmodifiable(_items);
  List<Item> get filteredItems => List.unmodifiable(_filteredItems);

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  Future<void> fetchItems() async {
    _setLoading(true);
    _setError(null);

    try {
      final fetchedItems = await _getItems(companyId);
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
    if (_searchQuery.isEmpty) {
      _filteredItems = List.from(_items);
      return;
    }

    _filteredItems = _items.where((item) {
      final nameMatch = item.itemName.toLowerCase().contains(_searchQuery);
      final idMatch = item.itemId.toString().contains(_searchQuery);
      final unitMatch = item.unit.toLowerCase().contains(_searchQuery);
      final typeMatch = item.itemType.toLowerCase().contains(_searchQuery);

      return nameMatch || idMatch || unitMatch || typeMatch;
    }).toList();
  }

  Future<List<Item>> _getItems(int companyId) async {
    try {
      final url = AppConfig.getItemsUrl(companyId);
      debugPrint('GET → $url');

      final response = await _apiService.get(Uri.parse(url));
      debugPrint('Response status: ${response.statusCode}');

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (body['responseStatus'] != true) {
        throw Exception(body['responseMessage'] ?? 'Unknown API error');
      }

      final List<dynamic> data = body['responseData'] as List<dynamic>? ?? [];

      final items = data
          .map((e) => Item.fromJson(e as Map<String, dynamic>))
          .toList();

      debugPrint('Parsed ${items.length} items');
      return items;
    } catch (e, stack) {
      debugPrint('API call failed: $e\n$stack');
      rethrow;
    }
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
