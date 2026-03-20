import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/core/widgets/app_drawer.dart';
import 'package:coreflow/core/widgets/vendor_selector_page.dart';
import 'package:coreflow/data/repositories/auth_repository.dart';
import 'package:coreflow/domain/model/payment/payment_proof_result.dart';
import 'package:coreflow/domain/model/vendors/vendors.dart';
import 'package:coreflow/features/dashboard/dashboard_view_model/dashboard_view_model.dart';
import 'package:coreflow/features/presentation/payment/proof/view/payment_proof_page.dart';
import 'package:coreflow/features/presentation/payment/send_payment/viewmodel/create_payment_sent_view_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CreatePaymentSentPage extends StatelessWidget {
  final int companyId;
  final PaymentProofResult? proofResult;

  const CreatePaymentSentPage({
    super.key,
    required this.companyId,
    this.proofResult,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CreatePaymentSentViewModel(
        repository: AuthRepository(),
        companyId: companyId,
      ),
      child: _CreatePaymentSentView(
        companyId: companyId,
        proofResult: proofResult,
      ),
    );
  }
}

class _CreatePaymentSentView extends StatefulWidget {
  final int companyId;
  final PaymentProofResult? proofResult;

  const _CreatePaymentSentView({
    required this.companyId,
    this.proofResult,
  });

  @override
  State<_CreatePaymentSentView> createState() =>
      _CreatePaymentSentViewState();
}

class _CreatePaymentSentViewState extends State<_CreatePaymentSentView> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  final _amountController = TextEditingController();
  final _referenceController = TextEditingController();
  final _remarksController = TextEditingController();

  static const List<String> _paymentModes = [
    'BANK_TRANSFER',
    'CASH',
    'CHEQUE',
    'UPI',
    'CREDIT_CARD',
    'DEBIT_CARD',
    'OTHER',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.proofResult != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final vm = context.read<CreatePaymentSentViewModel>();
        vm.setProofResult(widget.proofResult!);
        if (widget.proofResult!.amount != null) {
          _amountController.text =
              widget.proofResult!.amount! % 1 == 0
                  ? widget.proofResult!.amount!.toInt().toString()
                  : widget.proofResult!.amount.toString();
        }
        if (widget.proofResult!.transactionId != null) {
          _referenceController.text = widget.proofResult!.transactionId!;
        }
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _attachProof() async {
    final result = await Navigator.push<PaymentProofResult>(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentProofPage(companyId: widget.companyId),
      ),
    );
    if (result != null && mounted) {
      final vm = context.read<CreatePaymentSentViewModel>();
      vm.setProofResult(result);
      if (result.amount != null) {
        _amountController.text = result.amount! % 1 == 0
            ? result.amount!.toInt().toString()
            : result.amount.toString();
      }
      if (result.transactionId != null) {
        _referenceController.text = result.transactionId!;
      }
      setState(() {});
    }
  }

  Future<void> _selectVendor() async {
    final vendor = await Navigator.push<Vendor>(
      context,
      MaterialPageRoute(
        builder: (_) => VendorSelectorPage(companyId: widget.companyId),
      ),
    );
    if (vendor != null && mounted) {
      context.read<CreatePaymentSentViewModel>().setVendor(vendor);
    }
  }

  Future<void> _selectDate() async {
    final vm = context.read<CreatePaymentSentViewModel>();
    final picked = await showDatePicker(
      context: context,
      initialDate: vm.paymentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) {
      vm.setPaymentDate(picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final vm = context.read<CreatePaymentSentViewModel>();

    if (vm.selectedVendor == null) {
      _showError('Please select a vendor');
      return;
    }

    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    if (amount <= 0) {
      _showError('Please enter a valid amount');
      return;
    }

    vm.setAmount(amount);
    vm.setReferenceNumber(_referenceController.text.trim());
    vm.setPaymentRemarks(_remarksController.text.trim());

    await vm.submitPayment();

    if (vm.isSuccess && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Text('Payment Sent Successfully'),
            ],
          ),
          backgroundColor: LoginColors.success,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.pop(context, true);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: LoginColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dashboardVm = context.watch<DashboardViewModel>();
    final vm = context.watch<CreatePaymentSentViewModel>();

    return Scaffold(
      key: _scaffoldKey,
      drawerEnableOpenDragGesture: false,
      drawer: AppDrawer(vm: dashboardVm),
      backgroundColor: LoginColors.background,
      appBar: AppBar(
        title: Text(
          'Send Payment',
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilledButton.icon(
              icon: vm.isLoading
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save, size: 18),
              label: Text(
                vm.isLoading ? 'Sending' : 'Save',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                ),
              ),
              onPressed: vm.isLoading ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: LoginColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildVendorSection(vm),
                  const SizedBox(height: 20),
                  _buildProofSection(vm),
                  const SizedBox(height: 20),
                  _buildPaymentDetailsSection(vm),
                  const SizedBox(height: 20),
                  _buildOrderAllocationsSection(vm),
                  const SizedBox(height: 28),
                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton.icon(
                      onPressed:
                          vm.canSubmit && !vm.isLoading ? _submit : null,
                      icon: vm.isLoading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send_rounded, size: 20),
                      label: Text(
                        vm.isLoading
                            ? 'Sending Payment...'
                            : 'Send Payment',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: LoginColors.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            LoginColors.primary.withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  if (vm.errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: LoginColors.error.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: LoginColors.error.withOpacity(0.3)),
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
                ],
              ),
            ),
          ),
          if (vm.isLoading)
            Container(
              color: Colors.black.withOpacity(0.15),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildProofSection(CreatePaymentSentViewModel vm) {
    final hasProof = vm.fsId != null && vm.fsId!.isNotEmpty;

    return InkWell(
      onTap: _attachProof,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: LoginColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: LoginColors.borderLight),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: hasProof
              ? Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: LoginColors.success.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.check_circle_rounded,
                        color: LoginColors.success,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Proof Attached',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: LoginColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            vm.fsId!.length > 20
                                ? '${vm.fsId!.substring(0, 20)}...'
                                : vm.fsId!,
                            style: TextStyle(
                              fontSize: 12,
                              color: LoginColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: _attachProof,
                      style: TextButton.styleFrom(
                        foregroundColor: LoginColors.primary,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Change',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        vm.clearProof();
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: LoginColors.error,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Remove',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: LoginColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.receipt_long_rounded,
                        color: LoginColors.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Attach Payment Proof',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: LoginColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Upload screenshot or PDF for auto-fill',
                            style: TextStyle(
                              fontSize: 12,
                              color: LoginColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: LoginColors.textTertiary,
                      size: 22,
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildVendorSection(CreatePaymentSentViewModel vm) {
    final vendor = vm.selectedVendor;

    return InkWell(
      onTap: _selectVendor,
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
                  Icon(
                    Icons.store_rounded,
                    color: LoginColors.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Vendor',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: LoginColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              color: LoginColors.borderLight,
              height: 16,
              indent: 16,
              endIndent: 16,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: vendor != null
                  ? Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor:
                              LoginColors.primary.withOpacity(0.15),
                          child: Text(
                            vendor.displayName.isNotEmpty
                                ? vendor.displayName[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              color: LoginColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                vendor.displayName,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: LoginColors.textPrimary,
                                ),
                              ),
                              if (vendor.vendorCompanyName.isNotEmpty)
                                Text(
                                  vendor.vendorCompanyName,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: LoginColors.textSecondary,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: LoginColors.textTertiary,
                          size: 22,
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Icon(
                          Icons.storefront_rounded,
                          color: LoginColors.textTertiary,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Select a vendor',
                          style: TextStyle(
                            fontSize: 14,
                            color: LoginColors.textTertiary,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: LoginColors.textTertiary,
                          size: 22,
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentDetailsSection(CreatePaymentSentViewModel vm) {
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
                Icon(
                  Icons.payment_rounded,
                  color: LoginColors.primary,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Text(
                  'Payment Details',
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
                // Amount
                _buildTextField(
                  label: 'Amount',
                  controller: _amountController,
                  icon: Icons.currency_rupee_rounded,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Required';
                    final n = double.tryParse(v);
                    if (n == null || n <= 0) return 'Must be > 0';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Payment Date
                InkWell(
                  onTap: _selectDate,
                  borderRadius: BorderRadius.circular(10),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Payment Date',
                      labelStyle: TextStyle(
                          fontSize: 13, color: LoginColors.textSecondary),
                      prefixIcon: Icon(Icons.calendar_today_rounded,
                          size: 18, color: LoginColors.textTertiary),
                      filled: true,
                      fillColor: LoginColors.fieldFill,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            BorderSide(color: LoginColors.borderLight),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            BorderSide(color: LoginColors.borderLight),
                      ),
                    ),
                    child: Text(
                      DateFormat('dd MMM yyyy').format(vm.paymentDate),
                      style: TextStyle(
                        fontSize: 15,
                        color: LoginColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Mode of Payment
                DropdownButtonFormField<String>(
                  value: vm.modeOfPayment,
                  onChanged: (v) {
                    if (v != null) vm.setModeOfPayment(v);
                  },
                  items: _paymentModes
                      .map((m) => DropdownMenuItem(
                            value: m,
                            child: Text(
                              m.replaceAll('_', ' '),
                              style: TextStyle(
                                fontSize: 15,
                                color: LoginColors.textPrimary,
                              ),
                            ),
                          ))
                      .toList(),
                  decoration: InputDecoration(
                    labelText: 'Mode of Payment',
                    labelStyle: TextStyle(
                        fontSize: 13, color: LoginColors.textSecondary),
                    prefixIcon: Icon(Icons.account_balance_rounded,
                        size: 18, color: LoginColors.textTertiary),
                    filled: true,
                    fillColor: LoginColors.fieldFill,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          BorderSide(color: LoginColors.borderLight),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          BorderSide(color: LoginColors.borderLight),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                          color: LoginColors.primary, width: 1.2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Reference Number
                _buildTextField(
                  label: 'Reference Number (optional)',
                  controller: _referenceController,
                  icon: Icons.tag_rounded,
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 14),

                // Remarks
                _buildTextField(
                  label: 'Remarks (optional)',
                  controller: _remarksController,
                  icon: Icons.notes_rounded,
                  keyboardType: TextInputType.text,
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderAllocationsSection(CreatePaymentSentViewModel vm) {
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
                Icon(
                  Icons.receipt_long_rounded,
                  color: LoginColors.primary,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Order Allocations',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: LoginColors.textPrimary,
                    ),
                  ),
                ),
                if (_amountController.text.isNotEmpty)
                  Text(
                    'Unallocated: ${vm.unallocatedAmount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: vm.unallocatedAmount < 0
                          ? LoginColors.error
                          : LoginColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          Divider(color: LoginColors.borderLight, height: 16),
          if (vm.selectedVendor == null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 16, color: LoginColors.textTertiary),
                  const SizedBox(width: 8),
                  Text(
                    'Select a vendor to see unpaid orders',
                    style: TextStyle(
                      fontSize: 13,
                      color: LoginColors.textTertiary,
                    ),
                  ),
                ],
              ),
            )
          else if (vm.isLoadingOrders)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (vm.unpaidOrders.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.check_circle_outline_rounded,
                        size: 36, color: LoginColors.textTertiary),
                    const SizedBox(height: 8),
                    Text(
                      'No unpaid orders for this vendor',
                      style: TextStyle(
                        color: LoginColors.textTertiary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
              child: Row(
                children: [
                  const SizedBox(width: 36),
                  Expanded(
                    child: Text('Order',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: LoginColors.textTertiary,
                        )),
                  ),
                  Text('Balance',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: LoginColors.textTertiary,
                      )),
                ],
              ),
            ),
            Divider(color: LoginColors.borderLight, height: 1),
            ...vm.unpaidOrders.asMap().entries.map((entry) {
              final index = entry.key;
              final alloc = entry.value;
              return _buildOrderAllocationRow(vm, alloc, index);
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderAllocationRow(
    CreatePaymentSentViewModel vm,
    OrderAllocationEntry entry,
    int index,
  ) {
    return InkWell(
      onTap: () {
        vm.toggleOrderSelection(index, !entry.selected);
        if (entry.selected) {
          _showAllocationDetailSheet(vm, entry, index);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: entry.selected
              ? LoginColors.primaryLight.withOpacity(0.06)
              : null,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 28,
              child: Checkbox(
                value: entry.selected,
                onChanged: (v) {
                  vm.toggleOrderSelection(index, v ?? false);
                  if (v == true) {
                    _showAllocationDetailSheet(vm, entry, index);
                  }
                },
                activeColor: LoginColors.primary,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.order.orderNumber,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: LoginColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('dd MMM yyyy').format(entry.order.orderDate),
                    style: TextStyle(
                      fontSize: 12,
                      color: LoginColors.textSecondary,
                    ),
                  ),
                  if (entry.selected && entry.amountApplied > 0) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Allocated: ${entry.amountApplied.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: LoginColors.primary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  entry.order.balanceAmount.toStringAsFixed(2),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: LoginColors.textPrimary,
                  ),
                ),
                Text(
                  'of ${entry.order.totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: LoginColors.textTertiary,
                  ),
                ),
              ],
            ),
            if (entry.selected) ...[
              const SizedBox(width: 8),
              InkWell(
                onTap: () =>
                    _showAllocationDetailSheet(vm, entry, index),
                borderRadius: BorderRadius.circular(4),
                child: Icon(Icons.edit_rounded,
                    size: 16, color: LoginColors.primary),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showAllocationDetailSheet(
    CreatePaymentSentViewModel vm,
    OrderAllocationEntry entry,
    int index,
  ) {
    final amountCtrl = TextEditingController(
      text: entry.amountApplied > 0
          ? (entry.amountApplied % 1 == 0
              ? entry.amountApplied.toInt().toString()
              : entry.amountApplied.toString())
          : '',
    );
    final remarksCtrl =
        TextEditingController(text: entry.remarks ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: LoginColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: LoginColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              entry.order.orderNumber,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: LoginColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Balance: ${entry.order.balanceAmount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 13,
                color: LoginColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField(
              label: 'Amount to Apply',
              controller: amountCtrl,
              icon: Icons.currency_rupee_rounded,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                final n = double.tryParse(v);
                if (n == null || n <= 0) return 'Must be > 0';
                if (n > entry.order.balanceAmount) {
                  return 'Cannot exceed balance';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            _buildTextField(
              label: 'Remarks (optional)',
              controller: remarksCtrl,
              icon: Icons.notes_rounded,
              keyboardType: TextInputType.text,
              maxLines: 2,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: () {
                  final amount =
                      double.tryParse(amountCtrl.text.trim()) ?? 0;
                  if (amount <= 0) return;
                  vm.updateAllocationAmount(index, amount);
                  vm.updateAllocationRemarks(
                    index,
                    remarksCtrl.text.trim().isEmpty
                        ? null
                        : remarksCtrl.text.trim(),
                  );
                  Navigator.pop(context);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: LoginColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Apply',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: TextStyle(fontSize: 15, color: LoginColors.textPrimary),
      validator: validator,
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: LoginColors.error),
        ),
      ),
    );
  }
}
