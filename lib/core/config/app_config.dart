import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  // Base URL for API
  static String get baseUrl => dotenv.env['BASE_URL'] ?? '';

  // API Endpoints
  static const String loginEndpoint = '/api/auth/login';
  static const String registerEndpoint = '/api/auth/register';
  static const String verifyOtpEndpoint = '/api/auth/verify-otp';
  static const String resendOtpEndpoint = '/api/auth/send-otp';
  static const String companyEndpoint = '/api/companies/my-companies';
  static const String allCompaniesEndpoint = '/api/companies';
  static const String refreshTokenEndpoint = '/api/auth/refresh-token';

  // Company CRUD endpoints
  static const String companyDetailEndpoint = '/api/companies/{companyId}';
  static const String companyActivateEndpoint =
      '/api/companies/{companyId}/activate';
  static const String companyDeactivateEndpoint =
      '/api/companies/{companyId}/deactivate';
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
  static const String vendorMappedItemsEndpoint =
      '/api/companies/{companyId}/vendors/{vendorId}/items/mapped';
  static const String vendorItemsEndpoint =
      '/api/companies/{companyId}/vendors/{vendorId}/items';
  static const String vendorItemDetailEndpoint =
      '/api/companies/{companyId}/vendors/{vendorId}/items/{itemId}';
  static const String vendorItemActivateEndpoint =
      '/api/companies/{companyId}/vendors/{vendorId}/items/{itemId}/activate';
  static const String vendorItemDeactivateEndpoint =
      '/api/companies/{companyId}/vendors/{vendorId}/items/{itemId}/deactivate';
  static const String itemsEndpoint = '/api/companies/{companyId}/items';
  static const String itemDetailEndpoint =
      '/api/companies/{companyId}/items/{itemId}';
  static const String customerMappedItemsEndpoint =
      '/api/companies/{companyId}/customers/{customerId}/items/mapped';
  static const String customerItemsEndpoint =
      '/api/companies/{companyId}/customers/{customerId}/items';
  static const String customerItemDetailEndpoint =
      '/api/companies/{companyId}/customers/{customerId}/items/{itemId}';
  static const String customerItemActivateEndpoint =
      '/api/companies/{companyId}/customers/{customerId}/items/{itemId}/activate';
  static const String customerItemDeactivateEndpoint =
      '/api/companies/{companyId}/customers/{customerId}/items/{itemId}/deactivate';
  static const String customerSellableItemsEndpoint =
      '/api/companies/{companyId}/customers/{customerId}/items/sellable';
  static const String vendorPurchasableItemsEndpoint =
      '/api/companies/{companyId}/vendors/{vendorId}/items/purchasable';
  static const String fileEndpoint = '/api/file';
  static const String itemActivateEndpoint =
      '/api/companies/{companyId}/items/{itemId}/activate';

  static const String itemDeactivateEndpoint =
      '/api/companies/{companyId}/items/{itemId}/deactivate';
  static const String salesOrdersEndpoint =
      '/api/companies/{companyId}/sales/orders';
  static const String purchaseOrdersEndpoint =
      '/api/companies/{companyId}/purchase/orders';
  static const String paymentsSentSummaryEndpoint =
      '/api/companies/{companyId}/payments-sent/summary';
  static const String paymentsReceivedSummaryEndpoint =
      '/api/companies/{companyId}/payments-received/summary';
  static const String paymentDetailEndpoint =
      '/api/companies/{companyId}/payments/{paymentId}';
  static const String orderDetailEndpoint =
      '/api/companies/{companyId}/orders/{orderId}';
  static const String createPaymentSentEndpoint =
      '/api/companies/{companyId}/payments-sent';
  static const String vendorUnpaidOrdersEndpoint =
      '/api/companies/{companyId}/vendor/{vendorId}/unpaid-orders';
  static const String createPaymentReceivedEndpoint =
      '/api/companies/{companyId}/payments-received';
  static const String customerUnpaidOrdersEndpoint =
      '/api/companies/{companyId}/customer/{customerId}/unpaid-orders';
  static const String paymentProofEndpoint =
      '/api/companies/{companyId}/payments/payment-proof';
  static const String paymentProofFileEndpoint =
      '/api/companies/{companyId}/payments/payment-proof/{fsId}';

  static const String updatePurchaseOrderEndpoint =
      '/api/companies/{companyId}/purchase/orders/{orderId}';
  static const String updateSalesOrderEndpoint =
      '/api/companies/{companyId}/sales/orders/{orderId}';
  static const String updatePaymentSentEndpoint =
      '/api/companies/{companyId}/payments-sent/{paymentId}';
  static const String updatePaymentReceivedEndpoint =
      '/api/companies/{companyId}/payments-received/{paymentId}';

  // Invitation endpoints
  static const String customerInvitationEndpoint =
      '/api/companies/{companyId}/invitations/customers/{customerId}';
  static const String customerInvitationCodeEndpoint =
      '/api/companies/{companyId}/invitations/customers/{customerId}/code';
  static const String vendorInvitationEndpoint =
      '/api/companies/{companyId}/invitations/vendors/{vendorId}';
  static const String vendorInvitationCodeEndpoint =
      '/api/companies/{companyId}/invitations/vendors/{vendorId}/code';
  static const String acceptInvitationEndpoint =
      '/api/companies/{companyId}/invitations/{invitationCode}/accept';

  // getters for constructing full URLs
  static String get loginUrl => '$baseUrl$loginEndpoint';
  static String get registerUrl => '$baseUrl$registerEndpoint';
  static String get verifyOtpUrl => '$baseUrl$verifyOtpEndpoint';
  static String get resendOtpUrl => '$baseUrl$resendOtpEndpoint';
  static String get companyUrl => '$baseUrl$companyEndpoint';
  static String get allCompaniesUrl => '$baseUrl$allCompaniesEndpoint';
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
  static String getVendorMappedItemsUrl(int companyId, int vendorId) =>
      '$baseUrl${vendorMappedItemsEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{vendorId}', vendorId.toString())}';
  static String getVendorItemsUrl(int companyId, int vendorId) =>
      '$baseUrl${vendorItemsEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{vendorId}', vendorId.toString())}';
  static String getVendorItemDetailUrl(
    int companyId,
    int vendorId,
    int itemId,
  ) =>
      '$baseUrl${vendorItemDetailEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{vendorId}', vendorId.toString()).replaceAll('{itemId}', itemId.toString())}';
  static String getVendorItemActivateUrl(
    int companyId,
    int vendorId,
    int itemId,
  ) =>
      '$baseUrl${vendorItemActivateEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{vendorId}', vendorId.toString()).replaceAll('{itemId}', itemId.toString())}';
  static String getVendorItemDeactivateUrl(
    int companyId,
    int vendorId,
    int itemId,
  ) =>
      '$baseUrl${vendorItemDeactivateEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{vendorId}', vendorId.toString()).replaceAll('{itemId}', itemId.toString())}';

  static String getItemsUrl(int companyId) =>
      '$baseUrl${itemsEndpoint.replaceAll('{companyId}', companyId.toString())}';
  static String getItemDetailUrl(int companyId, int itemId) =>
      '$baseUrl${itemDetailEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{itemId}', itemId.toString())}';
  static String getCustomerMappedItemsUrl(int companyId, int customerId) =>
      '$baseUrl${customerMappedItemsEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{customerId}', customerId.toString())}';
  static String getCustomerItemsUrl(int companyId, int customerId) =>
      '$baseUrl${customerItemsEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{customerId}', customerId.toString())}';
  static String getCustomerItemDetailUrl(
    int companyId,
    int customerId,
    int itemId,
  ) =>
      '$baseUrl${customerItemDetailEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{customerId}', customerId.toString()).replaceAll('{itemId}', itemId.toString())}';
  static String getCustomerItemActivateUrl(
    int companyId,
    int customerId,
    int itemId,
  ) =>
      '$baseUrl${customerItemActivateEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{customerId}', customerId.toString()).replaceAll('{itemId}', itemId.toString())}';

  static String getCustomerItemDeactivateUrl(
    int companyId,
    int customerId,
    int itemId,
  ) =>
      '$baseUrl${customerItemDeactivateEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{customerId}', customerId.toString()).replaceAll('{itemId}', itemId.toString())}';

  static String getCustomerSellableItemsUrl(int companyId, int customerId) =>
      '$baseUrl${customerSellableItemsEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{customerId}', customerId.toString())}';

  static String getVendorPurchasableItemsUrl(int companyId, int vendorId) =>
      '$baseUrl${vendorPurchasableItemsEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{vendorId}', vendorId.toString())}';

  static String getFileUrl(String fsId) => '$baseUrl$fileEndpoint?fsId=$fsId';
  static String getItemActivateUrl(int companyId, int itemId) =>
      '$baseUrl${itemActivateEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{itemId}', itemId.toString())}';

  static String getItemDeactivateUrl(int companyId, int itemId) =>
      '$baseUrl${itemDeactivateEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{itemId}', itemId.toString())}';

  static String getSalesOrdersUrl(int companyId) =>
      '$baseUrl${salesOrdersEndpoint.replaceAll('{companyId}', companyId.toString())}';

  static String getPurchaseOrdersUrl(int companyId) =>
      '$baseUrl${purchaseOrdersEndpoint.replaceAll('{companyId}', companyId.toString())}';

  static String getPaymentsSentSummaryUrl(int companyId) =>
      '$baseUrl${paymentsSentSummaryEndpoint.replaceAll('{companyId}', companyId.toString())}';

  static String getPaymentsReceivedSummaryUrl(int companyId) =>
      '$baseUrl${paymentsReceivedSummaryEndpoint.replaceAll('{companyId}', companyId.toString())}';
  static String getPaymentDetailUrl(int companyId, int paymentId) =>
      '$baseUrl${paymentDetailEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{paymentId}', paymentId.toString())}';
  static String getSendPaymentDetailUrl(int companyId, int paymentId) =>
      getPaymentDetailUrl(companyId, paymentId);
  static String getReceivePaymentDetailUrl(int companyId, int paymentId) =>
      getPaymentDetailUrl(companyId, paymentId);
  static String getOrderDetailUrl(int companyId, int orderId) =>
      '$baseUrl${orderDetailEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{orderId}', orderId.toString())}';
  static String getOrderPaymentDetailsUrl(int companyId, int orderId) =>
      '$baseUrl/api/companies/$companyId/orders/$orderId/payment-details';

  static String getCreatePaymentSentUrl(int companyId) =>
      '$baseUrl${createPaymentSentEndpoint.replaceAll('{companyId}', companyId.toString())}';

  static String getVendorUnpaidOrdersUrl(int companyId, int vendorId) =>
      '$baseUrl${vendorUnpaidOrdersEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{vendorId}', vendorId.toString())}';

  static String getPaymentProofUrl(int companyId) =>
      '$baseUrl${paymentProofEndpoint.replaceAll('{companyId}', companyId.toString())}';

  static String getPaymentProofFileUrl(int companyId, String fsId) =>
      '$baseUrl${paymentProofFileEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{fsId}', fsId)}';

  static String getCreatePaymentReceivedUrl(int companyId) =>
      '$baseUrl${createPaymentReceivedEndpoint.replaceAll('{companyId}', companyId.toString())}';

  static String getCustomerUnpaidOrdersUrl(int companyId, int customerId) =>
      '$baseUrl${customerUnpaidOrdersEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{customerId}', customerId.toString())}';

  static String getUpdatePurchaseOrderUrl(int companyId, int orderId) =>
      '$baseUrl${updatePurchaseOrderEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{orderId}', orderId.toString())}';

  static String getUpdateSalesOrderUrl(int companyId, int orderId) =>
      '$baseUrl${updateSalesOrderEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{orderId}', orderId.toString())}';

  static String getUpdatePaymentSentUrl(int companyId, int paymentId) =>
      '$baseUrl${updatePaymentSentEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{paymentId}', paymentId.toString())}';

  static String getUpdatePaymentReceivedUrl(int companyId, int paymentId) =>
      '$baseUrl${updatePaymentReceivedEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{paymentId}', paymentId.toString())}';

  // ─── Order / Payment Status URLs ───
  static String getOrderStatusUrl(int companyId, int orderId, String action) =>
      '$baseUrl/api/companies/$companyId/orders/$orderId/$action';

  static String getCancelOrderUrl(int companyId, int orderId) =>
      '$baseUrl/api/companies/$companyId/orders/$orderId/cancel-order';

  static String getPaymentStatusUrl(
    int companyId,
    int paymentId,
    String action,
  ) => '$baseUrl/api/companies/$companyId/payments/$paymentId/$action';

  static String getCustomerInvitationUrl(int companyId, int customerId) =>
      '$baseUrl${customerInvitationEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{customerId}', customerId.toString())}';

  static String getCustomerInvitationCodeUrl(int companyId, int customerId) =>
      '$baseUrl${customerInvitationCodeEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{customerId}', customerId.toString())}';

  static String getVendorInvitationUrl(int companyId, int vendorId) =>
      '$baseUrl${vendorInvitationEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{vendorId}', vendorId.toString())}';

  static String getVendorInvitationCodeUrl(int companyId, int vendorId) =>
      '$baseUrl${vendorInvitationCodeEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{vendorId}', vendorId.toString())}';

  static String getAcceptInvitationUrl(int companyId, String invitationCode) =>
      '$baseUrl${acceptInvitationEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{invitationCode}', invitationCode)}';

  // Company CRUD URLs
  static String get createCompanyUrl => '$baseUrl$allCompaniesEndpoint';
  static String getCompanyDetailUrl(int companyId) =>
      '$baseUrl${companyDetailEndpoint.replaceAll('{companyId}', companyId.toString())}';
  static String getCompanyActivateUrl(int companyId) =>
      '$baseUrl${companyActivateEndpoint.replaceAll('{companyId}', companyId.toString())}';
  static String getCompanyDeactivateUrl(int companyId) =>
      '$baseUrl${companyDeactivateEndpoint.replaceAll('{companyId}', companyId.toString())}';

  // ─── Notifications ───
  static String getNotificationsUrl(int companyId, {int page = 0}) =>
      '$baseUrl/api/companies/$companyId/notifications?page=$page';

  static String getUnreadCountUrl(int companyId) =>
      '$baseUrl/api/companies/$companyId/notifications/unread-count';

  static String getMarkReadUrl(int companyId, int notificationId) =>
      '$baseUrl/api/companies/$companyId/notifications/$notificationId/read';

  static String getMarkAllReadUrl(int companyId) =>
      '$baseUrl/api/companies/$companyId/notifications/read-all';

  // ─── Advertisements ───
  static String get adsUrl => '$baseUrl/api/ads';

  // ─── Analytics / Dashboard ───
  static String getDashboardKpiUrl(
    int companyId,
    String startDate,
    String endDate,
  ) =>
      '$baseUrl/api/companies/$companyId/analytics/dashboard/kpi?startDate=$startDate&endDate=$endDate';

  static String getCashFlowUrl(
    int companyId,
    String startDate,
    String endDate,
  ) =>
      '$baseUrl/api/companies/$companyId/analytics/dashboard/cash-flow?startDate=$startDate&endDate=$endDate';

  static String getRevenueExpenseUrl(
    int companyId,
    String startDate,
    String endDate,
  ) =>
      '$baseUrl/api/companies/$companyId/analytics/dashboard/revenue-expense?startDate=$startDate&endDate=$endDate';

  static String getSalesSummaryUrl(int c, String s, String e) =>
      '$baseUrl/api/companies/$c/analytics/sales/summary?startDate=$s&endDate=$e';

  static String getPurchaseSummaryUrl(int c, String s, String e) =>
      '$baseUrl/api/companies/$c/analytics/purchase/summary?startDate=$s&endDate=$e';

  static String getSalesOrderFrequencyUrl(int c, String s, String e) =>
      '$baseUrl/api/companies/$c/analytics/sales/order-frequency?startDate=$s&endDate=$e';

  static String getPurchaseOrderFrequencyUrl(int c, String s, String e) =>
      '$baseUrl/api/companies/$c/analytics/purchase/order-frequency?startDate=$s&endDate=$e';

  static String getSalesPaymentFrequencyUrl(int c, String s, String e) =>
      '$baseUrl/api/companies/$c/analytics/sales/payment-frequency?startDate=$s&endDate=$e';

  static String getPurchasePaymentFrequencyUrl(int c, String s, String e) =>
      '$baseUrl/api/companies/$c/analytics/purchase/payment-frequency?startDate=$s&endDate=$e';

  static String getSalesItemFrequencyUrl(int c, String s, String e) =>
      '$baseUrl/api/companies/$c/analytics/sales/item-frequency?startDate=$s&endDate=$e';

  static String getPurchaseItemFrequencyUrl(int c, String s, String e) =>
      '$baseUrl/api/companies/$c/analytics/purchase/item-frequency?startDate=$s&endDate=$e';

  static String getSalesRunningOrderAmountUrl(int c, String s, String e) =>
      '$baseUrl/api/companies/$c/analytics/sales/running-order-amount?startDate=$s&endDate=$e';

  static String getPurchaseRunningOrderAmountUrl(int c, String s, String e) =>
      '$baseUrl/api/companies/$c/analytics/purchase/running-order-amount?startDate=$s&endDate=$e';

  static String getSalesRunningPaymentAmountUrl(int c, String s, String e) =>
      '$baseUrl/api/companies/$c/analytics/sales/running-payment-amount?startDate=$s&endDate=$e';

  static String getPurchaseRunningPaymentAmountUrl(int c, String s, String e) =>
      '$baseUrl/api/companies/$c/analytics/purchase/running-payment-amount?startDate=$s&endDate=$e';

  static String getSalesByCustomerUrl(int c, String s, String e) =>
      '$baseUrl/api/companies/$c/analytics/sales/by-customer?startDate=$s&endDate=$e';

  static String getPurchaseByVendorUrl(int c, String s, String e) =>
      '$baseUrl/api/companies/$c/analytics/purchase/by-vendor?startDate=$s&endDate=$e';

  static String getSalesByItemUrl(int c, String s, String e) =>
      '$baseUrl/api/companies/$c/analytics/sales/by-item?startDate=$s&endDate=$e';

  static String getPurchaseByItemUrl(int c, String s, String e) =>
      '$baseUrl/api/companies/$c/analytics/purchase/by-item?startDate=$s&endDate=$e';

  static String getProfitByItemUrl(int c, String s, String e) =>
      '$baseUrl/api/companies/$c/analytics/profit/by-item?startDate=$s&endDate=$e';

  static String getTopSellingItemsUrl(int c, String s, String e) =>
      '$baseUrl/api/companies/$c/analytics/dashboard/top-selling-items?startDate=$s&endDate=$e';

  static String getTopProfitableItemsUrl(int c, String s, String e) =>
      '$baseUrl/api/companies/$c/analytics/dashboard/top-profitable-items?startDate=$s&endDate=$e';

  static String getPaymentModeDistributionUrl(int c, String s, String e) =>
      '$baseUrl/api/companies/$c/analytics/dashboard/payment-mode-distribution?startDate=$s&endDate=$e';

  static String getMonthlyTrendUrl(int c, String s, String e) =>
      '$baseUrl/api/companies/$c/analytics/dashboard/monthly-trend?startDate=$s&endDate=$e';

  // ─── Company Config ───
  static String getCompanyConfigUrl(int companyId) =>
      '$baseUrl/api/companies/$companyId/config';

  static String getCompanyConfigKeyUrl(int companyId, String configKey) =>
      '$baseUrl/api/companies/$companyId/config/$configKey';

  // ─── Company Ref (Order / Payment overlays) ───
  static String getOrderRefUrl(int companyId, int orderId) =>
      '$baseUrl/api/companies/$companyId/orders/$orderId/ref';

  static String getPaymentRefUrl(int companyId, int paymentId) =>
      '$baseUrl/api/companies/$companyId/payments/$paymentId/ref';
}
