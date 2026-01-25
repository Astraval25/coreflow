import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/domain/model/vendors/vendors_detail.dart';
import 'package:flutter/material.dart';

class VendorAddressTile extends StatelessWidget {
  final String title;
  final Address? address;

  const VendorAddressTile({
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

    final fullAddress =
        parts.isEmpty ? 'No address provided' : parts.join('\n');

    const String vendorName = 'Vendor';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.person_pin_rounded,
                size: 20,
                color: LoginColors.textPrimary.withOpacity(0.75),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  vendorName,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.3,
                    fontWeight: FontWeight.w500,
                    color: LoginColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

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
