import 'package:flutter/material.dart';
import 'address_fields.dart';

class BillingAddressCard extends StatelessWidget {
  final bool sameAsBillingAddress;

  final ValueChanged<bool?> onSameChanged;
  final TextEditingController attention;
  final TextEditingController line1;
  final TextEditingController line2;
  final TextEditingController city;
  final TextEditingController state;
  final TextEditingController pincode;
  final TextEditingController phone;
  final TextEditingController email;

  const BillingAddressCard({
    super.key,
    required this.sameAsBillingAddress,
    required this.onSameChanged,
    required this.attention,
    required this.line1,
    required this.line2,
    required this.city,
    required this.state,
    required this.pincode,
    required this.phone,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceVariant,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Billing address',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Checkbox(value: sameAsBillingAddress, onChanged: onSameChanged),
                const Text('Same as shipping'),
              ],
            ),
            if (!sameAsBillingAddress) ...[
              const SizedBox(height: 16),
              AddressFields(
                attention: attention,
                line1: line1,
                line2: line2,
                city: city,
                state: state,
                pincode: pincode,
                phone: phone,
                email: email,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
