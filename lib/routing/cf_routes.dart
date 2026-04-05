import 'package:flutter/foundation.dart';
/// Centralized route path definitions for the CoreFlow app.
///
/// All routes follow the structure defined in ROUTING-STRUCTURE.md.
class CfRoutes {
  CfRoutes._();

  // ── Auth ──────────────────────────────────────────────────────────────
  static const login = '/cf/auth/login';
  static const register = '/cf/auth/register';
  static const verifyBase = '/cf/auth/verify';
  static String verify(String userPath) => '/cf/auth/verify/$userPath';
  static const resendOtp = '/cf/auth/resend-otp';

  // ── Legal ─────────────────────────────────────────────────────────────
  static const privacyPolicy = '/cf/legal/privacy-policy';
  static const termsOfService = '/cf/legal/terms-of-service';

  // ── Company Management ────────────────────────────────────────────────
  static const companyList = '/cf/company/list';
  static const companyCreate = '/cf/company/create';
  static String companyDetail(int companyId) =>
      '/cf/company/$companyId/detail';
  static String companyUpdate(int companyId) =>
      '/cf/company/$companyId/update';

  // ── Dashboard ─────────────────────────────────────────────────────────
  static String dashboard(int companyId) =>
      '/cf/company/$companyId/dashboard';

  // ── Notifications ─────────────────────────────────────────────────────
  static String notifications(int companyId) =>
      '/cf/company/$companyId/notifications';

  // ── User ──────────────────────────────────────────────────────────────
  static String profile(int userId) => '/cf/user/$userId/profile';
  static String settings(int userId) => '/cf/user/$userId/settings';

  // ── Customers ─────────────────────────────────────────────────────────
  static String customers(int companyId) =>
      '/cf/company/$companyId/customers';
  static String customerCreate(int companyId) =>
      '/cf/company/$companyId/customers/create';
  static String customerDetail(int companyId, int customerId) =>
      '/cf/company/$companyId/customers/$customerId/detail';
  static String customerUpdate(int companyId, int customerId) =>
      '/cf/company/$companyId/customers/$customerId/update';

  // ── Vendors ───────────────────────────────────────────────────────────
  static String vendors(int companyId) =>
      '/cf/company/$companyId/vendors';
  static String vendorCreate(int companyId) =>
      '/cf/company/$companyId/vendors/create';
  static String vendorDetail(int companyId, int vendorId) =>
      '/cf/company/$companyId/vendors/$vendorId/detail';
  static String vendorUpdate(int companyId, int vendorId) =>
      '/cf/company/$companyId/vendors/$vendorId/update';

  // ── Items ─────────────────────────────────────────────────────────────
  static String items(int companyId) =>
      '/cf/company/$companyId/items';
  static String itemCreate(int companyId) =>
      '/cf/company/$companyId/items/create';
  static String itemDetail(int companyId, int itemId) =>
      '/cf/company/$companyId/items/$itemId/detail';
  static String itemUpdate(int companyId, int itemId) =>
      '/cf/company/$companyId/items/$itemId/update';

  // ── Sales ─────────────────────────────────────────────────────────────
  static String sales(int companyId) =>
      '/cf/company/$companyId/sales';
  static String salesCreate(int companyId) =>
      '/cf/company/$companyId/sales/create';
  static String salesDetail(int companyId, int salesId) =>
      '/cf/company/$companyId/sales/$salesId/detail';
  static String salesUpdate(int companyId, int salesId) =>
      '/cf/company/$companyId/sales/$salesId/update';

  // ── Purchase ──────────────────────────────────────────────────────────
  static String purchase(int companyId) =>
      '/cf/company/$companyId/purchase/list';
  static String purchaseCreate(int companyId) =>
      '/cf/company/$companyId/purchase/create';
  static String purchaseDetail(int companyId, int purchaseId) =>
      '/cf/company/$companyId/purchase/$purchaseId/detail';
  static String purchaseUpdate(int companyId, int purchaseId) =>
      '/cf/company/$companyId/purchase/$purchaseId/update';

  // ── Payment Received ──────────────────────────────────────────────────
  static String paymentReceived(int companyId) =>
      '/cf/company/$companyId/payment-received/list';
  static String paymentReceivedCreate(int companyId) =>
      '/cf/company/$companyId/payment-received/create';
  static String paymentReceivedDetail(int companyId, int id) =>
      '/cf/company/$companyId/payment-received/$id/detail';
  static String paymentReceivedUpdate(int companyId, int id) =>
      '/cf/company/$companyId/payment-received/$id/update';

  // ── Payment Made ──────────────────────────────────────────────────────
  static String paymentMade(int companyId) =>
      '/cf/company/$companyId/payment-made/list';
  static String paymentMadeCreate(int companyId) =>
      '/cf/company/$companyId/payment-made/create';
  static String paymentMadeDetail(int companyId, int id) =>
      '/cf/company/$companyId/payment-made/$id/detail';
  static String paymentMadeUpdate(int companyId, int id) =>
      '/cf/company/$companyId/payment-made/$id/update';

  // ── Employees ─────────────────────────────────────────────────────
  static String employees(int companyId) =>
      '/cf/company/$companyId/employees';
  static String employeeCreate(int companyId) =>
      '/cf/company/$companyId/employees/create';
  static String employeeDetail(int companyId, int employeeId) =>
      '/cf/company/$companyId/employees/$employeeId/detail';
  static String employeeUpdate(int companyId, int employeeId) =>
      '/cf/company/$companyId/employees/$employeeId/update';

  // ── Report ────────────────────────────────────────────────────────────
  static String reportCustomers(int companyId) =>
      '/cf/company/$companyId/report/customers';
  static String reportVendors(int companyId) =>
      '/cf/company/$companyId/report/vendors';
  static String reportItems(int companyId) =>
      '/cf/company/$companyId/report/items';
  static String reportSales(int companyId) =>
      '/cf/company/$companyId/report/sales';
  static String reportPurchase(int companyId) =>
      '/cf/company/$companyId/report/purchase';
  static String reportPaymentReceived(int companyId) =>
      '/cf/company/$companyId/report/payment-received';
  static String reportPaymentMade(int companyId) =>
      '/cf/company/$companyId/report/payment-made';

  // ── Marketplace (not in ROUTING-STRUCTURE.md, kept for compatibility) ─
  static const marketplace = '/cf/marketplace';
  static String marketplaceCompany(int companyId) =>
      '/cf/marketplace/$companyId';

  // ── Helpers ───────────────────────────────────────────────────────────

  /// Extracts the section path after `/cf/company/:companyId/`.
  /// Returns null if the location doesn't match the pattern.
  static String? getCompanySection(String location) {
    debugPrint('Extracting company section from: $location');
    final match = RegExp(r'^/cf/company/\d+/(.+)$').firstMatch(location);
    return match?.group(1);
  }

  /// Checks if the current location's company section starts with [section].
  static bool isSectionActive(String location, String section) {
    final s = getCompanySection(location);
    return s != null && s.startsWith(section);
  }

  /// Checks if the location is under the user section.
  static bool isUserSection(String location, String section) {
    final match = RegExp(r'^/cf/user/\d+/(.+)$').firstMatch(location);
    final s = match?.group(1);
    return s != null && s.startsWith(section);
  }
}
