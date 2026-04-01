import 'package:coreflow/routing/cf_routes.dart';
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
      if (mounted) context.go(CfRoutes.login);
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

    final companyId = dashVm.companyId;
    if (companyId != null) {
      context.go(CfRoutes.dashboard(companyId));
    } else {
      context.go(CfRoutes.login);
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
        child: FadeTransition(
          opacity: Tween<double>(
            begin: 0.4,
            end: 1.0,
          ).animate(_pulseController),
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: LoginColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Image.asset(
                'assets/icons/app_icon.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
