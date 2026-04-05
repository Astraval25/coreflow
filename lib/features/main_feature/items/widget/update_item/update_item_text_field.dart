import 'package:coreflow/core/theme/colors.dart';
import 'package:flutter/material.dart';

class UpdateItemStyledTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final Color iconColor;
  final bool isNumber;
  final bool isRequired;
  final bool validateNonNegative;
  final bool validateTaxRate;
  final String? hintText;
  final int maxLines;

  const UpdateItemStyledTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.icon,
    required this.iconColor,
    this.isNumber = false,
    this.isRequired = false,
    this.validateNonNegative = false,
    this.validateTaxRate = false,
    this.hintText,
    this.maxLines = 1,
  });

  static const double _iconSize = 18;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isNumber
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      style: TextStyle(fontSize: 16, color: LoginColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        labelStyle: TextStyle(fontSize: 14, color: LoginColors.textSecondary),
        hintStyle: TextStyle(fontSize: 14, color: LoginColors.textTertiary),
        prefixIcon: Icon(icon, size: _iconSize, color: iconColor),
        filled: true,
        fillColor: LoginColors.fieldFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: LoginColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: LoginColors.error, width: 1.4),
        ),
      ),
      validator: (value) {
        if (isRequired && (value == null || value.trim().isEmpty)) {
          return '$label is required';
        }

        if (validateNonNegative && value != null && value.trim().isNotEmpty) {
          final numValue = double.tryParse(value);
          if (numValue == null || numValue < 0) {
            return 'Enter valid $label';
          }
        }

        if (validateTaxRate && value != null && value.trim().isNotEmpty) {
          final tax = double.tryParse(value);
          if (tax == null || tax < 0 || tax > 100) {
            return 'Enter valid tax rate (0 - 100)';
          }
        }

        return null;
      },
    );
  }
}
