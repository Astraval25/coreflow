import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/core/widgets/customer_selector_page.dart';
import 'package:coreflow/data/repositories/auth_repository/auth_repository.dart';
import 'package:coreflow/domain/model/main_model/customer/customer.dart';
import 'package:coreflow/domain/model/main_model/items/sellable_item.dart';
import 'package:coreflow/domain/model/main_model/sales/sales_order_detail.dart';
import 'package:coreflow/features/main_feature/customers/view_model/customer_detail_view_model.dart';
import 'package:coreflow/features/main_feature/customers/widget/detail/body/customer_item_pages.dart';
import 'package:coreflow/features/main_feature/items/widget/item_section_card.dart';
import 'package:coreflow/features/main_feature/sales/viewmodel/update_sales_order_view_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class UpdateSalesOrderPage extends StatelessWidget {
  final int companyId;
  final SalesOrderDetail initialOrder;

  const UpdateSalesOrderPage({
    super.key,
    required this.companyId,
    required this.initialOrder,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UpdateSalesOrderViewModel(
        repository: AuthRepository(),
        companyId: companyId,
        orderId: initialOrder.orderId,
        initialOrder: initialOrder,
      ),
      child: _UpdateSalesOrderView(companyId: companyId),
    );
  }
}

class _UpdateSalesOrderView extends StatefulWidget {
  final int companyId;

  const _UpdateSalesOrderView({required this.companyId});

  @override
  State<_UpdateSalesOrderView> createState() => _UpdateSalesOrderViewState();
}

class _UpdateSalesOrderViewState extends State<_UpdateSalesOrderView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _taxController;
  late final TextEditingController _discountController;
  late final TextEditingController _deliveryController;

  bool _initialized = false;

  @override
  void dispose() {
    _taxController.dispose();
    _discountController.dispose();
    _deliveryController.dispose();
    super.dispose();
  }

  void _initControllers(UpdateSalesOrderViewModel vm) {
    if (_initialized) return;
    _taxController = TextEditingController(
      text: vm.taxAmount > 0 ? vm.taxAmount.toStringAsFixed(2) : '',
    );
    _discountController = TextEditingController(
      text: vm.discountAmount > 0 ? vm.discountAmount.toStringAsFixed(2) : '',
    );
    _deliveryController = TextEditingController(
      text: vm.deliveryCharge > 0 ? vm.deliveryCharge.toStringAsFixed(2) : '',
    );
    _initialized = true;
  }

  Future<void> _selectCustomer() async {
    final customer = await Navigator.push<Customer>(
      context,
      MaterialPageRoute(
        builder: (_) => CustomerSelectorPage(companyId: widget.companyId),
      ),
    );
    if (customer != null && mounted) {
      context.read<UpdateSalesOrderViewModel>().setCustomer(customer);
    }
  }

  Future<void> _selectOrderDate() async {
    final vm = context.read<UpdateSalesOrderViewModel>();
    final minDate = DateTime(2000);
    final maxDate = DateTime.now().add(Duration(days: 3650));
    final initialDate = vm.orderDate.isBefore(minDate)
        ? minDate
        : (vm.orderDate.isAfter(maxDate) ? maxDate : vm.orderDate);
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: minDate,
      lastDate: maxDate,
    );
    if (picked != null && mounted) {
      vm.setOrderDate(picked);
    }
  }

  Future<void> _selectPaymentDueDate() async {
    final vm = context.read<UpdateSalesOrderViewModel>();
    final minDate = DateTime(2000);
    final maxDate = DateTime.now().add(const Duration(days: 3650));
    final initialDate = vm.paymentDueDate.isBefore(minDate)
        ? minDate
        : (vm.paymentDueDate.isAfter(maxDate) ? maxDate : vm.paymentDueDate);
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: minDate,
      lastDate: maxDate,
    );
    if (picked != null && mounted) {
      vm.setPaymentDueDate(picked);
    }
  }

  void _showAddItemSheet() {
    final vm = context.read<UpdateSalesOrderViewModel>();

    if (vm.selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 2),
          content: const Text('Please select a customer first'),
          backgroundColor: LoginColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    final items = vm.availableItems;

    if (items.isEmpty && !vm.isLoadingItems) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 2),
          content: const Text('No sellable items available for this customer'),
          backgroundColor: LoginColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _OrderItemSelectionPage(
          child: _ItemPickerSheet(
            items: items,
            existingItemIds: vm.orderItems.map((e) => e.itemId).toSet(),
            existingItemValues: {
              for (final entry in vm.orderItems)
                entry.itemId: _ItemDetailResult(
                  qty: entry.quantity,
                  price: entry.updatedPrice,
                  description: entry.itemDescription,
                ),
            },
            companyId: widget.companyId,
            customerId: vm.selectedCustomer!.customerId,
            hostContext: context,
            onItemsUpdated: vm.reloadSellableItems,
            onItemSelected: (item, detail) {
              final existingIdx = vm.orderItems.indexWhere(
                (e) => e.itemId == item.itemId,
              );
              if (existingIdx == -1) {
                vm.addItemFromCatalog(item);
              }
              final idx = vm.orderItems.indexWhere(
                (e) => e.itemId == item.itemId,
              );
              if (idx == -1) return;
              vm.updateItemQuantity(idx, detail.qty);
              vm.updateItemPrice(idx, detail.price);
              vm.updateItemDescription(idx, detail.description);
            },
            onItemRemoved: (item) {
              final idx = vm.orderItems.indexWhere(
                (e) => e.itemId == item.itemId,
              );
              if (idx != -1) vm.removeOrderItem(idx);
            },
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final vm = context.read<UpdateSalesOrderViewModel>();

    if (vm.selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 2),
          content: const Text('Please select a customer'),
          backgroundColor: LoginColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    if (vm.orderItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 2),
          content: const Text('Please add at least one item'),
          backgroundColor: LoginColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    vm.setTaxAmount(double.tryParse(_taxController.text.trim()) ?? 0);
    vm.setDiscountAmount(double.tryParse(_discountController.text.trim()) ?? 0);
    vm.setDeliveryCharge(double.tryParse(_deliveryController.text.trim()) ?? 0);

    await vm.submitUpdate();

    if (vm.isSuccess && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 2),
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Text('Sales Order Updated Successfully'),
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

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<UpdateSalesOrderViewModel>();
    _initControllers(vm);

    return Scaffold(
      backgroundColor: LoginColors.background,
      appBar: AppBar(
        title: Text(
          'Update Sales Order',
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
                  _buildOrderItemsSection(vm),
                  const SizedBox(height: 20),
                  _buildSummarySection(vm),
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
                        vm.isLoading ? 'Updating Order...' : 'Update Order',
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

  Widget _buildCustomerSection(UpdateSalesOrderViewModel vm) {
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

  Widget _buildOrderItemsSection(UpdateSalesOrderViewModel vm) {
    return ItemSectionCard(
      title: 'Items',
      icon: Icons.shopping_bag_rounded,
      iconColor: LoginColors.primary,
      padding: EdgeInsets.zero,
      children: [
        if (vm.orderItems.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.add_shopping_cart_rounded,
                    size: 36,
                    color: LoginColors.textTertiary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No items added yet',
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
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
            child: Row(
              children: [
                const SizedBox(width: 28),
                Expanded(
                  child: Text(
                    'Item',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: LoginColors.textTertiary,
                    ),
                  ),
                ),
                Text(
                  'Amount',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: LoginColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Divider(color: LoginColors.borderLight, height: 1),
          ...vm.orderItems.asMap().entries.map((entry) {
            return _buildOrderItemRow(vm, entry.value, entry.key);
          }),
        ],
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: vm.isLoadingItems ? null : _showAddItemSheet,
              icon: vm.isLoadingItems
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add_rounded, size: 20),
              label: Text(
                vm.isLoadingItems ? 'Loading Items...' : 'Manage Items',
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: LoginColors.primary,
                side: BorderSide(
                  color: LoginColors.primary.withValues(alpha: 0.4),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderItemRow(
    UpdateSalesOrderViewModel vm,
    UpdateSalesOrderItemEntry entry,
    int index,
  ) {
    final qtyStr = entry.quantity % 1 == 0
        ? entry.quantity.toInt().toString()
        : entry.quantity.toString();
    final priceStr = entry.updatedPrice % 1 == 0
        ? entry.updatedPrice.toInt().toString()
        : entry.updatedPrice.toStringAsFixed(2);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => vm.removeOrderItem(index),
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.only(right: 8, top: 1),
              child: Icon(
                Icons.close_rounded,
                size: 16,
                color: LoginColors.error,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.itemName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: LoginColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$qtyStr x $priceStr',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: LoginColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                entry.lineTotal.toStringAsFixed(2),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: LoginColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              InkWell(
                onTap: _showAddItemSheet,
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Icon(
                    Icons.edit_rounded,
                    size: 16,
                    color: LoginColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection(UpdateSalesOrderViewModel vm) {
    final tax = double.tryParse(_taxController.text.trim()) ?? 0;
    final discount = double.tryParse(_discountController.text.trim()) ?? 0;
    final delivery = double.tryParse(_deliveryController.text.trim()) ?? 0;
    final subtotal = vm.subtotal;
    final total = subtotal + tax - discount + delivery;
    final dueInDays = vm.paymentDueDate
        .difference(
          DateTime(vm.orderDate.year, vm.orderDate.month, vm.orderDate.day),
        )
        .inDays;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: LoginColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LoginColors.borderLight),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
            child: Row(
              children: [
                Icon(
                  Icons.summarize_rounded,
                  color: LoginColors.primary,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Text(
                  'Order Summary',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: LoginColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Text(
                  'has Bill',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: LoginColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Transform.scale(
                  scale: 0.8,
                  child: Switch(
                    value: vm.hasBill,
                    onChanged: vm.setHasBill,
                    activeThumbColor: LoginColors.primary,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ),
          Divider(color: LoginColors.borderLight, height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              children: [
                InkWell(
                  onTap: _selectOrderDate,
                  borderRadius: BorderRadius.circular(10),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Order Date',
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
                      DateFormat('dd MMM yyyy').format(vm.orderDate),
                      style: TextStyle(
                        fontSize: 15,
                        color: LoginColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                InkWell(
                  onTap: _selectPaymentDueDate,
                  borderRadius: BorderRadius.circular(10),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Payment Due Date',
                      labelStyle: TextStyle(
                        fontSize: 13,
                        color: LoginColors.textSecondary,
                      ),
                      prefixIcon: Icon(
                        Icons.event_available_rounded,
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
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            DateFormat('dd MMM yyyy').format(vm.paymentDueDate),
                            style: TextStyle(
                              fontSize: 15,
                              color: LoginColors.textPrimary,
                            ),
                          ),
                        ),
                        Text(
                          dueInDays >= 0
                              ? 'Due in $dueInDays day${dueInDays == 1 ? '' : 's'}'
                              : 'Overdue by ${-dueInDays} day${dueInDays == -1 ? '' : 's'}',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: dueInDays >= 0
                                ? LoginColors.primary
                                : LoginColors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _SummaryRow(label: 'Subtotal', value: subtotal),
                const SizedBox(height: 10),
                _EditableSummaryRow(
                  label: 'Tax',
                  controller: _taxController,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 10),
                _EditableSummaryRow(
                  label: 'Discount',
                  controller: _discountController,
                  onChanged: (_) => setState(() {}),
                  isNegative: true,
                ),
                const SizedBox(height: 10),
                _EditableSummaryRow(
                  label: 'Delivery',
                  controller: _deliveryController,
                  onChanged: (_) => setState(() {}),
                ),
                Divider(color: LoginColors.borderLight, height: 24),
                _SummaryRow(label: 'Total', value: total, isBold: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Item Detail Result ─────────────────────────────────────────

class _ItemDetailResult {
  final double qty;
  final double price;
  final String? description;

  _ItemDetailResult({required this.qty, required this.price, this.description});
}

class _OrderItemSelectionPage extends StatelessWidget {
  final Widget child;
  const _OrderItemSelectionPage({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LoginColors.background,
      appBar: AppBar(
        title: const Text('Order Items'),
        backgroundColor: LoginColors.background,
        foregroundColor: LoginColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: child,
    );
  }
}

// ── Item Detail Sheet ──────────────────────────────────────────

// ── Editable Summary Row ──────────────────────────────────────

class _EditableSummaryRow extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool isNegative;

  const _EditableSummaryRow({
    required this.label,
    required this.controller,
    required this.onChanged,
    this.isNegative = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: LoginColors.textSecondary,
          ),
        ),
        SizedBox(
          width: 100,
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isNegative ? LoginColors.error : LoginColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: '0.00',
              hintStyle: TextStyle(
                fontSize: 14,
                color: LoginColors.textTertiary,
              ),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 6,
              ),
              border: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: LoginColors.borderLight,
                  width: 0.8,
                ),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: LoginColors.borderLight,
                  width: 0.8,
                ),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: LoginColors.primary, width: 1.2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Summary Row ───────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  final String label;
  final double value;
  final bool isBold;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 15 : 14,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: isBold ? LoginColors.textPrimary : LoginColors.textSecondary,
          ),
        ),
        Text(
          value.toStringAsFixed(2),
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
            color: isBold ? LoginColors.primary : LoginColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

// ── Item Picker Sheet ─────────────────────────────────────────

class _ItemPickerSheet extends StatefulWidget {
  final List<SellableItem> items;
  final Set<int> existingItemIds;
  final Map<int, _ItemDetailResult> existingItemValues;
  final void Function(SellableItem item, _ItemDetailResult detail)
  onItemSelected;
  final ValueChanged<SellableItem> onItemRemoved;
  final int companyId;
  final int customerId;
  final BuildContext hostContext;
  final Future<void> Function()? onItemsUpdated;

  const _ItemPickerSheet({
    required this.items,
    required this.existingItemIds,
    required this.existingItemValues,
    required this.onItemSelected,
    required this.onItemRemoved,
    required this.companyId,
    required this.customerId,
    required this.hostContext,
    this.onItemsUpdated,
  });

  @override
  State<_ItemPickerSheet> createState() => _ItemPickerSheetState();
}

class _ItemPickerSheetState extends State<_ItemPickerSheet> {
  final _searchController = TextEditingController();
  final Map<int, TextEditingController> _qtyControllers = {};
  final Map<int, TextEditingController> _priceControllers = {};
  late final Set<int> _localAddedItemIds;
  bool _showAll = true;

  List<SellableItem> _applySearch(List<SellableItem> items) {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) return items;
    return items.where((i) => i.itemName.toLowerCase().contains(q)).toList();
  }

  bool get _hasBaseItems => widget.items.any((i) => i.source == 'ITEM_BASE');
  bool get _hasCustomerItems =>
      widget.items.any((i) => i.source != 'ITEM_BASE');

  TextEditingController _qtyControllerFor(int itemId) {
    final existing = widget.existingItemValues[itemId];
    return _qtyControllers.putIfAbsent(
      itemId,
      () => TextEditingController(
        text: existing == null ? '' : _numberText(existing.qty),
      ),
    );
  }

  String _numberText(double value) {
    if (value % 1 == 0) return value.toInt().toString();
    return value.toString();
  }

  TextEditingController _priceControllerFor(SellableItem item) {
    final existing = widget.existingItemValues[item.itemId];
    return _priceControllers.putIfAbsent(
      item.itemId,
      () => TextEditingController(
        text: _numberText(existing?.price ?? item.price),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _localAddedItemIds = Set<int>.from(widget.existingItemIds);
  }

  @override
  void dispose() {
    _searchController.dispose();
    for (final controller in _qtyControllers.values) {
      controller.dispose();
    }
    for (final controller in _priceControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _applySelections() {
    for (final item in widget.items) {
      final qtyText = _qtyControllerFor(item.itemId).text.trim();
      final qty = double.tryParse(qtyText);
      if (qty == null || qty <= 0) {
        if (_localAddedItemIds.remove(item.itemId)) {
          widget.onItemRemoved(item);
        }
        continue;
      }

      final priceText = _priceControllerFor(item).text.trim();
      final parsedPrice = double.tryParse(priceText);
      final price = parsedPrice != null && parsedPrice >= 0
          ? parsedPrice
          : item.price;

      widget.onItemSelected(
        item,
        _ItemDetailResult(
          qty: qty,
          price: price,
          description: item.description.isEmpty ? null : item.description,
        ),
      );
      _localAddedItemIds.add(item.itemId);
    }

    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  Future<void> _openCreateCustomerItemFlow() async {
    Navigator.of(context).pop();

    final created = await Navigator.of(widget.hostContext).push<bool>(
      MaterialPageRoute(
        builder: (_) => SelectCompanyItemPage(
          viewModel: CustomerDetailViewModel(
            companyId: widget.companyId,
            customerId: widget.customerId,
          ),
        ),
      ),
    );

    if (!widget.hostContext.mounted || created != true) return;
    await widget.onItemsUpdated?.call();
    if (!widget.hostContext.mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.75;
    final customerItems = _applySearch(
      widget.items.where((i) => i.source != 'ITEM_BASE').toList(),
    );
    final baseItems = _showAll
        ? _applySearch(
            widget.items.where((i) => i.source == 'ITEM_BASE').toList(),
          )
        : <SellableItem>[];
    final allEmpty = customerItems.isEmpty && baseItems.isEmpty;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
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
              'Manage Items',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: LoginColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search items...',
                hintStyle: TextStyle(
                  fontSize: 13,
                  color: LoginColors.textTertiary,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  size: 20,
                  color: LoginColors.textTertiary,
                ),
                filled: true,
                fillColor: LoginColors.fieldFill,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
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
            const SizedBox(height: 10),
            Flexible(
              child: allEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _hasCustomerItems
                                  ? 'No items found'
                                  : 'No customer-specific items found',
                              style: TextStyle(color: LoginColors.textTertiary),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed: _openCreateCustomerItemFlow,
                                icon: const Icon(Icons.add_circle_outline),
                                label: const Text('Create Customer Item'),
                                style: FilledButton.styleFrom(
                                  backgroundColor: LoginColors.primary,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                            if (!_showAll && _hasBaseItems) ...[
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () =>
                                    setState(() => _showAll = true),
                                child: const Text('Show All Items'),
                              ),
                            ],
                          ],
                        ),
                      ),
                    )
                  : ListView(
                      shrinkWrap: true,
                      children: [
                        ...customerItems.map(_buildItemTile),
                        if (!_showAll && _hasBaseItems) ...[
                          const SizedBox(height: 4),
                          Divider(color: LoginColors.borderLight, height: 1),
                          InkWell(
                            onTap: () => setState(() => _showAll = true),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.expand_more_rounded,
                                    size: 20,
                                    color: LoginColors.primary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Show All Items',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: LoginColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Divider(color: LoginColors.borderLight, height: 1),
                        ],
                        if (_showAll && baseItems.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
                            child: Text(
                              'All Items',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: LoginColors.textTertiary,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                          ...baseItems.map(_buildItemTile),
                        ],
                      ],
                    ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: FilledButton(
                onPressed: _applySelections,
                style: FilledButton.styleFrom(
                  backgroundColor: LoginColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Apply',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemTile(SellableItem item) {
    final alreadyAdded = _localAddedItemIds.contains(item.itemId);
    final qtyController = _qtyControllerFor(item.itemId);
    final priceController = _priceControllerFor(item);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: LoginColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: alreadyAdded ? LoginColors.success : LoginColors.borderLight,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              item.itemName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: LoginColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 90,
            child: TextField(
              controller: priceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: TextStyle(fontSize: 12.5, color: LoginColors.textPrimary),
              decoration: InputDecoration(
                labelText: 'Price',
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 9,
                ),
                filled: true,
                fillColor: LoginColors.fieldFill,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: LoginColors.borderLight),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 70,
            child: TextField(
              controller: qtyController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: TextStyle(fontSize: 12.5, color: LoginColors.textPrimary),
              decoration: InputDecoration(
                labelText: 'Qty',
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 9,
                ),
                filled: true,
                fillColor: LoginColors.fieldFill,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: LoginColors.borderLight),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
