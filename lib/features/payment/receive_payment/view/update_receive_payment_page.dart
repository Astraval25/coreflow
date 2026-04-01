import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/core/widgets/customer_selector_page.dart';
import 'package:coreflow/data/repositories/auth_repository.dart';
import 'package:coreflow/domain/model/customer/customer.dart';
import 'package:coreflow/domain/model/payment/payment_detail.dart';
import 'package:coreflow/features/payment/receive_payment/viewmodel/update_receive_payment_view_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class UpdateReceivePaymentPage extends StatelessWidget {
  final int companyId;
  final PaymentDetail initialPayment;

  const UpdateReceivePaymentPage({
    super.key,
    required this.companyId,
    required this.initialPayment,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UpdateReceivePaymentViewModel(
        repository: AuthRepository(),
        companyId: companyId,
        paymentId: initialPayment.paymentId,
        initialPayment: initialPayment,
      ),
      child: _UpdateReceivePaymentView(companyId: companyId),
    );
  }
}

class _UpdateReceivePaymentView extends StatefulWidget {
  final int companyId;

  const _UpdateReceivePaymentView({required this.companyId});

  @override
  State<_UpdateReceivePaymentView> createState() =>
      _UpdateReceivePaymentViewState();
}

class _UpdateReceivePaymentViewState extends State<_UpdateReceivePaymentView> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _amountController;
  late final TextEditingController _referenceController;
  late final TextEditingController _remarksController;

  final List<TextEditingController> _allocAmountControllers = [];
  final List<TextEditingController> _allocRemarksControllers = [];

  bool _initialized = false;

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

  void _initControllers(UpdateReceivePaymentViewModel vm) {
    if (_initialized) return;
    _amountController = TextEditingController(
      text: vm.amount > 0 ? vm.amount.toStringAsFixed(2) : '',
    );
    _referenceController = TextEditingController(
      text: vm.referenceNumber ?? '',
    );
    _remarksController = TextEditingController(text: vm.paymentRemarks ?? '');
    _initialized = true;
  }

  void _syncAllocationControllers(
    List<UpdateReceivePaymentAllocationEntry> allocations,
  ) {
    while (_allocAmountControllers.length > allocations.length) {
      _allocAmountControllers.removeLast().dispose();
      _allocRemarksControllers.removeLast().dispose();
    }
    while (_allocAmountControllers.length < allocations.length) {
      final idx = _allocAmountControllers.length;
      final entry = allocations[idx];
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

  void _syncAllocationAmountsFromVm(
    List<UpdateReceivePaymentAllocationEntry> allocations,
  ) {
    for (
      int i = 0;
      i < allocations.length && i < _allocAmountControllers.length;
      i++
    ) {
      final v = allocations[i].amountApplied;
      final text = v > 0
          ? (v % 1 == 0 ? v.toInt().toString() : v.toStringAsFixed(2))
          : '';
      if (_allocAmountControllers[i].text != text) {
        _allocAmountControllers[i].text = text;
      }
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
      context.read<UpdateReceivePaymentViewModel>().setCustomer(customer);
    }
  }

  Future<void> _selectDate() async {
    final vm = context.read<UpdateReceivePaymentViewModel>();
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

    final vm = context.read<UpdateReceivePaymentViewModel>();

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
        'Total allocated (${vm.totalAllocated.toStringAsFixed(2)}) exceeds amount',
      );
      return;
    }

    vm.setReferenceNumber(_referenceController.text.trim());
    vm.setPaymentRemarks(_remarksController.text.trim());

    await vm.submitUpdate();

    if (vm.isSuccess && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 1),
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Text('Payment Updated Successfully'),
            ],
          ),
          backgroundColor: LoginColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      Navigator.pop(context, true);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(seconds: 1),
        content: Text(message),
        backgroundColor: LoginColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<UpdateReceivePaymentViewModel>();
    _initControllers(vm);

    return Scaffold(
      backgroundColor: LoginColors.background,
      appBar: AppBar(
        title: Text(
          'Update Payment Received',
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
                  _buildPaymentDetailsSection(vm),
                  const SizedBox(height: 20),
                  Builder(
                    builder: (_) {
                      _syncAllocationControllers(vm.allocations);
                      return _buildOrderAllocationsSection(vm);
                    },
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
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
                          : const Icon(Icons.save_rounded, size: 20),
                      label: Text(
                        vm.isLoading ? 'Updating Payment...' : 'Update Payment',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: LoginColors.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: LoginColors.primary.withValues(
                          alpha: 0.4,
                        ),
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
                        color: LoginColors.error.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: LoginColors.error.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            color: LoginColors.error,
                            size: 20,
                          ),
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
              color: Colors.black.withValues(alpha: 0.15),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildCustomerSection(UpdateReceivePaymentViewModel vm) {
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
                          backgroundColor: LoginColors.primary.withValues(
                            alpha: 0.15,
                          ),
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
                          Icons.person_outline_rounded,
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

  Widget _buildPaymentDetailsSection(UpdateReceivePaymentViewModel vm) {
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
                  decoration: _fieldDecoration(
                    label: 'Amount',
                    icon: Icons.currency_rupee_rounded,
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
                            _syncAllocationAmountsFromVm(vm.allocations);
                            setState(() {});
                          }
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                // Payment Date
                InkWell(
                  onTap: _selectDate,
                  borderRadius: BorderRadius.circular(10),
                  child: InputDecorator(
                    decoration: _fieldDecoration(
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
                // Mode of Payment
                DropdownButtonFormField<String>(
                  value: vm.modeOfPayment,
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
                  decoration: _fieldDecoration(
                    label: 'Mode of Payment',
                    icon: Icons.account_balance_rounded,
                  ),
                ),
                const SizedBox(height: 14),
                // Reference Number
                TextFormField(
                  controller: _referenceController,
                  keyboardType: TextInputType.text,
                  style: TextStyle(
                    fontSize: 15,
                    color: LoginColors.textPrimary,
                  ),
                  decoration: _fieldDecoration(
                    label: 'Reference Number (optional)',
                    icon: Icons.tag_rounded,
                    suffixIcon: vm.selectedCustomer != null
                        ? Tooltip(
                            message: 'Auto-fill customer name',
                            child: IconButton(
                              icon: Icon(
                                Icons.person_pin_rounded,
                                size: 20,
                                color: LoginColors.primary,
                              ),
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
                // Remarks
                TextFormField(
                  controller: _remarksController,
                  keyboardType: TextInputType.text,
                  maxLines: 2,
                  style: TextStyle(
                    fontSize: 15,
                    color: LoginColors.textPrimary,
                  ),
                  decoration: _fieldDecoration(
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

  Widget _buildOrderAllocationsSection(UpdateReceivePaymentViewModel vm) {
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
                  Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: LoginColors.textTertiary,
                  ),
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
          else if (vm.allocations.isEmpty)
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
                      'No orders to allocate',
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
            ...vm.allocations.asMap().entries.map((entry) {
              return _buildAllocationRow(vm, entry.value, entry.key);
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

  Widget _buildAllocationRow(
    UpdateReceivePaymentViewModel vm,
    UpdateReceivePaymentAllocationEntry entry,
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
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  entry.orderNumber.isNotEmpty
                      ? entry.orderNumber
                      : '#${entry.orderId}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: LoginColors.textPrimary,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  entry.balanceAmount.toStringAsFixed(2),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: LoginColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
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
                    setState(() {});
                  },
                  decoration: inputDecoration.copyWith(hintText: '0.00'),
                ),
              ),
            ],
          ),
          if (hasAmount) ...[
            const SizedBox(height: 8),
            TextField(
              controller: remarksCtrl,
              keyboardType: TextInputType.text,
              style: TextStyle(fontSize: 12, color: LoginColors.textSecondary),
              onChanged: (v) => vm.updateAllocationRemarks(index, v.trim()),
              decoration: inputDecoration.copyWith(
                hintText: 'Allocation remarks (optional)',
              ),
            ),
          ],
        ],
      ),
    );
  }

  InputDecoration _fieldDecoration({
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
