import 'package:flutter/material.dart';

class CustomerInfoSection extends StatelessWidget {
  final GlobalKey<FormState>? formKey;
  final TextEditingController customerName;
  final TextEditingController displayName;
  final TextEditingController email;
  final TextEditingController phone;
  final TextEditingController pan;
  final TextEditingController gst;
  final TextEditingController advance;

  const CustomerInfoSection({
    super.key,
    this.formKey,
    required this.customerName,
    required this.displayName,
    required this.email,
    required this.phone,
    required this.pan,
    required this.gst,
    required this.advance,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Customer information',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: customerName,
          decoration: const InputDecoration(
            labelText: 'Customer name *',
            border: OutlineInputBorder(),
          ),
          validator: (value) => (value?.isEmpty ?? true) ? 'Customer name is required' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: displayName,
          decoration: const InputDecoration(
            labelText: 'Display name',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: email,
          decoration: const InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: phone,
          decoration: const InputDecoration(
            labelText: 'Phone',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: pan,
                decoration: const InputDecoration(
                  labelText: 'PAN',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: gst,
                decoration: const InputDecoration(
                  labelText: 'GST',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: advance,
          decoration: const InputDecoration(
            labelText: 'Advance amount',
            border: OutlineInputBorder(),
            prefixText: '₹ ',
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
      ],
    );
  }
}
