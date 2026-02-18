import 'package:coreflow/core/theme/colors.dart';
import 'package:flutter/material.dart';

class CustomerInfoSections extends StatefulWidget {
  final GlobalKey<FormState>? formKey;
  final TextEditingController customerName;
  final TextEditingController displayName;

  const CustomerInfoSections({
    super.key,
    this.formKey,
    required this.customerName,
    required this.displayName,
  });

  @override
  State<CustomerInfoSections> createState() => _CustomerInfoSectionsState();
}

class _CustomerInfoSectionsState extends State<CustomerInfoSections> {
  bool _displayNameManuallyEdited = false;
  static const double _iconSize = 18;

  @override
  void initState() {
    super.initState();

    widget.customerName.addListener(_syncDisplayName);
  }

  void _syncDisplayName() {
    if (!_displayNameManuallyEdited) {
      widget.displayName.text = widget.customerName.text;
    }
  }

  @override
  void dispose() {
    widget.customerName.removeListener(_syncDisplayName);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        /// Customer Name
        TextFormField(
          controller: widget.customerName,
          keyboardType: TextInputType.name,
          textCapitalization: TextCapitalization.words,
          decoration: _inputDecoration(
            labelText: 'Customer name *',
            icon: Icons.person_outline_rounded,
          ),
          validator: (value) => (value?.trim().isEmpty ?? true)
              ? 'Customer name is required'
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
