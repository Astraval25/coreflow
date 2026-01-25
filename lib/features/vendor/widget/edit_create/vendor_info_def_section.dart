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
          decoration: InputDecoration(
            labelText: 'Vendor name *',
            border: const UnderlineInputBorder(),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
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
          decoration: InputDecoration(
            labelText: 'Display name *',
            border: const UnderlineInputBorder(),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
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
}
