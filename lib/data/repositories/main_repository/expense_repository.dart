import 'dart:convert';

import 'package:coreflow/core/config/app_config.dart';
import 'package:coreflow/data/services/api_services.dart';
import 'package:coreflow/domain/model/main_model/expense/expense.dart';
import 'package:coreflow/domain/model/main_model/expense/expense_account.dart';
import 'package:coreflow/domain/model/main_model/expense/expense_requests.dart';
import 'package:flutter/material.dart';

class ExpenseMutationResult {
  final bool success;
  final String message;
  final int? entityId;

  const ExpenseMutationResult({
    required this.success,
    required this.message,
    this.entityId,
  });
}

class ExpenseRepository {
  final ApiService _apiService = ApiService();

  Future<List<String>> getExpenseAccountTypes(int companyId) async {
    try {
      final response = await _apiService.get(
        Uri.parse(AppConfig.getExpenseAccountTypesUrl(companyId)),
      );
      final decoded = _decode(response);
      if (!_isSuccess(response.statusCode, decoded)) return [];

      final responseData = decoded['responseData'];
      if (responseData is! List) return [];
      return responseData.map((e) => e.toString()).toList(growable: false);
    } catch (e) {
      debugPrint('Get expense account types error: $e');
      return [];
    }
  }

  Future<ExpenseMutationResult> createExpenseAccount(
    int companyId,
    ExpenseAccountRequest request,
  ) async {
    try {
      final response = await _apiService.post(
        AppConfig.getExpenseAccountsUrl(companyId),
        request.toJson(),
      );
      final decoded = _decode(response);
      final success = _isSuccess(response.statusCode, decoded);
      final message = _message(
        decoded,
        fallback: success
            ? 'Expense account created successfully'
            : 'Failed to create expense account',
      );
      final id = _extractEntityId(decoded['responseData'], 'expenseAccountId');
      return ExpenseMutationResult(
        success: success,
        message: message,
        entityId: id,
      );
    } catch (e) {
      debugPrint('Create expense account error: $e');
      return const ExpenseMutationResult(
        success: false,
        message: 'Failed to create expense account',
      );
    }
  }

  Future<List<ExpenseAccount>> getExpenseAccounts(
    int companyId, {
    bool? activeOnly,
  }) async {
    try {
      final response = await _apiService.get(
        Uri.parse(
          AppConfig.getExpenseAccountsUrl(companyId, activeOnly: activeOnly),
        ),
      );
      final decoded = _decode(response);
      if (!_isSuccess(response.statusCode, decoded)) return [];
      return _parseList(decoded['responseData'], ExpenseAccount.fromJson);
    } catch (e) {
      debugPrint('Get expense accounts error: $e');
      return [];
    }
  }

  Future<ExpenseAccount?> getExpenseAccountDetail(
    int companyId,
    int expenseAccountId,
  ) async {
    try {
      final response = await _apiService.get(
        Uri.parse(
          AppConfig.getExpenseAccountDetailUrl(companyId, expenseAccountId),
        ),
      );
      final decoded = _decode(response);
      if (!_isSuccess(response.statusCode, decoded)) return null;
      final responseData = decoded['responseData'];
      if (responseData is! Map<String, dynamic>) return null;
      return ExpenseAccount.fromJson(responseData);
    } catch (e) {
      debugPrint('Get expense account detail error: $e');
      return null;
    }
  }

  Future<ExpenseMutationResult> updateExpenseAccount(
    int companyId,
    int expenseAccountId,
    ExpenseAccountRequest request,
  ) async {
    try {
      final response = await _apiService.put(
        AppConfig.getExpenseAccountDetailUrl(companyId, expenseAccountId),
        request.toJson(),
      );
      final decoded = _decode(response);
      final success = _isSuccess(response.statusCode, decoded);
      final message = _message(
        decoded,
        fallback: success
            ? 'Expense account updated successfully'
            : 'Failed to update expense account',
      );
      return ExpenseMutationResult(
        success: success,
        message: message,
        entityId: expenseAccountId,
      );
    } catch (e) {
      debugPrint('Update expense account error: $e');
      return const ExpenseMutationResult(
        success: false,
        message: 'Failed to update expense account',
      );
    }
  }

  Future<ExpenseMutationResult> activateExpenseAccount(
    int companyId,
    int expenseAccountId,
  ) async {
    return _toggleExpenseAccount(
      companyId: companyId,
      expenseAccountId: expenseAccountId,
      activate: true,
    );
  }

  Future<ExpenseMutationResult> deactivateExpenseAccount(
    int companyId,
    int expenseAccountId,
  ) async {
    return _toggleExpenseAccount(
      companyId: companyId,
      expenseAccountId: expenseAccountId,
      activate: false,
    );
  }

  Future<ExpenseMutationResult> _toggleExpenseAccount({
    required int companyId,
    required int expenseAccountId,
    required bool activate,
  }) async {
    try {
      final url = activate
          ? AppConfig.getExpenseAccountActivateUrl(companyId, expenseAccountId)
          : AppConfig.getExpenseAccountDeactivateUrl(
              companyId,
              expenseAccountId,
            );
      final response = await _apiService.patch(url, const {});
      final decoded = _decode(response);
      final success = _isSuccess(response.statusCode, decoded);
      final fallback = activate
          ? 'Failed to activate expense account'
          : 'Failed to deactivate expense account';
      return ExpenseMutationResult(
        success: success,
        message: _message(decoded, fallback: fallback),
        entityId: expenseAccountId,
      );
    } catch (e) {
      debugPrint('Toggle expense account error: $e');
      return ExpenseMutationResult(
        success: false,
        message: activate
            ? 'Failed to activate expense account'
            : 'Failed to deactivate expense account',
      );
    }
  }

  Future<ExpenseMutationResult> createExpense(
    int companyId,
    ExpenseRequest request,
  ) async {
    try {
      final response = await _apiService.post(
        AppConfig.getExpensesUrl(companyId),
        request.toJson(),
      );
      final decoded = _decode(response);
      final success = _isSuccess(response.statusCode, decoded);
      final message = _message(
        decoded,
        fallback: success
            ? 'Expense created successfully'
            : 'Failed to create expense',
      );
      final id = _extractEntityId(decoded['responseData'], 'expenseId');
      return ExpenseMutationResult(
        success: success,
        message: message,
        entityId: id,
      );
    } catch (e) {
      debugPrint('Create expense error: $e');
      return const ExpenseMutationResult(
        success: false,
        message: 'Failed to create expense',
      );
    }
  }

  Future<List<Expense>> getExpenses(int companyId, {bool? activeOnly}) async {
    try {
      final response = await _apiService.get(
        Uri.parse(AppConfig.getExpensesUrl(companyId, activeOnly: activeOnly)),
      );
      final decoded = _decode(response);
      if (!_isSuccess(response.statusCode, decoded)) return [];
      return _parseList(decoded['responseData'], Expense.fromJson);
    } catch (e) {
      debugPrint('Get expenses error: $e');
      return [];
    }
  }

  Future<Expense?> getExpenseDetail(int companyId, int expenseId) async {
    try {
      final response = await _apiService.get(
        Uri.parse(AppConfig.getExpenseDetailUrl(companyId, expenseId)),
      );
      final decoded = _decode(response);
      if (!_isSuccess(response.statusCode, decoded)) return null;
      final responseData = decoded['responseData'];
      if (responseData is! Map<String, dynamic>) return null;
      return Expense.fromJson(responseData);
    } catch (e) {
      debugPrint('Get expense detail error: $e');
      return null;
    }
  }

  Future<ExpenseMutationResult> updateExpense(
    int companyId,
    int expenseId,
    ExpenseRequest request,
  ) async {
    try {
      final response = await _apiService.put(
        AppConfig.getExpenseDetailUrl(companyId, expenseId),
        request.toJson(),
      );
      final decoded = _decode(response);
      final success = _isSuccess(response.statusCode, decoded);
      final message = _message(
        decoded,
        fallback: success
            ? 'Expense updated successfully'
            : 'Failed to update expense',
      );
      return ExpenseMutationResult(
        success: success,
        message: message,
        entityId: expenseId,
      );
    } catch (e) {
      debugPrint('Update expense error: $e');
      return const ExpenseMutationResult(
        success: false,
        message: 'Failed to update expense',
      );
    }
  }

  Future<ExpenseMutationResult> activateExpense(
    int companyId,
    int expenseId,
  ) async {
    return _toggleExpense(
      companyId: companyId,
      expenseId: expenseId,
      activate: true,
    );
  }

  Future<ExpenseMutationResult> deactivateExpense(
    int companyId,
    int expenseId,
  ) async {
    return _toggleExpense(
      companyId: companyId,
      expenseId: expenseId,
      activate: false,
    );
  }

  Future<ExpenseMutationResult> _toggleExpense({
    required int companyId,
    required int expenseId,
    required bool activate,
  }) async {
    try {
      final url = activate
          ? AppConfig.getExpenseActivateUrl(companyId, expenseId)
          : AppConfig.getExpenseDeactivateUrl(companyId, expenseId);
      final response = await _apiService.patch(url, const {});
      final decoded = _decode(response);
      final success = _isSuccess(response.statusCode, decoded);
      final fallback = activate
          ? 'Failed to activate expense'
          : 'Failed to deactivate expense';
      return ExpenseMutationResult(
        success: success,
        message: _message(decoded, fallback: fallback),
        entityId: expenseId,
      );
    } catch (e) {
      debugPrint('Toggle expense error: $e');
      return ExpenseMutationResult(
        success: false,
        message: activate
            ? 'Failed to activate expense'
            : 'Failed to deactivate expense',
      );
    }
  }

  Map<String, dynamic> _decode(dynamic response) {
    if (response == null) return <String, dynamic>{};
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
      return <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  bool _isSuccess(int statusCode, Map<String, dynamic> body) {
    if (statusCode < 200 || statusCode >= 300) return false;
    if (body.isEmpty) return true;
    if (!body.containsKey('responseStatus')) return true;
    return body['responseStatus'] == true;
  }

  String _message(Map<String, dynamic> body, {required String fallback}) {
    final msg = body['responseMessage']?.toString();
    if (msg == null || msg.trim().isEmpty) return fallback;
    return msg.trim();
  }

  int? _extractEntityId(dynamic data, String key) {
    if (data is Map<String, dynamic>) {
      return _toInt(data[key]);
    }
    return _toInt(data);
  }

  List<T> _parseList<T>(dynamic raw, T Function(Map<String, dynamic>) parser) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(parser)
        .toList(growable: false);
  }

  int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }
}
