import 'package:coreflow/features/customers/view/add/add_customer_page.dart';
import 'package:coreflow/features/items/view/add/add_items_page.dart';
import 'package:coreflow/features/items/view/items_page.dart';
import 'package:coreflow/features/vender/view/add/add_vender_page.dart';
import 'package:coreflow/features/customers/view/customers_page.dart';
import 'package:coreflow/features/dashboard/dashboard_view/dashboard_page.dart';
import 'package:coreflow/features/vender/view/vender_page.dart';
import 'package:coreflow/features/login/view/login_page.dart';
import 'package:coreflow/features/profile/view_page/profile_page.dart';
import 'package:coreflow/features/registration/view/register_screen.dart';
import 'package:coreflow/features/resend_otp/view/resend_otp_sreen.dart';
import 'package:coreflow/features/verify_otp/view/verify_otp_screen.dart';
import 'package:go_router/go_router.dart';
import '../../../data/repositories/auth_repository.dart';

final _authRepo = AuthRepository();

final GoRouter router = GoRouter(
  initialLocation: '/login',

  routes: [
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
    GoRoute(
      path: '/:role/dashboard',
      builder: (context, state) =>
          DashboardPage(role: state.pathParameters['role']),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardPage(),
    ),
    GoRoute(path: '/profile', builder: (context, state) => const ProfilePage()),

    GoRoute(
      path: '/customers',
      builder: (context, state) => const CustomersPage(),
    ),
    GoRoute(path: '/vender', builder: (context, state) => const VenderPage()),
    GoRoute(path: '/items', builder: (context, state) => const ItemsPage()),

    GoRoute(
      path: '/customersadd',
      builder: (context, state) => const AddCustomerPage(),
    ),
    GoRoute(
      path: '/venderadd',
      builder: (context, state) => const AddVenderPage(),
    ),
    GoRoute(
      path: '/itemsadd',
      builder: (context, state) => const AddItemsPage(),
    ),
  ],

  redirect: (context, state) async {
    final authData = await _authRepo.getAuthData();
    final isLoggedIn = await _authRepo.isLoggedIn();
    final location = state.matchedLocation;

    final publicRoutes = ['/login', '/register', '/resend-otp', '/verify'];
    final isPublicRoute = publicRoutes.any(
      (route) => location.startsWith(route),
    );

    if (!isLoggedIn && !isPublicRoute) {
      return '/login';
    }

    if (isLoggedIn && location == '/login') {
      final landingUrl = authData?['landingUrl'] as String?;
      if (landingUrl != null && landingUrl.isNotEmpty) {
        return landingUrl.startsWith('/') ? landingUrl : '/$landingUrl';
      } else {
        return '/dashboard';
      }
    }

    return null;
  },
);
