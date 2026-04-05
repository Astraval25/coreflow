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

      if (response.statusCode == 200 || response.statusCode == 201) {
        isSuccess = true;
      } else {
        isSuccess = false;
        errorMessage = 'Failed to update item: ${response.statusCode}';
      }
    } catch (e) {
      isSuccess = false;
      errorMessage = 'Error updating item: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
