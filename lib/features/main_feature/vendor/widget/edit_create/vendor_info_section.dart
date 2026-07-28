import 'package:coreflow/core/theme/colors.dart';
import 'package:flutter/material.dart';

class VendorInfoSection extends StatelessWidget {
  final GlobalKey<FormState>? formKey;
  final TextEditingController email;
  final TextEditingController phone;
  final TextEditingController pan;
  final TextEditingController gst;
  final TextEditingController dueAmount;
  final TextEditingController language;

  VendorInfoSection({
    super.key,
    this.formKey,
    required this.email,
    required this.phone,
    required this.pan,
    required this.gst,
    required this.dueAmount,
    required this.language,
  });

  final List<String> _languages = ['en', 'hi', 'ta', 'te', 'kn', 'ml', 'bn'];
  static const double _iconSize = 18;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<String>(
          initialValue: _languages.contains(language.text)
              ? language.text
              : null,
          decoration: _inputDecoration(
            labelText: 'Language',
            icon: Icons.language_rounded,
            hintText: 'en',
          ),
          items: _languages.map((String lang) {
            return DropdownMenuItem<String>(
              value: lang,
              child: Text(lang.toUpperCase()),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              language.text = newValue;
            }
          },
        ),
        const SizedBox(height: 20),

        TextFormField(
          controller: email,
          style: const TextStyle(fontSize: 16),
          decoration: _inputDecoration(
            labelText: 'Email',
            icon: Icons.alternate_email_rounded,
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 20),

        TextFormField(
          controller: phone,
          style: const TextStyle(fontSize: 16),
          decoration: _inputDecoration(
            labelText: 'Phone',
            icon: Icons.call_outlined,
          ),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: pan,
                style: const TextStyle(fontSize: 16),
                decoration: _inputDecoration(
                  labelText: 'PAN',
                  icon: Icons.account_box_outlined,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: gst,
                style: const TextStyle(fontSize: 16),
                decoration: _inputDecoration(
                  labelText: 'GST',
                  icon: Icons.receipt_long_outlined,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        TextFormField(
          controller: dueAmount,
          style: const TextStyle(fontSize: 16),
          decoration: _inputDecoration(
            labelText: 'Advance amount',
            icon: Icons.currency_rupee_rounded,
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({
    required String labelText,
    required IconData icon,
    String? hintText,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      labelStyle: TextStyle(fontSize: 14, color: LoginColors.textSecondary),
      hintStyle: TextStyle(fontSize: 14, color: LoginColors.textTertiary),
      prefixIcon: Icon(icon, size: _iconSize, color: LoginColors.textTertiary),
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
