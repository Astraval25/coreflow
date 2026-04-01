import 'package:coreflow/data/repositories/auth_repository.dart';
import 'package:coreflow/features/customers/view/customer_create_page.dart';
import 'package:coreflow/features/customers/view/customer_detail_page.dart';
import 'package:coreflow/features/customers/view/customer_edit_page.dart';
import 'package:coreflow/features/dashboard/dashboard_view/notification_page.dart';
import 'package:coreflow/features/items/view/create_item_screen.dart';
import 'package:coreflow/features/items/view/item_detail_view.dart';
import 'package:coreflow/features/items/view/items_view.dart';
import 'package:coreflow/features/auth/registration/view/register_screen.dart';
import 'package:coreflow/features/customers/view/customers_page.dart';
import 'package:coreflow/features/dashboard/dashboard_view/dashboard_page.dart';
import 'package:coreflow/features/auth/login/view/login_page.dart';
import 'package:coreflow/features/profile/view_page/profile_page.dart';
import 'package:coreflow/features/resend_otp/view/resend_otp_sreen.dart';
import 'package:coreflow/features/settings/view/settings_page.dart';
import 'package:coreflow/features/legal/view/privacy_policy_page.dart';
import 'package:coreflow/features/legal/view/terms_of_service_page.dart';
import 'package:coreflow/features/vendor/view/vendor_create_page.dart';
import 'package:coreflow/features/vendor/view/vendor_detail_page.dart';
import 'package:coreflow/features/vendor/view/vendor_edit_page.dart';
import 'package:coreflow/features/company/view/manage_companies_page.dart';
import 'package:coreflow/features/marketplace/view/marketplace_page.dart';
import 'package:coreflow/features/marketplace/view/company_profile_page.dart';
import 'package:coreflow/features/vendor/view/vendor_page.dart';
import 'package:coreflow/features/verify_otp/view/verify_otp_screen.dart';
import 'package:coreflow/features/dashboard/widget/main_layout.dart';
import 'package:coreflow/features/sales/view/sales_page.dart';
import 'package:coreflow/features/sales/view/create_sales_order_page.dart';
import 'package:coreflow/features/purchase/view/purchase_page.dart';
import 'package:coreflow/features/purchase/view/create_purchase_order_page.dart';
import 'package:coreflow/features/payment/send_payment/view/payment_page.dart';
import 'package:coreflow/features/payment/send_payment/view/create_payment_sent_page.dart';
import 'package:coreflow/features/payment/receive_payment/view/pay_received_page.dart';
import 'package:coreflow/features/payment/receive_payment/view/create_receive_payment_page.dart';
import 'package:coreflow/features/report/view/report_list_page.dart';
import 'package:coreflow/features/splash/view/splash_page.dart';
import 'package:go_router/go_router.dart';


final _authRepo = AuthRepository();
final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashPage()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/verify/:userPath',
      builder: (context, state) =>
          VerifyOtpScreen(userPath: state.pathParameters['userPath']),
    ),
    GoRoute(
      path: '/verify',
      builder: (context, state) =>
          VerifyOtpScreen(userPath: state.uri.queryParameters['email']),
    ),
    GoRoute(
      path: '/resend-otp',
      builder: (context, state) => const ResendOtpScreen(),
    ),

    // Shell Route for Main Layout
    ShellRoute(
      builder: (context, state, child) {
        return MainLayout(child: child);
      },
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardPage(),
        ),
        GoRoute(
          path: '/:role/dashboard',
          builder: (context, state) =>
              DashboardPage(role: state.pathParameters['role']),
        ),
        GoRoute(
          path: '/dashboard/notifications/:companyId',
          builder: (context, state) => NotificationPage(
            companyId: int.parse(state.pathParameters['companyId'] ?? '0'),
          ),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfilePage(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsPage(),
        ),
        GoRoute(
          path: '/privacy-policy',
          builder: (context, state) => const PrivacyPolicyPage(),
        ),
        GoRoute(
          path: '/terms-of-service',
          builder: (context, state) => const TermsOfServicePage(),
        ),
        GoRoute(
          path: '/sales',
          builder: (context, state) => const SalesPage(),
        ),
        GoRoute(
          path: '/sales/:companyId/create',
          builder: (context, state) {
            final companyId = int.parse(state.pathParameters['companyId']!);
            final extra = state.extra as Map<String, dynamic>?;
            return CreateSalesOrderPage(
              companyId: companyId,
              preSelectedCustomer: extra?['preSelectedCustomer'] as Map<String, dynamic>?,
            );
          },
        ),
        GoRoute(
          path: '/purchase',
          builder: (context, state) => const PurchasePage(),
        ),
        GoRoute(
          path: '/purchase/:companyId/create',
          builder: (context, state) {
            final companyId = int.parse(state.pathParameters['companyId']!);
            final extra = state.extra as Map<String, dynamic>?;
            return CreatePurchaseOrderPage(
              companyId: companyId,
              preSelectedVendor: extra?['preSelectedVendor'] as Map<String, dynamic>?,
            );
          },
        ),
        GoRoute(
          path: '/payment',
          builder: (context, state) => const PaymentPage(),
        ),
        GoRoute(
          path: '/payment/:companyId/create',
          builder: (context, state) {
            final companyId = int.parse(state.pathParameters['companyId']!);
            final extra = state.extra as Map<String, dynamic>?;
            return CreatePaymentSentPage(
              companyId: companyId,
              preSelectedVendor: extra?['preSelectedVendor'] as Map<String, dynamic>?,
            );
          },
        ),
        GoRoute(
          path: '/pay-received',
          builder: (context, state) => const PayReceivedPage(),
        ),
        GoRoute(
          path: '/pay-received/:companyId/create',
          builder: (context, state) {
            final companyId = int.parse(state.pathParameters['companyId']!);
            final extra = state.extra as Map<String, dynamic>?;
            return CreateReceivePaymentPage(
              companyId: companyId,
              preSelectedCustomer: extra?['preSelectedCustomer'] as Map<String, dynamic>?,
            );
          },
        ),
        GoRoute(
          path: '/manage-companies',
          builder: (context, state) => const ManageCompaniesPage(),
        ),
        GoRoute(
          path: '/report/:companyId',
          builder: (context, state) {
            final companyId = int.parse(state.pathParameters['companyId']!);
            return ReportListPage(companyId: companyId);
          },
        ),
        // Customers route inside shell
        GoRoute(
          path: '/customers/:companyId',
          builder: (context, state) {
            final companyId = int.parse(state.pathParameters['companyId']!);
            return ActiveCustomersPage(companyId: companyId);
          },
          routes: [
            GoRoute(
              path: 'add',
              builder: (context, state) {
                final companyId = int.parse(state.pathParameters['companyId']!);
                return CustomerCreatePage(companyId: companyId);
              },
            ),
            GoRoute(
              path: ':customerId',
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
              routes: [
                GoRoute(
                  path: 'edit',
                  builder: (context, state) {
                    final companyId = int.parse(
                      state.pathParameters['companyId']!,
                    );
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
          ],
        ),
        // Vendors route inside shell
        GoRoute(
          path: '/vendors/:companyId',
          builder: (context, state) {
            final companyId = int.parse(state.pathParameters['companyId']!);
            return ActiveVendorsPage(companyId: companyId);
          },
          routes: [
            GoRoute(
              path: 'add',
              builder: (context, state) {
                final companyId = int.parse(state.pathParameters['companyId']!);
                return VendorCreatePage(companyId: companyId);
              },
            ),
            GoRoute(
              path: ':vendorId',
              builder: (context, state) {
                final companyId = int.parse(state.pathParameters['companyId']!);
                final vendorId = int.parse(state.pathParameters['vendorId']!);
                return VendorDetailView(
                  companyId: companyId,
                  vendorId: vendorId,
                );
              },
              routes: [
                GoRoute(
                  path: 'edit',
                  builder: (context, state) {
                    final companyId = int.parse(
                      state.pathParameters['companyId']!,
                    );
                    final vendorId = int.parse(
                      state.pathParameters['vendorId']!,
                    );
                    return VendorEditPage(
                      companyId: companyId,
                      vendorId: vendorId,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        // Marketplace routes
        GoRoute(
          path: '/marketplace',
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
        // Items route inside shell
        GoRoute(
          path: '/items/:companyId',
          builder: (context, state) {
            final companyId = int.parse(state.pathParameters['companyId']!);
            return ItemsPage(companyId: companyId);
          },
          routes: [
            GoRoute(
              path: 'add',
              builder: (context, state) {
                final companyId = int.parse(state.pathParameters['companyId']!);
                return CreateItemScreen(companyId: companyId);
              },
            ),
            GoRoute(
              path: ':itemId',
              builder: (context, state) {
                final companyId = int.parse(state.pathParameters['companyId']!);
                final itemId = int.parse(state.pathParameters['itemId']!);
                return ItemDetailView(companyId: companyId, itemId: itemId);
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

    final publicRoutes = ['/login', '/register', '/resend-otp', '/verify'];
    final isPublicRoute = publicRoutes.any(
      (route) => location.startsWith(route),
    );

    if (!isLoggedIn && !isPublicRoute) return '/login';
    if (isLoggedIn && location == '/login') return '/dashboard';
    return null;
  },
);
