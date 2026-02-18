import 'package:coreflow/core/theme/colors.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String labelText;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final void Function(String)? onSubmitted;
  final bool enabled;
  final List<String>? autofillHints;
  final String? hintText;
  final String? helperText;
  final String? prefixText;
  final int? minLines;
  final int? maxLines;
  final bool alignLabelWithHint;

  const CustomTextField({
    super.key,
    this.controller,
    required this.labelText,
    this.validator,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.prefixIcon,
    this.suffixIcon,
    this.onSubmitted,
    this.enabled = true,
    this.autofillHints,
    this.hintText,
    this.helperText,
    this.prefixText,
    this.minLines,
    this.maxLines = 1,
    this.alignLabelWithHint = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      onFieldSubmitted: onSubmitted,
      enabled: enabled,
      autofillHints: autofillHints,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        helperText: helperText,
        prefixText: prefixText,
        alignLabelWithHint: alignLabelWithHint,
        labelStyle: TextStyle(color: LoginColors.textSecondary),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: LoginColors.textSecondary)
            : null,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: LoginColors.fieldFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: LoginColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: LoginColors.error, width: 2),
        ),
      ),
    );
  }
}
