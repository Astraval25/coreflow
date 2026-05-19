import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/core/utils/common_formatters.dart';
import 'package:coreflow/core/widgets/app_drawer.dart';
import 'package:coreflow/domain/model/main_model/customer/customer_detail.dart';
import 'package:coreflow/routing/cf_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:coreflow/features/main_feature/customers/widget/detail/body/customer_expand_more_option.dart';
import 'package:coreflow/features/main_feature/customers/widget/detail/body/customer_detail_sections.dart';
import 'package:coreflow/features/main_feature/customers/widget/detail/body/customer_item_section.dart';
import 'package:coreflow/core/widgets/skeleton.dart';
import 'package:coreflow/features/main_feature/customers/widget/detail/customer_detail_body.dart';
import 'package:coreflow/features/main_feature/customers/widget/detail/customer_error_state.dart';
import '../view_model/customer_detail_view_model.dart';
import '../../dashboard/dashboard_view_model/dashboard_view_model.dart';

class CustomerDetailContent extends StatelessWidget {
  const CustomerDetailContent({super.key});

  @override
  Widget build(BuildContext context) {
    LoginColors.setBrightness(Theme.of(context).brightness);
    final dashboardVM = context.read<DashboardViewModel>();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                DashboardColors.headerGradientStart,
                DashboardColors.headerGradientEnd,
              ],
            ),
          ),
        ),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 19,
            ),
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Consumer<CustomerDetailViewModel>(
          builder: (context, vm, child) {
            if (vm.isLoading || vm.customer == null) {
              return const Text(
                'Customer Details',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                ),
              );
            }
            final customer = vm.customer!;
            return InkWell(
              onTap: () => _openCustomerProfileSheet(context, customer),
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.white.withValues(alpha: 0.20),
                      child: const Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 17,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        customer.customerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        actions: [
          Consumer<CustomerDetailViewModel>(
            builder: (context, vm, _) {
              if (vm.isLoading || vm.customer == null) {
                return const SizedBox.shrink();
              }
              return _CustomerBalanceChip(amount: vm.customer!.dueAmount ?? 0);
            },
          ),
          const SizedBox(width: 6),
          Consumer<CustomerDetailViewModel>(
            builder: (context, vm, child) {
              if (vm.customer == null || vm.isLoading) {
                return const SizedBox(width: 10);
              }

              return PopupMenuButton<String>(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.more_vert,
                    color: Colors.white,
                    size: 19,
                  ),
                ),
                color: LoginColors.surface,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: LoginColors.borderLight),
                ),
                onSelected: (value) async {
                  switch (value) {
                    case 'edit':
                      await context.push(
                        CfRoutes.customerUpdate(vm.companyId, vm.customerId),
                      );
                      vm.loadCustomerDetail();
                      break;
                    case 'otherAction':
                      if (vm.customer != null) {
                        vm.isActive
                            ? vm.deactivateCustomer(context)
                            : vm.activateCustomer(context);
                      }
                      break;
                  }
                },
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem(
                    value: 'edit',
                    textStyle: TextStyle(
                      color: LoginColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.edit_rounded,
                          size: 18,
                          color: LoginColors.primary,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Edit',
                          style: TextStyle(color: LoginColors.textPrimary),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'otherAction',
                    textStyle: TextStyle(
                      color: LoginColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 12),
                        Icon(
                          vm.isActive ? Icons.circle : Icons.circle,
                          size: 18,
                          color: vm.isActive
                              ? const Color.fromARGB(255, 255, 0, 0)
                              : const Color.fromARGB(255, 0, 255, 0),
                        ),

                        const SizedBox(width: 8),
                        Text(
                          vm.isActive ? 'Make inactive' : 'Make active',
                          style: TextStyle(color: LoginColors.textPrimary),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawerEnableOpenDragGesture: false,
      drawer: AppDrawer(vm: dashboardVM),
      body: Consumer<CustomerDetailViewModel>(
        builder: (context, vm, child) {
          return Stack(
            children: [
              RefreshIndicator(
                onRefresh: () async => vm.loadCustomerDetail(),
                backgroundColor: LoginColors.surface,
                color: LoginColors.primary,
                child: NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification.metrics.maxScrollExtent <= 0) return false;
                    final triggerOffset =
                        notification.metrics.maxScrollExtent * 0.85;
                    if (notification.metrics.pixels >= triggerOffset) {
                      vm.loadMoreOrdersPaymentsIfNeeded();
                    }
                    return false;
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight:
                            MediaQuery.of(context).size.height -
                            AppBar().preferredSize.height -
                            MediaQuery.of(context).padding.top,
                      ),
                      child: _buildBody(context, vm),
                    ),
                  ),
                ),
              ),
              if (!vm.isLoading &&
                  !vm.isError &&
                  !vm.isNoData &&
                  vm.customer != null)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: CustomerBottomOptionsPanel(
                    vm: vm,
                    customer: vm.customer!,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, CustomerDetailViewModel vm) {
    if (vm.isLoading) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header Skeleton
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: LoginColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: LoginColors.borderLight, width: 1),
              ),
              child: Row(
                children: [
                  const Skeleton(height: 70, width: 70, borderRadius: 35),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Skeleton(height: 24, width: 180),
                        const SizedBox(height: 12),
                        const Skeleton(height: 16, width: 120),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Body Skeletons
            const Skeleton(
              height: 200,
              width: double.infinity,
              borderRadius: 24,
            ),
            const SizedBox(height: 24),
            const Skeleton(
              height: 180,
              width: double.infinity,
              borderRadius: 24,
            ),
          ],
        ),
      );
    }

    if (vm.isError) {
      return CustomerErrorState(
        message: vm.errorMessage ?? 'Failed to load customer data',
        onRetry: vm.loadCustomerDetail,
      );
    }

    return Column(children: [CustomerDetailBody(customer: vm.customer!)]);
  }

  void _openCustomerProfileSheet(
    BuildContext context,
    CustomerDetailData customer,
  ) {
    final vm = context.read<CustomerDetailViewModel>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: vm,
        child: _CustomerProfileSheet(customer: customer),
      ),
    );
  }
}

class _CustomerProfileSheet extends StatelessWidget {
  final CustomerDetailData customer;

  const _CustomerProfileSheet({required this.customer});

  @override
  Widget build(BuildContext context) {
    final sheetHeight = MediaQuery.of(context).size.height * 0.92;

    return Container(
      height: sheetHeight,
      decoration: BoxDecoration(
        color: LoginColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: LoginColors.border,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: LoginColors.primary.withValues(alpha: 0.14),
                  child: Icon(
                    Icons.person_rounded,
                    color: LoginColors.primaryDark,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    customer.customerName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: LoginColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 28),
              child: Column(
                children: [
                  CustomerBasicInfoSection(customer: customer),
                  const CustomerOrderPaymentTrendSection(),
                  _CustomerCompanyLinkSection(customer: customer),
                  CustomerAddressSection(customer: customer),
                  const CustomerItemSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomerCompanyLinkSection extends StatelessWidget {
  final CustomerDetailData customer;

  const _CustomerCompanyLinkSection({required this.customer});

  @override
  Widget build(BuildContext context) {
    final linkedCompany = customer.customerCompany;
    final linkedName = linkedCompany?.companyName?.trim() ?? '';
    final companyId = linkedCompany?.companyId;
    final hasLink = companyId != null && linkedName.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 6),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFB07A00).withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFB07A00).withValues(alpha: 0.55),
          ),
        ),
        child: InkWell(
          onTap: hasLink
              ? () => context.push(CfRoutes.marketplaceCompany(companyId))
              : null,
          borderRadius: BorderRadius.circular(12),
          child: Row(
            children: [
              const Icon(
                Icons.link_rounded,
                size: 18,
                color: Color(0xFFB07A00),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  hasLink ? linkedName : 'Company not linked',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF8A5A00),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (hasLink)
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 13,
                  color: Color(0xFF8A5A00),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomerBalanceChip extends StatelessWidget {
  final double amount;

  const _CustomerBalanceChip({required this.amount});

  @override
  Widget build(BuildContext context) {
    final isAdvance = amount >= 0;
    final color = isAdvance ? LoginColors.success : LoginColors.error;
    return Container(
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
      ),
      child: Text(
        '${isAdvance ? 'Adv' : 'Due'} ${formatMoney(amount.abs())}',
        style: TextStyle(
          color: color.withValues(alpha: 0.92),
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
