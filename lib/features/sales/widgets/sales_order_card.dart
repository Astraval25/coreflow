import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/domain/model/sales/sales_order.dart';
import 'package:flutter/material.dart';

class AnimatedSalesOrderCard extends StatelessWidget {
  final SalesOrder order;
  final int index;

  const AnimatedSalesOrderCard({super.key, required this.order, required this.index});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 220 + (index * 35).clamp(0, 280)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 16),
            child: child,
          ),
        );
      },
      child: SalesOrderCard(order: order),
    );
  }
}

class SalesOrderCard extends StatelessWidget {
  final SalesOrder order;

  const SalesOrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isCompact = screenWidth < 360;
    final badgeReserve = isCompact ? 92.0 : 120.0;
    final normalizedStatus = order.orderStatus.trim().toUpperCase();
    final isViewed = normalizedStatus == 'ORDER_VIEWED';
    final isOrdered = normalizedStatus == 'ORDER';
    final statusColor = order.isActive
        ? LoginColors.success
        : LoginColors.error;
    final dateText = _formatDate(order.orderDate);
    final tickColor = isViewed
        ? LoginColors.success
        : isOrdered
        ? LoginColors.textSecondary
        : null;

    return Container(
      decoration: BoxDecoration(
        color: LoginColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: LoginColors.border),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(right: badgeReserve),
                  child: Text(
                    order.platformRef?.isNotEmpty == true
                        ? order.platformRef!
                        : '#${order.orderId}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: LoginColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                if (isCompact) ...[
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _SalesInfoPill(
                        icon: Icons.business_rounded,
                        value: order.buyerCompanyName,
                      ),
                      _SalesInfoPill(
                        icon: Icons.person_outline_rounded,
                        value: order.vendorName,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  _SalesInfoPill(
                    icon: Icons.calendar_today_rounded,
                    value: dateText,
                  ),
                ] else
                  Row(
                    children: [
                      Expanded(
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            _SalesInfoPill(
                              icon: Icons.business_rounded,
                              value: order.buyerCompanyName,
                            ),
                            _SalesInfoPill(
                              icon: Icons.person_outline_rounded,
                              value: order.vendorName,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      _SalesInfoPill(
                        icon: Icons.calendar_today_rounded,
                        value: dateText,
                      ),
                    ],
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _SalesMetricTile(
                        label: 'Total',
                        value: _money(order.totalAmount),
                        valueColor: LoginColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _SalesMetricTile(
                        label: 'Paid',
                        value: _money(order.paidAmount),
                        valueColor: LoginColors.success,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _SalesMetricTile(
                        label: 'Pending',
                        value: _money(
                          order.totalAmount - order.paidAmount < 0
                              ? 0
                              : order.totalAmount - order.paidAmount,
                        ),
                        valueColor: LoginColors.accent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: _SalesStatusBadge(
              label:
                  (order.orderStatus == "ORDER_VIEWED" ||
                      order.orderStatus == "ORDER")
                  ? "NEW ORDER"
                  : order.orderStatus,
              color: statusColor,
            ),
          ),
          if (tickColor != null)
            Positioned(
              right: 10,
              bottom: 10,
              child: Icon(Icons.done_all_rounded, size: 24, color: tickColor),
            ),
        ],
      ),
    );
  }
}

class _SalesStatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _SalesStatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(10)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _SalesInfoPill extends StatelessWidget {
  final IconData icon;
  final String value;
  final double fontSize;
  final FontWeight fontWeight;

  const _SalesInfoPill({
    required this.icon,
    required this.value,
    this.fontSize = 12,
    this.fontWeight = FontWeight.w600,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: LoginColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            color: LoginColors.textSecondary,
            fontSize: fontSize,
            fontWeight: fontWeight,
          ),
        ),
      ],
    );
  }
}

class _SalesMetricTile extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _SalesMetricTile({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: LoginColors.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

String _money(double value) => value.toStringAsFixed(2);

String _formatDate(DateTime date) {
  final yyyy = date.year.toString().padLeft(4, '0');
  final mm = date.month.toString().padLeft(2, '0');
  final dd = date.day.toString().padLeft(2, '0');
  return '$dd-$mm-$yyyy';
}
