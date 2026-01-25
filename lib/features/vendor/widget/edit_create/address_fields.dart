import 'package:flutter/material.dart';

class VendorAddressFields extends StatelessWidget {
  final TextEditingController attention;
  final TextEditingController line1;
  final TextEditingController line2;
  final TextEditingController city;
  final TextEditingController state;
  final TextEditingController pincode;
  final TextEditingController phone;
  final TextEditingController email;

  const VendorAddressFields({
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: attention,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            labelText: 'Attention name',
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
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: line1,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            labelText: 'Address line 1',
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
        const SizedBox(height: 16),
        TextFormField(
          controller: line2,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            labelText: 'Address line 2',
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
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: city,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  labelText: 'City',
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
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: state,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  labelText: 'State',
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
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: pincode,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  labelText: 'Pincode',
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
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
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
            ),
          ],
        ),
        const SizedBox(height: 16),
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
      ],
    );
  }
}
