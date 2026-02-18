import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/features/customers/view_model/customer_edit_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SaveCustomerButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isSaving;

  const SaveCustomerButton({
    super.key,
    required this.onPressed,
    required this.isSaving,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CustomerEditViewModel>(
      builder: (context, viewModel, _) {
        return SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton(
            onPressed: viewModel.isSaving ? null : onPressed,
            style: FilledButton.styleFrom(
              backgroundColor: LoginColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
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
                    'Save customer',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
          ),
        );
      },
    );
  }
}
