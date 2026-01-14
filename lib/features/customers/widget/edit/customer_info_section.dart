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
  final TextEditingController language;

  CustomerInfoSection({
    super.key,
    this.formKey,
    required this.customerName,
    required this.displayName,
    required this.email,
    required this.phone,
    required this.pan,
    required this.gst,
    required this.advance,
    required this.language,
  });

  final List<String> _languages = ['en', 'hi', 'ta', 'te', 'kn', 'ml', 'bn'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Customer information',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        TextFormField(
          controller: customerName,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            labelText: 'Customer name *',
            labelStyle: TextStyle(
              fontSize: 14,
              color: Theme.of(context).hintColor,
            ),
            border: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            errorBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.red),
            ),
          ),
          validator: (value) =>
              (value?.isEmpty ?? true) ? 'Customer name is required' : null,
        ),
        const SizedBox(height: 20),

        TextFormField(
          controller: displayName,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            labelText: 'Display name *',
            labelStyle: TextStyle(
              fontSize: 14,
              color: Theme.of(context).hintColor,
            ),
            border: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            errorBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.red),
            ),
          ),
          validator: (value) =>
              (value?.isEmpty ?? true) ? 'Display name is required' : null,
        ),
        const SizedBox(height: 20),

        DropdownButtonFormField<String>(
          value: _languages.contains(language.text) ? language.text : null,
          decoration: InputDecoration(
            labelText: 'Language',
            hintText: 'en',
            labelStyle: TextStyle(
              fontSize: 14,
              color: Theme.of(context).hintColor,
            ),
            border: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
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
          decoration: InputDecoration(
            labelText: 'Email',
            labelStyle: TextStyle(
              fontSize: 14,
              color: Theme.of(context).hintColor,
            ),
            border: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 20),

        TextFormField(
          controller: phone,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            labelText: 'Phone',
            labelStyle: TextStyle(
              fontSize: 14,
              color: Theme.of(context).hintColor,
            ),
            border: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
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
                decoration: InputDecoration(
                  labelText: 'PAN',
                  labelStyle: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).hintColor,
                  ),
                  border: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: 2,
                    ),
                  ),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: gst,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  labelText: 'GST',
                  labelStyle: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).hintColor,
                  ),
                  border: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: 2,
                    ),
                  ),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        TextFormField(
          controller: advance,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            labelText: 'Advance amount',
            labelStyle: TextStyle(
              fontSize: 14,
              color: Theme.of(context).hintColor,
            ),
            prefixIcon: Icon(
              Icons.currency_rupee_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
            border: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
      ],
    );
  }
}
