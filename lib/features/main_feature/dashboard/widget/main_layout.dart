import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/core/theme/theme_provider.dart';
import 'package:coreflow/core/share_intent/share_intent_handler.dart';
import 'package:coreflow/core/storage/dashboard_bottom_nav_storage.dart';
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
  List<String> _pinnedActionIds = List<String>.from(
    DashboardBottomNavStorage.defaultPinnedActionIds,
  );

  @override
  void initState() {
    super.initState();
    DashboardBottomNavStorage.changeToken.addListener(_onPinConfigChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _shareIntentHandler.start(context);
      _loadPinnedActions();
    });
  }

  @override
  void dispose() {
    DashboardBottomNavStorage.changeToken.removeListener(_onPinConfigChanged);
    _shareIntentHandler.dispose();
    super.dispose();
  }

  int _calculateSelectedIndex(
    BuildContext context,
    List<_BottomNavAction> nav,
  ) {
    final String location = GoRouterState.of(context).matchedLocation;
    final section = CfRoutes.getCompanySection(location);
    if (section == null) return 0;
    for (var i = 0; i < nav.length; i++) {
      if (nav[i].matches(section)) {
        return i;
      }
    }
    return 0;
  }

  void _onItemTapped(
    int index,
    BuildContext context,
    List<_BottomNavAction> nav,
  ) {
    final vm = context.read<DashboardViewModel>();
    final companyId = vm.companyId;
    if (companyId == null) return;
    if (index < 0 || index >= nav.length) return;
    context.go(nav[index].routeBuilder(companyId));
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

  Future<void> _loadPinnedActions() async {
    final companyId = context.read<DashboardViewModel>().companyId;
    if (companyId == null) return;
    final ids = await DashboardBottomNavStorage.loadPinnedActionIds(companyId);
    if (!mounted) return;
    setState(() {
      _pinnedActionIds = ids;
    });
  }

  void _onPinConfigChanged() {
    _loadPinnedActions();
  }

  List<_BottomNavAction> _buildBottomNavActions(DashboardViewModel vm) {
    final registry = <String, _BottomNavAction>{
      'customers': _BottomNavAction(
        id: 'customers',
        selectedIcon: Icons.group_rounded,
        unselectedIcon: Icons.group_outlined,
        label: 'Customer',
        routeBuilder: CfRoutes.customers,
        badgeCount: vm.customerUnreadCount,
        sectionPrefixes: const ['customers'],
      ),
      'vendors': _BottomNavAction(
        id: 'vendors',
        selectedIcon: Icons.store_rounded,
        unselectedIcon: Icons.store_outlined,
        label: 'Vendor',
        routeBuilder: CfRoutes.vendors,
        badgeCount: vm.vendorUnreadCount,
        sectionPrefixes: const ['vendors'],
      ),
      'items': _BottomNavAction(
        id: 'items',
        selectedIcon: Icons.inventory_2_rounded,
        unselectedIcon: Icons.inventory_2_outlined,
        label: 'Items',
        routeBuilder: CfRoutes.items,
        sectionPrefixes: const ['items'],
      ),
      'employees': _BottomNavAction(
        id: 'employees',
        selectedIcon: Icons.badge_rounded,
        unselectedIcon: Icons.badge_outlined,
        label: 'Employee',
        routeBuilder: CfRoutes.employees,
        badgeCount: vm.employeeUnreadCount,
        sectionPrefixes: const [
          'employees',
          'work-definitions',
          'employee-work-logs',
          'employee-leave-requests',
          'employee-salary',
        ],
      ),
      'sales_orders': _BottomNavAction(
        id: 'sales_orders',
        selectedIcon: Icons.receipt_long_rounded,
        unselectedIcon: Icons.receipt_long_outlined,
        label: 'Sales',
        routeBuilder: CfRoutes.sales,
        sectionPrefixes: const ['sales'],
      ),
      'purchase_orders': _BottomNavAction(
        id: 'purchase_orders',
        selectedIcon: Icons.shopping_cart_rounded,
        unselectedIcon: Icons.shopping_cart_outlined,
        label: 'Purchase',
        routeBuilder: CfRoutes.purchase,
        sectionPrefixes: const ['purchase'],
      ),
      'payment_made': _BottomNavAction(
        id: 'payment_made',
        selectedIcon: Icons.payments_rounded,
        unselectedIcon: Icons.payments_outlined,
        label: 'Pay Made',
        routeBuilder: CfRoutes.paymentMade,
        sectionPrefixes: const ['payment-made'],
      ),
      'payment_received': _BottomNavAction(
        id: 'payment_received',
        selectedIcon: Icons.account_balance_wallet_rounded,
        unselectedIcon: Icons.account_balance_wallet_outlined,
        label: 'Pay Recv',
        routeBuilder: CfRoutes.paymentReceived,
        sectionPrefixes: const ['payment-received'],
      ),
      'expenses': _BottomNavAction(
        id: 'expenses',
        selectedIcon: Icons.receipt_long_rounded,
        unselectedIcon: Icons.receipt_long_outlined,
        label: 'Expense',
        routeBuilder: CfRoutes.expenses,
        sectionPrefixes: const ['expenses'],
      ),
    };

    final actions = <_BottomNavAction>[
      _BottomNavAction(
        id: 'home',
        selectedIcon: Icons.grid_view_rounded,
        unselectedIcon: Icons.grid_view_outlined,
        label: 'Home',
        routeBuilder: CfRoutes.dashboard,
        sectionPrefixes: const ['dashboard'],
      ),
    ];

    final pinned = _pinnedActionIds.isNotEmpty
        ? _pinnedActionIds
        : DashboardBottomNavStorage.defaultPinnedActionIds;
    for (final id in pinned) {
      final action = registry[id];
      if (action != null) {
        actions.add(action);
      }
    }
    return actions;
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();
    final vm = context.watch<DashboardViewModel>();
    _syncShareCompanyId(vm.companyId);
    final bottomNav = _buildBottomNavActions(vm);
    final selectedIndex = _calculateSelectedIndex(context, bottomNav);
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
                            total: bottomNav.length,
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
                            children: List.generate(
                              bottomNav.length,
                              (index) => _buildNavItem(
                                index,
                                bottomNav[index],
                                animValue,
                                nav: bottomNav,
                              ),
                            ),
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
    _BottomNavAction action,
    double animValue, {
    required List<_BottomNavAction> nav,
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
        onTap: () => _onItemTapped(index, context, nav),
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
                        isSelected
                            ? action.selectedIcon
                            : action.unselectedIcon,
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
                        action.label,
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
              if (action.badgeCount > 0)
                Positioned(
                  right: 4,
                  top: floatOffset + 2,
                  child: _CountBadge(count: action.badgeCount),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavAction {
  final String id;
  final IconData selectedIcon;
  final IconData unselectedIcon;
  final String label;
  final String Function(int companyId) routeBuilder;
  final List<String> sectionPrefixes;
  final int badgeCount;

  const _BottomNavAction({
    required this.id,
    required this.selectedIcon,
    required this.unselectedIcon,
    required this.label,
    required this.routeBuilder,
    required this.sectionPrefixes,
    this.badgeCount = 0,
  });

  bool matches(String section) {
    for (final prefix in sectionPrefixes) {
      if (section.startsWith(prefix)) return true;
    }
    return false;
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
