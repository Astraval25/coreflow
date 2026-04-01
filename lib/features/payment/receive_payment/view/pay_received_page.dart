import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/core/theme/theme_provider.dart';
import 'package:coreflow/core/widgets/app_drawer.dart';
import 'package:coreflow/core/widgets/searchable_entity_app_bar.dart';
import 'package:coreflow/data/repositories/auth_repository.dart';
import 'package:coreflow/features/dashboard/dashboard_view_model/dashboard_view_model.dart';
import 'package:coreflow/features/payment/receive_payment/view/create_receive_payment_page.dart';
import 'package:coreflow/features/payment/receive_payment/view/pay_received_detail_page.dart';
import 'package:coreflow/features/payment/receive_payment/viewmodel/receive_payment_view_model.dart';
import 'package:coreflow/features/payment/receive_payment/widgets/pay_received_body_message.dart';
import 'package:coreflow/features/payment/receive_payment/widgets/pay_received_card.dart';
import 'package:coreflow/features/payment/receive_payment/widgets/pay_received_empty_state.dart';
import 'package:coreflow/features/payment/receive_payment/widgets/pay_received_loading_body.dart';
import 'package:coreflow/features/payment/receive_payment/widgets/pay_received_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class PayReceivedPage extends StatelessWidget {
  const PayReceivedPage({super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();
    return Consumer<DashboardViewModel>(
      builder: (context, vm, child) {
        if (vm.isLoading) {
          return const PayReceivedSkeleton();
        }

        final companyId = vm.companyId;
        if (companyId == null) {
          return const PayReceivedEmptyState(
            title: 'Pay Received',
            subtitle: 'Company not selected.',
          );
        }

        return ChangeNotifierProvider<ReceivePaymentViewModel>(
          create: (_) => ReceivePaymentViewModel(
            repository: AuthRepository(),
            companyId: companyId,
          )..fetchPaymentsReceivedSummary(),
          child: const _PayReceivedContent(),
        );
      },
    );
  }
}

class _PayReceivedContent extends StatefulWidget {
  const _PayReceivedContent();

  @override
  State<_PayReceivedContent> createState() => _PayReceivedContentState();
}

class _PayReceivedContentState extends State<_PayReceivedContent> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _disabledSearchController =
      TextEditingController();
  int _selectedTabIndex = 1;

  @override
  void dispose() {
    _disabledSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();
    final dashboardVm = context.watch<DashboardViewModel>();

    return Consumer<ReceivePaymentViewModel>(
      builder: (context, vm, child) {
        return WillPopScope(
          onWillPop: _handleWillPop,
          child: Scaffold(
            key: _scaffoldKey,
            backgroundColor: LoginColors.background,
            drawerEnableOpenDragGesture: false,
            drawer: AppDrawer(vm: dashboardVm),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.endFloat,
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
                SearchableEntityTab(label: 'Sent'),
                SearchableEntityTab(label: 'Received'),
              ],
              selectedTabIndex: _selectedTabIndex,
              onTabSelected: (index) {
                if (index == 0) {
                  context.go('/payment');
                  return;
                }
                setState(() => _selectedTabIndex = index);
              },
            ),
            body:
                RefreshIndicator(onRefresh: vm.refresh, child: _buildBody(vm)),
          ),
        );
      },
    );
  }

  Future<bool> _handleWillPop() async {
    context.go('/dashboard');
    return false;
  }

  Widget _buildBody(ReceivePaymentViewModel vm) {
    if (vm.isLoading) {
      return const PayReceivedLoadingBody();
    }

    if (vm.errorMessage != null && vm.payments.isEmpty) {
      return PayReceivedBodyMessage(subtitle: vm.errorMessage!);
    }

    if (vm.payments.isEmpty) {
      return const PayReceivedBodyMessage(
        subtitle: 'No received payment summary found.',
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
          child: PayReceivedCard(payment: payment),
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
            PayReceivedDetailPage(companyId: companyId, paymentId: paymentId),
      ),
    );
  }

  Widget _buildCreateButton() {
    return Consumer<ReceivePaymentViewModel>(
      builder: (context, vm, child) {
        return FloatingActionButton.extended(
          backgroundColor: LoginColors.primary,
          foregroundColor: Colors.white,
          onPressed: () => _navigateToCreatePayment(vm.companyId),
          icon: const Icon(Icons.add_rounded),
          label: const Text(
            'Receive Payment',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        );
      },
    );
  }

  Future<void> _navigateToCreatePayment(int companyId) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CreateReceivePaymentPage(companyId: companyId),
      ),
    );
    
    if (result == true && mounted) {
      // Refresh the list if payment was created successfully
      final vm = context.read<ReceivePaymentViewModel>();
      vm.refresh();
    }
  }
}
