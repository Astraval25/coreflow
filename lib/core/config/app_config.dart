import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get baseUrl => dotenv.env['BASE_URL'] ?? '';
  static const String loginEndpoint = '/api/auth/login';
  static const String registerEndpoint = '/api/auth/register';
  static const String verifyOtpEndpoint = '/api/auth/verify-otp';
  static const String resendOtpEndpoint = ' /api/auth/send-otp';
  static const String companyEndpoint = '/api/companies/my-companies';
  static const String refreshTokenEndpoint = '/api/auth/refresh-token';
  static const String activeCustomersEndpoint =
      '/api/companies/{companyId}/customers/active';
  static const String customerDetailEndpoint =
      '/api/companies/{companyId}/customers/{customerId}';
  static const String customerEditEndpoint =
      '/api/companies/{companyId}/customers/{customerId}';
  static const String createCustomerEndpoint =
      '/api/companies/{companyId}/customers';

  static String get loginUrl => '$baseUrl$loginEndpoint';
  static String get registerUrl => '$baseUrl$registerEndpoint';
  static String get verifyOtpUrl => '$baseUrl$verifyOtpEndpoint';
  static String get resendOtpUrl => '$baseUrl$resendOtpEndpoint';
  static String get companyUrl => '$baseUrl$companyEndpoint';
  static String get refreshTokenUrl => '$baseUrl$refreshTokenEndpoint';
  static String getActiveCustomersUrl(int companyId) =>
      '$baseUrl${activeCustomersEndpoint.replaceAll('{companyId}', companyId.toString())}';

  static String getCustomerDetailUrl(int companyId, int customerId) =>
      '$baseUrl${customerDetailEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{customerId}', customerId.toString())}';

  static String getCustomerEditUrl(int companyId, int customerId) =>
      '$baseUrl${customerEditEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{customerId}', customerId.toString())}';

  static String getCreateCustomerUrl(int companyId) =>
      '$baseUrl${createCustomerEndpoint.replaceAll('{companyId}', companyId.toString())}';
}
