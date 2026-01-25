import 'package:coreflow/core/theme/colors.dart'; // assuming this is where LoginColors lives
import 'package:coreflow/domain/model/customer/customer_detail.dart';
import 'package:flutter/material.dart';

class CustomerAddressTile extends StatelessWidget {
  final String title;
  final Address? address;

  const CustomerAddressTile({
    super.key,
    required this.title,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    if (address == null) {
      return const SizedBox.shrink();
    }

    // Build address lines
    final parts = <String>[];

    if (address!.line1?.trim().isNotEmpty ?? false) {
      parts.add(address!.line1!.trim());
    }
    if (address!.line2?.trim().isNotEmpty ?? false) {
      parts.add(address!.line2!.trim());
    }

    final cityState = [
      address!.city?.trim() ?? '',
      address!.state?.trim() ?? '',
    ].where((p) => p.isNotEmpty).join(', ');
    if (cityState.isNotEmpty) parts.add(cityState);

    final fullAddress = parts.isEmpty
        ? 'No address provided'
        : parts.join('\n');

    final attention = (address!.attentionName?.trim().isNotEmpty ?? false)
        ? address!.attentionName!.trim()
        : '—';

    final hasAttention = attention != '—';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      // decoration: BoxDecoration(
      //   color: Colors.white,
      //   borderRadius: BorderRadius.circular(12),
      //   border: Border.all(color: LoginColors.border),
      //   boxShadow: [
      //     BoxShadow(
      //       color: LoginColors.shadowLight.withOpacity(0.05),
      //       blurRadius: 6,
      //       offset: const Offset(0, 2),
      //     ),
      //   ],
      // ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: LoginColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 1, color: LoginColors.border),

          // Attention / Name
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.person_pin_rounded,
                size: 20,
                color: LoginColors.textPrimary.withOpacity(0.75),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  attention,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.3,
                    fontWeight: FontWeight.w500,
                    color: hasAttention
                        ? LoginColors.textPrimary
                        : LoginColors.textTertiary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Address lines
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 20,
                color: LoginColors.textPrimary.withOpacity(0.75),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  fullAddress,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.45,
                    color: fullAddress == 'No address provided'
                        ? LoginColors.textTertiary
                        : LoginColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
