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
  static const String paymentProofEndpoint =
      '/api/companies/{companyId}/payments/payment-proof';

  // getters for constructing full URLs
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

  static String getCreatePaymentSentUrl(int companyId) =>
      '$baseUrl${createPaymentSentEndpoint.replaceAll('{companyId}', companyId.toString())}';

  static String getVendorUnpaidOrdersUrl(int companyId, int vendorId) =>
      '$baseUrl${vendorUnpaidOrdersEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{vendorId}', vendorId.toString())}';

  static String getPaymentProofUrl(int companyId) =>
      '$baseUrl${paymentProofEndpoint.replaceAll('{companyId}', companyId.toString())}';
}
