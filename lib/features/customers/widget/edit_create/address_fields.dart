import 'package:coreflow/core/theme/colors.dart';
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
  static const double _iconSize = 18;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: attention,
          style: const TextStyle(fontSize: 16),
          decoration: _inputDecoration(
            labelText: 'Attention name',
            icon: Icons.person_pin_circle_outlined,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: line1,
          style: const TextStyle(fontSize: 16),
          decoration: _inputDecoration(
            labelText: 'Address line 1',
            icon: Icons.home_work_outlined,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: line2,
          style: const TextStyle(fontSize: 16),
          decoration: _inputDecoration(
            labelText: 'Address line 2',
            icon: Icons.add_road_rounded,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: city,
                style: const TextStyle(fontSize: 16),
                decoration: _inputDecoration(
                  labelText: 'City',
                  icon: Icons.location_city_outlined,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: state,
                style: const TextStyle(fontSize: 16),
                decoration: _inputDecoration(
                  labelText: 'State',
                  icon: Icons.map_outlined,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: pincode,
                style: const TextStyle(fontSize: 16),
                decoration: _inputDecoration(
                  labelText: 'Pincode',
                  icon: Icons.markunread_mailbox_outlined,
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: phone,
                style: const TextStyle(fontSize: 16),
                decoration: _inputDecoration(
                  labelText: 'Phone',
                  icon: Icons.call_outlined,
                ),
                keyboardType: TextInputType.phone,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: email,
          style: const TextStyle(fontSize: 16),
          decoration: _inputDecoration(
            labelText: 'Email',
            icon: Icons.alternate_email_rounded,
          ),
          keyboardType: TextInputType.emailAddress,
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({
    required String labelText,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(
        fontSize: 14,
        color: LoginColors.textSecondary,
      ),
      prefixIcon: Icon(
        icon,
        size: _iconSize,
        color: LoginColors.textTertiary,
      ),
      filled: true,
      fillColor: LoginColors.fieldFill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: LoginColors.borderLight, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: LoginColors.borderLight, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: LoginColors.primary, width: 1.4),
      ),
    );
  }
}
