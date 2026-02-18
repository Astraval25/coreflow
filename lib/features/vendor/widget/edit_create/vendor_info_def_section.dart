import 'package:coreflow/core/theme/colors.dart';
import 'package:flutter/material.dart';

class VendorInfoSections extends StatefulWidget {
  final GlobalKey<FormState>? formKey;
  final TextEditingController vendorName;
  final TextEditingController displayName;

  const VendorInfoSections({
    super.key,
    this.formKey,
    required this.vendorName,
    required this.displayName,
  });

  @override
  State<VendorInfoSections> createState() => _VendorInfoSectionsState();
}

class _VendorInfoSectionsState extends State<VendorInfoSections> {
  bool _displayNameManuallyEdited = false;
  static const double _iconSize = 18;

  @override
  void initState() {
    super.initState();

    widget.vendorName.addListener(_syncDisplayName);
  }

  void _syncDisplayName() {
    if (!_displayNameManuallyEdited) {
      widget.displayName.text = widget.vendorName.text;
    }
  }

  @override
  void dispose() {
    widget.vendorName.removeListener(_syncDisplayName);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        /// Vendor Name
        TextFormField(
          controller: widget.vendorName,
          keyboardType: TextInputType.name,
          textCapitalization: TextCapitalization.words,
          decoration: _inputDecoration(
            labelText: 'Vendor name *',
            icon: Icons.storefront_outlined,
          ),
          validator: (value) => (value?.trim().isEmpty ?? true)
              ? 'Vendor name is required'
              : null,
          textInputAction: TextInputAction.next,
        ),

        const SizedBox(height: 20),

        TextFormField(
          controller: widget.displayName,
          keyboardType: TextInputType.name,
          textCapitalization: TextCapitalization.words,
          decoration: _inputDecoration(
            labelText: 'Display name *',
            icon: Icons.badge_outlined,
          ),
          onChanged: (value) {
            _displayNameManuallyEdited = value.isNotEmpty;
          },
          validator: (value) => (value?.trim().isEmpty ?? true)
              ? 'Display name is required'
              : null,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) {
            FocusScope.of(context).unfocus();
          },
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
