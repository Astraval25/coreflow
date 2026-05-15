import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/core/theme/theme_provider.dart';
import 'package:coreflow/core/widgets/app_drawer.dart';
import 'package:coreflow/core/widgets/searchable_entity_app_bar.dart';
import 'package:coreflow/data/repositories/auth_repository/auth_repository.dart';
import 'package:coreflow/features/main_feature/dashboard/dashboard_view_model/dashboard_view_model.dart';
import 'package:coreflow/features/main_feature/payment/send_payment/view/create_payment_sent_page.dart';
import 'package:coreflow/features/main_feature/payment/send_payment/view/send_payment_detail_page.dart';
import 'package:coreflow/features/main_feature/payment/send_payment/viewmodel/send_payment_view_model.dart';
import 'package:coreflow/features/main_feature/payment/send_payment/widgets/payment_body_message.dart';
import 'package:coreflow/features/main_feature/payment/send_payment/widgets/payment_card.dart';
import 'package:coreflow/features/main_feature/payment/send_payment/widgets/payment_empty_state.dart';
import 'package:coreflow/features/main_feature/payment/send_payment/widgets/payment_loading_body.dart';
import 'package:coreflow/features/main_feature/payment/send_payment/widgets/payment_skeleton.dart';
import 'package:coreflow/routing/cf_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class PaymentPage extends StatelessWidget {
  const PaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();
    return Consumer<DashboardViewModel>(
      builder: (context, vm, child) {
        if (vm.isLoading) {
          return const PaymentSkeleton();
        }

        final companyId = vm.companyId;
        if (companyId == null) {
          return const PaymentEmptyState(
            title: 'Payment',
            subtitle: 'Company not selected.',
          );
        }

        return ChangeNotifierProvider<SendPaymentViewModel>(
          create: (_) => SendPaymentViewModel(
            repository: AuthRepository(),
            companyId: companyId,
          )..fetchPaymentsSentSummary(),
          child: const _PaymentContent(),
        );
      },
    );
  }
}

class _PaymentContent extends StatefulWidget {
  const _PaymentContent();

  @override
  State<_PaymentContent> createState() => _PaymentContentState();
}

class _PaymentContentState extends State<_PaymentContent> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _disabledSearchController =
      TextEditingController();
  _PaymentTopTab _selectedTopTab = _PaymentTopTab.payments;

  @override
  void dispose() {
    _disabledSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();
    final dashboardVm = context.watch<DashboardViewModel>();

    return Consumer<SendPaymentViewModel>(
      builder: (context, vm, child) {
        return WillPopScope(
          onWillPop: _handleWillPop,
          child: Scaffold(
            key: _scaffoldKey,
            backgroundColor: LoginColors.background,
            drawerEnableOpenDragGesture: false,
            drawer: AppDrawer(vm: dashboardVm),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            floatingActionButton: _buildCreateButton(),
            appBar: SearchableEntityAppBar(
              isSearchOpen: false,
              onSearchToggle: () {},
              searchQuery: '',
              searchController: _disabledSearchController,
              onSearchChanged: (_) {},
              onClearSearch: () {},
              scaffoldKey: _scaffoldKey,
              title: '',
              searchHint: '',
              showSearchAction: false,
              tabs: const [
                SearchableEntityTab(label: 'Pay'),
                SearchableEntityTab(label: 'Received'),
              ],
              selectedTabIndex: _selectedTopTab.index,
              onTabSelected: (index) {
                if (index == _PaymentTopTab.payments.index) {
                  setState(() => _selectedTopTab = _PaymentTopTab.payments);
                  return;
                }
                if (index == _PaymentTopTab.received.index) {
                  final dashVm = context.read<DashboardViewModel>();
                  if (dashVm.companyId != null) {
                    context.go(CfRoutes.paymentReceived(dashVm.companyId!));
                  }
                }
              },
            ),
            body: RefreshIndicator(
              onRefresh: vm.refresh,
              child: _buildBody(vm),
            ),
          ),
        );
      },
    );
  }

  Future<bool> _handleWillPop() async {
    final dashVm = context.read<DashboardViewModel>();
    if (dashVm.companyId != null) {
      context.go(CfRoutes.dashboard(dashVm.companyId!));
    }
    return false;
  }

  Widget _buildBody(SendPaymentViewModel vm) {
    if (vm.isLoading) {
      return const PaymentLoadingBody();
    }

    if (vm.errorMessage != null && vm.payments.isEmpty) {
      return PaymentBodyMessage(
        icon: Icons.error_outline_rounded,
        title: 'Payment',
        subtitle: vm.errorMessage!,
      );
    }

    if (vm.payments.isEmpty) {
      return const PaymentBodyMessage(
        icon: Icons.account_balance_wallet_outlined,
        title: 'Payment',
        subtitle: 'No payments found.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
      itemCount: vm.payments.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final payment = vm.payments[index];
        return InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _openPaymentDetail(vm.companyId, payment.paymentId),
          child: PaymentCard(payment: payment),
        );
      },
    );
  }

  Future<void> _openPaymentDetail(int companyId, int paymentId) async {
    if (paymentId <= 0) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            SendPaymentDetailPage(companyId: companyId, paymentId: paymentId),
      ),
    );
  }

  Widget _buildCreateButton() {
    final companyId = context.read<DashboardViewModel>().companyId;
    return FloatingActionButton.extended(
      backgroundColor: LoginColors.primary,
      foregroundColor: Colors.white,
      onPressed: () async {
        if (companyId == null) return;
        final result = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => CreatePaymentSentPage(companyId: companyId),
          ),
        );
        if (result == true && mounted) {
          context.read<SendPaymentViewModel>().refresh();
        }
      },
      icon: const Icon(Icons.add_rounded),
      label: const Text(
        'Send Payment',
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}

enum _PaymentTopTab { payments, received }
