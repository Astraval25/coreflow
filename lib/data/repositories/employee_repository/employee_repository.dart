import 'dart:convert';
import 'dart:typed_data';

import 'package:coreflow/data/services/api_services.dart';
import 'package:coreflow/domain/model/employee_model/create_employee_request.dart';
import 'package:coreflow/domain/model/employee_model/employee.dart';
import 'package:coreflow/domain/model/employee_model/employee_auth_models.dart';
import 'package:coreflow/domain/model/employee_model/employee_detail.dart';
import 'package:coreflow/domain/model/employee_model/employee_edit_request.dart';
import 'package:coreflow/domain/model/employee_model/employee_edit_response.dart';
import 'package:coreflow/domain/model/employee_model/employee_module_models.dart';
import 'package:coreflow/domain/model/employee_model/employee_status_response.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../core/config/app_config.dart';

class EmployeeRepository {
  final ApiService _apiService = ApiService();

  Future<List<Employee>> getEmployees(int companyId, {bool? activeOnly}) async {
    try {
      final response = await _apiService.get(
        Uri.parse(AppConfig.getEmployeesUrl(companyId, activeOnly: activeOnly)),
      );
      return _parseList(response, Employee.fromJson);
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
      if (response.statusCode == 420) return null;
      return _parseData(response, EmployeeDetailData.fromJson);
    } catch (e) {
      debugPrint('Get employee detail error: $e');
      return null;
    }
  }

  Future<EmployeeEditResponse?> createEmployee(
    int companyId,
    CreateEmployeeRequest request,
  ) async {
    return _postEditResponse(
      AppConfig.getCreateEmployeeUrl(companyId),
      request.toJson(),
      debugLabel: 'Create employee',
    );
  }

  Future<EmployeeEditResponse?> updateEmployee(
    int companyId,
    int employeeId,
    EmployeeEditRequest request,
  ) async {
    return _putEditResponse(
      AppConfig.getUpdateEmployeeUrl(companyId, employeeId),
      request.toJson(),
      debugLabel: 'Update employee',
    );
  }

  Future<EmployeeStatusResponse?> deactivateEmployee(
    int companyId,
    int employeeId,
  ) async {
    return _patchStatusResponse(
      AppConfig.getDeactivateEmployeeUrl(companyId, employeeId),
      const {},
      debugLabel: 'Deactivate employee',
    );
  }

  Future<EmployeeEditResponse?> createSalaryConfig(
    int companyId,
    int employeeId,
    CreateSalaryConfigRequest request,
  ) async {
    return _postEditResponse(
      AppConfig.getEmployeeSalaryConfigUrl(companyId, employeeId),
      request.toJson(),
      debugLabel: 'Create salary config',
    );
  }

  Future<SalaryConfigData?> getActiveSalaryConfig(
    int companyId,
    int employeeId,
  ) async {
    try {
      final response = await _apiService.get(
        Uri.parse(AppConfig.getEmployeeSalaryConfigUrl(companyId, employeeId)),
      );
      return _parseData(response, SalaryConfigData.fromJson);
    } catch (e) {
      debugPrint('Get active salary config error: $e');
      return null;
    }
  }

  Future<List<SalaryConfigData>> getSalaryConfigHistory(
    int companyId,
    int employeeId,
  ) async {
    try {
      final response = await _apiService.get(
        Uri.parse(
          AppConfig.getEmployeeSalaryConfigHistoryUrl(companyId, employeeId),
        ),
      );
      return _parseList(response, SalaryConfigData.fromJson);
    } catch (e) {
      debugPrint('Get salary config history error: $e');
      return [];
    }
  }

  Future<EmployeeEditResponse?> createPortalUser(
    int companyId,
    int employeeId,
    CreatePortalUserRequest request,
  ) async {
    return _postEditResponse(
      AppConfig.getEmployeePortalUserUrl(companyId, employeeId),
      request.toJson(),
      debugLabel: 'Create portal user',
    );
  }

  Future<PortalUserData?> getPortalUser(int companyId, int employeeId) async {
    try {
      final response = await _apiService.get(
        Uri.parse(AppConfig.getEmployeePortalUserUrl(companyId, employeeId)),
      );
      return _parseData(response, PortalUserData.fromJson);
    } catch (e) {
      debugPrint('Get portal user error: $e');
      return null;
    }
  }

  Future<EmployeeStatusResponse?> resetPortalUserPassword(
    int companyId,
    int employeeId,
    ResetPortalPasswordRequest request,
  ) async {
    return _patchStatusResponse(
      AppConfig.getEmployeePortalUserResetPasswordUrl(companyId, employeeId),
      request.toJson(),
      debugLabel: 'Reset portal password',
    );
  }

  Future<EmployeeEditResponse?> createWorkDefinition(
    int companyId,
    CreateWorkDefinitionRequest request,
  ) async {
    return _postEditResponse(
      AppConfig.getWorkDefinitionsUrl(companyId),
      request.toJson(),
      debugLabel: 'Create work definition',
    );
  }

  Future<List<WorkDefinitionData>> getWorkDefinitions(
    int companyId, {
    bool? activeOnly,
  }) async {
    try {
      final response = await _apiService.get(
        Uri.parse(
          AppConfig.getWorkDefinitionsUrl(companyId, activeOnly: activeOnly),
        ),
      );
      return _parseList(response, WorkDefinitionData.fromJson);
    } catch (e) {
      debugPrint('Get work definitions error: $e');
      return [];
    }
  }

  Future<WorkDefinitionData?> getWorkDefinitionDetail(
    int companyId,
    int workDefId,
  ) async {
    try {
      final response = await _apiService.get(
        Uri.parse(AppConfig.getWorkDefinitionDetailUrl(companyId, workDefId)),
      );
      return _parseData(response, WorkDefinitionData.fromJson);
    } catch (e) {
      debugPrint('Get work definition detail error: $e');
      return null;
    }
  }

  Future<EmployeeStatusResponse?> updateWorkDefinition(
    int companyId,
    int workDefId,
    UpdateWorkDefinitionRequest request,
  ) async {
    return _putStatusResponse(
      AppConfig.getWorkDefinitionDetailUrl(companyId, workDefId),
      request.toJson(),
      debugLabel: 'Update work definition',
    );
  }

  Future<EmployeeStatusResponse?> deactivateWorkDefinition(
    int companyId,
    int workDefId,
  ) async {
    return _patchStatusResponse(
      AppConfig.getDeactivateWorkDefinitionUrl(companyId, workDefId),
      const {},
      debugLabel: 'Deactivate work definition',
    );
  }

  Future<List<RateHistoryData>> getRateHistory(
    int companyId,
    int workDefId,
  ) async {
    try {
      final response = await _apiService.get(
        Uri.parse(
          AppConfig.getWorkDefinitionRateHistoryUrl(companyId, workDefId),
        ),
      );
      return _parseList(response, RateHistoryData.fromJson);
    } catch (e) {
      debugPrint('Get rate history error: $e');
      return [];
    }
  }

  Future<EmployeeEditResponse?> createWorkLog(
    int companyId,
    CreateWorkLogRequest request,
  ) async {
    return _postEditResponse(
      AppConfig.getWorkLogsUrl(companyId),
      request.toJson(),
      debugLabel: 'Create work log',
    );
  }

  Future<List<WorkLogData>> getWorkLogsByCompanyDateRange(
    int companyId, {
    String? from,
    String? to,
  }) async {
    try {
      final response = await _apiService.get(
        Uri.parse(AppConfig.getWorkLogsUrl(companyId, from: from, to: to)),
      );
      return _parseList(response, WorkLogData.fromJson);
    } catch (e) {
      debugPrint('Get work logs by company error: $e');
      return [];
    }
  }

  Future<List<WorkLogData>> getWorkLogsByEmployeeDateRange(
    int companyId,
    int employeeId, {
    String? from,
    String? to,
  }) async {
    try {
      final response = await _apiService.get(
        Uri.parse(
          AppConfig.getWorkLogsByEmployeeUrl(
            companyId,
            employeeId,
            from: from,
            to: to,
          ),
        ),
      );
      return _parseList(response, WorkLogData.fromJson);
    } catch (e) {
      debugPrint('Get work logs by employee error: $e');
      return [];
    }
  }

  Future<List<WorkLogData>> getPendingWorkLogs(int companyId) async {
    try {
      final response = await _apiService.get(
        Uri.parse(AppConfig.getPendingWorkLogsUrl(companyId)),
      );
      return _parseList(response, WorkLogData.fromJson);
    } catch (e) {
      debugPrint('Get pending work logs error: $e');
      return [];
    }
  }

  Future<EmployeeStatusResponse?> reviewWorkLog(
    int companyId,
    int logId,
    ReviewWorkLogRequest request,
  ) async {
    return _patchStatusResponse(
      AppConfig.getReviewWorkLogUrl(companyId, logId),
      request.toJson(),
      debugLabel: 'Review work log',
    );
  }

  Future<EmployeeEditResponse?> createLeaveLog(
    int companyId,
    CreateLeaveLogRequest request,
  ) async {
    return _postEditResponse(
      AppConfig.getLeaveLogsUrl(companyId),
      request.toJson(),
      debugLabel: 'Create leave log',
    );
  }

  Future<List<LeaveLogData>> getLeaveLogsByCompanyDateRange(
    int companyId, {
    String? from,
    String? to,
  }) async {
    try {
      final response = await _apiService.get(
        Uri.parse(AppConfig.getLeaveLogsUrl(companyId, from: from, to: to)),
      );
      return _parseList(response, LeaveLogData.fromJson);
    } catch (e) {
      debugPrint('Get leave logs by company error: $e');
      return [];
    }
  }

  Future<List<LeaveLogData>> getLeaveLogsByEmployeeDateRange(
    int companyId,
    int employeeId, {
    String? from,
    String? to,
  }) async {
    try {
      final response = await _apiService.get(
        Uri.parse(
          AppConfig.getLeaveLogsByEmployeeUrl(
            companyId,
            employeeId,
            from: from,
            to: to,
          ),
        ),
      );
      return _parseList(response, LeaveLogData.fromJson);
    } catch (e) {
      debugPrint('Get leave logs by employee error: $e');
      return [];
    }
  }

  Future<List<LeaveLogData>> getPendingLeaveLogs(int companyId) async {
    try {
      final response = await _apiService.get(
        Uri.parse(AppConfig.getPendingLeaveLogsUrl(companyId)),
      );
      return _parseList(response, LeaveLogData.fromJson);
    } catch (e) {
      debugPrint('Get pending leave logs error: $e');
      return [];
    }
  }

  Future<EmployeeStatusResponse?> reviewLeaveLog(
    int companyId,
    int leaveId,
    ReviewLeaveLogRequest request,
  ) async {
    return _patchStatusResponse(
      AppConfig.getReviewLeaveLogUrl(companyId, leaveId),
      request.toJson(),
      debugLabel: 'Review leave log',
    );
  }

  Future<EmployeeEditResponse?> calculateSalary(
    int companyId,
    CalculateSalaryRequest request,
  ) async {
    return _postEditResponse(
      AppConfig.getSalaryCalculateUrl(companyId),
      request.toJson(),
      debugLabel: 'Calculate salary',
    );
  }

  Future<List<SalaryPeriodSummary>> getSalaryPeriods(
    int companyId, {
    String? period,
  }) async {
    try {
      final response = await _apiService.get(
        Uri.parse(AppConfig.getSalaryPeriodsUrl(companyId, period: period)),
      );
      return _parseList(response, SalaryPeriodSummary.fromJson);
    } catch (e) {
      debugPrint('Get salary periods error: $e');
      return [];
    }
  }

  Future<SalaryPeriodDetailData?> getSalaryPeriodDetail(
    int companyId,
    int salaryPeriodId,
  ) async {
    try {
      final response = await _apiService.get(
        Uri.parse(
          AppConfig.getSalaryPeriodDetailUrl(companyId, salaryPeriodId),
        ),
      );
      return _parseData(response, SalaryPeriodDetailData.fromJson);
    } catch (e) {
      debugPrint('Get salary period detail error: $e');
      return null;
    }
  }

  Future<EmployeeStatusResponse?> approveSalaryPeriod(
    int companyId,
    int salaryPeriodId,
  ) async {
    return _patchStatusResponse(
      AppConfig.getApproveSalaryPeriodUrl(companyId, salaryPeriodId),
      const {},
      debugLabel: 'Approve salary period',
    );
  }

  Future<EmployeeStatusResponse?> markSalaryPeriodPaid(
    int companyId,
    int salaryPeriodId, {
    MarkSalaryPaidRequest? request,
  }) async {
    return _patchStatusResponse(
      AppConfig.getMarkSalaryPaidUrl(companyId, salaryPeriodId),
      request?.toJson() ?? const {},
      debugLabel: 'Mark salary paid',
    );
  }

  Future<SalaryReportData?> getSalaryReport(
    int companyId, {
    required String from,
    required String to,
  }) async {
    try {
      final response = await _apiService.get(
        Uri.parse(AppConfig.getSalaryReportUrl(companyId, from: from, to: to)),
      );
      return _parseData(response, SalaryReportData.fromJson);
    } catch (e) {
      debugPrint('Get salary report error: $e');
      return null;
    }
  }

  Future<Uint8List?> downloadSalarySlip(
    int companyId,
    int salaryPeriodId,
  ) async {
    try {
      final response = await _apiService.get(
        Uri.parse(AppConfig.getSalarySlipUrl(companyId, salaryPeriodId)),
      );
      if (response.statusCode != 200) return null;
      return response.bodyBytes;
    } catch (e) {
      debugPrint('Download salary slip error: $e');
      return null;
    }
  }

  Future<EmployeeAuthResponse?> employeeLogin(
    EmployeeLoginRequest request,
  ) async {
    try {
      final response = await _apiService.post(
        AppConfig.employeeLoginUrl,
        request.toJson(),
      );
      if (response.statusCode != 200 && response.statusCode != 202) {
        return _parseEmployeeAuthResponse(response);
      }
      return _parseEmployeeAuthResponse(response);
    } catch (e) {
      debugPrint('Employee login error: $e');
      return null;
    }
  }

  Future<EmployeeAuthResponse?> employeeRefreshToken(
    String refreshToken,
  ) async {
    try {
      final response = await _apiService.post(
        AppConfig.employeeRefreshTokenUrl,
        {'refreshToken': refreshToken},
      );
      return _parseEmployeeAuthResponse(response);
    } catch (e) {
      debugPrint('Employee refresh token error: $e');
      return null;
    }
  }

  Future<EmployeeDetailData?> getMyProfile() async {
    try {
      final response = await _apiService.get(
        Uri.parse(AppConfig.employeeMeUrl),
      );
      return _parseData(response, EmployeeDetailData.fromJson);
    } catch (e) {
      debugPrint('Get my profile error: $e');
      return null;
    }
  }

  Future<List<SalaryPeriodSummary>> getMySalaryPeriods({
    String? from,
    String? to,
    String? period,
  }) async {
    try {
      final response = await _apiService.get(
        Uri.parse(AppConfig.getEmployeeMySalaryPeriodsUrl(
          from: from,
          to: to,
          period: period,
        )),
      );
      return _parseList(response, SalaryPeriodSummary.fromJson);
    } catch (e) {
      debugPrint('Get my salary periods error: $e');
      return [];
    }
  }

  Future<SalaryReportData?> getMySalaryReport({
    required String from,
    required String to,
  }) async {
    try {
      final response = await _apiService.get(
        Uri.parse(AppConfig.getEmployeeMySalaryReportUrl(from: from, to: to)),
      );
      final parsed = _parseData(response, SalaryReportData.fromJson);
      if (parsed != null) return parsed;
    } catch (e) {
      debugPrint('Get my salary report via /api/emp failed: $e');
    }

    try {
      final periods = await getMySalaryPeriods();
      return _buildSalaryReportFromPeriods(periods, from: from, to: to);
    } catch (e) {
      debugPrint('Get my salary report fallback error: $e');
      return null;
    }
  }

  Future<SalaryPeriodDetailData?> getMySalaryDetail(int salaryPeriodId) async {
    try {
      final response = await _apiService.get(
        Uri.parse(AppConfig.getEmployeeMySalaryDetailUrl(salaryPeriodId)),
      );
      return _parseData(response, SalaryPeriodDetailData.fromJson);
    } catch (e) {
      debugPrint('Get my salary detail error: $e');
      return null;
    }
  }

  Future<Uint8List?> downloadMySalarySlip(int salaryPeriodId) async {
    try {
      final response = await _apiService.get(
        Uri.parse(AppConfig.getEmployeeMySalarySlipUrl(salaryPeriodId)),
      );
      if (response.statusCode != 200) return null;
      return response.bodyBytes;
    } catch (e) {
      debugPrint('Download my salary slip error: $e');
      return null;
    }
  }

  Future<List<WorkLogData>> getMyWorkLogs({String? from, String? to}) async {
    try {
      final response = await _apiService.get(
        Uri.parse(AppConfig.getEmployeeMyWorkLogsUrl(from: from, to: to)),
      );
      return _parseList(response, WorkLogData.fromJson);
    } catch (e) {
      debugPrint('Get my work logs error: $e');
      return [];
    }
  }

  Future<List<LeaveLogData>> getMyLeaveLogs({String? from, String? to}) async {
    try {
      final response = await _apiService.get(
        Uri.parse(AppConfig.getEmployeeMyLeaveLogsUrl(from: from, to: to)),
      );
      return _parseList(response, LeaveLogData.fromJson);
    } catch (e) {
      debugPrint('Get my leave logs error: $e');
      return [];
    }
  }

  Future<List<WorkDefinitionData>> getEmployeeVisibleWorkDefinitions({
    int? companyId,
    bool activeOnly = true,
  }) async {
    try {
      final employeeResponse = await _apiService.get(
        Uri.parse(
          AppConfig.getEmployeeWorkDefinitionsUrl(activeOnly: activeOnly),
        ),
      );
      final employeeData = _parseList(
        employeeResponse,
        WorkDefinitionData.fromJson,
      );
      if (employeeData.isNotEmpty) return employeeData;
    } catch (e) {
      debugPrint('Employee work definitions via /api/emp failed: $e');
    }

    if (companyId == null) return [];
    return getWorkDefinitions(companyId, activeOnly: activeOnly);
  }

  /// Update an existing employee work log via the admin "/employee" endpoint.
  /// Server should reject if the log is already APPROVED.
  Future<EmployeeEditResponse?> updateMyWorkLog(
    CreateWorkLogRequest request, {
    required int companyId,
  }) async {
    try {
      final response = await _apiService.put(
        AppConfig.getUpdateWorkLogEmployeeUrl(companyId),
        request.toJson(),
      );
      return _parseEditResponse(response);
    } catch (e) {
      debugPrint('Update my work log error: $e');
      return null;
    }
  }

  /// Update an existing employee leave log via the admin "/employee" endpoint.
  /// Server should reject if the leave is already APPROVED.
  Future<EmployeeEditResponse?> updateMyLeaveLog(
    CreateLeaveLogRequest request, {
    required int companyId,
  }) async {
    try {
      final response = await _apiService.put(
        AppConfig.getUpdateLeaveLogEmployeeUrl(companyId),
        request.toJson(),
      );
      return _parseEditResponse(response);
    } catch (e) {
      debugPrint('Update my leave log error: $e');
      return null;
    }
  }

  Future<EmployeeEditResponse?> createMyWorkLog(
    CreateWorkLogRequest request, {
    int? companyId,
  }) async {
    try {
      final response = await _apiService.post(
        AppConfig.getEmployeeMyWorkLogsUrl(),
        request.toJson(),
      );
      final parsed = _parseEditResponse(response);
      if (parsed?.responseStatus == true) return parsed;
    } catch (e) {
      debugPrint('Create my work log via /api/emp failed: $e');
    }

    if (companyId == null) return null;
    return createWorkLog(companyId, request);
  }

  Future<EmployeeEditResponse?> createMyLeaveLog(
    CreateLeaveLogRequest request, {
    int? companyId,
  }) async {
    try {
      final response = await _apiService.post(
        AppConfig.getEmployeeMyLeaveLogsUrl(),
        request.toJson(),
      );
      final parsed = _parseEditResponse(response);
      if (parsed?.responseStatus == true) return parsed;
    } catch (e) {
      debugPrint('Create my leave log via /api/emp failed: $e');
    }

    if (companyId == null) return null;
    return createLeaveLog(companyId, request);
  }

  EmployeeAuthResponse? _parseEmployeeAuthResponse(http.Response response) {
    final body = _decodeBody(response);
    if (body == null) return null;
    return EmployeeAuthResponse.fromJson(body);
  }

  Future<EmployeeEditResponse?> _postEditResponse(
    String url,
    Map<String, dynamic> body, {
    required String debugLabel,
  }) async {
    try {
      final response = await _apiService.post(url, body);
      final parsed = _parseEditResponse(response);
      if (parsed?.responseStatus != true) {
        debugPrint(
          '$debugLabel failed [${response.statusCode}]: ${response.body}',
        );
      }
      return parsed;
    } catch (e) {
      debugPrint('$debugLabel error: $e');
      return null;
    }
  }

  Future<EmployeeEditResponse?> _putEditResponse(
    String url,
    Map<String, dynamic> body, {
    required String debugLabel,
  }) async {
    try {
      final response = await _apiService.put(url, body);
      final parsed = _parseEditResponse(response);
      if (parsed?.responseStatus != true) {
        debugPrint(
          '$debugLabel failed [${response.statusCode}]: ${response.body}',
        );
      }
      return parsed;
    } catch (e) {
      debugPrint('$debugLabel error: $e');
      return null;
    }
  }

  Future<EmployeeStatusResponse?> _putStatusResponse(
    String url,
    Map<String, dynamic> body, {
    required String debugLabel,
  }) async {
    try {
      final response = await _apiService.put(url, body);
      return _parseStatusResponse(response);
    } catch (e) {
      debugPrint('$debugLabel error: $e');
      return null;
    }
  }

  Future<EmployeeStatusResponse?> _patchStatusResponse(
    String url,
    Map<String, dynamic> body, {
    required String debugLabel,
  }) async {
    try {
      final response = await _apiService.patch(url, body);
      return _parseStatusResponse(response);
    } catch (e) {
      debugPrint('$debugLabel error: $e');
      return null;
    }
  }

  EmployeeEditResponse? _parseEditResponse(http.Response response) {
    final body = _decodeBody(response);
    if (body == null) return null;
    return EmployeeEditResponse.fromJson(body);
  }

  EmployeeStatusResponse? _parseStatusResponse(http.Response response) {
    final body = _decodeBody(response);
    if (body == null) return null;
    return EmployeeStatusResponse.fromJson(body);
  }

  T? _parseData<T>(
    http.Response response,
    T Function(Map<String, dynamic>) parser,
  ) {
    final body = _decodeBody(response);
    if (body == null || body['responseStatus'] != true) return null;
    final data = body['responseData'];
    if (data is! Map<String, dynamic>) return null;
    return parser(data);
  }

  List<T> _parseList<T>(
    http.Response response,
    T Function(Map<String, dynamic>) parser,
  ) {
    final body = _decodeBody(response);
    if (body == null || body['responseStatus'] != true) return [];
    final data = body['responseData'];
    if (data is! List) return [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(parser)
        .toList(growable: false);
  }

  Map<String, dynamic>? _decodeBody(http.Response response) {
    if (response.body.isEmpty) return null;
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) return null;
    return decoded;
  }

  SalaryReportData _buildSalaryReportFromPeriods(
    List<SalaryPeriodSummary> periods, {
    required String from,
    required String to,
  }) {
    final fromDate = DateTime.tryParse(from);
    final toDate = DateTime.tryParse(to);

    final filtered = periods.where((period) {
      if (fromDate == null || toDate == null) return true;
      final periodFrom = DateTime.tryParse(period.fromDate);
      final periodTo = DateTime.tryParse(period.toDate);
      if (periodFrom == null || periodTo == null) return true;
      return !periodTo.isBefore(fromDate) && !periodFrom.isAfter(toDate);
    }).toList(growable: false);

    var totalGross = 0.0;
    var totalNet = 0.0;
    var totalDeductions = 0.0;

    final details = filtered.map((period) {
      final gross = period.grossAmount ?? 0;
      final net = period.netAmount ?? 0;
      final deductions = gross - net;

      totalGross += gross;
      totalNet += net;
      totalDeductions += deductions;

      return SalaryPeriodDetailData(
        salaryPeriodId: period.salaryPeriodId,
        employeeId: period.employeeId,
        employeeName: period.employeeName,
        employeeCode: period.employeeCode,
        period: period.period,
        fromDate: period.fromDate,
        toDate: period.toDate,
        salaryType: period.salaryType,
        grossAmount: period.grossAmount,
        otherDeductions: deductions,
        netAmount: period.netAmount,
        status: period.status,
        lines: const [],
      );
    }).toList(growable: false);

    return SalaryReportData(
      fromDate: from,
      toDate: to,
      totalEmployees: details.isEmpty ? 0 : 1,
      totalGrossAmount: totalGross,
      totalDeductions: totalDeductions,
      totalNetAmount: totalNet,
      salaryDetails: details,
    );
  }
}
