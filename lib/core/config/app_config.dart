import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get baseUrl => dotenv.env['BASE_URL'] ?? '';
  static const String loginEndpoint = '/api/auth/login';
  static const String registerEndpoint = '/api/auth/register';
  static const String verifyOtpEndpoint = '/api/auth/verify-otp';
  static const String resendOtpEndpoint = ' /api/auth/send-otp';
  static const String companyEndpoint = '/api/companies/my-companies';
  static const String refreshTokenEndpoint = '/api/auth/refresh-token';
  static const String customersEndpoint =
      '/api/companies/{companyId}/customers';
  static const String customerDetailEndpoint =
      '/api/companies/{companyId}/customers/{customerId}';
  static const String customerEditEndpoint =
      '/api/companies/{companyId}/customers/{customerId}';
  static const String createCustomerEndpoint =
      '/api/companies/{companyId}/customers';
  static const String customerActivateEndpoint =
      '/api/companies/{companyId}/customers/{customerId}/activate';
  static const String customerDeactivateEndpoint =
      '/api/companies/{companyId}/customers/{customerId}/deactivate';

  static const String activeVendorsEndpoint =
      '/api/companies/{companyId}/customers/active';
  static const String vendorsDetailEndpoint =
      '/api/companies/{companyId}/customers/{customerId}';
  static const String vendorsEditEndpoint =
      '/api/companies/{companyId}/customers/{customerId}';
  static const String createVendorsEndpoint =
      '/api/companies/{companyId}/customers';
  static const String vendorsActivateEndpoint =
      '/api/companies/{companyId}/customers/{customerId}/activate';
  static const String vendorsDeactivateEndpoint =
      '/api/companies/{companyId}/customers/{customerId}/deactivate';

  static String get loginUrl => '$baseUrl$loginEndpoint';
  static String get registerUrl => '$baseUrl$registerEndpoint';
  static String get verifyOtpUrl => '$baseUrl$verifyOtpEndpoint';
  static String get resendOtpUrl => '$baseUrl$resendOtpEndpoint';
  static String get companyUrl => '$baseUrl$companyEndpoint';
  static String get refreshTokenUrl => '$baseUrl$refreshTokenEndpoint';
  static String getCustomersUrl(int companyId) =>
      '$baseUrl${customersEndpoint.replaceAll('{companyId}', companyId.toString())}';

  static String getCustomerDetailUrl(int companyId, int customerId) =>
      '$baseUrl${customerDetailEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{customerId}', customerId.toString())}';

  static String getCustomerEditUrl(int companyId, int customerId) =>
      '$baseUrl${customerEditEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{customerId}', customerId.toString())}';

  static String getCreateCustomerUrl(int companyId) =>
      '$baseUrl${createCustomerEndpoint.replaceAll('{companyId}', companyId.toString())}';

  static String getCustomerActivateUrl(int companyId, int customerId) =>
      '$baseUrl${customerActivateEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{customerId}', customerId.toString())}';

  static String getCustomerDeactivateUrl(int companyId, int customerId) =>
      '$baseUrl${customerDeactivateEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{customerId}', customerId.toString())}';
  static String getActiVevendorssUrl(int companyId) =>
      '$baseUrl${activeVendorsEndpoint.replaceAll('{companyId}', companyId.toString())}';

  static String getVendorsDetailUrl(int companyId, int customerId) =>
      '$baseUrl${vendorsDetailEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{customerId}', customerId.toString())}';

  static String getVendorsEditUrl(int companyId, int customerId) =>
      '$baseUrl${vendorsEditEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{customerId}', customerId.toString())}';

  static String getCreateVendorsUrl(int companyId) =>
      '$baseUrl${createVendorsEndpoint.replaceAll('{companyId}', companyId.toString())}';

  static String getVendorsActivateUrl(int companyId, int customerId) =>
      '$baseUrl${vendorsActivateEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{customerId}', customerId.toString())}';

  static String getVendorsDeactivateUrl(int companyId, int customerId) =>
      '$baseUrl${vendorsDeactivateEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{customerId}', customerId.toString())}';
}
