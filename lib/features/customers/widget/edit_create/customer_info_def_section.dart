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
          decoration: InputDecoration(
            labelText: 'Customer name *',
            border: const UnderlineInputBorder(),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
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
