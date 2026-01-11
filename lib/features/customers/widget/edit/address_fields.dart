import 'package:flutter/material.dart';

class AddressFields extends StatelessWidget {
  final TextEditingController attention;
  final TextEditingController line1;
  final TextEditingController line2;
  final TextEditingController city;
  final TextEditingController state;
  final TextEditingController pincode;
  final TextEditingController phone;
  final TextEditingController email;

  const AddressFields({
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
      children: [
        TextFormField(
          controller: attention,
          decoration: const InputDecoration(
            labelText: 'Attention name',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: line1,
          decoration: const InputDecoration(
            labelText: 'Address line 1 *',
            border: OutlineInputBorder(),
          ),
          validator: (value) => (value?.isEmpty ?? true) ? 'Address line 1 is required' : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: line2,
          decoration: const InputDecoration(
            labelText: 'Address line 2',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: city,
                decoration: const InputDecoration(
                  labelText: 'City *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => (value?.isEmpty ?? true) ? 'City is required' : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: state,
                decoration: const InputDecoration(
                  labelText: 'State *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => (value?.isEmpty ?? true) ? 'State is required' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: pincode,
                decoration: const InputDecoration(
                  labelText: 'Pincode *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) => (value?.isEmpty ?? true) ? 'Pincode is required' : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: phone,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: email,
          decoration: const InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
      ],
    );
  }
}
