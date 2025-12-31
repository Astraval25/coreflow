import 'package:coreflow/features/dashboard/dashboard_view/dashboard_page.dart';
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
