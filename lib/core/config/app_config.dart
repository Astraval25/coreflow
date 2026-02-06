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
      '/api/companies/{companyId}/vendors';
  static const String vendorDetailEndpoint =
      '/api/companies/{companyId}/vendors/{vendorId}';
  static const String vendorEditEndpoint =
      '/api/companies/{companyId}/vendors/{vendorId}';
  static const String createVendorEndpoint =
      '/api/companies/{companyId}/vendors';
  static const String vendorActivateEndpoint =
      '/api/companies/{companyId}/vendors/{vendorId}/activate';
  static const String vendorDeactivateEndpoint =
      '/api/companies/{companyId}/vendors/{vendorId}/deactivate';
  static const String itemsEndpoint = '/api/companies/{companyId}/items';
  static const String itemDetailEndpoint =
      '/api/companies/{companyId}/items/{itemId}';
  static const String fileEndpoint = '/api/file';

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

  static String getActiveVendorsUrl(int companyId) =>
      '$baseUrl${activeVendorsEndpoint.replaceAll('{companyId}', companyId.toString())}';

  static String getVendorDetailUrl(int companyId, int vendorId) =>
      '$baseUrl${vendorDetailEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{vendorId}', vendorId.toString())}';

  static String getVendorEditUrl(int companyId, int vendorId) =>
      '$baseUrl${vendorEditEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{vendorId}', vendorId.toString())}';

  static String getCreateVendorUrl(int companyId) =>
      '$baseUrl${createVendorEndpoint.replaceAll('{companyId}', companyId.toString())}';

  static String getVendorActivateUrl(int companyId, int vendorId) =>
      '$baseUrl${vendorActivateEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{vendorId}', vendorId.toString())}';

  static String getVendorDeactivateUrl(int companyId, int vendorId) =>
      '$baseUrl${vendorDeactivateEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{vendorId}', vendorId.toString())}';

  static String getItemsUrl(int companyId) =>
      '$baseUrl${itemsEndpoint.replaceAll('{companyId}', companyId.toString())}';
  static String getItemDetailUrl(int companyId, int itemId) =>
      '$baseUrl${itemDetailEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{itemId}', itemId.toString())}';

  static String getFileUrl(String fsId) => '$baseUrl$fileEndpoint?fsId=$fsId';
}
