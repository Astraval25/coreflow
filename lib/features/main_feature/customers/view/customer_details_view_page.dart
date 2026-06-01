import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/core/utils/common_formatters.dart';
import 'package:coreflow/domain/model/main_model/analytics/party_order_payment_trend.dart';
import 'package:coreflow/domain/model/main_model/customer/customer_detail.dart';
import 'package:coreflow/features/main_feature/customers/widget/detail/body/customer_item_section.dart';
import 'package:coreflow/features/main_feature/customers/view_model/customer_detail_view_model.dart';
import 'package:coreflow/features/main_feature/customers/widget/detail/customer_address_tile.dart';
import 'package:coreflow/features/main_feature/customers/widget/detail/customer_info_tile.dart';
import 'package:coreflow/routing/cf_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomerDetailsViewPage extends StatelessWidget {
  final CustomerDetailData customer;

  const CustomerDetailsViewPage({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    LoginColors.setBrightness(Theme.of(context).brightness);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          customer.customerName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          children: [
            CustomerBasicInfoSection(customer: customer),
            const CustomerOrderPaymentTrendSection(),
            const CustomerItemSection(),
            const _CustomerCompanyLinkSection(),
            CustomerAddressSection(customer: customer),
            Consumer<CustomerDetailViewModel>(
              builder: (context, vm, _) {
                final currentCustomer = vm.customer ?? customer;
                return _CustomerWhatsAppActionTile(customer: currentCustomer);
              },
            ),
            Consumer<CustomerDetailViewModel>(
              builder: (context, vm, _) {
                final currentCustomer = vm.customer ?? customer;
                return _CustomerBlockActionTile(
                  vm: vm,
                  customer: currentCustomer,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomerWhatsAppActionTile extends StatelessWidget {
  final CustomerDetailData customer;

  const _CustomerWhatsAppActionTile({required this.customer});

  @override
  Widget build(BuildContext context) {
    final phone = customer.phone?.trim() ?? '';
    final isEnabled = phone.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Material(
        color: LoginColors.surface,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: isEnabled ? () => _openWhatsApp(context, phone) : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: BoxDecoration(
              color: LoginColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: LoginColors.borderLight),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.chat_rounded,
                  color: isEnabled
                      ? const Color(0xFF25D366)
                      : LoginColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'View on WhatsApp',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: isEnabled
                          ? LoginColors.textPrimary
                          : LoginColors.textSecondary,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: LoginColors.textSecondary,
                ),
              ],
            ),
          ),
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not open WhatsApp')));
    }
  }
}

class _CustomerBlockActionTile extends StatelessWidget {
  final CustomerDetailViewModel vm;
  final CustomerDetailData customer;

  const _CustomerBlockActionTile({required this.vm, required this.customer});

  @override
  Widget build(BuildContext context) {
    final isConnected = customer.isFullyConnected;
    final isPending = customer.connectionStatus == 'PENDING';
    final canAcceptAgain =
        !isConnected && customer.connectionStatus == 'REJECTED';
    final canTap = isConnected || canAcceptAgain;
    final isBusy = vm.isConnectionLoading;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Material(
        color: LoginColors.surface,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: (isBusy || !canTap)
              ? null
              : () => _onBlockToggle(context, isLinked: isConnected),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: BoxDecoration(
              color: LoginColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: LoginColors.borderLight),
            ),
            child: Row(
              children: [
                Icon(
                  isConnected ? Icons.block_rounded : Icons.lock_open_rounded,
                  color: isConnected
                      ? LoginColors.error
                      : (canAcceptAgain
                            ? LoginColors.success
                            : LoginColors.textSecondary),
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isConnected
                        ? 'Block Customer'
                        : (canAcceptAgain
                              ? 'Accept Link Request'
                              : (isPending
                                    ? 'Link Request Pending'
                                    : 'No Linked Company')),
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: isConnected
                          ? LoginColors.error
                          : (canAcceptAgain
                                ? LoginColors.success
                                : LoginColors.textSecondary),
                    ),
                  ),
                ),
                if (isBusy)
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: LoginColors.textSecondary,
                    ),
                  )
                else
                  Icon(
                    Icons.chevron_right_rounded,
                    color: LoginColors.textSecondary,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onBlockToggle(
    BuildContext context, {
    required bool isLinked,
  }) async {
    final isUnlinkFlow = isLinked;
    final shouldProceed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          isUnlinkFlow ? 'Disconnect company link?' : 'Accept link request?',
        ),
        content: Text(
          isUnlinkFlow
              ? 'This will remove the current company link and show link request acceptance again.'
              : 'This will accept the pending/rejected link request.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(isUnlinkFlow ? 'Disconnect' : 'Accept'),
          ),
        ],
      ),
    );

    if (shouldProceed != true) return;

    final success = await vm.undoConnectionDecision(
      isUnlinkFlow ? 'REJECTED' : 'ACCEPTED',
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? (isUnlinkFlow
                    ? 'Company link disconnected'
                    : 'Link request accepted')
              : (vm.errorMessage ?? 'Failed to update status'),
        ),
        backgroundColor: success ? LoginColors.success : LoginColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class CustomerSectionHeader extends StatelessWidget {
  final String title;

  const CustomerSectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: LoginColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 3,
            width: 50,
            decoration: BoxDecoration(
              color: LoginColors.textPrimary.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomerCompanyLinkSection extends StatelessWidget {
  const _CustomerCompanyLinkSection();

  @override
  Widget build(BuildContext context) {
    return Consumer<CustomerDetailViewModel>(
      builder: (context, vm, _) {
        final customer = vm.customer;
        if (customer == null) return const SizedBox.shrink();

        final linkedCompany = customer.customerCompany;
        final linkedName = linkedCompany?.companyName?.trim() ?? '';
        final companyId = linkedCompany?.companyId;
        final hasLink = companyId != null && linkedName.isNotEmpty;
        final canSuggestLink =
            !hasLink &&
            vm.linkSuggestion?.hasAccount == true &&
            customer.phone?.trim().isNotEmpty == true;

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: hasLink
                      ? () =>
                            context.push(CfRoutes.marketplaceCompany(companyId))
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
                if (!hasLink && vm.isLinkSuggestionLoading) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: const [
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Checking account by phone...',
                        style: TextStyle(
                          color: Color(0xFF8A5A00),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class CustomerBasicInfoSection extends StatelessWidget {
  final CustomerDetailData customer;

  const CustomerBasicInfoSection({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CustomerSectionHeader(title: 'Basic Information'),
        Divider(height: 1, thickness: 1, color: LoginColors.border),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              CustomerInfoTile(
                icon: Icons.email_outlined,
                label: 'Email',
                value: customer.email,
              ),
              CustomerInfoTile(
                icon: Icons.phone_outlined,
                label: 'Phone',
                value: customer.phone,
              ),
              CustomerInfoTile(
                icon: Icons.badge_outlined,
                label: 'PAN',
                value: customer.pan,
              ),
              CustomerInfoTile(
                icon: Icons.receipt_long_outlined,
                label: 'GST',
                value: customer.gst,
              ),
              CustomerInfoTile(
                icon: Icons.language_rounded,
                label: 'Language',
                value: customer.lang,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class CustomerAddressSection extends StatelessWidget {
  final CustomerDetailData customer;

  const CustomerAddressSection({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    final Address? shippingToShow =
        (customer.sameAsBillingAddress || customer.shippingAddress == null)
        ? customer.billingAddress
        : customer.shippingAddress;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CustomerSectionHeader(title: 'Address Details'),
        Divider(height: 1, thickness: 1, color: LoginColors.border),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomerAddressTile(
                title: 'Billing Address',
                address: customer.billingAddress,
              ),
              if (shippingToShow != null) ...[
                const SizedBox(height: 8),
                CustomerAddressTile(
                  title: 'Shipping Address',
                  address: shippingToShow,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class CustomerOrderPaymentTrendSection extends StatelessWidget {
  const CustomerOrderPaymentTrendSection({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CustomerDetailViewModel>();
    final trend = vm.monthlyOrderPaymentTrend;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CustomerSectionHeader(title: 'Last 30 Days Orders & Payments'),
        Divider(height: 1, thickness: 1, color: LoginColors.border),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: LoginColors.surfaceSecondary,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: LoginColors.borderLight),
            ),
            child: Builder(
              builder: (context) {
                if (vm.isMonthlyOrderPaymentTrendLoading) {
                  return const SizedBox(
                    height: 160,
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: LoginColors.primary,
                      ),
                    ),
                  );
                }
                if (trend.isEmpty) {
                  return SizedBox(
                    height: 120,
                    child: Center(
                      child: Text(
                        'No trend data available',
                        style: TextStyle(color: LoginColors.textSecondary),
                      ),
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _LegendDot(color: LoginColors.primary, label: 'Order'),
                        const SizedBox(width: 14),
                        _LegendDot(
                          color: LoginColors.success,
                          label: 'Payment',
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 150,
                      child: CustomPaint(
                        painter: _OrderPaymentTrendPainter(trend: trend),
                        child: const SizedBox.expand(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          formatDate(trend.first.day),
                          style: TextStyle(
                            fontSize: 11.5,
                            color: LoginColors.textSecondary,
                          ),
                        ),
                        Text(
                          formatDate(trend.last.day),
                          style: TextStyle(
                            fontSize: 11.5,
                            color: LoginColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: LoginColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _OrderPaymentTrendPainter extends CustomPainter {
  final List<PartyOrderPaymentTrendEntry> trend;

  const _OrderPaymentTrendPainter({required this.trend});

  @override
  void paint(Canvas canvas, Size size) {
    if (trend.length < 2) return;

    final orderValues = trend.map((entry) => entry.orderAmount).toList();
    final paymentValues = trend.map((entry) => entry.paidAmount).toList();
    final maxValue = [
      ...orderValues,
      ...paymentValues,
    ].fold<double>(0, (max, value) => value > max ? value : max);

    final safeMax = maxValue <= 0 ? 1.0 : maxValue;
    final chartHeight = size.height - 8;
    final stepX = size.width / (trend.length - 1);

    final gridPaint = Paint()
      ..color = LoginColors.borderLight
      ..strokeWidth = 1;
    for (var i = 0; i < 4; i++) {
      final y = chartHeight * (i / 3);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    Path buildPath(List<double> values) {
      final path = Path();
      for (var i = 0; i < values.length; i++) {
        final x = i * stepX;
        final y = chartHeight - (values[i] / safeMax) * chartHeight;
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      return path;
    }

    final orderPath = buildPath(orderValues);
    final paymentPath = buildPath(paymentValues);

    final orderPaint = Paint()
      ..color = LoginColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.3;
    final paymentPaint = Paint()
      ..color = LoginColors.success
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.3;

    canvas.drawPath(orderPath, orderPaint);
    canvas.drawPath(paymentPath, paymentPaint);
  }

  @override
  bool shouldRepaint(covariant _OrderPaymentTrendPainter oldDelegate) {
    return oldDelegate.trend != trend;
  }
}
