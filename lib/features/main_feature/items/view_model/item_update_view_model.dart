import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:coreflow/data/services/api_services.dart';
import 'package:coreflow/domain/model/main_model/items/update_item_request.dart';
import 'package:coreflow/core/config/app_config.dart';

class UpdateItemViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool isLoading = false;
  bool isSuccess = false;
  String? errorMessage;

  void resetState({bool notify = true}) {
    final hasChanges = isLoading || isSuccess || errorMessage != null;

    isLoading = false;
    isSuccess = false;
    errorMessage = null;

    if (notify && hasChanges) {
      notifyListeners();
    }
  }

  String getFileUrl(String fsId) => AppConfig.getFileUrl(fsId);

  Future<void> updateItem({
    required int companyId,
    required int itemId,
    required UpdateItemRequest request,
    File? imageFile,
  }) async {
    isLoading = true;
    isSuccess = false;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.updateItem(
        companyId: companyId,
        itemId: itemId,
        itemData: request.toJson(),
        imageFile: imageFile,
      );

      final decoded = _safeDecode(response.body);
      final isHttpSuccess =
          response.statusCode >= 200 && response.statusCode < 300;
      final backendStatus = decoded?['responseStatus'];
      final isBusinessSuccess = backendStatus is bool
          ? backendStatus
          : isHttpSuccess;

      if (isHttpSuccess && isBusinessSuccess) {
        isSuccess = true;
      } else {
        isSuccess = false;
        errorMessage =
            decoded?['responseMessage'] ??
            decoded?['message'] ??
            'Failed to update item: ${response.statusCode}';
      }
    } catch (e) {
      isSuccess = false;
      errorMessage = 'Error updating item: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Map<String, dynamic>? _safeDecode(String body) {
    try {
      return jsonDecode(body);
    } catch (_) {
      return null;
    }
  }
}
