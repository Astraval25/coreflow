import 'dart:convert';
import 'dart:io';
import 'package:coreflow/data/services/api_services.dart';
import 'package:coreflow/domain/model/main_model/items/create_item_request.dart';
import 'package:coreflow/domain/model/main_model/items/detail_item.dart';
import 'package:coreflow/domain/model/main_model/items/item.dart';
import 'package:coreflow/domain/model/main_model/items/item_status_response.dart';
import 'package:coreflow/domain/model/main_model/items/update_item_request.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../core/config/app_config.dart';

class ItemRepository {
  final ApiService _apiService = ApiService();

  Future<List<Item>> getItems(int companyId) async {
    try {
      final url = AppConfig.getItemsUrl(companyId);
      final response = await _apiService.get(Uri.parse(url));

      // debugPrint('GET /items response status: ${response.statusCode}');

      if (response.statusCode != 200) {
        debugPrint('Get items failed: ${response.statusCode}');
        return [];
      }

      final Map<String, dynamic> decodedBody =
          jsonDecode(response.body) as Map<String, dynamic>;

      final bool? responseStatus = decodedBody['responseStatus'];
      if (responseStatus != true) {
        debugPrint(
          'Get items responseStatus false: ${decodedBody['responseMessage']}',
        );
        return [];
      }

      final List<dynamic> data = decodedBody['responseData'] ?? [];
      final List<Item> items = data.map((json) => Item.fromJson(json)).toList();

      return items;
    } catch (e, stack) {
      debugPrint('Get items error: $e\n$stack');
      return [];
    }
  }

  Future<ItemResponse> fetchItemDetail(int companyId, int itemId) async {
    final url = AppConfig.getItemDetailUrl(companyId, itemId);
    final response = await _apiService.get(Uri.parse(url));

    debugPrint(
      'Item detail response: ${response.statusCode} → ${response.body}',
    );

    if (response.statusCode == 200) {
      final jsonMap = json.decode(response.body) as Map<String, dynamic>;
      return ItemResponse.fromJson(jsonMap);
    } else {
      throw Exception(
        'Failed to load item detail: ${response.statusCode} - ${response.body}',
      );
    }
  }

  String getFileUrl(String fsId) => AppConfig.getFileUrl(fsId);

  Future<http.Response> createItem({
    required int companyId,
    required CreateItemRequest request,
    required String token,
    File? imageFile,
  }) async {
    final uri = Uri.parse(AppConfig.getItemsUrl(companyId));

    final multipartRequest = http.MultipartRequest('POST', uri);

    multipartRequest.headers['Authorization'] = 'Bearer $token';

    multipartRequest.fields['item'] = jsonEncode(request.toJson());

    if (imageFile != null) {
      multipartRequest.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );
    }

    final streamedResponse = await multipartRequest.send();
    return await http.Response.fromStream(streamedResponse);
  }

  Future<http.Response> updateItem({
    required int companyId,
    required int itemId,
    required UpdateItemRequest request,
    required String token,
    File? imageFile,
  }) async {
    final uri = Uri.parse(AppConfig.getItemDetailUrl(companyId, itemId));

    final multipartRequest = http.MultipartRequest('PUT', uri);

    multipartRequest.headers['Authorization'] = 'Bearer $token';

    multipartRequest.fields['item'] = jsonEncode(request.toJson());

    if (imageFile != null) {
      multipartRequest.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );
    }

    final streamedResponse = await multipartRequest.send();
    return await http.Response.fromStream(streamedResponse);
  }

  Future<ItemStatusResponse?> activateItem(int companyId, int itemId) async {
    try {
      final response = await _apiService.patch(
        AppConfig.getItemActivateUrl(companyId, itemId),
        {},
      );

      if (response.statusCode != 200 && response.statusCode != 203) {
        debugPrint('Activate item failed: ${response.statusCode}');
        return null;
      }

      final data = jsonDecode(response.body);
      return ItemStatusResponse.fromJson(data);
    } catch (e) {
      debugPrint('Activate item error: $e');
      return null;
    }
  }

  Future<ItemStatusResponse?> deactivateItem(int companyId, int itemId) async {
    try {
      final response = await _apiService.patch(
        AppConfig.getItemDeactivateUrl(companyId, itemId),
        {},
      );

      if (response.statusCode != 200 && response.statusCode != 203) {
        debugPrint('Deactivate item failed: ${response.statusCode}');
        return null;
      }

      final data = jsonDecode(response.body);
      return ItemStatusResponse.fromJson(data);
    } catch (e) {
      debugPrint('Deactivate item error: $e');
      return null;
    }
  }
}
