import 'package:coreflow/data/repositories/auth_repository/auth_repository.dart';
import 'package:coreflow/core/storage/token_storage.dart';
import 'package:coreflow/features/main_feature/customers/view/customer_create_page.dart';
import 'package:coreflow/features/main_feature/customers/view/customer_detail_page.dart';
import 'package:coreflow/features/main_feature/customers/view/customer_edit_page.dart';
import 'package:coreflow/features/main_feature/dashboard/dashboard_view/notification_page.dart';
import 'package:coreflow/features/main_feature/items/view/create_item_screen.dart';
import 'package:coreflow/features/main_feature/items/view/item_detail_view.dart';
import 'package:coreflow/features/main_feature/items/view/items_view.dart';
import 'package:coreflow/features/auth_feature/registration/view/register_screen.dart';
import 'package:coreflow/features/main_feature/customers/view/customers_page.dart';
import 'package:coreflow/features/main_feature/dashboard/dashboard_view/dashboard_page.dart';
import 'package:coreflow/features/auth_feature/login/view/login_page.dart';
import 'package:coreflow/features/main_feature/profile/view_page/profile_page.dart';
import 'package:coreflow/features/auth_feature/resend_otp/view/resend_otp_sreen.dart';
import 'package:coreflow/features/main_feature/settings/view/settings_page.dart';
import 'package:coreflow/features/main_feature/legal/view/privacy_policy_page.dart';
import 'package:coreflow/features/main_feature/legal/view/terms_of_service_page.dart';
import 'package:coreflow/features/main_feature/vendor/view/vendor_create_page.dart';
import 'package:coreflow/features/main_feature/vendor/view/vendor_detail_page.dart';
import 'package:coreflow/features/main_feature/vendor/view/vendor_edit_page.dart';
import 'package:coreflow/features/main_feature/company/view/manage_companies_page.dart';
import 'package:coreflow/features/main_feature/marketplace/view/marketplace_page.dart';
import 'package:coreflow/features/main_feature/marketplace/view/company_profile_page.dart';
import 'package:coreflow/features/main_feature/vendor/view/vendor_page.dart';
import 'package:coreflow/features/auth_feature/verify_otp/view/verify_otp_screen.dart';
import 'package:coreflow/features/main_feature/dashboard/widget/main_layout.dart';
import 'package:coreflow/features/main_feature/sales/view/sales_page.dart';
import 'package:coreflow/features/main_feature/sales/view/create_sales_order_page.dart';
import 'package:coreflow/features/main_feature/purchase/view/purchase_page.dart';
import 'package:coreflow/features/main_feature/purchase/view/create_purchase_order_page.dart';
import 'package:coreflow/features/main_feature/payment/send_payment/view/payment_page.dart';
import 'package:coreflow/features/main_feature/payment/send_payment/view/create_payment_sent_page.dart';
import 'package:coreflow/features/main_feature/payment/receive_payment/view/pay_received_page.dart';
import 'package:coreflow/features/main_feature/payment/receive_payment/view/create_receive_payment_page.dart';
import 'package:coreflow/features/main_feature/expense/view/create_expense_page.dart';
import 'package:coreflow/features/main_feature/expense/view/expenses_page.dart';
import 'package:coreflow/features/main_feature/report/view/report_list_page.dart';
import 'package:coreflow/core/utils/splash/view/splash_page.dart';
import 'package:coreflow/features/employee_feature/employees/view/employees_page.dart';
import 'package:coreflow/features/employee_feature/employees/view/employee_detail_page.dart';
import 'package:coreflow/features/employee_feature/employees/view/employee_view_page.dart';
import 'package:coreflow/features/employee_feature/employees/view/employee_create_page.dart';
import 'package:coreflow/features/employee_feature/employees/view/employee_edit_page.dart';
import 'package:coreflow/features/employee_feature/leave_logs/view/admin_leave_logs_page.dart';
import 'package:coreflow/features/employee_feature/portal/view/employee_portal_page.dart';
import 'package:coreflow/features/employee_feature/salary/view/admin_salary_page.dart';
import 'package:coreflow/features/employee_feature/work_definitions/view/work_definitions_page.dart';
import 'package:coreflow/features/employee_feature/work_logs/view/admin_work_logs_page.dart';
import 'package:coreflow/routing/cf_routes.dart';
import 'package:go_router/go_router.dart';

final _authRepo = AuthRepository();
final GoRouter router = GoRouter(
  initialLocation: '/',
  refreshListenable: TokenStorage.authStateNotifier,
  routes: [
    // Splash
    GoRoute(path: '/', builder: (context, state) => const SplashPage()),

    // ── Auth ────────────────────────────────────────────────────────────
    GoRoute(
      path: CfRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: CfRoutes.register,
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/cf/auth/verify/:userPath',
      builder: (context, state) =>
          VerifyOtpScreen(userPath: state.pathParameters['userPath']),
    ),
    GoRoute(
      path: CfRoutes.verifyBase,
      builder: (context, state) =>
          VerifyOtpScreen(userPath: state.uri.queryParameters['email']),
    ),
    GoRoute(
      path: CfRoutes.resendOtp,
      builder: (context, state) => const ResendOtpScreen(),
    ),
    GoRoute(
      path: CfRoutes.employeePortalHome,
      builder: (context, state) => const EmployeePortalPage(),
    ),

    // ── Legal ───────────────────────────────────────────────────────────
    GoRoute(
      path: CfRoutes.privacyPolicy,
      builder: (context, state) => const PrivacyPolicyPage(),
    ),
    GoRoute(
      path: CfRoutes.termsOfService,
      builder: (context, state) => const TermsOfServicePage(),
    ),

    // ── Shell Route for Main Layout ─────────────────────────────────────
    ShellRoute(
      builder: (context, state, child) {
        return MainLayout(child: child);
      },
      routes: [
        // ── Company Management ──────────────────────────────────────────
        GoRoute(
          path: CfRoutes.companyList,
          builder: (context, state) => const ManageCompaniesPage(),
        ),

        // ── Dashboard ───────────────────────────────────────────────────
        GoRoute(
          path: '/cf/company/:companyId/dashboard',
          builder: (context, state) => const DashboardPage(),
        ),

        // ── Notifications ───────────────────────────────────────────────
        GoRoute(
          path: '/cf/company/:companyId/notifications',
          builder: (context, state) => NotificationPage(
            companyId: int.parse(state.pathParameters['companyId'] ?? '0'),
          ),
        ),

        // ── User ────────────────────────────────────────────────────────
        GoRoute(
          path: '/cf/user/:userId/profile',
          builder: (context, state) => const ProfilePage(),
        ),
        GoRoute(
          path: '/cf/user/:userId/settings',
          builder: (context, state) => const SettingsPage(),
        ),

        // ── Customers ───────────────────────────────────────────────────
        GoRoute(
          path: '/cf/company/:companyId/customers',
          builder: (context, state) {
            final companyId = int.parse(state.pathParameters['companyId']!);
            return ActiveCustomersPage(companyId: companyId);
          },
          routes: [
            GoRoute(
              path: 'create',
              builder: (context, state) {
                final companyId = int.parse(state.pathParameters['companyId']!);
                return CustomerCreatePage(companyId: companyId);
              },
            ),
            GoRoute(
              path: ':customerId/detail',
              builder: (context, state) {
                final companyId = int.parse(state.pathParameters['companyId']!);
                final customerId = int.parse(
                  state.pathParameters['customerId']!,
                );
                return CustomerDetailView(
                  companyId: companyId,
                  customerId: customerId,
                );
              },
            ),
            GoRoute(
              path: ':customerId/update',
              builder: (context, state) {
                final companyId = int.parse(state.pathParameters['companyId']!);
                final customerId = int.parse(
                  state.pathParameters['customerId']!,
                );
                return CustomerEditPage(
                  companyId: companyId,
                  customerId: customerId,
                );
              },
            ),
          ],
        ),

        // ── Vendors ─────────────────────────────────────────────────────
        GoRoute(
          path: '/cf/company/:companyId/vendors',
          builder: (context, state) {
            final companyId = int.parse(state.pathParameters['companyId']!);
            return ActiveVendorsPage(companyId: companyId);
          },
          routes: [
            GoRoute(
              path: 'create',
              builder: (context, state) {
                final companyId = int.parse(state.pathParameters['companyId']!);
                return VendorCreatePage(companyId: companyId);
              },
            ),
            GoRoute(
              path: ':vendorId/detail',
              builder: (context, state) {
                final companyId = int.parse(state.pathParameters['companyId']!);
                final vendorId = int.parse(state.pathParameters['vendorId']!);
                return VendorDetailView(
                  companyId: companyId,
                  vendorId: vendorId,
                );
              },
            ),
            GoRoute(
              path: ':vendorId/update',
              builder: (context, state) {
                final companyId = int.parse(state.pathParameters['companyId']!);
                final vendorId = int.parse(state.pathParameters['vendorId']!);
                return VendorEditPage(companyId: companyId, vendorId: vendorId);
              },
            ),
          ],
        ),

        // ── Employees ────────────────────────────────────────────────────
        GoRoute(
          path: '/cf/company/:companyId/employees',
          builder: (context, state) {
            final companyId = int.parse(state.pathParameters['companyId']!);
            return EmployeesPage(companyId: companyId);
          },
          routes: [
            GoRoute(
              path: 'create',
              builder: (context, state) {
                final companyId = int.parse(state.pathParameters['companyId']!);
                return EmployeeCreatePage(companyId: companyId);
              },
            ),
            GoRoute(
              path: ':employeeId/detail',
              builder: (context, state) {
                final companyId = int.parse(state.pathParameters['companyId']!);
                final employeeId = int.parse(
                  state.pathParameters['employeeId']!,
                );
                return EmployeeViewPage(
                  companyId: companyId,
                  employeeId: employeeId,
                );
              },
            ),
            GoRoute(
              path: ':employeeId/profile',
              builder: (context, state) {
                final companyId = int.parse(state.pathParameters['companyId']!);
                final employeeId = int.parse(
                  state.pathParameters['employeeId']!,
                );
                return EmployeeDetailPage(
                  companyId: companyId,
                  employeeId: employeeId,
                );
              },
            ),
            GoRoute(
              path: ':employeeId/update',
              builder: (context, state) {
                final companyId = int.parse(state.pathParameters['companyId']!);
                final employeeId = int.parse(
                  state.pathParameters['employeeId']!,
                );
                return EmployeeEditPage(
                  companyId: companyId,
                  employeeId: employeeId,
                );
              },
            ),
          ],
        ),

        // ── Items ───────────────────────────────────────────────────────
        GoRoute(
          path: '/cf/company/:companyId/work-definitions',
          builder: (context, state) {
            final companyId = int.parse(state.pathParameters['companyId']!);
            return WorkDefinitionsPage(companyId: companyId);
          },
        ),
        GoRoute(
          path: '/cf/company/:companyId/employee-work-logs',
          builder: (context, state) {
            final companyId = int.parse(state.pathParameters['companyId']!);
            return AdminWorkLogsPage(companyId: companyId);
          },
        ),
        GoRoute(
          path: '/cf/company/:companyId/employee-leave-requests',
          builder: (context, state) {
            final companyId = int.parse(state.pathParameters['companyId']!);
            return AdminLeaveLogsPage(companyId: companyId);
          },
        ),
        GoRoute(
          path: '/cf/company/:companyId/employee-salary',
          builder: (context, state) {
            final companyId = int.parse(state.pathParameters['companyId']!);
            return AdminSalaryPage(companyId: companyId);
          },
        ),
        GoRoute(
          path: '/cf/company/:companyId/items',
          builder: (context, state) {
            final companyId = int.parse(state.pathParameters['companyId']!);
            return ItemsPage(companyId: companyId);
          },
          routes: [
            GoRoute(
              path: 'create',
              builder: (context, state) {
                final companyId = int.parse(state.pathParameters['companyId']!);
                return CreateItemScreen(companyId: companyId);
              },
            ),
            GoRoute(
              path: ':itemId/detail',
              builder: (context, state) {
                final companyId = int.parse(state.pathParameters['companyId']!);
                final itemId = int.parse(state.pathParameters['itemId']!);
                return ItemDetailView(companyId: companyId, itemId: itemId);
              },
            ),
          ],
        ),

        // ── Sales ───────────────────────────────────────────────────────
        GoRoute(
          path: '/cf/company/:companyId/sales',
          builder: (context, state) => const SalesPage(),
          routes: [
            GoRoute(
              path: 'create',
              builder: (context, state) {
                final companyId = int.parse(state.pathParameters['companyId']!);
                final extra = state.extra as Map<String, dynamic>?;
                return CreateSalesOrderPage(
                  companyId: companyId,
                  preSelectedCustomer:
                      extra?['preSelectedCustomer'] as Map<String, dynamic>?,
                );
              },
            ),
          ],
        ),

        // ── Purchase ────────────────────────────────────────────────────
        GoRoute(
          path: '/cf/company/:companyId/purchase/list',
          builder: (context, state) => const PurchasePage(),
        ),
        GoRoute(
          path: '/cf/company/:companyId/purchase/create',
          builder: (context, state) {
            final companyId = int.parse(state.pathParameters['companyId']!);
            final extra = state.extra as Map<String, dynamic>?;
            return CreatePurchaseOrderPage(
              companyId: companyId,
              preSelectedVendor:
                  extra?['preSelectedVendor'] as Map<String, dynamic>?,
            );
          },
        ),

        // ── Payment Made ────────────────────────────────────────────────
        GoRoute(
          path: '/cf/company/:companyId/payment-made/list',
          builder: (context, state) => const PaymentPage(),
        ),
        GoRoute(
          path: '/cf/company/:companyId/payment-made/create',
          builder: (context, state) {
            final companyId = int.parse(state.pathParameters['companyId']!);
            final extra = state.extra as Map<String, dynamic>?;
            return CreatePaymentSentPage(
              companyId: companyId,
              preSelectedVendor:
                  extra?['preSelectedVendor'] as Map<String, dynamic>?,
            );
          },
        ),

        // ── Payment Received ────────────────────────────────────────────
        GoRoute(
          path: '/cf/company/:companyId/payment-received/list',
          builder: (context, state) => const PayReceivedPage(),
        ),
        GoRoute(
          path: '/cf/company/:companyId/payment-received/create',
          builder: (context, state) {
            final companyId = int.parse(state.pathParameters['companyId']!);
            final extra = state.extra as Map<String, dynamic>?;
            return CreateReceivePaymentPage(
              companyId: companyId,
              preSelectedCustomer:
                  extra?['preSelectedCustomer'] as Map<String, dynamic>?,
            );
          },
        ),

        // Expenses
        GoRoute(
          path: '/cf/company/:companyId/expenses/list',
          builder: (context, state) {
            final companyId = int.parse(state.pathParameters['companyId']!);
            return ExpensesPage(companyId: companyId);
          },
        ),
        GoRoute(
          path: '/cf/company/:companyId/expenses/create',
          builder: (context, state) {
            final companyId = int.parse(state.pathParameters['companyId']!);
            return CreateExpensePage(companyId: companyId);
          },
        ),

        // ── Report ──────────────────────────────────────────────────────
        GoRoute(
          path: '/cf/company/:companyId/report/customers',
          builder: (context, state) {
            final companyId = int.parse(state.pathParameters['companyId']!);
            return ReportListPage(companyId: companyId);
          },
        ),

        // ── Marketplace ─────────────────────────────────────────────────
        GoRoute(
          path: CfRoutes.marketplace,
          builder: (context, state) => const MarketplacePage(),
          routes: [
            GoRoute(
              path: ':companyId',
              builder: (context, state) {
                final companyId = int.parse(state.pathParameters['companyId']!);
                return CompanyProfilePage(companyId: companyId);
              },
            ),
          ],
        ),
      ],
    ),
  ],
  redirect: (context, state) async {
    final isLoggedIn = await _authRepo.isLoggedIn();
    final location = state.matchedLocation;

    // Splash handles its own auth check
    if (location == '/') return null;

    final publicRoutes = [
      CfRoutes.login,
      CfRoutes.register,
      CfRoutes.resendOtp,
      CfRoutes.verifyBase,
      CfRoutes.privacyPolicy,
      CfRoutes.termsOfService,
    ];
    final isPublicRoute = publicRoutes.any(
      (route) => location.startsWith(route),
    );

    if (!isLoggedIn && !isPublicRoute) return CfRoutes.login;
    if (isLoggedIn && location == CfRoutes.login) {
      final authData = await _authRepo.getAuthData();
      final isEmployee =
          authData?['roleCode']?.toString().toUpperCase() == 'EMP' ||
          authData?['authType']?.toString().toLowerCase() == 'employee';
      if (isEmployee) return CfRoutes.employeePortalHome;
      return null;
    }
    return null;
  },
);
