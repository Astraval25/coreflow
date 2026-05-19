import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/core/utils/common_formatters.dart';
import 'package:coreflow/domain/model/main_model/analytics/party_order_payment_trend.dart';
import 'package:coreflow/domain/model/main_model/customer/customer_detail.dart';
import 'package:coreflow/features/main_feature/customers/view_model/customer_detail_view_model.dart';
import 'package:coreflow/features/main_feature/customers/widget/detail/customer_address_tile.dart';
import 'package:coreflow/features/main_feature/customers/widget/detail/customer_info_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
