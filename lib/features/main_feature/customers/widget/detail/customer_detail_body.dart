import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/core/utils/common_formatters.dart';
import 'package:coreflow/core/widgets/connection_request_banner.dart';
import 'package:coreflow/core/widgets/link_company_section.dart';
import 'package:coreflow/domain/model/main_model/customer/customer_detail.dart';
import 'package:coreflow/features/main_feature/customers/view_model/customer_detail_view_model.dart';
import 'package:coreflow/features/main_feature/customers/widget/detail/body/customer_orders_payments_section.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomerDetailBody extends StatefulWidget {
  final CustomerDetailData customer;
  static const double _horizontal = 20;

  const CustomerDetailBody({super.key, required this.customer});

  @override
  State<CustomerDetailBody> createState() => _CustomerDetailBodyState();
}

class _CustomerDetailBodyState extends State<CustomerDetailBody> {
  TransactionFilter _selectedFilter = TransactionFilter.all;

  @override
  Widget build(BuildContext context) {
    final customer = widget.customer;
    final vm = context.watch<CustomerDetailViewModel>();
    final isLinked = customer.customerCompany != null;

    return Column(
      children: [
        _buildConnectionBanner(context, vm, customer),
        _buildLinkCompanyStrip(context, vm, isLinked),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            CustomerDetailBody._horizontal,
            6,
            CustomerDetailBody._horizontal,
            8,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Orders & Payments',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: LoginColors.textPrimary,
                  ),
                ),
              ),
              _buildFilterDropdown(),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 120),
          child: CustomerOrdersPaymentsSection(filter: _selectedFilter),
        ),
      ],
    );
  }

  Widget _buildFilterDropdown() {
    return PopupMenuButton<TransactionFilter>(
      onSelected: (value) => setState(() => _selectedFilter = value),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (context) => const [
        PopupMenuItem(value: TransactionFilter.all, child: Text('All')),
        PopupMenuItem(
          value: TransactionFilter.payments,
          child: Text('Payment'),
        ),
        PopupMenuItem(value: TransactionFilter.orders, child: Text('Order')),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: LoginColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: LoginColors.borderLight),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _labelFor(_selectedFilter),
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: LoginColors.textPrimary,
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: LoginColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  String _labelFor(TransactionFilter filter) {
    switch (filter) {
      case TransactionFilter.all:
        return 'All';
      case TransactionFilter.payments:
        return 'Payment';
      case TransactionFilter.orders:
        return 'Order';
    }
  }

  Widget _buildConnectionBanner(
    BuildContext context,
    CustomerDetailViewModel vm,
    CustomerDetailData customer,
  ) {
    if (!customer.hasConnectionRequest) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        CustomerDetailBody._horizontal,
        6,
        CustomerDetailBody._horizontal,
        6,
      ),
      child: ConnectionRequestBanner(
        connectionStatus: customer.connectionStatus!,
        isAwaitingCounterpartyAcceptance:
            customer.isAwaitingCounterpartyAcceptance,
        requesterName: customer.customerName,
        requesterPhone: customer.phone,
        requesterEmail: customer.email,
        isLoading: vm.isConnectionLoading,
        onAccept: () async {
          final success = await vm.acceptConnection();
          final latest = vm.customer;
          final message = success
              ? (latest?.isFullyConnected == true
                    ? 'Connection completed'
                    : 'Accepted. Waiting for other company')
              : (vm.errorMessage?.trim().isNotEmpty == true
                    ? vm.errorMessage!
                    : 'Failed to accept');
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: success ? Colors.green : Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        onReject: () async {
          final success = await vm.rejectConnection();
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  success
                      ? 'Connection rejected'
                      : (vm.errorMessage?.trim().isNotEmpty == true
                            ? vm.errorMessage!
                            : 'Failed to reject'),
                ),
                backgroundColor: success ? Colors.orange : Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        onUndo: (newStatus) async {
          final success = await vm.undoConnectionDecision(newStatus);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  success
                      ? 'Connection updated'
                      : (vm.errorMessage?.trim().isNotEmpty == true
                            ? vm.errorMessage!
                            : 'Failed to update'),
                ),
                backgroundColor: success ? Colors.green : Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildLinkCompanyStrip(
    BuildContext context,
    CustomerDetailViewModel vm,
    bool isLinked,
  ) {
    if (isLinked) {
      final linkedName =
          widget.customer.customerCompany?.companyName?.trim().isNotEmpty ==
              true
          ? widget.customer.customerCompany!.companyName!
          : 'Linked Company';
      final amount = widget.customer.dueAmount ?? 0.0;
      final amountColor = amount >= 0 ? LoginColors.success : LoginColors.error;

      return Padding(
        padding: const EdgeInsets.fromLTRB(
          CustomerDetailBody._horizontal,
          6,
          CustomerDetailBody._horizontal,
          6,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: LoginColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: LoginColors.borderLight),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  linkedName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: LoginColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                formatMoney(amount),
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: amountColor,
                ),
              ),
            ],
          ),
        ),
      );
    }
    // Hide manual linking when connection request flow is active
    if (widget.customer.hasConnectionRequest) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        CustomerDetailBody._horizontal,
        6,
        CustomerDetailBody._horizontal,
        6,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: LoginColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: LoginColors.borderLight),
          boxShadow: [
            BoxShadow(
              color: LoginColors.shadowLight.withValues(alpha: 0.07),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: LinkCompanySection(
          isLinked: false,
          isLoading: vm.isInvitationLoading,
          invitationCode: vm.invitationData?.invitationCode,
          onGenerateCode: () async {
            final response = await vm.sendInvitation();
            if (!context.mounted) return;
            if (response != null && !response.responseStatus) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  duration: const Duration(seconds: 2),
                  content: Text(response.responseMessage),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          onGetExistingCode: () async {
            final response = await vm.getInvitationCode();
            if (!context.mounted) return;
            if (response == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  duration: Duration(seconds: 2),
                  content: Text('No existing invitation code found'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          onAcceptCode: (code) async {
            final response = await vm.acceptInvitation(code);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  duration: const Duration(seconds: 2),
                  content: Text(
                    response?.responseStatus == true
                        ? 'Company linked successfully'
                        : response?.responseMessage ?? 'Failed to link company',
                  ),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: response?.responseStatus == true
                      ? Colors.green
                      : Colors.red,
                ),
              );
            }
            return response?.responseStatus == true;
          },
        ),
      ),
    );
  }
}
