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

  // ── Core data ────────────────────────────────────────────────────────────────
  List<Item> _items = [];
  List<Item> _filteredItems = [];

  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  // ── Getters ──────────────────────────────────────────────────────────────────
  List<Item> get items => List.unmodifiable(_items);
  List<Item> get filteredItems => List.unmodifiable(_filteredItems);

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  // ── Fetch / Refresh ──────────────────────────────────────────────────────────
  Future<void> fetchItems() async {
    _setLoading(true);
    _setError(null);

    try {
      final fetched = await _getItems(companyId);
      _items = fetched;
      _applyFilter(); // important: re-apply current search after fetch
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

  // ── Search / Filter ──────────────────────────────────────────────────────────
  void filterItems(String query) {
    _searchQuery = query.trim().toLowerCase();
    _applyFilter();
    notifyListeners();
  }

  void clearSearch() {
    filterItems('');
  }

  void _applyFilter() {
    if (_searchQuery.isEmpty) {
      _filteredItems = List.from(_items);
    } else {
      _filteredItems = _items.where((item) {
        final nameMatch = item.itemName.toLowerCase().contains(_searchQuery);
        final idMatch = item.itemId.toString().contains(_searchQuery);
        final unitMatch = item.unit.toLowerCase().contains(_searchQuery);
        return nameMatch || idMatch || unitMatch;
      }).toList();
    }
  }

  // ── API Call ─────────────────────────────────────────────────────────────────
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
        final msg = body['responseMessage'] ?? 'Unknown error';
        throw Exception('API error: $msg');
      }

      final List<dynamic> data = body['responseData'] ?? [];
      final items = data
          .map((json) => Item.fromJson(json as Map<String, dynamic>))
          .toList();

      debugPrint('Parsed ${items.length} items');
      return items;
    } catch (e) {
      debugPrint('API call failed: $e');
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
