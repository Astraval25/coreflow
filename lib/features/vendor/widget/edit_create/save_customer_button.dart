import 'package:coreflow/features/vendor/view_model/vendor_edit_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SaveVendorButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isSaving;

  const SaveVendorButton({
    super.key,
    required this.onPressed,
    required this.isSaving,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<VendorEditViewModel>(
      builder: (context, viewModel, _) {
        return SizedBox(
          width: double.infinity,
          height: 50,
          child: FilledButton(
            onPressed: viewModel.isSaving ? null : onPressed,
            child: viewModel.isSaving
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Save vendor',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        );
      },
    );
  }
}
