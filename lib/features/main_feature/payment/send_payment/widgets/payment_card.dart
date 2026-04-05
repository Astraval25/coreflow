import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/domain/model/main_model/payment/payment_sent_summary.dart';
import 'package:flutter/material.dart';

class PaymentCard extends StatelessWidget {
  final PaymentSentSummary payment;

  const PaymentCard({super.key, required this.payment});

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
                    payment.platformRef?.isNotEmpty == true
                        ? payment.platformRef!
                        : paymentIdText,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
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
                      _PaymentInfoPill(
                        icon: Icons.person_outline_rounded,
                        value: payment.vendorName,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                      ),
                      if (payment.referenceNumber?.isNotEmpty == true)
                        _PaymentInfoPill(
                          icon: Icons.tag_rounded,
                          value: payment.referenceNumber!,
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  _PaymentInfoPill(
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
                            _PaymentInfoPill(
                              icon: Icons.person_outline_rounded,
                              value: payment.vendorName,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                            ),
                            if (payment.referenceNumber?.isNotEmpty == true)
                              _PaymentInfoPill(
                                icon: Icons.tag_rounded,
                                value: payment.referenceNumber!,
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      _PaymentInfoPill(
                        icon: Icons.calendar_today_rounded,
                        value: dateText,
                      ),
                    ],
                  ),
                const SizedBox(height: 8),
                _PaymentMetricTile(
                  label: 'Amount',
                  value: _money(payment.amount),
                  valueColor: LoginColors.textPrimary,
                  modeOfPayment: payment.modeOfPayment,
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: _PaymentStatusBadge(
              label: payment.paymentStatus,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentStatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _PaymentStatusBadge({required this.label, required this.color});

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

class _PaymentInfoPill extends StatelessWidget {
  final IconData icon;
  final String value;
  final double fontSize;
  final FontWeight fontWeight;

  const _PaymentInfoPill({
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

class _PaymentMetricTile extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final String modeOfPayment;

  const _PaymentMetricTile({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.modeOfPayment,
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value,
              style: TextStyle(
                color: valueColor,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
            _ModeOfPaymentChip(modeOfPayment: modeOfPayment),
          ],
        ),
      ],
    );
  }
}

class _ModeOfPaymentChip extends StatelessWidget {
  final String modeOfPayment;

  const _ModeOfPaymentChip({required this.modeOfPayment});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: LoginColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        modeOfPayment,
        style: TextStyle(
          color: LoginColors.primary,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
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
