import 'package:flutter/material.dart';
import 'address_fields.dart';

class ShippingAddressCard extends StatelessWidget {
  final TextEditingController attention;
  final TextEditingController line1;
  final TextEditingController line2;
  final TextEditingController city;
  final TextEditingController state;
  final TextEditingController pincode;
  final TextEditingController phone;
  final TextEditingController email;

  const ShippingAddressCard({
    super.key,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const SizedBox(width: 12),
            Text(
              'Shipping address',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

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
    );
  }
}
