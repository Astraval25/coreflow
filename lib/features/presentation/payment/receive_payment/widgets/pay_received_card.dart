import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/domain/model/payment/payment_received_summary.dart';
import 'package:flutter/material.dart';

class PayReceivedCard extends StatelessWidget {
  final PaymentReceivedSummary payment;

  const PayReceivedCard({super.key, required this.payment});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isCompact = screenWidth < 360;
    final badgeReserve = isCompact ? 92.0 : 120.0;
    final normalizedStatus = payment.paymentStatus.trim().toUpperCase();
    final statusColor = normalizedStatus == 'PAID'
        ? LoginColors.success
        : LoginColors.error;
    final dateText = _formatDate(payment.paymentDate);
    final paymentIdText = payment.paymentNumber?.isNotEmpty == true
        ? payment.paymentNumber!
        : '#${payment.paymentId}';

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
                    paymentIdText,
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
                      _PayReceivedInfoPill(
                        icon: Icons.person_outline_rounded,
                        value: payment.customerName,
                      ),
                      _PayReceivedInfoPill(
                        icon: Icons.payments_rounded,
                        value: payment.modeOfPayment,
                      ),
                      if (payment.referenceNumber?.isNotEmpty == true)
                        _PayReceivedInfoPill(
                          icon: Icons.tag_rounded,
                          value: payment.referenceNumber!,
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  _PayReceivedInfoPill(
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
                            _PayReceivedInfoPill(
                              icon: Icons.person_outline_rounded,
                              value: payment.customerName,
                            ),
                            _PayReceivedInfoPill(
                              icon: Icons.payments_rounded,
                              value: payment.modeOfPayment,
                            ),
                            if (payment.referenceNumber?.isNotEmpty == true)
                              _PayReceivedInfoPill(
                                icon: Icons.tag_rounded,
                                value: payment.referenceNumber!,
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      _PayReceivedInfoPill(
                        icon: Icons.calendar_today_rounded,
                        value: dateText,
                      ),
                    ],
                  ),
                const Divider(thickness: 1.0, color: Colors.grey, height: 15.0),
                const SizedBox(height: 10),
                _PayReceivedMetricTile(
                  label: 'Amount Received',
                  value: _money(payment.amount),
                  valueColor: LoginColors.success,
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: _PayReceivedStatusBadge(
              label: payment.paymentStatus,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _PayReceivedStatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _PayReceivedStatusBadge({required this.label, required this.color});

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

class _PayReceivedInfoPill extends StatelessWidget {
  final IconData icon;
  final String value;

  const _PayReceivedInfoPill({required this.icon, required this.value});

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
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _PayReceivedMetricTile extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _PayReceivedMetricTile({
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
