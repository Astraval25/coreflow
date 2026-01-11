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
    if (address == null) return const SizedBox.shrink();

    final theme = Theme.of(context);

    final lines = <String>[
      if (address!.line1?.isNotEmpty ?? false) address!.line1!,
      if (address!.line2?.isNotEmpty ?? false) address!.line2!,
      if ((address!.city?.isNotEmpty ?? false) ||
          (address!.state?.isNotEmpty ?? false))
        '${address!.city ?? ''}'
            '${address!.city?.isNotEmpty == true && address!.state?.isNotEmpty == true ? ', ' : ''}'
            '${address!.state ?? ''}',
      address!.pincode.toString(),
    ].where((e) => e.trim().isNotEmpty).toList();

    final fullAddress = lines.join('\n');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                width: 36,
                child: Icon(Icons.person_pin_rounded, size: 20),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      address!.attentionName?.isNotEmpty == true
                          ? address!.attentionName!
                          : '—',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          width: 36,
                          child: Icon(Icons.location_on_outlined, size: 20),
                        ),
                        Expanded(
                          child: Text(
                            fullAddress,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
