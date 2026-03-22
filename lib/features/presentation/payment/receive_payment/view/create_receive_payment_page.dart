import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/core/widgets/app_drawer.dart';
import 'package:coreflow/core/widgets/customer_selector_page.dart';
import 'package:coreflow/data/repositories/auth_repository.dart';
import 'package:coreflow/domain/model/customer/customer.dart';
import 'package:coreflow/domain/model/payment/payment_proof_result.dart';
import 'package:coreflow/features/dashboard/dashboard_view_model/dashboard_view_model.dart';
import 'package:coreflow/features/presentation/payment/proof/view/payment_proof_page.dart';
import 'package:coreflow/features/presentation/payment/receive_payment/view/pay_received_detail_page.dart';
import 'package:coreflow/features/presentation/payment/receive_payment/viewmodel/create_receive_payment_view_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CreateReceivePaymentPage extends StatelessWidget {
  final int companyId;
  final PaymentProofResult? proofResult;
  final Customer? initialCustomer;
  final int? initialOrderId;
  final double? initialAmount;

  const CreateReceivePaymentPage({
    super.key,
    required this.companyId,
    this.proofResult,
    this.initialCustomer,
    this.initialOrderId,
    this.initialAmount,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CreateReceivePaymentViewModel(
        repository: AuthRepository(),
        companyId: companyId,
      ),
      child: _CreateReceivePaymentView(
        companyId: companyId,
        proofResult: proofResult,
        initialCustomer: initialCustomer,
        initialOrderId: initialOrderId,
        initialAmount: initialAmount,
      ),
    );
  }
}

class _CreateReceivePaymentView extends StatefulWidget {
  final int companyId;
  final PaymentProofResult? proofResult;
  final Customer? initialCustomer;
  final int? initialOrderId;
  final double? initialAmount;

  const _CreateReceivePaymentView({
    required this.companyId,
    this.proofResult,
    this.initialCustomer,
    this.initialOrderId,
    this.initialAmount,
  });

  @override
  State<_CreateReceivePaymentView> createState() =>
      _CreateReceivePaymentViewState();
}

class _CreateReceivePaymentViewState extends State<_CreateReceivePaymentView> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  final _amountController = TextEditingController();
  final _referenceController = TextEditingController();
  final _remarksController = TextEditingController();

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
      final vm = context.read<CreateReceivePaymentViewModel>();

      if (widget.proofResult != null) {
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
      }

      if (widget.initialCustomer != null) {
        await vm.setCustomerWithOrder(
          widget.initialCustomer!,
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

  void _syncAllocationControllers(List<OrderAllocationEntry> orders) {
    while (_allocAmountControllers.length > orders.length) {
      _allocAmountControllers.removeLast().dispose();
      _allocRemarksControllers.removeLast().dispose();
    }
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

  void _syncAllocationAmountsFromVm(List<OrderAllocationEntry> orders) {
    for (int i = 0;
        i < orders.length && i < _allocAmountControllers.length;
        i++) {
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
      final vm = context.read<CreateReceivePaymentViewModel>();
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

  Future<void> _selectCustomer() async {
    final customer = await Navigator.push<Customer>(
      context,
      MaterialPageRoute(
        builder: (_) => CustomerSelectorPage(companyId: widget.companyId),
      ),
    );
    if (customer != null && mounted) {
      context.read<CreateReceivePaymentViewModel>().setCustomer(customer);
    }
  }

  Future<void> _selectDate() async {
    final vm = context.read<CreateReceivePaymentViewModel>();
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

    final vm = context.read<CreateReceivePaymentViewModel>();

    if (vm.selectedCustomer == null) {
      _showError('Please select a customer');
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
          'Total allocated (${vm.totalAllocated.toStringAsFixed(2)}) exceeds amount');
      return;
    }

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
              Text('Payment Received Successfully'),
            ],
          ),
          backgroundColor: LoginColors.success,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.pop(context, true);
      if (vm.createdPaymentId != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PayReceivedDetailPage(
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
    final vm = context.watch<CreateReceivePaymentViewModel>();

    return Scaffold(
      key: _scaffoldKey,
      drawerEnableOpenDragGesture: false,
      drawer: AppDrawer(vm: dashboardVm),
      backgroundColor: LoginColors.background,
      appBar: AppBar(
        title: Text(
          'Receive Payment',
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
                vm.isLoading ? 'Saving' : 'Save',
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
                  _buildCustomerSection(vm),
                  const SizedBox(height: 20),
                  _buildProofSection(vm),
                  const SizedBox(height: 20),
                  _buildPaymentDetailsSection(vm),
                  const SizedBox(height: 20),
                  Builder(builder: (_) {
                    _syncAllocationControllers(vm.unpaidOrders);
                    return _buildOrderAllocationsSection(vm);
                  }),
                  const SizedBox(height: 28),
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
                          : const Icon(Icons.call_received_rounded, size: 20),
                      label: Text(
                        vm.isLoading
                            ? 'Saving Payment...'
                            : 'Receive Payment',
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

  Widget _buildProofSection(CreateReceivePaymentViewModel vm) {
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
                      onPressed: () => vm.clearProof(),
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

  Widget _buildCustomerSection(CreateReceivePaymentViewModel vm) {
    final customer = vm.selectedCustomer;

    return InkWell(
      onTap: _selectCustomer,
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
                    Icons.person_rounded,
                    color: LoginColors.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Customer',
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
              child: customer != null
                  ? Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor:
                              LoginColors.primary.withOpacity(0.15),
                          child: Text(
                            customer.displayName.isNotEmpty
                                ? customer.displayName[0].toUpperCase()
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
                                customer.displayName,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: LoginColors.textPrimary,
                                ),
                              ),
                              if (customer.customerCompanyName.isNotEmpty)
                                Text(
                                  customer.customerCompanyName,
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
                          Icons.person_search_rounded,
                          color: LoginColors.textTertiary,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Select a customer',
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

  Widget _buildPaymentDetailsSection(CreateReceivePaymentViewModel vm) {
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
                TextFormField(
                  controller: _amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(
                      fontSize: 15, color: LoginColors.textPrimary),
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
                  decoration: _inputDecoration(
                    label: 'Amount',
                    icon: Icons.currency_rupee_rounded,
                    suffixIcon: Tooltip(
                      message: 'Auto-split to orders',
                      child: IconButton(
                        icon: Icon(Icons.auto_fix_high_rounded,
                            size: 20, color: LoginColors.primary),
                        onPressed: () {
                          final amount = double.tryParse(
                                  _amountController.text.trim()) ??
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
                  ),
                ),
                const SizedBox(height: 14),
                InkWell(
                  onTap: _selectDate,
                  borderRadius: BorderRadius.circular(10),
                  child: InputDecorator(
                    decoration: _inputDecoration(
                      label: 'Payment Date',
                      icon: Icons.calendar_today_rounded,
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
                  decoration: _inputDecoration(
                    label: 'Mode of Payment',
                    icon: Icons.account_balance_rounded,
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _referenceController,
                  keyboardType: TextInputType.text,
                  style: TextStyle(
                      fontSize: 15, color: LoginColors.textPrimary),
                  decoration: _inputDecoration(
                    label: 'Reference Number (optional)',
                    icon: Icons.tag_rounded,
                    suffixIcon: vm.selectedCustomer != null
                        ? Tooltip(
                            message: 'Auto-fill customer name',
                            child: IconButton(
                              icon: Icon(Icons.person_pin_rounded,
                                  size: 20, color: LoginColors.primary),
                              onPressed: () {
                                _referenceController.text =
                                    'Received from ${vm.selectedCustomer!.displayName}';
                              },
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _remarksController,
                  maxLines: 2,
                  keyboardType: TextInputType.text,
                  style: TextStyle(
                      fontSize: 15, color: LoginColors.textPrimary),
                  decoration: _inputDecoration(
                    label: 'Remarks (optional)',
                    icon: Icons.notes_rounded,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderAllocationsSection(CreateReceivePaymentViewModel vm) {
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
          if (vm.selectedCustomer == null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 16, color: LoginColors.textTertiary),
                  const SizedBox(width: 8),
                  Text(
                    'Select a customer to see unpaid orders',
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
                      'No unpaid orders for this customer',
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
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text('Order',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: LoginColors.textTertiary,
                        )),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text('Balance',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: LoginColors.textTertiary,
                        )),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text('Allocate',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: LoginColors.textTertiary,
                        )),
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
    CreateReceivePaymentViewModel vm,
    OrderAllocationEntry entry,
    int index,
  ) {
    if (index >= _allocAmountControllers.length) return const SizedBox.shrink();
    final amountCtrl = _allocAmountControllers[index];
    final remarksCtrl = _allocRemarksControllers[index];
    final hasAmount = entry.amountApplied > 0;

    final rowDecoration = InputDecoration(
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
        color: hasAmount ? LoginColors.primary.withOpacity(0.04) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          Row(
            children: [
              SizedBox(
                width: 110,
                height: 34,
                child: TextField(
                  controller: amountCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.right,
                  style:
                      TextStyle(fontSize: 13, color: LoginColors.textPrimary),
                  onChanged: (v) {
                    final amount = double.tryParse(v.trim()) ?? 0;
                    vm.updateAllocationAmount(index, amount);
                  },
                  decoration: rowDecoration.copyWith(hintText: '0.00'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 34,
                  child: TextField(
                    controller: remarksCtrl,
                    style: TextStyle(
                        fontSize: 12, color: LoginColors.textPrimary),
                    onChanged: (v) {
                      vm.updateAllocationRemarks(
                          index, v.trim().isEmpty ? null : v.trim());
                    },
                    decoration:
                        rowDecoration.copyWith(hintText: 'Remarks (optional)'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(fontSize: 13, color: LoginColors.textSecondary),
      prefixIcon: Icon(icon, size: 18, color: LoginColors.textTertiary),
      suffixIcon: suffixIcon,
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
        borderSide: BorderSide(color: LoginColors.primary, width: 1.2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: LoginColors.error),
      ),
    );
  }
}
