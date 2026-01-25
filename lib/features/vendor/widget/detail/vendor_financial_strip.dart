import 'package:coreflow/domain/model/vendors/vendors_detail.dart';
import 'package:flutter/material.dart';

class VendorFinancialStrip extends StatelessWidget {
  final VendorsDetailData vendor;

  const VendorFinancialStrip({super.key, required this.vendor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final amount = vendor.dueAmount ?? 0.0;
    final isPositive = amount >= 0;
    final balanceColor = isPositive
        ? Colors.green.shade700
        : Colors.red.shade700;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: balanceColor.withOpacity(0.08),
      child: Row(
        children: [
          Icon(
            isPositive
                ? Icons.trending_up_rounded
                : Icons.trending_down_rounded,
            color: balanceColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Advance balance',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isPositive ? 'Vendor has advance' : 'Vendor owes amount',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.black.withOpacity(0.65),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '₹${amount.abs().toStringAsFixed(2)}',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: balanceColor,
            ),
          ),
        ],
      ),
    );
  }
}
