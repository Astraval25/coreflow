import 'dart:io';

import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/data/repositories/auth_repository.dart';
import 'package:coreflow/features/presentation/payment/proof/view_model/payment_proof_view_model.dart';
import 'package:coreflow/features/presentation/payment/proof/widget/file_source_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PaymentProofPage extends StatelessWidget {
  final int companyId;
  final File? initialFile;

  const PaymentProofPage({
    super.key,
    required this.companyId,
    this.initialFile,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PaymentProofViewModel(
        repository: AuthRepository(),
        companyId: companyId,
      ),
      child: _PaymentProofView(initialFile: initialFile),
    );
  }
}

class _PaymentProofView extends StatefulWidget {
  final File? initialFile;

  const _PaymentProofView({this.initialFile});

  @override
  State<_PaymentProofView> createState() => _PaymentProofViewState();
}

class _PaymentProofViewState extends State<_PaymentProofView> {
  final _amountController = TextEditingController();
  final _transactionIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialFile != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final vm = context.read<PaymentProofViewModel>();
        vm.setFile(widget.initialFile!);
        vm.uploadProof();
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _transactionIdController.dispose();
    super.dispose();
  }

  Future<void> _selectFile() async {
    final file = await FileSourceBottomSheet.show(context);
    if (file != null && mounted) {
      context.read<PaymentProofViewModel>().setFile(file);
    }
  }

  void _onUpload() {
    context.read<PaymentProofViewModel>().uploadProof();
  }

  void _onContinue() {
    final vm = context.read<PaymentProofViewModel>();

    // Sync edited values
    final amount = double.tryParse(_amountController.text.trim());
    vm.setConfirmedAmount(amount);
    vm.setConfirmedTransactionId(
      _transactionIdController.text.trim().isEmpty
          ? null
          : _transactionIdController.text.trim(),
    );

    final result = vm.buildResult();
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PaymentProofViewModel>();

    // Sync controllers when proof data first arrives
    if (vm.hasProofData) {
      if (_amountController.text.isEmpty && vm.confirmedAmount != null) {
        _amountController.text = vm.confirmedAmount! % 1 == 0
            ? vm.confirmedAmount!.toInt().toString()
            : vm.confirmedAmount.toString();
      }
      if (_transactionIdController.text.isEmpty &&
          vm.confirmedTransactionId != null) {
        _transactionIdController.text = vm.confirmedTransactionId!;
      }
    }

    return Scaffold(
      backgroundColor: LoginColors.background,
      appBar: AppBar(
        title: Text(
          'Payment Proof',
          style: TextStyle(
            color: LoginColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        foregroundColor: LoginColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: LoginColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // File preview / select
            _buildFileSection(vm),
            const SizedBox(height: 20),

            // Upload button (when file selected but not yet uploaded)
            if (vm.hasFile && !vm.hasProofData && !vm.isUploading)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.icon(
                  onPressed: _onUpload,
                  icon: const Icon(Icons.cloud_upload_rounded, size: 20),
                  label: const Text(
                    'Upload & Extract Data',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: LoginColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),

            // Loading
            if (vm.isUploading) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: LoginColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: LoginColors.borderLight),
                ),
                child: Column(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      'Analyzing payment proof...',
                      style: TextStyle(
                        fontSize: 14,
                        color: LoginColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Error
            if (vm.errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: LoginColors.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: LoginColors.error.withValues(alpha:0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline_rounded,
                        color: LoginColors.error, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        vm.errorMessage!,
                        style: TextStyle(
                          color: LoginColors.error,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Extracted data form
            if (vm.hasProofData) ...[
              const SizedBox(height: 20),
              _buildExtractedDataSection(vm),
              const SizedBox(height: 28),

              // Continue button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: _onContinue,
                  icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                  label: const Text(
                    'Continue to Payment',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: LoginColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFileSection(PaymentProofViewModel vm) {
    if (!vm.hasFile) {
      // No file selected — show picker card
      return InkWell(
        onTap: _selectFile,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 40),
          decoration: BoxDecoration(
            color: LoginColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: LoginColors.borderLight,
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            children: [
              Icon(Icons.cloud_upload_outlined,
                  size: 48, color: LoginColors.textTertiary),
              const SizedBox(height: 12),
              Text(
                'Tap to select payment proof',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: LoginColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Image or PDF',
                style: TextStyle(
                  fontSize: 12,
                  color: LoginColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // File selected — show preview
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: LoginColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LoginColors.borderLight),
      ),
      child: Column(
        children: [
          if (vm.isImage)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.file(
                vm.selectedFile!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: LoginColors.primary.withValues(alpha: 0.08),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.picture_as_pdf_rounded,
                      size: 48, color: LoginColors.primary),
                  const SizedBox(height: 8),
                  Text(
                    vm.fileName,
                    style: TextStyle(
                      fontSize: 13,
                      color: LoginColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.attachment_rounded,
                    size: 16, color: LoginColors.textTertiary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    vm.fileName,
                    style: TextStyle(
                      fontSize: 13,
                      color: LoginColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton(
                  onPressed: _selectFile,
                  style: TextButton.styleFrom(
                    foregroundColor: LoginColors.primary,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Change',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExtractedDataSection(PaymentProofViewModel vm) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: LoginColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LoginColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(Icons.auto_awesome_rounded,
                    color: LoginColors.primary, size: 18),
                const SizedBox(width: 10),
                Text(
                  'Extracted Data',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: LoginColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Divider(color: LoginColors.borderLight, height: 16),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Column(
              children: [
                _buildField(
                  label: 'Amount',
                  controller: _amountController,
                  icon: Icons.currency_rupee_rounded,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 14),
                _buildField(
                  label: 'Transaction / Reference ID',
                  controller: _transactionIdController,
                  icon: Icons.tag_rounded,
                ),
                if (vm.proofData?.extractedText != null &&
                    vm.proofData!.extractedText!.trim().isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: LoginColors.fieldFill,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: LoginColors.borderLight),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.text_snippet_rounded,
                                size: 16, color: LoginColors.textTertiary),
                            const SizedBox(width: 6),
                            Text(
                              'Extracted Text',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: LoginColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          vm.proofData!.extractedText!,
                          style: TextStyle(
                            fontSize: 13,
                            color: LoginColors.textSecondary,
                          ),
                          maxLines: 6,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(fontSize: 15, color: LoginColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            TextStyle(fontSize: 13, color: LoginColors.textSecondary),
        prefixIcon:
            Icon(icon, size: 18, color: LoginColors.textTertiary),
        filled: true,
        fillColor: LoginColors.fieldFill,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: LoginColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: LoginColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              BorderSide(color: LoginColors.primary, width: 1.2),
        ),
      ),
    );
  }
}
