import 'dart:convert';
import 'package:coreflow/data/services/api_services.dart';
import 'package:coreflow/domain/model/employee_model/create_employee_request.dart';
import 'package:coreflow/domain/model/employee_model/employee.dart';
import 'package:coreflow/domain/model/employee_model/employee_detail.dart';
import 'package:coreflow/domain/model/employee_model/employee_edit_request.dart';
import 'package:coreflow/domain/model/employee_model/employee_edit_response.dart';
import 'package:coreflow/domain/model/employee_model/employee_status_response.dart';
import 'package:flutter/material.dart';
import '../../../core/config/app_config.dart';

class EmployeeRepository {
  final ApiService _apiService = ApiService();

  Future<List<Employee>> getEmployees(int companyId, {bool? activeOnly}) async {
    try {
      final url = AppConfig.getEmployeesUrl(companyId, activeOnly: activeOnly);
      final response = await _apiService.get(Uri.parse(url));

      if (response.statusCode != 200) return [];

      final Map<String, dynamic> decodedBody = jsonDecode(response.body);

      if (decodedBody['responseStatus'] != true) return [];

      final List<dynamic> data = decodedBody['responseData'] ?? [];
      return data.map((json) => Employee.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Get employees error: $e');
      return [];
    }
  }

  Future<EmployeeDetailData?> getEmployeeDetail(
    int companyId,
    int employeeId,
  ) async {
    try {
      final response = await _apiService.get(
        Uri.parse(AppConfig.getEmployeeDetailUrl(companyId, employeeId)),
      );

      if (response.statusCode == 420) {
        debugPrint('Employee inactive (420): ID $employeeId');
        return null;
      }

      if (response.statusCode != 200) {
        debugPrint('Employee detail failed: ${response.statusCode}');
        return null;
      }

      final data = jsonDecode(response.body);
      final detailResponse = EmployeeDetailResponse.fromJson(data);

      return detailResponse.responseStatus
          ? detailResponse.responseData
          : null;
    } catch (e) {
      debugPrint('Get employee detail error: $e');
      return null;
    }
  }

  Future<EmployeeEditResponse?> createEmployee(
    int companyId,
    CreateEmployeeRequest request,
  ) async {
    try {
      final response = await _apiService.post(
        AppConfig.getCreateEmployeeUrl(companyId),
        request.toJson(),
      );

      if (response.statusCode != 200 && response.statusCode != 201) return null;

      final data = jsonDecode(response.body);
      return EmployeeEditResponse(
        responseStatus: data['responseStatus'] ?? false,
        responseCode: data['responseCode'],
        responseMessage: data['responseMessage'] ?? '',
        responseData: data['responseData'],
      );
    } catch (e) {
      debugPrint('Create employee error: $e');
      return null;
    }
  }

  Future<EmployeeEditResponse?> updateEmployee(
    int companyId,
    int employeeId,
    EmployeeEditRequest request,
  ) async {
    try {
      final response = await _apiService.put(
        AppConfig.getUpdateEmployeeUrl(companyId, employeeId),
        request.toJson(),
      );

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body);
      return EmployeeEditResponse(
        responseStatus: data['responseStatus'] ?? false,
        responseCode: data['responseCode'],
        responseMessage: data['responseMessage'] ?? '',
        responseData: data['responseData'],
      );
    } catch (e) {
      debugPrint('Update employee error: $e');
      return null;
    }
  }

  Future<EmployeeStatusResponse?> deactivateEmployee(
    int companyId,
    int employeeId,
  ) async {
    try {
      final response = await _apiService.patch(
        AppConfig.getDeactivateEmployeeUrl(companyId, employeeId),
        {},
      );

      if (response.statusCode != 200 && response.statusCode != 203) {
        debugPrint('Deactivate failed: ${response.statusCode}');
        return null;
      }

      final data = jsonDecode(response.body);
      return EmployeeStatusResponse.fromJson(data);
    } catch (e) {
      debugPrint('Deactivate employee error: $e');
      return null;
    }
  }
}
