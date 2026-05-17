import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/core/theme/theme_provider.dart';
import 'package:coreflow/core/share_intent/share_intent_handler.dart';
import 'package:coreflow/core/widgets/company_switch_loading.dart';
import 'package:coreflow/routing/cf_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:coreflow/features/main_feature/dashboard/dashboard_view_model/dashboard_view_model.dart';
import 'package:coreflow/core/widgets/app_drawer.dart';

class MainLayout extends StatefulWidget {
  final Widget child;
  const MainLayout({super.key, required this.child});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  static const double _desktopFrameWidth = 1800;
  static const double _desktopFrameHeight = 900;
  static const double _desktopSidebarWidth = 304;
  static const Duration _dashboardExitInterval = Duration(seconds: 2);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ShareIntentHandler _shareIntentHandler = ShareIntentHandler();
  int? _lastCompanyId;
  DateTime? _lastDashboardBackPressedAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _shareIntentHandler.start(context);
    });
  }

  @override
  void dispose() {
    _shareIntentHandler.dispose();
    super.dispose();
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;
    final section = CfRoutes.getCompanySection(location);
    if (section == null) return 0;
    if (section.startsWith('dashboard')) return 0;
    if (section.startsWith('customers')) {
      return 1;
    }
    if (section.startsWith('vendors')) return 2;
    if (section.startsWith('employees') ||
        section.startsWith('work-definitions') ||
        section.startsWith('employee-work-logs') ||
        section.startsWith('employee-leave-requests') ||
        section.startsWith('employee-salary')) {
      return 3;
    }
    if (section.startsWith('expenses')) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    final vm = context.read<DashboardViewModel>();
    final companyId = vm.companyId;
    if (companyId == null) return;
    switch (index) {
      case 0:
        context.go(CfRoutes.dashboard(companyId));
        break;
      case 1:
        context.go(CfRoutes.customers(companyId));
        break;
      case 2:
        context.go(CfRoutes.vendors(companyId));
        break;
      case 3:
        context.go(CfRoutes.employees(companyId));
        break;
      case 4:
        context.go(CfRoutes.expenses(companyId));
        break;
    }
  }

  int? _extractCompanyIdFromLocation(String location) {
    final match = RegExp(r'^/cf/company/(\d+)/').firstMatch(location);
    final idText = match?.group(1);
    return idText == null ? null : int.tryParse(idText);
  }

  Future<bool> _onBackPressed() async {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      _lastDashboardBackPressedAt = null;
      navigator.pop();
      return true;
    }

    final router = GoRouter.of(context);
    if (router.canPop()) {
      _lastDashboardBackPressedAt = null;
      router.pop();
      return true;
    }

    final location = GoRouterState.of(context).matchedLocation;
    final vmCompanyId = context.read<DashboardViewModel>().companyId;
    final locationCompanyId = _extractCompanyIdFromLocation(location);
    final targetCompanyId = vmCompanyId ?? locationCompanyId;
    final isDashboard =
        targetCompanyId != null &&
        location == CfRoutes.dashboard(targetCompanyId);

    if (!isDashboard && targetCompanyId != null) {
      _lastDashboardBackPressedAt = null;
      context.go(CfRoutes.dashboard(targetCompanyId));
      return true;
    }

    final now = DateTime.now();
    final pressedRecently =
        _lastDashboardBackPressedAt != null &&
        now.difference(_lastDashboardBackPressedAt!) <= _dashboardExitInterval;

    if (pressedRecently) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      await SystemNavigator.pop();
      return true;
    }

    _lastDashboardBackPressedAt = now;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Press back again to exit'),
        duration: _dashboardExitInterval,
        behavior: SnackBarBehavior.floating,
        backgroundColor: LoginColors.textPrimary,
      ),
    );

    return true;
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();
    final selectedIndex = _calculateSelectedIndex(context);
    final vm = context.watch<DashboardViewModel>();
    _syncShareCompanyId(vm.companyId);
    final screenSize = MediaQuery.sizeOf(context);
    final mediaQuery = MediaQuery.of(context);
    final bottomInset = mediaQuery.viewPadding.bottom;
    final keyboardInset = mediaQuery.viewInsets.bottom;
    final isKeyboardVisible = keyboardInset > 0;
    final useFixedDesktopSidebar =
        screenSize.width >= _desktopFrameWidth &&
        screenSize.height >= _desktopFrameHeight;

    if (vm.isSwitchingCompany) {
      return CompanySwitchLoading(companyName: vm.companyName ?? 'Company');
    }

    return BackButtonListener(
      onBackButtonPressed: _onBackPressed,
      child: Scaffold(
        key: _scaffoldKey,
        extendBody: !useFixedDesktopSidebar,
        drawer: useFixedDesktopSidebar ? null : AppDrawer(vm: vm),
        body: useFixedDesktopSidebar
            ? Center(
                child: SizedBox(
                  width: _desktopFrameWidth,
                  height: _desktopFrameHeight,
                  child: Row(
                    children: [
                      SizedBox(
                        width: _desktopSidebarWidth,
                        child: AppDrawer(vm: vm),
                      ),
                      Expanded(child: widget.child),
                    ],
                  ),
                ),
              )
            : Padding(
                padding: EdgeInsets.only(
                  bottom: isKeyboardVisible ? 12 : 80 + bottomInset,
                ), // Reduce padding when keyboard is open
                child: widget.child,
              ),
        bottomNavigationBar: useFixedDesktopSidebar || isKeyboardVisible
            ? null
            : TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
                tween: Tween<double>(begin: 0, end: selectedIndex.toDouble()),
                builder: (context, animValue, child) {
                  return Container(
                    height: 90 + bottomInset, // Add safe area for 3-button nav
                    padding: EdgeInsets.only(bottom: bottomInset),
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        // Liquid Background with Notch
                        CustomPaint(
                          size: Size(MediaQuery.of(context).size.width, 70),
                          painter: CurvedPainter(
                            index: animValue,
                            total: 5,
                            color: LoginColors
                                .surface, // Theme-aware surface color
                            shadowColor: LoginColors.shadowLight,
                          ),
                        ),

                        // Navigation Items Row
                        SizedBox(
                          height: 70,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildNavItem(
                                0,
                                Icons.grid_view_rounded,
                                Icons.grid_view_outlined,
                                'Home',
                                animValue,
                              ),
                              _buildNavItem(
                                1,
                                Icons.group_rounded,
                                Icons.group_outlined,
                                'Customer',
                                animValue,
                                badgeCount: vm.customerUnreadCount,
                              ),
                              _buildNavItem(
                                2,
                                Icons.store_rounded,
                                Icons.store_outlined,
                                'Vendor',
                                animValue,
                                badgeCount: vm.vendorUnreadCount,
                              ),
                              _buildNavItem(
                                3,
                                Icons.badge_rounded,
                                Icons.badge_outlined,
                                'Employee',
                                animValue,
                                badgeCount: vm.employeeUnreadCount,
                              ),
                              _buildNavItem(
                                4,
                                Icons.receipt_long_rounded,
                                Icons.receipt_long_outlined,
                                'Expense',
                                animValue,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  void _syncShareCompanyId(int? companyId) {
    if (_lastCompanyId == companyId) return;
    _lastCompanyId = companyId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _shareIntentHandler.updateCompanyId(companyId, context);
    });
  }

  // Helper to build nav items with "floating" animation
  Widget _buildNavItem(
    int index,
    IconData selectedIcon,
    IconData unselectedIcon,
    String label,
    double animValue, {
    int badgeCount = 0,
  }) {
    // Calculate distance from the active index
    double distance = (animValue - index).abs();
    // 0.0 means active, 1.0 means adjacent
    double normalizedDistance = distance.clamp(0.0, 1.0);

    // Animation Values
    double floatOffset =
        (1.0 - normalizedDistance) * -20; // Move UP by 20px when active
    // double scale = 1.0 + (0.2 * (1.0 - normalizedDistance)); // Scale up by 20%
    // double opacity = 1.0 - normalizedDistance; // Opacity of the "Active blob"

    final isSelected = distance < 0.5;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTapped(index, context),
        behavior: HitTestBehavior.opaque,
        child: Container(
          color: Colors.transparent, // Hit test target
          alignment: Alignment.bottomCenter,
          padding: const EdgeInsets.only(bottom: 12), // Align content
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // Floating Icon
              Transform.translate(
                offset: Offset(0, floatOffset),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon Container
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? LoginColors.primary
                            : Colors.transparent,
                        shape: BoxShape.circle,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: LoginColors.primary.withValues(
                                    alpha: 0.4,
                                  ),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Icon(
                        isSelected ? selectedIcon : unselectedIcon,
                        color: isSelected
                            ? Colors.white
                            : LoginColors.textTertiary,
                        size: 24, // Standard size
                      ),
                    ),

                    // Text Label (Fades out when active, fades in when inactive)
                    if (!isSelected) ...[
                      const SizedBox(height: 2),
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 9,
                          height: 1.0,
                          fontWeight: FontWeight.w600,
                          color: LoginColors.textTertiary,
                        ),
                      ),
                    ] else ...[
                      // Spacer to keep layout height consistent if needed,
                      // but mostly we want the icon to float up and overlap the border
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),

              // Notification Badge
              if (badgeCount > 0)
                Positioned(
                  right: 4,
                  top: floatOffset + 2,
                  child: _CountBadge(count: badgeCount),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  final int count;
  const _CountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 16),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: LoginColors.error,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: LoginColors.surface, width: 1.5),
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
    );
  }
}

class CurvedPainter extends CustomPainter {
  final double index;
  final int total;
  final Color color;
  final Color shadowColor;

  CurvedPainter({
    required this.index,
    required this.total,
    required this.color,
    required this.shadowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill; // Main background color

    final shadowPaint = Paint()
      ..color = shadowColor
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8); // Soft shadow

    double itemWidth = size.width / total;
    double centerX = (itemWidth * index) + (itemWidth / 2);

    // Path Logic
    final path = Path();

    // Start from top-left
    path.moveTo(0, 0);

    // Standard "Notch" Mechanism
    double notchWidth = itemWidth * 0.75; // Width of the curve
    double notchDepth = 35.0; // How deep the curve goes

    // Calculate curve control points
    double leftX = centerX - (notchWidth / 2);
    double rightX = centerX + (notchWidth / 2);

    // Draw line to start of notch
    path.lineTo(leftX - 10, 0);

    // Draw the "Liquid" Curve (Cubic Bezier for smoothness)
    // P0: Start (leftX - 10, 0)
    // P1: Control Point 1 (leftX, 0) -> Smooth entry
    // P2: Control Point 2 (centerX - 20, notchDepth) -> Going down
    // P3: Bottom Center (centerX, notchDepth)
    path.cubicTo(
      leftX + 5,
      0, // CP1 x, y
      centerX - 15,
      notchDepth, // CP2 x, y
      centerX,
      notchDepth, // End x, y (Bottom center of notch)
    );

    // Second half of the curve (Symmetric)
    path.cubicTo(
      centerX + 15,
      notchDepth, // CP1
      rightX - 5,
      0, // CP2
      rightX + 10,
      0, // End
    );

    // Finish the path rectangle
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    // Draw Shadow first
    canvas.drawPath(path.shift(const Offset(0, -2)), shadowPaint);

    // Draw Main Shape
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CurvedPainter oldDelegate) {
    return oldDelegate.index != index || oldDelegate.color != color;
  }
}
