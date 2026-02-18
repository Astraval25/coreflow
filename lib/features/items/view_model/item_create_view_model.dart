import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:coreflow/data/services/api_services.dart';
import 'package:coreflow/domain/model/items/create_item_request.dart';

class CreateItemViewModel extends ChangeNotifier {
  final ApiService _apiService;

  CreateItemViewModel({required ApiService apiService})
    : _apiService = apiService;

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  bool _isSuccess = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get isSuccess => _isSuccess;

  // ==========================================================
  // CREATE ITEM
  // ==========================================================
  Future<void> createItem({
    required int companyId,
    required CreateItemRequest request,
    File? imageFile,
  }) async {
    if (_isLoading) return;

    _setLoading(true);
    _clearMessages();

    try {
      final response = await _apiService.createItem(
        companyId: companyId,
        itemData: request.toJson(),
        imageFile: imageFile,
      );

      // Try decoding backend JSON safely
      final decoded = _safeDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        _isSuccess = true;
        _successMessage =
            decoded?['responseMessage'] ??
            decoded?['message'] ??
            "Item created successfully";
      } else {
        // Show backend message if available
        String backendMessage =
            decoded?['responseMessage'] ??
            decoded?['message'] ??
            "Server returned status ${response.statusCode}";

        _errorMessage = backendMessage;
      }
    } on SocketException {
      _errorMessage = "No internet connection. Please check your network.";
    } on HttpException catch (e) {
      _errorMessage = "HTTP error: ${e.message}";
    } on FormatException {
      _errorMessage = "Invalid response format from server.";
    } catch (e) {
      _errorMessage = "Unexpected error: ${e.toString()}";
    }

    _setLoading(false);
  }

  // ==========================================================
  // UPDATE ITEM
  // ==========================================================
  Future<void> updateItem({
    required int companyId,
    required int itemId,
    required Map<String, dynamic> itemData,
    File? imageFile,
  }) async {
    if (_isLoading) return;

    _setLoading(true);
    _clearMessages();

    try {
      final response = await _apiService.updateItem(
        companyId: companyId,
        itemId: itemId,
        itemData: itemData,
        imageFile: imageFile,
      );

      // Try decoding backend JSON safely
      final decoded = _safeDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        _isSuccess = true;
        _successMessage =
            decoded?['responseMessage'] ??
            decoded?['message'] ??
            "Item updated successfully";
      } else {
        // Show backend message if available
        String backendMessage =
            decoded?['responseMessage'] ??
            decoded?['message'] ??
            "Server returned status ${response.statusCode}";

        _errorMessage = backendMessage;
      }
    } on SocketException {
      _errorMessage = "No internet connection. Please check your network.";
    } on HttpException catch (e) {
      _errorMessage = "HTTP error: ${e.message}";
    } on FormatException {
      _errorMessage = "Invalid response format from server.";
    } catch (e) {
      _errorMessage = "Unexpected error: ${e.toString()}";
    }

    _setLoading(false);
  }

  // ==========================================================
  // HELPERS
  // ==========================================================
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    _isSuccess = false;
  }

  Map<String, dynamic>? _safeDecode(String body) {
    try {
      return jsonDecode(body);
    } catch (_) {
      return null;
    }
  }

  void resetState() {
    final hasMessagesOrSuccess =
        _errorMessage != null || _successMessage != null || _isSuccess;
    _clearMessages();
    if (hasMessagesOrSuccess) {
      notifyListeners();
    }
  }
}
