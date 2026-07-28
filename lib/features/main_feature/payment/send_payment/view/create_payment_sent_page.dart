import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/core/widgets/app_drawer.dart';
import 'package:coreflow/core/widgets/success_popup.dart';
import 'package:coreflow/core/widgets/vendor_selector_page.dart';
import 'package:coreflow/data/repositories/auth_repository/auth_repository.dart';
import 'package:coreflow/domain/model/main_model/payment/payment_proof_result.dart';
import 'package:coreflow/domain/model/main_model/vendors/vendors.dart';
import 'package:coreflow/features/main_feature/dashboard/dashboard_view_model/dashboard_view_model.dart';
import 'package:coreflow/features/main_feature/payment/proof/view/payment_proof_page.dart';
import 'package:coreflow/features/main_feature/payment/send_payment/view/send_payment_detail_page.dart';
import 'package:coreflow/features/main_feature/payment/send_payment/viewmodel/create_payment_sent_view_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CreatePaymentSentPage extends StatelessWidget {
  final int companyId;
  final PaymentProofResult? proofResult;
  final Vendor? initialVendor;
  final int? initialOrderId;
  final double? initialAmount;
  final Map<String, dynamic>? preSelectedVendor;

  const CreatePaymentSentPage({
    super.key,
    required this.companyId,
    this.proofResult,
    this.initialVendor,
    this.initialOrderId,
    this.initialAmount,
    this.preSelectedVendor,
  });

  @override
  Widget build(BuildContext context) {
    Vendor? vendor = initialVendor;
    if (vendor == null && preSelectedVendor != null) {
      vendor = Vendor.fromJson(preSelectedVendor!);
    }

    return ChangeNotifierProvider(
      create: (_) => CreatePaymentSentViewModel(
        repository: AuthRepository(),
        companyId: companyId,
      ),
      child: _CreatePaymentSentView(
        companyId: companyId,
        proofResult: proofResult,
        initialVendor: vendor,
        initialOrderId: initialOrderId,
        initialAmount: initialAmount,
      ),
    );
  }
}

class _CreatePaymentSentView extends StatefulWidget {
  final int companyId;
  final PaymentProofResult? proofResult;
  final Vendor? initialVendor;
  final int? initialOrderId;
  final double? initialAmount;

  const _CreatePaymentSentView({
    required this.companyId,
    this.proofResult,
    this.initialVendor,
    this.initialOrderId,
    this.initialAmount,
  });

  @override
  State<_CreatePaymentSentView> createState() => _CreatePaymentSentViewState();
}

class _CreatePaymentSentViewState extends State<_CreatePaymentSentView> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  final _amountController = TextEditingController();
  final _referenceController = TextEditingController();
  final _remarksController = TextEditingController();

  // Per-row allocation controllers (amount + remarks)
  final List<TextEditingController> _allocAmountControllers = [];
  final List<TextEditingController> _allocRemarksControllers = [];

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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final vm = context.read<CreatePaymentSentViewModel>();

      if (widget.proofResult != null) {
        vm.setProofResult(widget.proofResult!);
        if (widget.proofResult!.amount != null) {
          _amountController.text = widget.proofResult!.amount! % 1 == 0
              ? widget.proofResult!.amount!.toInt().toString()
              : widget.proofResult!.amount.toString();
        }
        if (widget.proofResult!.transactionId != null) {
          _referenceController.text = widget.proofResult!.transactionId!;
        }
      }

      if (widget.initialVendor != null) {
        await vm.setVendorWithOrder(
          widget.initialVendor!,
          orderId: widget.initialOrderId,
          amount: widget.initialAmount,
        );
      }

      if (_amountController.text.trim().isEmpty && vm.amount > 0) {
        _amountController.text = vm.amount % 1 == 0
            ? vm.amount.toInt().toString()
            : vm.amount.toStringAsFixed(2);
      }

      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    _remarksController.dispose();
    for (final c in _allocAmountControllers) {
      c.dispose();
    }
    for (final c in _allocRemarksControllers) {
      c.dispose();
    }
    super.dispose();
  }

  /// Ensures allocation controllers match the current order list.
  /// Called from build() whenever the order count changes.
  void _syncAllocationControllers(List<OrderAllocationEntry> orders) {
    // Dispose extras if list shrank
    while (_allocAmountControllers.length > orders.length) {
      _allocAmountControllers.removeLast().dispose();
      _allocRemarksControllers.removeLast().dispose();
    }
    // Add controllers for new entries
    while (_allocAmountControllers.length < orders.length) {
      final idx = _allocAmountControllers.length;
      final entry = orders[idx];
      _allocAmountControllers.add(
        TextEditingController(
          text: entry.amountApplied > 0
              ? (entry.amountApplied % 1 == 0
                    ? entry.amountApplied.toInt().toString()
                    : entry.amountApplied.toStringAsFixed(2))
              : '',
        ),
      );
      _allocRemarksControllers.add(
        TextEditingController(text: entry.remarks ?? ''),
      );
    }
  }

  /// Syncs controller texts after auto-split without recreating controllers.
  void _syncAllocationAmountsFromVm(List<OrderAllocationEntry> orders) {
    for (
      int i = 0;
      i < orders.length && i < _allocAmountControllers.length;
      i++
    ) {
      final v = orders[i].amountApplied;
      final text = v > 0
          ? (v % 1 == 0 ? v.toInt().toString() : v.toStringAsFixed(2))
          : '';
      if (_allocAmountControllers[i].text != text) {
        _allocAmountControllers[i].text = text;
      }
    }
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

    if (vm.totalAllocated > amount) {
      _showError(
        'Total allocated (${vm.totalAllocated.toStringAsFixed(2)}) exceeds amount',
      );
      return;
    }

    vm.setReferenceNumber(_referenceController.text.trim());
    vm.setPaymentRemarks(_remarksController.text.trim());

    await vm.submitPayment();

    if (vm.isSuccess && mounted) {
      final navigator = Navigator.of(context);
      await showSuccessPopup(
        context: context,
        message: 'Payment Sent Successfully',
      );
      if (!mounted) return;
      navigator.pop(true);
      if (vm.createdPaymentId != null) {
        navigator.push(
          MaterialPageRoute(
            builder: (_) => SendPaymentDetailPage(
              companyId: widget.companyId,
              paymentId: vm.createdPaymentId!,
            ),
          ),
        );
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(seconds: 2),
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
                  Builder(
                    builder: (_) {
                      _syncAllocationControllers(vm.unpaidOrders);
                      return _buildOrderAllocationsSection(vm);
                    },
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
          if (vm.isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.15),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        bottom: false,
        child: Container(
          color: LoginColors.surface,
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (vm.errorMessage != null) ...[
                _buildErrorMessage(vm.errorMessage!),
                const SizedBox(height: 10),
              ],
              _buildSendPaymentButton(vm),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSendPaymentButton(CreatePaymentSentViewModel vm) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton.icon(
        onPressed: vm.canSubmit && !vm.isLoading ? _submit : null,
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
          vm.isLoading ? 'Sending Payment...' : 'Send Payment',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: LoginColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: LoginColors.primary.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorMessage(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: LoginColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: LoginColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: LoginColors.error, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: LoginColors.error,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
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
                        color: LoginColors.success.withValues(alpha: 0.12),
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
                          horizontal: 12,
                          vertical: 4,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Change',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        vm.clearProof();
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: LoginColors.error,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Remove',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
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
                        color: LoginColors.primary.withValues(alpha: 0.1),
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
                          backgroundColor: LoginColors.primary.withValues(
                            alpha: 0.15,
                          ),
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
                // Amount with auto-split button
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: TextStyle(
                    fontSize: 15,
                    color: LoginColors.textPrimary,
                  ),
                  onChanged: (v) {
                    final amount = double.tryParse(v.trim()) ?? 0;
                    vm.setAmount(amount);
                  },
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Required';
                    final n = double.tryParse(v);
                    if (n == null || n <= 0) return 'Must be > 0';
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    labelStyle: TextStyle(
                      fontSize: 13,
                      color: LoginColors.textSecondary,
                    ),
                    prefixIcon: Icon(
                      Icons.currency_rupee_rounded,
                      size: 18,
                      color: LoginColors.textTertiary,
                    ),
                    suffixIcon: Tooltip(
                      message: 'Auto-split to orders',
                      child: IconButton(
                        icon: Icon(
                          Icons.auto_fix_high_rounded,
                          size: 20,
                          color: LoginColors.primary,
                        ),
                        onPressed: () {
                          final amount =
                              double.tryParse(_amountController.text.trim()) ??
                              0;
                          if (amount > 0) {
                            vm.setAmount(amount);
                            vm.autoSplitAmount();
                            _syncAllocationAmountsFromVm(vm.unpaidOrders);
                            setState(() {});
                          }
                        },
                      ),
                    ),
                    filled: true,
                    fillColor: LoginColors.fieldFill,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
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
                      borderSide: BorderSide(
                        color: LoginColors.primary,
                        width: 1.2,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: LoginColors.error),
                    ),
                  ),
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
                        fontSize: 13,
                        color: LoginColors.textSecondary,
                      ),
                      prefixIcon: Icon(
                        Icons.calendar_today_rounded,
                        size: 18,
                        color: LoginColors.textTertiary,
                      ),
                      filled: true,
                      fillColor: LoginColors.fieldFill,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: LoginColors.borderLight),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: LoginColors.borderLight),
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
                  initialValue: vm.modeOfPayment,
                  onChanged: (v) {
                    if (v != null) vm.setModeOfPayment(v);
                  },
                  items: _paymentModes
                      .map(
                        (m) => DropdownMenuItem(
                          value: m,
                          child: Text(
                            m.replaceAll('_', ' '),
                            style: TextStyle(
                              fontSize: 15,
                              color: LoginColors.textPrimary,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  decoration: InputDecoration(
                    labelText: 'Mode of Payment',
                    labelStyle: TextStyle(
                      fontSize: 13,
                      color: LoginColors.textSecondary,
                    ),
                    prefixIcon: Icon(
                      Icons.account_balance_rounded,
                      size: 18,
                      color: LoginColors.textTertiary,
                    ),
                    filled: true,
                    fillColor: LoginColors.fieldFill,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
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
                      borderSide: BorderSide(
                        color: LoginColors.primary,
                        width: 1.2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Reference Number with auto-fill
                TextFormField(
                  controller: _referenceController,
                  keyboardType: TextInputType.text,
                  style: TextStyle(
                    fontSize: 15,
                    color: LoginColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Reference Number (optional)',
                    labelStyle: TextStyle(
                      fontSize: 13,
                      color: LoginColors.textSecondary,
                    ),
                    prefixIcon: Icon(
                      Icons.tag_rounded,
                      size: 18,
                      color: LoginColors.textTertiary,
                    ),
                    suffixIcon: vm.selectedVendor != null
                        ? Tooltip(
                            message: 'Auto-fill vendor name',
                            child: IconButton(
                              icon: Icon(
                                Icons.person_pin_rounded,
                                size: 20,
                                color: LoginColors.primary,
                              ),
                              onPressed: () {
                                _referenceController.text =
                                    'Transferred to ${vm.selectedVendor!.displayName}';
                              },
                            ),
                          )
                        : null,
                    filled: true,
                    fillColor: LoginColors.fieldFill,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
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
                      borderSide: BorderSide(
                        color: LoginColors.primary,
                        width: 1.2,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: LoginColors.error),
                    ),
                  ),
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
                  Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: LoginColors.textTertiary,
                  ),
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
                    Icon(
                      Icons.check_circle_outline_rounded,
                      size: 36,
                      color: LoginColors.textTertiary,
                    ),
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
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Order',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: LoginColors.textTertiary,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Balance',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: LoginColors.textTertiary,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Allocate',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: LoginColors.textTertiary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: LoginColors.borderLight, height: 1),
            ...vm.unpaidOrders.asMap().entries.map((entry) {
              final index = entry.key;
              final alloc = entry.value;
              return _buildOrderAllocationRow(vm, alloc, index);
            }),
            // Total allocated summary
            Divider(color: LoginColors.borderLight, height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Allocated',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: LoginColors.textPrimary,
                    ),
                  ),
                  Text(
                    vm.totalAllocated.toStringAsFixed(2),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: vm.totalAllocated > vm.amount
                          ? LoginColors.error
                          : LoginColors.primary,
                    ),
                  ),
                ],
              ),
            ),
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
    if (index >= _allocAmountControllers.length) return const SizedBox.shrink();
    final amountCtrl = _allocAmountControllers[index];
    final remarksCtrl = _allocRemarksControllers[index];
    final hasAmount = entry.amountApplied > 0;

    final inputDecoration = InputDecoration(
      hintStyle: TextStyle(fontSize: 12, color: LoginColors.textTertiary),
      filled: true,
      fillColor: LoginColors.fieldFill,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: LoginColors.borderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: LoginColors.borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: LoginColors.primary, width: 1.2),
      ),
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: BoxDecoration(
        color: hasAmount ? LoginColors.primary.withValues(alpha: 0.04) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order info + balance row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.order.orderNumber,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: LoginColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('dd MMM yyyy').format(entry.order.orderDate),
                      style: TextStyle(
                        fontSize: 11,
                        color: LoginColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'Bal: ${entry.order.balanceAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: LoginColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Amount + Remarks fields side by side
          Row(
            children: [
              // Amount field
              SizedBox(
                width: 110,
                height: 34,
                child: TextField(
                  controller: amountCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 13,
                    color: LoginColors.textPrimary,
                  ),
                  onChanged: (v) {
                    final amount = double.tryParse(v.trim()) ?? 0;
                    vm.updateAllocationAmount(index, amount);
                  },
                  decoration: inputDecoration.copyWith(hintText: '0.00'),
                ),
              ),
              const SizedBox(width: 8),
              // Remarks field
              Expanded(
                child: SizedBox(
                  height: 34,
                  child: TextField(
                    controller: remarksCtrl,
                    style: TextStyle(
                      fontSize: 12,
                      color: LoginColors.textPrimary,
                    ),
                    onChanged: (v) {
                      vm.updateAllocationRemarks(
                        index,
                        v.trim().isEmpty ? null : v.trim(),
                      );
                    },
                    decoration: inputDecoration.copyWith(
                      hintText: 'Remarks (optional)',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
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
        labelStyle: TextStyle(fontSize: 13, color: LoginColors.textSecondary),
        prefixIcon: Icon(icon, size: 18, color: LoginColors.textTertiary),
        filled: true,
        fillColor: LoginColors.fieldFill,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
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
          borderSide: BorderSide(color: LoginColors.primary, width: 1.2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: LoginColors.error),
        ),
      ),
    );
  }
}
