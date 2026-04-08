import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/core/widgets/app_drawer.dart';
import 'package:coreflow/core/widgets/customer_selector_page.dart';
import 'package:coreflow/core/widgets/success_popup.dart';
import 'package:coreflow/data/repositories/auth_repository/auth_repository.dart';
import 'package:coreflow/domain/model/main_model/customer/customer.dart';
import 'package:coreflow/domain/model/main_model/items/sellable_item.dart';
import 'package:coreflow/features/main_feature/dashboard/dashboard_view_model/dashboard_view_model.dart';
import 'package:coreflow/features/main_feature/customers/view_model/customer_detail_view_model.dart';
import 'package:coreflow/features/main_feature/customers/widget/detail/body/customer_item_pages.dart';
import 'package:coreflow/features/main_feature/items/widget/item_section_card.dart';
import 'package:coreflow/features/main_feature/sales/view/sales_order_detail_page.dart';
import 'package:coreflow/features/main_feature/sales/viewmodel/create_sales_order_view_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CreateSalesOrderPage extends StatelessWidget {
  final int companyId;
  final Map<String, dynamic>? preSelectedCustomer;

  const CreateSalesOrderPage({
    super.key,
    required this.companyId,
    this.preSelectedCustomer,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CreateSalesOrderViewModel(
        repository: AuthRepository(),
        companyId: companyId,
      ),
      child: _CreateSalesOrderView(
        companyId: companyId,
        preSelectedCustomer: preSelectedCustomer,
      ),
    );
  }
}

class _CreateSalesOrderView extends StatefulWidget {
  final int companyId;
  final Map<String, dynamic>? preSelectedCustomer;

  const _CreateSalesOrderView({
    required this.companyId,
    this.preSelectedCustomer,
  });

  @override
  State<_CreateSalesOrderView> createState() => _CreateSalesOrderViewState();
}

class _CreateSalesOrderViewState extends State<_CreateSalesOrderView> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  final _taxController = TextEditingController();
  final _discountController = TextEditingController();
  final _deliveryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.preSelectedCustomer != null) {
        final vm = context.read<CreateSalesOrderViewModel>();
        final customer = Customer.fromJson(widget.preSelectedCustomer!);
        vm.setCustomer(customer);
      }
    });
  }

  @override
  void dispose() {
    _taxController.dispose();
    _discountController.dispose();
    _deliveryController.dispose();
    super.dispose();
  }

  Future<void> _selectCustomer() async {
    final customer = await Navigator.push<Customer>(
      context,
      MaterialPageRoute(
        builder: (_) => CustomerSelectorPage(companyId: widget.companyId),
      ),
    );
    if (customer != null && mounted) {
      context.read<CreateSalesOrderViewModel>().setCustomer(customer);
    }
  }

  Future<void> _selectOrderDate() async {
    final vm = context.read<CreateSalesOrderViewModel>();
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

  void _showAddItemSheet() {
    final vm = context.read<CreateSalesOrderViewModel>();

    if (vm.selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 2),
          content: const Text('Please select a customer first'),
          backgroundColor: LoginColors.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: LoginColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ItemPickerSheet(
        items: items,
        existingItemIds: vm.orderItems.map((e) => e.item.itemId).toSet(),
        companyId: widget.companyId,
        customerId: vm.selectedCustomer!.customerId,
        hostContext: context,
        onItemsUpdated: vm.reloadSellableItems,
        onItemSelected: (item) async {
          Navigator.pop(context);
          final result = await _showItemDetailDialog(
            item: item,
            initialQty: 0,
            initialPrice: item.price,
            initialDesc: item.description.isNotEmpty ? item.description : null,
          );
          if (result != null && mounted) {
            vm.addOrderItem(item);
            final idx = vm.orderItems.length - 1;
            vm.updateItemQuantity(idx, result.qty);
            vm.updateItemPrice(idx, result.price);
            vm.updateItemDescription(idx, result.description);
          }
        },
      ),
    );
  }

  Future<_ItemDetailResult?> _showItemDetailDialog({
    required SellableItem item,
    required double initialQty,
    required double initialPrice,
    String? initialDesc,
    bool isEdit = false,
  }) {
    return showModalBottomSheet<_ItemDetailResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: LoginColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ItemDetailSheet(
        itemName: item.itemName,
        initialQty: initialQty,
        initialPrice: initialPrice,
        initialDesc: initialDesc,
        isEdit: isEdit,
      ),
    );
  }

  void _showEditItemDialog(CreateSalesOrderViewModel vm, int index) async {
    final entry = vm.orderItems[index];
    final result = await _showItemDetailDialog(
      item: entry.item,
      initialQty: entry.quantity,
      initialPrice: entry.updatedPrice,
      initialDesc: entry.itemDescription,
      isEdit: true,
    );
    if (result != null && mounted) {
      vm.updateItemQuantity(index, result.qty);
      vm.updateItemPrice(index, result.price);
      vm.updateItemDescription(index, result.description);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final vm = context.read<CreateSalesOrderViewModel>();

    if (vm.selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 2),
          content: const Text('Please select a customer'),
          backgroundColor: LoginColors.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    // Sync text field values to VM
    vm.setTaxAmount(double.tryParse(_taxController.text.trim()) ?? 0);
    vm.setDiscountAmount(
        double.tryParse(_discountController.text.trim()) ?? 0);
    vm.setDeliveryCharge(
        double.tryParse(_deliveryController.text.trim()) ?? 0);

    await vm.submitOrder();

    if (vm.isSuccess && mounted) {
      final navigator = Navigator.of(context);
      await showSuccessPopup(
        context: context,
        message: 'Sales Order Created Successfully',
      );
      if (!mounted) return;
      navigator.pop(true);
      if (vm.createdOrderId != null) {
        navigator.push(
          MaterialPageRoute(
            builder: (_) => SalesOrderDetailPage(
              companyId: widget.companyId,
              orderId: vm.createdOrderId!,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashboardVm = context.watch<DashboardViewModel>();
    final vm = context.watch<CreateSalesOrderViewModel>();

    return Scaffold(
      key: _scaffoldKey,
      drawerEnableOpenDragGesture: false,
      drawer: AppDrawer(vm: dashboardVm),
      backgroundColor: LoginColors.background,
      appBar: AppBar(
        title: Text(
          'New Sales',
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
                vm.isLoading ? 'Creating' : 'Save',
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
                  // Customer Selection
                  _buildCustomerSection(vm),
                  const SizedBox(height: 20),

                  // Order Items
                  _buildOrderItemsSection(vm),
                  const SizedBox(height: 20),

                  // Order Summary (includes editable charges + bill toggle)
                  _buildSummarySection(vm),
                  const SizedBox(height: 28),

                  // Submit Button
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
                          : const Icon(Icons.send_rounded, size: 20),
                      label: Text(
                        vm.isLoading ? 'Creating Order...' : 'Create Order',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: LoginColors.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            LoginColors.primary.withValues(
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
                        color: LoginColors.error.withValues(alpha:0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: LoginColors.error.withValues(alpha: 0.3),
                        ),
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
              color: Colors.black.withValues(alpha: 0.15),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildCustomerSection(CreateSalesOrderViewModel vm) {
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
                          backgroundColor: LoginColors.primary.withValues(alpha:
                            0.15,
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
                          Icons.person_add_rounded,
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

  Widget _buildOrderItemsSection(CreateSalesOrderViewModel vm) {
    return ItemSectionCard(
      title: 'Items',
      icon: Icons.shopping_cart_rounded,
      iconColor: LoginColors.primary,
      padding: EdgeInsets.zero,
      children: [
        if (vm.orderItems.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.add_shopping_cart_rounded,
                      size: 36, color: LoginColors.textTertiary),
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
          // Header row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
            child: Row(
              children: [
                const SizedBox(width: 28),
                Expanded(
                  child: Text('Item',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: LoginColors.textTertiary,
                      )),
                ),
                Text('Amount',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: LoginColors.textTertiary,
                    )),
              ],
            ),
          ),
          Divider(color: LoginColors.borderLight, height: 1),
          // Item rows
          ...vm.orderItems.asMap().entries.map((entry) {
            final index = entry.key;
            final orderItem = entry.value;
            return _buildOrderItemRow(vm, orderItem, index);
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
              label:
                  Text(vm.isLoadingItems ? 'Loading Items...' : 'Add Item'),
              style: OutlinedButton.styleFrom(
                foregroundColor: LoginColors.primary,
                side:
                    BorderSide(color: LoginColors.primary.withValues(alpha:0.4)),
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
      CreateSalesOrderViewModel vm, OrderItemEntry entry, int index) {
    final qtyStr = entry.quantity % 1 == 0
        ? entry.quantity.toInt().toString()
        : entry.quantity.toString();
    final priceStr = entry.updatedPrice % 1 == 0
        ? entry.updatedPrice.toInt().toString()
        : entry.updatedPrice.toStringAsFixed(2);

    return InkWell(
      onTap: () => _showEditItemDialog(vm, index),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Remove button
            InkWell(
              onTap: () => vm.removeOrderItem(index),
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.only(right: 8, top: 1),
                child: Icon(Icons.close_rounded,
                    size: 16, color: LoginColors.error),
              ),
            ),
            // Item name + qty x price
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.item.itemName,
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
            // Amount
            Text(
              entry.lineTotal.toStringAsFixed(2),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: LoginColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummarySection(CreateSalesOrderViewModel vm) {
    final tax = double.tryParse(_taxController.text.trim()) ?? 0;
    final discount = double.tryParse(_discountController.text.trim()) ?? 0;
    final delivery = double.tryParse(_deliveryController.text.trim()) ?? 0;
    final subtotal = vm.subtotal;
    final total = subtotal + tax - discount + delivery;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: LoginColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LoginColors.borderLight),
      ),
      child: Column(
        children: [
          // Title row with Generate Bill toggle
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
            child: Row(
              children: [
                Icon(Icons.summarize_rounded,
                    color: LoginColors.primary, size: 18),
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

// ── Item Detail Result ───────────────────────────────────────

class _ItemDetailResult {
  final double qty;
  final double price;
  final String? description;

  _ItemDetailResult({
    required this.qty,
    required this.price,
    this.description,
  });
}

// ── Item Detail Sheet (Add / Edit) ───────────────────────────

class _ItemDetailSheet extends StatefulWidget {
  final String itemName;
  final double initialQty;
  final double initialPrice;
  final String? initialDesc;
  final bool isEdit;

  const _ItemDetailSheet({
    required this.itemName,
    required this.initialQty,
    required this.initialPrice,
    this.initialDesc,
    this.isEdit = false,
  });

  @override
  State<_ItemDetailSheet> createState() => _ItemDetailSheetState();
}

class _ItemDetailSheetState extends State<_ItemDetailSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _qtyController;
  late TextEditingController _priceController;
  late TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    _qtyController = TextEditingController(
      text: widget.initialQty == 0
          ? ''
          : (widget.initialQty % 1 == 0
                ? widget.initialQty.toInt().toString()
                : widget.initialQty.toString()),
    );
    _priceController = TextEditingController(
        text: widget.initialPrice % 1 == 0
            ? widget.initialPrice.toInt().toString()
            : widget.initialPrice.toString());
    _descController = TextEditingController(text: widget.initialDesc ?? '');
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _priceController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _confirm() {
    if (!_formKey.currentState!.validate()) return;

    final qty = double.tryParse(_qtyController.text.trim()) ?? 1;
    final price = double.tryParse(_priceController.text.trim()) ?? 0;
    final desc = _descController.text.trim();

    Navigator.pop(
      context,
      _ItemDetailResult(
        qty: qty,
        price: price,
        description: desc.isEmpty ? null : desc,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Form(
        key: _formKey,
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
              widget.itemName,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: LoginColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _sheetField(
                    label: 'Quantity',
                    controller: _qtyController,
                    icon: Icons.numbers_rounded,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      final n = double.tryParse(v);
                      if (n == null || n <= 0) return 'Must be > 0';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _sheetField(
                    label: 'Price',
                    controller: _priceController,
                    icon: Icons.currency_rupee_rounded,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      final n = double.tryParse(v);
                      if (n == null || n < 0) return 'Invalid';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _sheetField(
              label: 'Description (optional)',
              controller: _descController,
              icon: Icons.notes_rounded,
              isNumber: false,
              maxLines: 2,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: _confirm,
                style: FilledButton.styleFrom(
                  backgroundColor: LoginColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  widget.isEdit ? 'Update Item' : 'Add Item',
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sheetField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool isNumber = true,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isNumber
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
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

// ── Editable Summary Row ─────────────────────────────────────

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
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
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
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              border: UnderlineInputBorder(
                borderSide: BorderSide(
                    color: LoginColors.borderLight, width: 0.8),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                    color: LoginColors.borderLight, width: 0.8),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide:
                    BorderSide(color: LoginColors.primary, width: 1.2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Summary Row ──────────────────────────────────────────────

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
            color:
                isBold ? LoginColors.textPrimary : LoginColors.textSecondary,
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

// ── Item Picker Bottom Sheet ─────────────────────────────────

class _ItemPickerSheet extends StatefulWidget {
  final List<SellableItem> items;
  final Set<int> existingItemIds;
  final ValueChanged<SellableItem> onItemSelected;
  final int companyId;
  final int customerId;
  final BuildContext hostContext;
  final Future<void> Function()? onItemsUpdated;

  const _ItemPickerSheet({
    required this.items,
    required this.existingItemIds,
    required this.onItemSelected,
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
  bool _showAll = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<SellableItem> _applySearch(List<SellableItem> items) {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) return items;
    return items.where((i) => i.itemName.toLowerCase().contains(q)).toList();
  }

  bool get _hasBaseItems =>
      widget.items.any((i) => i.source == 'ITEM_BASE');
  bool get _hasCustomerItems =>
      widget.items.any((i) => i.source != 'ITEM_BASE');

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
    ScaffoldMessenger.of(widget.hostContext).showSnackBar( 
      const SnackBar(
        duration: Duration(seconds: 2),
        content: Text('Customer item created successfully'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.65;
    final customerItems = _applySearch(
        widget.items.where((i) => i.source != 'ITEM_BASE').toList());
    final baseItems = _showAll
        ? _applySearch(
            widget.items.where((i) => i.source == 'ITEM_BASE').toList())
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
              'Add Item',
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
              style:
                  TextStyle(fontSize: 14, color: LoginColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search items...',
                hintStyle: TextStyle(
                    fontSize: 13, color: LoginColors.textTertiary),
                prefixIcon: Icon(Icons.search_rounded,
                    color: LoginColors.textTertiary, size: 20),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                filled: true,
                fillColor: LoginColors.fieldFill,
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
                              style: TextStyle(
                                color: LoginColors.textTertiary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed: _openCreateCustomerItemFlow,
                                icon: const Icon(Icons.add_circle_outline),
                                label:
                                    const Text('Create Customer Item'),
                                style: FilledButton.styleFrom(
                                  backgroundColor: LoginColors.primary,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                            if (!_showAll && _hasBaseItems) ...[
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () => setState(() => _showAll = true),
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
                        // Customer-specific items
                        ...customerItems.map(_buildItemTile),
                        // "Show All Items" button
                        if (!_showAll && _hasBaseItems) ...[
                          const SizedBox(height: 4),
                          Divider(
                              color: LoginColors.borderLight, height: 1),
                          InkWell(
                            onTap: () => setState(() => _showAll = true),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.expand_more_rounded,
                                      size: 20,
                                      color: LoginColors.primary),
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
                          Divider(
                              color: LoginColors.borderLight, height: 1),
                        ],
                        // Base items section
                        if (_showAll && baseItems.isNotEmpty) ...[
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(8, 12, 8, 4),
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
          ],
        ),
      ),
    );
  }

  Widget _buildItemTile(SellableItem item) {
    final alreadyAdded = widget.existingItemIds.contains(item.itemId);

    return ListTile(
      dense: true,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: LoginColors.primary.withValues(alpha: 0.12),
        child: Text(
          item.itemName.isNotEmpty
              ? item.itemName[0].toUpperCase()
              : '?',
          style: TextStyle(
            color: LoginColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
      title: Text(
        item.itemName,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: alreadyAdded
              ? LoginColors.textTertiary
              : LoginColors.textPrimary,
        ),
      ),
      subtitle: Text(
        '${item.price.toStringAsFixed(2)}${item.hsnCode.isNotEmpty ? ' | HSN: ${item.hsnCode}' : ''}',
        style: TextStyle(
          fontSize: 12,
          color: LoginColors.textSecondary,
        ),
      ),
      trailing: alreadyAdded
          ? Icon(Icons.check_circle_rounded,
              color: LoginColors.success, size: 20)
          : Icon(Icons.add_circle_outline_rounded,
              color: LoginColors.primary, size: 20),
      onTap: alreadyAdded ? null : () => widget.onItemSelected(item),
    );
  }
}
