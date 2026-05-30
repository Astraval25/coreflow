import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/core/utils/common_formatters.dart';
import 'package:coreflow/core/widgets/connection_request_banner.dart';
import 'package:coreflow/core/widgets/link_company_section.dart';
import 'package:coreflow/domain/model/main_model/customer/customer_detail.dart';
import 'package:coreflow/features/main_feature/customers/view_model/customer_detail_view_model.dart';
import 'package:coreflow/features/main_feature/customers/widget/detail/body/customer_orders_payments_section.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

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
        _buildTopActionsBlock(context, customer),
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
        PopupMenuItem(value: TransactionFilter.payments, child: Text('Payment')),
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
              : 'Failed to accept';
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
                content: Text(success ? 'Connection rejected' : 'Failed to reject'),
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
                content: Text(success ? 'Connection updated' : 'Failed to update'),
                backgroundColor: success ? Colors.green : Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildTopActionsBlock(
    BuildContext context,
    CustomerDetailData customer,
  ) {
    if (!customer.isFullyConnected) return const SizedBox.shrink();

    final amount = customer.dueAmount ?? 0.0;
    final isAdvance = amount >= 0;
    final amountColor = isAdvance ? LoginColors.success : LoginColors.error;
    final phone = customer.phone?.trim() ?? '';

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        CustomerDetailBody._horizontal,
        6,
        CustomerDetailBody._horizontal,
        6,
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: TextStyle(
                color: LoginColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (phone.isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _openWhatsApp(context, phone),
                      icon: const Icon(Icons.chat_rounded, size: 18),
                      label: const Text('WhatsApp'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF25D366),
                        side: const BorderSide(color: Color(0xFF25D366)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _makeCall(context, phone),
                      icon: const Icon(Icons.call_rounded, size: 18),
                      label: const Text('Call'),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: amountColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: amountColor.withValues(alpha: 0.24)),
              ),
              child: Row(
                children: [
                  Icon(
                    isAdvance
                        ? Icons.trending_up_rounded
                        : Icons.trending_down_rounded,
                    color: amountColor,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isAdvance ? 'Advance Amount' : 'Due Amount',
                      style: TextStyle(
                        color: LoginColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                  Text(
                    formatMoney(amount.abs()),
                    style: TextStyle(
                      color: amountColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 13.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkCompanyStrip(
    BuildContext context,
    CustomerDetailViewModel vm,
    bool isLinked,
  ) {
    if (isLinked) return const SizedBox.shrink();
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

  Future<void> _openWhatsApp(BuildContext context, String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    final whatsappPhone = cleanPhone.startsWith('+')
        ? cleanPhone.substring(1)
        : cleanPhone;
    final launched = await launchUrl(
      Uri.parse('https://wa.me/$whatsappPhone'),
      mode: LaunchMode.externalApplication,
    );
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open WhatsApp')),
      );
    }
  }

  Future<void> _makeCall(BuildContext context, String phone) async {
    final launched = await launchUrl(
      Uri.parse('tel:$phone'),
      mode: LaunchMode.externalApplication,
    );
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not start call')),
      );
    }
  }
}
