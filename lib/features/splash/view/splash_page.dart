import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/data/repositories/auth_repository.dart';
import 'package:coreflow/features/dashboard/dashboard_view_model/dashboard_view_model.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  final AuthRepository _authRepo = AuthRepository();
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _initialize();
  }

  Future<void> _initialize() async {
    final isLoggedIn = await _authRepo.isLoggedIn();

    if (!mounted) return;

    if (!isLoggedIn) {
      if (mounted) context.go('/login');
      return;
    }

    // User is logged in — load dashboard data before navigating
    final dashVm = context.read<DashboardViewModel>();
    await dashVm.loadUserData(force: true);
    if (!mounted) return;

    await Future.wait([
      dashVm.loadCompanies(force: true),
      dashVm.refreshUnreadCount(),
    ]);

    if (!mounted) return;

    final authData = await _authRepo.getAuthData();
    final landingUrl = authData?['landingUrl'] as String?;

    if (!mounted) return;
    if (landingUrl != null && landingUrl.isNotEmpty) {
      context.go(landingUrl.startsWith('/') ? landingUrl : '/$landingUrl');
    } else {
      context.go('/dashboard');
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LoginColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeTransition(
              opacity: Tween<double>(
                begin: 0.4,
                end: 1.0,
              ).animate(_pulseController),
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: LoginColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.hub_rounded,
                  size: 40,
                  color: LoginColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'CoreFlow',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: LoginColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            // const SizedBox(height: 32),
            // SizedBox(
            //   width: 28,
            //   height: 28,
            //   child: CircularProgressIndicator(
            //     strokeWidth: 3,
            //     color: LoginColors.primary,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
