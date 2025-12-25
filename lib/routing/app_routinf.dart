import 'package:coreflow/data/repositories/auth_repository.dart';
import 'package:coreflow/features/dashboard/dashboard_view/dashboard_page.dart';
import 'package:coreflow/features/login/view/login_page.dart';
import 'package:coreflow/features/registration/view/register_screen.dart';
import 'package:go_router/go_router.dart';  // Add this import

final GoRouter router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',  // ← ADD THIS
      builder: (context, state) => const RegisterScreen(),  // ← Your Register widget
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardPage(),
    ),
  ],
  redirect: (context, state) async {
    final authRepo = AuthRepository();
    final isLoggedIn = await authRepo.isLoggedIn();
    
    if (!isLoggedIn && state.uri.toString() != '/login' && state.uri.toString() != '/register') {
      return '/login';  // ← Updated: allow /register
    }
    if (isLoggedIn && state.uri.toString() == '/login') {
      return '/dashboard';
    }
    return null;
  },
);
