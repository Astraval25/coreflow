import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  // Base URL for API
  static String get baseUrl {
    final raw = (dotenv.env['BASE_URL'] ?? '').trim();
    if (raw.isEmpty) return raw;

    // Production web host serves HTML on plain HTTP; force HTTPS for API calls.
    if (raw.startsWith('http://coreflow.astraval.com')) {
      return raw.replaceFirst('http://', 'https://');
    }
    return raw;
  }

  // API Endpoints
  static const String loginEndpoint = '/api/auth/login';
  static const String registerEndpoint = '/api/auth/register';
  static const String verifyOtpEndpoint = '/api/auth/verify-otp';
  static const String resendOtpEndpoint = '/api/auth/send-otp';
  static const String companyEndpoint = '/api/companies/my-companies';
  static const String allCompaniesEndpoint = '/api/companies';
  static const String marketplaceCompaniesEndpoint =
      '/api/marketplace/companies';
  static const String marketplaceCompanyDetailEndpoint =
      '/api/marketplace/companies/{companyId}';
  static const String marketplaceCompanyItemsEndpoint =
      '/api/marketplace/companies/{companyId}/items';
  static const String refreshTokenEndpoint = '/api/auth/refresh-token';
  static const String userProfileEndpoint = '/api/users/me';

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
  static const String customerContactLookupEndpoint =
      '/api/companies/{companyId}/customers/contact-lookup';
  static const String customerLinkByPhoneEndpoint =
      '/api/companies/{companyId}/customers/{customerId}/link-by-phone';
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
  static const String vendorContactLookupEndpoint =
      '/api/companies/{companyId}/vendors/contact-lookup';
  static const String vendorLinkByPhoneEndpoint =
      '/api/companies/{companyId}/vendors/{vendorId}/link-by-phone';
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
  static const String customerOrdersPaymentsEndpoint =
      '/api/companies/{companyId}/customers/{customerId}/orders-payments';
  static const String vendorOrdersPaymentsEndpoint =
      '/api/companies/{companyId}/vendors/{vendorId}/orders-payments';
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
  static const String expenseAccountsEndpoint =
      '/api/companies/{companyId}/expense-accounts';
  static const String expenseAccountTypesEndpoint =
      '/api/companies/{companyId}/expense-accounts/account-types';
  static const String expenseAccountDetailEndpoint =
      '/api/companies/{companyId}/expense-accounts/{expenseAccountId}';
  static const String expenseAccountActivateEndpoint =
      '/api/companies/{companyId}/expense-accounts/{expenseAccountId}/activate';
  static const String expenseAccountDeactivateEndpoint =
      '/api/companies/{companyId}/expense-accounts/{expenseAccountId}/deactivate';
  static const String expensesEndpoint = '/api/companies/{companyId}/expenses';
  static const String expenseDetailEndpoint =
      '/api/companies/{companyId}/expenses/{expenseId}';
  static const String expenseActivateEndpoint =
      '/api/companies/{companyId}/expenses/{expenseId}/activate';
  static const String expenseDeactivateEndpoint =
      '/api/companies/{companyId}/expenses/{expenseId}/deactivate';

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

  // Connection request endpoints
  static const String customerConnectionAcceptEndpoint =
      '/api/companies/{companyId}/customers/{customerId}/connection/accept';
  static const String customerConnectionRejectEndpoint =
      '/api/companies/{companyId}/customers/{customerId}/connection/reject';
  static const String customerConnectionUndoEndpoint =
      '/api/companies/{companyId}/customers/{customerId}/connection/undo';
  static const String vendorConnectionAcceptEndpoint =
      '/api/companies/{companyId}/vendors/{vendorId}/connection/accept';
  static const String vendorConnectionRejectEndpoint =
      '/api/companies/{companyId}/vendors/{vendorId}/connection/reject';
  static const String vendorConnectionUndoEndpoint =
      '/api/companies/{companyId}/vendors/{vendorId}/connection/undo';

  // getters for constructing full URLs
  static String get loginUrl => '$baseUrl$loginEndpoint';
  static String get registerUrl => '$baseUrl$registerEndpoint';
  static String get verifyOtpUrl => '$baseUrl$verifyOtpEndpoint';
  static String get resendOtpUrl => '$baseUrl$resendOtpEndpoint';
  static String get companyUrl => '$baseUrl$companyEndpoint';
  static String get allCompaniesUrl => '$baseUrl$allCompaniesEndpoint';
  static String get marketplaceCompaniesUrl =>
      '$baseUrl$marketplaceCompaniesEndpoint';
  static String get refreshTokenUrl => '$baseUrl$refreshTokenEndpoint';
  static String get userProfileUrl => '$baseUrl$userProfileEndpoint';
  static String getMarketplaceCompanyDetailUrl(int companyId) =>
      '$baseUrl${marketplaceCompanyDetailEndpoint.replaceAll('{companyId}', companyId.toString())}';
  static String getMarketplaceCompanyItemsUrl(int companyId) =>
      '$baseUrl${marketplaceCompanyItemsEndpoint.replaceAll('{companyId}', companyId.toString())}';
  static String getCustomersUrl(int companyId) =>
      '$baseUrl${customersEndpoint.replaceAll('{companyId}', companyId.toString())}';

  static String getCustomerDetailUrl(int companyId, int customerId) =>
      '$baseUrl${customerDetailEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{customerId}', customerId.toString())}';

  static String getCustomerEditUrl(int companyId, int customerId) =>
      '$baseUrl${customerEditEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{customerId}', customerId.toString())}';

  static String getCreateCustomerUrl(int companyId) =>
      '$baseUrl${createCustomerEndpoint.replaceAll('{companyId}', companyId.toString())}';

  static String getCustomerContactLookupUrl(int companyId) =>
      '$baseUrl${customerContactLookupEndpoint.replaceAll('{companyId}', companyId.toString())}';

  static String getCustomerLinkByPhoneUrl(int companyId, int customerId) =>
      '$baseUrl${customerLinkByPhoneEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{customerId}', customerId.toString())}';

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

  static String getVendorContactLookupUrl(int companyId) =>
      '$baseUrl${vendorContactLookupEndpoint.replaceAll('{companyId}', companyId.toString())}';

  static String getVendorLinkByPhoneUrl(int companyId, int vendorId) =>
      '$baseUrl${vendorLinkByPhoneEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{vendorId}', vendorId.toString())}';

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

  static String getCustomerOrdersPaymentsUrl(
    int companyId,
    int customerId, {
    int? page,
    int? size,
  }) {
    final base =
        '$baseUrl${customerOrdersPaymentsEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{customerId}', customerId.toString())}';
    if (page == null && size == null) return base;

    final params = <String>[
      if (page != null) 'page=$page',
      if (size != null) 'size=$size',
    ];
    return '$base?${params.join('&')}';
  }

  // Alias kept for clearer call sites.
  static String getCustomerOrdersAndPaymentsUrl(
    int companyId,
    int customerId,
  ) => getCustomerOrdersPaymentsUrl(companyId, customerId);

  static String getVendorPurchasableItemsUrl(int companyId, int vendorId) =>
      '$baseUrl${vendorPurchasableItemsEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{vendorId}', vendorId.toString())}';

  static String getVendorOrdersPaymentsUrl(
    int companyId,
    int vendorId, {
    int? page,
    int? size,
  }) {
    final base =
        '$baseUrl${vendorOrdersPaymentsEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{vendorId}', vendorId.toString())}';
    if (page == null && size == null) return base;

    final params = <String>[
      if (page != null) 'page=$page',
      if (size != null) 'size=$size',
    ];
    return '$base?${params.join('&')}';
  }

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

  static String getOrderBillDownloadUrl(int companyId, int orderId) =>
      '$baseUrl/api/companies/$companyId/orders/$orderId/bill';

  static String getCreatePaymentSentUrl(int companyId) =>
      '$baseUrl${createPaymentSentEndpoint.replaceAll('{companyId}', companyId.toString())}';

  static String getVendorUnpaidOrdersUrl(int companyId, int vendorId) =>
      '$baseUrl${vendorUnpaidOrdersEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{vendorId}', vendorId.toString())}';

  static String getPaymentProofUrl(int companyId) =>
      '$baseUrl${paymentProofEndpoint.replaceAll('{companyId}', companyId.toString())}';

  static String getPaymentProofFileUrl(int companyId, String fsId) =>
      '$baseUrl${paymentProofFileEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{fsId}', fsId)}';

  static String getExpenseAccountTypesUrl(int companyId) =>
      '$baseUrl${expenseAccountTypesEndpoint.replaceAll('{companyId}', companyId.toString())}';

  static String getExpenseAccountsUrl(int companyId, {bool? activeOnly}) {
    final base =
        '$baseUrl${expenseAccountsEndpoint.replaceAll('{companyId}', companyId.toString())}';
    if (activeOnly == null) return base;
    return '$base?activeOnly=$activeOnly';
  }

  static String getExpenseAccountDetailUrl(
    int companyId,
    int expenseAccountId,
  ) =>
      '$baseUrl${expenseAccountDetailEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{expenseAccountId}', expenseAccountId.toString())}';

  static String getExpenseAccountActivateUrl(
    int companyId,
    int expenseAccountId,
  ) =>
      '$baseUrl${expenseAccountActivateEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{expenseAccountId}', expenseAccountId.toString())}';

  static String getExpenseAccountDeactivateUrl(
    int companyId,
    int expenseAccountId,
  ) =>
      '$baseUrl${expenseAccountDeactivateEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{expenseAccountId}', expenseAccountId.toString())}';

  static String getExpensesUrl(int companyId, {bool? activeOnly}) {
    final base =
        '$baseUrl${expensesEndpoint.replaceAll('{companyId}', companyId.toString())}';
    if (activeOnly == null) return base;
    return '$base?activeOnly=$activeOnly';
  }

  static String getExpenseDetailUrl(int companyId, int expenseId) =>
      '$baseUrl${expenseDetailEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{expenseId}', expenseId.toString())}';

  static String getExpenseActivateUrl(int companyId, int expenseId) =>
      '$baseUrl${expenseActivateEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{expenseId}', expenseId.toString())}';

  static String getExpenseDeactivateUrl(int companyId, int expenseId) =>
      '$baseUrl${expenseDeactivateEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{expenseId}', expenseId.toString())}';

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

  // Connection request URL builders
  static String getCustomerConnectionAcceptUrl(int companyId, int customerId) =>
      '$baseUrl${customerConnectionAcceptEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{customerId}', customerId.toString())}';

  static String getCustomerConnectionRejectUrl(int companyId, int customerId) =>
      '$baseUrl${customerConnectionRejectEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{customerId}', customerId.toString())}';

  static String getCustomerConnectionUndoUrl(int companyId, int customerId) =>
      '$baseUrl${customerConnectionUndoEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{customerId}', customerId.toString())}';

  static String getVendorConnectionAcceptUrl(int companyId, int vendorId) =>
      '$baseUrl${vendorConnectionAcceptEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{vendorId}', vendorId.toString())}';

  static String getVendorConnectionRejectUrl(int companyId, int vendorId) =>
      '$baseUrl${vendorConnectionRejectEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{vendorId}', vendorId.toString())}';

  static String getVendorConnectionUndoUrl(int companyId, int vendorId) =>
      '$baseUrl${vendorConnectionUndoEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{vendorId}', vendorId.toString())}';

  // Company CRUD URLs
  static String get createCompanyUrl => '$baseUrl$allCompaniesEndpoint';
  static String getCompanyDetailUrl(int companyId) =>
      '$baseUrl${companyDetailEndpoint.replaceAll('{companyId}', companyId.toString())}';
  static String getCompanyActivateUrl(int companyId) =>
      '$baseUrl${companyActivateEndpoint.replaceAll('{companyId}', companyId.toString())}';
  static String getCompanyDeactivateUrl(int companyId) =>
      '$baseUrl${companyDeactivateEndpoint.replaceAll('{companyId}', companyId.toString())}';
  static String getCompanyLogoUploadUrl(int companyId) =>
      '$baseUrl/api/companies/$companyId/logo';

  // ─── Notifications ───
  static String getNotificationsUrl(int companyId, {int page = 0}) =>
      '$baseUrl/api/companies/$companyId/notifications?page=$page';

  static String getUnreadCountUrl(int companyId) =>
      '$baseUrl/api/companies/$companyId/notifications/unread-count';

  static String getMarkReadUrl(int companyId, int notificationId) =>
      '$baseUrl/api/companies/$companyId/notifications/$notificationId/read';

  static String getMarkSubjectReadUrl(
    int companyId,
    String subjectType,
    int subjectId,
  ) =>
      '$baseUrl/api/companies/$companyId/notifications/subjects/$subjectType/$subjectId/read';

  static String getMarkAllReadUrl(int companyId) =>
      '$baseUrl/api/companies/$companyId/notifications/read-all';

  // ─── Device Tokens (FCM) ───
  static String get registerDeviceTokenUrl => '$baseUrl/api/device-tokens';
  static String get deregisterDeviceTokenUrl => '$baseUrl/api/device-tokens';

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

  static String getCustomerOrderPaymentTrendUrl(
    int companyId,
    int customerId,
    String startDate,
    String endDate,
  ) =>
      '$baseUrl/api/companies/$companyId/analytics/customers/$customerId/order-payment-trend?startDate=$startDate&endDate=$endDate';

  static String getVendorOrderPaymentTrendUrl(
    int companyId,
    int vendorId,
    String startDate,
    String endDate,
  ) =>
      '$baseUrl/api/companies/$companyId/analytics/vendors/$vendorId/order-payment-trend?startDate=$startDate&endDate=$endDate';

  static String getEmployeeAnalyticsOverviewUrl(
    int companyId,
    String startDate,
    String endDate,
  ) =>
      '$baseUrl/api/companies/$companyId/analytics/employees/overview?startDate=$startDate&endDate=$endDate';

  static String getEmployeeDailyAnalyticsUrl(
    int companyId,
    int employeeId,
    String startDate,
    String endDate,
  ) =>
      '$baseUrl/api/companies/$companyId/analytics/employees/$employeeId/daily?startDate=$startDate&endDate=$endDate';

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

  static String getOrderHistoryUrl(int c, String s, String e) =>
      '$baseUrl/api/companies/$c/analytics/history/orders?startDate=$s&endDate=$e';

  static String getPaymentHistoryUrl(int c, String s, String e) =>
      '$baseUrl/api/companies/$c/analytics/history/payments?startDate=$s&endDate=$e';

  static String getOperationalReportUrl(
    int companyId,
    String reportPath,
    String startDate,
    String endDate,
  ) =>
      '$baseUrl/api/companies/$companyId/analytics/reports/$reportPath?startDate=$startDate&endDate=$endDate';

  // ─── Employee Module (modemp) ───
  static const String employeesEndpoint =
      '/api/companies/{companyId}/modemp/employees';
  static const String employeeDetailEndpoint =
      '/api/companies/{companyId}/modemp/employees/{employeeId}';
  static const String employeeActivityLogsEndpoint =
      '/api/companies/{companyId}/modemp/employees/{employeeId}/activity-logs';
  static const String employeeDeactivateEndpoint =
      '/api/companies/{companyId}/modemp/employees/{employeeId}/deactivate';
  static const String employeeActivateEndpoint =
      '/api/companies/{companyId}/modemp/employees/{employeeId}/activate';
  static const String employeeSalaryConfigEndpoint =
      '/api/companies/{companyId}/modemp/employees/{employeeId}/salary-config';
  static const String employeeSalaryConfigHistoryEndpoint =
      '/api/companies/{companyId}/modemp/employees/{employeeId}/salary-config/history';
  static const String employeePortalUserEndpoint =
      '/api/companies/{companyId}/modemp/employees/{employeeId}/portal-user';
  static const String employeePortalUserResetPasswordEndpoint =
      '/api/companies/{companyId}/modemp/employees/{employeeId}/portal-user/reset-password';
  static const String employeePortalUserActivateEndpoint =
      '/api/companies/{companyId}/modemp/employees/{employeeId}/portal-user/activate';
  static const String employeePortalUserDeactivateEndpoint =
      '/api/companies/{companyId}/modemp/employees/{employeeId}/portal-user/deactivate';
  static const String workDefinitionsEndpoint =
      '/api/companies/{companyId}/modemp/work-definitions';
  static const String workDefinitionDetailEndpoint =
      '/api/companies/{companyId}/modemp/work-definitions/{workDefId}';
  static const String workDefinitionDeactivateEndpoint =
      '/api/companies/{companyId}/modemp/work-definitions/{workDefId}/deactivate';
  static const String workDefinitionActivateEndpoint =
      '/api/companies/{companyId}/modemp/work-definitions/{workDefId}/activate';
  static const String workDefinitionRateHistoryEndpoint =
      '/api/companies/{companyId}/modemp/work-definitions/{workDefId}/rate-history';
  static const String workLogsEndpoint =
      '/api/companies/{companyId}/modemp/work-logs';
  static const String updateWorkLogEmployeeEndpoint =
      '/api/companies/{companyId}/modemp/work-logs/employee';
  static const String updateLeaveLogEmployeeEndpoint =
      '/api/companies/{companyId}/modemp/leave-logs/employee';
  static const String workLogsByEmployeeEndpoint =
      '/api/companies/{companyId}/modemp/work-logs/employee/{employeeId}';
  static const String pendingWorkLogsEndpoint =
      '/api/companies/{companyId}/modemp/work-logs/pending';
  static const String reviewWorkLogEndpoint =
      '/api/companies/{companyId}/modemp/work-logs/{logId}/review';
  static const String updateWorkLogByAdminEndpoint =
      '/api/companies/{companyId}/modemp/work-logs/{logId}';
  static const String deleteWorkLogByAdminEndpoint =
      '/api/companies/{companyId}/modemp/work-logs/{logId}';
  static const String leaveLogsEndpoint =
      '/api/companies/{companyId}/modemp/leave-logs';
  static const String leaveLogsByEmployeeEndpoint =
      '/api/companies/{companyId}/modemp/leave-logs/employee/{employeeId}';
  static const String pendingLeaveLogsEndpoint =
      '/api/companies/{companyId}/modemp/leave-logs/pending';
  static const String reviewLeaveLogEndpoint =
      '/api/companies/{companyId}/modemp/leave-logs/{leaveId}/review';
  static const String updateLeaveLogByAdminEndpoint =
      '/api/companies/{companyId}/modemp/leave-logs/{leaveId}';
  static const String deleteLeaveLogByAdminEndpoint =
      '/api/companies/{companyId}/modemp/leave-logs/{leaveId}';
  static const String salaryCalculateEndpoint =
      '/api/companies/{companyId}/modemp/salary/calculate';
  static const String salaryPeriodsEndpoint =
      '/api/companies/{companyId}/modemp/salary/periods';
  static const String salaryPeriodDetailEndpoint =
      '/api/companies/{companyId}/modemp/salary/periods/{salaryPeriodId}';
  static const String salaryApproveEndpoint =
      '/api/companies/{companyId}/modemp/salary/periods/{salaryPeriodId}/approve';
  static const String salaryMarkPaidEndpoint =
      '/api/companies/{companyId}/modemp/salary/periods/{salaryPeriodId}/mark-paid';
  static const String salaryReportEndpoint =
      '/api/companies/{companyId}/modemp/salary/report';
  static const String salarySlipEndpoint =
      '/api/companies/{companyId}/modemp/salary/periods/{salaryPeriodId}/slip';
  static const String employeeLoginEndpoint = '/api/auth/employee/login';
  static const String employeeRefreshTokenEndpoint = '/api/auth/refresh-token';
  static const String employeeMeEndpoint = '/api/emp/me';
  static const String employeeMySalaryPeriodsEndpoint =
      '/api/emp/salary/periods';
  static const String employeeMySalaryReportEndpoint = '/api/emp/salary/report';
  static const String employeeMySalaryDetailEndpoint =
      '/api/emp/salary/periods/{salaryPeriodId}';
  static const String employeeMySalarySlipEndpoint =
      '/api/emp/salary/periods/{salaryPeriodId}/slip';
  static const String employeeMyWorkLogsEndpoint = '/api/emp/work-logs';
  static const String employeeMyLeaveLogsEndpoint = '/api/emp/leave-logs';
  static const String employeeWorkDefinitionsEndpoint =
      '/api/emp/work-definitions';

  static String getEmployeesUrl(int companyId, {bool? activeOnly}) {
    final base =
        '$baseUrl${employeesEndpoint.replaceAll('{companyId}', companyId.toString())}';
    if (activeOnly == null) return base;
    return '$base?activeOnly=$activeOnly';
  }

  static String getEmployeeDetailUrl(int companyId, int employeeId) =>
      '$baseUrl${employeeDetailEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{employeeId}', employeeId.toString())}';

  static String getEmployeeActivityLogsUrl(
    int companyId,
    int employeeId, {
    String? from,
    String? to,
  }) {
    final base =
        '$baseUrl${employeeActivityLogsEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{employeeId}', employeeId.toString())}';
    final params = <String>[
      if (from != null && from.isNotEmpty) 'from=$from',
      if (to != null && to.isNotEmpty) 'to=$to',
    ];
    if (params.isEmpty) return base;
    return '$base?${params.join('&')}';
  }

  static String getCreateEmployeeUrl(int companyId) =>
      '$baseUrl${employeesEndpoint.replaceAll('{companyId}', companyId.toString())}';

  static String getUpdateEmployeeUrl(int companyId, int employeeId) =>
      '$baseUrl${employeeDetailEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{employeeId}', employeeId.toString())}';

  static String getDeactivateEmployeeUrl(int companyId, int employeeId) =>
      '$baseUrl${employeeDeactivateEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{employeeId}', employeeId.toString())}';

  static String getActivateEmployeeUrl(int companyId, int employeeId) =>
      '$baseUrl${employeeActivateEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{employeeId}', employeeId.toString())}';

  static String getEmployeePortalUserActivateUrl(
    int companyId,
    int employeeId,
  ) =>
      '$baseUrl${employeePortalUserActivateEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{employeeId}', employeeId.toString())}';

  static String getEmployeePortalUserDeactivateUrl(
    int companyId,
    int employeeId,
  ) =>
      '$baseUrl${employeePortalUserDeactivateEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{employeeId}', employeeId.toString())}';

  static String getEmployeeSalaryConfigUrl(int companyId, int employeeId) =>
      '$baseUrl${employeeSalaryConfigEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{employeeId}', employeeId.toString())}';

  static String getEmployeeSalaryConfigHistoryUrl(
    int companyId,
    int employeeId,
  ) =>
      '$baseUrl${employeeSalaryConfigHistoryEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{employeeId}', employeeId.toString())}';

  static String getEmployeePortalUserUrl(int companyId, int employeeId) =>
      '$baseUrl${employeePortalUserEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{employeeId}', employeeId.toString())}';

  static String getEmployeePortalUserResetPasswordUrl(
    int companyId,
    int employeeId,
  ) =>
      '$baseUrl${employeePortalUserResetPasswordEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{employeeId}', employeeId.toString())}';

  static String getWorkDefinitionsUrl(int companyId, {bool? activeOnly}) {
    final base =
        '$baseUrl${workDefinitionsEndpoint.replaceAll('{companyId}', companyId.toString())}';
    if (activeOnly == null) return base;
    return '$base?activeOnly=$activeOnly';
  }

  static String getWorkDefinitionDetailUrl(int companyId, int workDefId) =>
      '$baseUrl${workDefinitionDetailEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{workDefId}', workDefId.toString())}';

  static String getDeactivateWorkDefinitionUrl(int companyId, int workDefId) =>
      '$baseUrl${workDefinitionDeactivateEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{workDefId}', workDefId.toString())}';

  static String getActivateWorkDefinitionUrl(int companyId, int workDefId) =>
      '$baseUrl${workDefinitionActivateEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{workDefId}', workDefId.toString())}';

  static String getWorkDefinitionRateHistoryUrl(int companyId, int workDefId) =>
      '$baseUrl${workDefinitionRateHistoryEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{workDefId}', workDefId.toString())}';

  static String getWorkLogsUrl(int companyId, {String? from, String? to}) {
    final base =
        '$baseUrl${workLogsEndpoint.replaceAll('{companyId}', companyId.toString())}';
    final params = <String>[
      if (from != null && from.isNotEmpty) 'from=$from',
      if (to != null && to.isNotEmpty) 'to=$to',
    ];
    if (params.isEmpty) return base;
    return '$base?${params.join('&')}';
  }

  static String getWorkLogsByEmployeeUrl(
    int companyId,
    int employeeId, {
    String? from,
    String? to,
  }) {
    final base =
        '$baseUrl${workLogsByEmployeeEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{employeeId}', employeeId.toString())}';
    final params = <String>[
      if (from != null && from.isNotEmpty) 'from=$from',
      if (to != null && to.isNotEmpty) 'to=$to',
    ];
    if (params.isEmpty) return base;
    return '$base?${params.join('&')}';
  }

  static String getPendingWorkLogsUrl(int companyId) =>
      '$baseUrl${pendingWorkLogsEndpoint.replaceAll('{companyId}', companyId.toString())}';

  static String getReviewWorkLogUrl(int companyId, int logId) =>
      '$baseUrl${reviewWorkLogEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{logId}', logId.toString())}';

  static String getUpdateWorkLogByAdminUrl(int companyId, int logId) =>
      '$baseUrl${updateWorkLogByAdminEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{logId}', logId.toString())}';

  static String getDeleteWorkLogByAdminUrl(int companyId, int logId) =>
      '$baseUrl${deleteWorkLogByAdminEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{logId}', logId.toString())}';

  static String getLeaveLogsUrl(int companyId, {String? from, String? to}) {
    final base =
        '$baseUrl${leaveLogsEndpoint.replaceAll('{companyId}', companyId.toString())}';
    final params = <String>[
      if (from != null && from.isNotEmpty) 'from=$from',
      if (to != null && to.isNotEmpty) 'to=$to',
    ];
    if (params.isEmpty) return base;
    return '$base?${params.join('&')}';
  }

  static String getLeaveLogsByEmployeeUrl(
    int companyId,
    int employeeId, {
    String? from,
    String? to,
  }) {
    final base =
        '$baseUrl${leaveLogsByEmployeeEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{employeeId}', employeeId.toString())}';
    final params = <String>[
      if (from != null && from.isNotEmpty) 'from=$from',
      if (to != null && to.isNotEmpty) 'to=$to',
    ];
    if (params.isEmpty) return base;
    return '$base?${params.join('&')}';
  }

  static String getPendingLeaveLogsUrl(int companyId) =>
      '$baseUrl${pendingLeaveLogsEndpoint.replaceAll('{companyId}', companyId.toString())}';

  static String getReviewLeaveLogUrl(int companyId, int leaveId) =>
      '$baseUrl${reviewLeaveLogEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{leaveId}', leaveId.toString())}';

  static String getUpdateLeaveLogByAdminUrl(int companyId, int leaveId) =>
      '$baseUrl${updateLeaveLogByAdminEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{leaveId}', leaveId.toString())}';

  static String getDeleteLeaveLogByAdminUrl(int companyId, int leaveId) =>
      '$baseUrl${deleteLeaveLogByAdminEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{leaveId}', leaveId.toString())}';

  static String getSalaryCalculateUrl(int companyId) =>
      '$baseUrl${salaryCalculateEndpoint.replaceAll('{companyId}', companyId.toString())}';

  static String getSalaryPeriodsUrl(int companyId, {String? period}) {
    final base =
        '$baseUrl${salaryPeriodsEndpoint.replaceAll('{companyId}', companyId.toString())}';
    if (period == null || period.isEmpty) return base;
    return '$base?period=$period';
  }

  static String getSalaryPeriodDetailUrl(int companyId, int salaryPeriodId) =>
      '$baseUrl${salaryPeriodDetailEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{salaryPeriodId}', salaryPeriodId.toString())}';

  static String getDeleteSalaryPeriodUrl(int companyId, int salaryPeriodId) =>
      getSalaryPeriodDetailUrl(companyId, salaryPeriodId);

  static String getApproveSalaryPeriodUrl(int companyId, int salaryPeriodId) =>
      '$baseUrl${salaryApproveEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{salaryPeriodId}', salaryPeriodId.toString())}';

  static String getMarkSalaryPaidUrl(int companyId, int salaryPeriodId) =>
      '$baseUrl${salaryMarkPaidEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{salaryPeriodId}', salaryPeriodId.toString())}';

  static String getSalaryReportUrl(
    int companyId, {
    required String from,
    required String to,
  }) =>
      '$baseUrl${salaryReportEndpoint.replaceAll('{companyId}', companyId.toString())}?from=$from&to=$to';

  static String getSalarySlipUrl(int companyId, int salaryPeriodId) =>
      '$baseUrl${salarySlipEndpoint.replaceAll('{companyId}', companyId.toString()).replaceAll('{salaryPeriodId}', salaryPeriodId.toString())}';

  static String get employeeLoginUrl => '$baseUrl$employeeLoginEndpoint';

  static String get employeeRefreshTokenUrl =>
      '$baseUrl$employeeRefreshTokenEndpoint';

  static String get employeeMeUrl => '$baseUrl$employeeMeEndpoint';

  static String getEmployeeMySalaryPeriodsUrl({
    String? from,
    String? to,
    String? period,
  }) {
    final base = '$baseUrl$employeeMySalaryPeriodsEndpoint';
    final params = <String>[
      if (from != null && from.isNotEmpty) 'from=$from',
      if (to != null && to.isNotEmpty) 'to=$to',
      if (period != null && period.isNotEmpty) 'period=$period',
    ];
    if (params.isEmpty) return base;
    return '$base?${params.join('&')}';
  }

  static String getUpdateWorkLogEmployeeUrl(int companyId) =>
      '$baseUrl${updateWorkLogEmployeeEndpoint.replaceAll('{companyId}', companyId.toString())}';

  static String getUpdateLeaveLogEmployeeUrl(int companyId) =>
      '$baseUrl${updateLeaveLogEmployeeEndpoint.replaceAll('{companyId}', companyId.toString())}';

  static String getEmployeeMySalaryReportUrl({
    required String from,
    required String to,
  }) => '$baseUrl$employeeMySalaryReportEndpoint?from=$from&to=$to';

  static String getEmployeeMySalaryDetailUrl(int salaryPeriodId) =>
      '$baseUrl${employeeMySalaryDetailEndpoint.replaceAll('{salaryPeriodId}', salaryPeriodId.toString())}';

  static String getEmployeeMySalarySlipUrl(int salaryPeriodId) =>
      '$baseUrl${employeeMySalarySlipEndpoint.replaceAll('{salaryPeriodId}', salaryPeriodId.toString())}';

  static String getEmployeeMyWorkLogsUrl({String? from, String? to}) {
    final base = '$baseUrl$employeeMyWorkLogsEndpoint';
    final params = <String>[
      if (from != null && from.isNotEmpty) 'from=$from',
      if (to != null && to.isNotEmpty) 'to=$to',
    ];
    if (params.isEmpty) return base;
    return '$base?${params.join('&')}';
  }

  static String getEmployeeMyLeaveLogsUrl({String? from, String? to}) {
    final base = '$baseUrl$employeeMyLeaveLogsEndpoint';
    final params = <String>[
      if (from != null && from.isNotEmpty) 'from=$from',
      if (to != null && to.isNotEmpty) 'to=$to',
    ];
    if (params.isEmpty) return base;
    return '$base?${params.join('&')}';
  }

  static String getEmployeeWorkDefinitionsUrl({bool? activeOnly}) {
    final base = '$baseUrl$employeeWorkDefinitionsEndpoint';
    if (activeOnly == null) return base;
    return '$base?activeOnly=$activeOnly';
  }

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
