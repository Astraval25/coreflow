import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/domain/model/vendors/vendors_detail.dart';
import 'package:flutter/material.dart';

class VendorFinancialStrip extends StatelessWidget {
  final VendorsDetailData vendor;
  static const double _horizontalPadding = 20;

  const VendorFinancialStrip({super.key, required this.vendor});

  @override
  Widget build(BuildContext context) {
    final amount = vendor.dueAmount ?? 0.0;
    final isPositive = amount >= 0;
    final balanceColor = isPositive ? LoginColors.success : LoginColors.error;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        _horizontalPadding,
        8,
        _horizontalPadding,
        8,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: LoginColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: LoginColors.borderLight),
          boxShadow: [
            BoxShadow(
              color: LoginColors.shadowLight.withOpacity(0.07),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: balanceColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPositive
                    ? Icons.trending_up_rounded
                    : Icons.trending_down_rounded,
                color: balanceColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Advance balance',
                    style: TextStyle(
                      color: LoginColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isPositive ? 'Vendor has advance' : 'Vendor owes amount',
                    style: TextStyle(
                      color: LoginColors.textSecondary,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '₹${amount.abs().toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: balanceColor,
                fontSize: 15.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
