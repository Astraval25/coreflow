import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/core/widgets/app_drawer.dart';
import 'package:coreflow/core/widgets/vendor_selector_page.dart';
import 'package:coreflow/core/widgets/success_popup.dart';
import 'package:coreflow/data/repositories/auth_repository/auth_repository.dart';
import 'package:coreflow/domain/model/main_model/items/sellable_item.dart';
import 'package:coreflow/domain/model/main_model/vendors/vendors.dart';
import 'package:coreflow/features/main_feature/dashboard/dashboard_view_model/dashboard_view_model.dart';
import 'package:coreflow/features/main_feature/vendor/view_model/vendor_detail_view_model.dart';
import 'package:coreflow/features/main_feature/vendor/widget/detail/body/vendor_item_pages.dart';
import 'package:coreflow/features/main_feature/items/widget/item_section_card.dart';
import 'package:coreflow/features/main_feature/purchase/view/purchase_order_detail_page.dart';
import 'package:coreflow/features/main_feature/purchase/viewmodel/create_purchase_order_view_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CreatePurchaseOrderPage extends StatelessWidget {
  final int companyId;
  final Map<String, dynamic>? preSelectedVendor;

  const CreatePurchaseOrderPage({
    super.key,
    required this.companyId,
    this.preSelectedVendor,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CreatePurchaseOrderViewModel(
        repository: AuthRepository(),
        companyId: companyId,
      ),
      child: _CreatePurchaseOrderView(
        companyId: companyId,
        preSelectedVendor: preSelectedVendor,
      ),
    );
  }
}

class _CreatePurchaseOrderView extends StatefulWidget {
  final int companyId;
  final Map<String, dynamic>? preSelectedVendor;

  const _CreatePurchaseOrderView({
    required this.companyId,
    this.preSelectedVendor,
  });

  @override
  State<_CreatePurchaseOrderView> createState() =>
      _CreatePurchaseOrderViewState();
}

class _CreatePurchaseOrderViewState extends State<_CreatePurchaseOrderView> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  final _taxController = TextEditingController();
  final _discountController = TextEditingController();
  final _deliveryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.preSelectedVendor != null) {
        final vm = context.read<CreatePurchaseOrderViewModel>();
        final vendor = Vendor.fromJson(widget.preSelectedVendor!);
        vm.setVendor(vendor);
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

  Future<void> _selectVendor() async {
    final vendor = await Navigator.push<Vendor>(
      context,
      MaterialPageRoute(
        builder: (_) => VendorSelectorPage(companyId: widget.companyId),
      ),
    );
    if (vendor != null && mounted) {
      context.read<CreatePurchaseOrderViewModel>().setVendor(vendor);
    }
  }

  Future<void> _selectOrderDate() async {
    final vm = context.read<CreatePurchaseOrderViewModel>();
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
    final vm = context.read<CreatePurchaseOrderViewModel>();
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
    final vm = context.read<CreatePurchaseOrderViewModel>();

    if (vm.selectedVendor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 2),
          content: const Text('Please select a vendor first'),
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
          content: const Text('No purchasable items available for this vendor'),
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
            existingItemIds: vm.orderItems.map((e) => e.item.itemId).toSet(),
            existingItemValues: {
              for (final entry in vm.orderItems)
                entry.item.itemId: _ItemDetailResult(
                  qty: entry.quantity,
                  price: entry.updatedPrice,
                  description: entry.itemDescription,
                ),
            },
            companyId: widget.companyId,
            vendorId: vm.selectedVendor!.vendorId,
            hostContext: context,
            canEditPrice: !vm.vendorHasCompany,
            onItemsUpdated: vm.reloadPurchasableItems,
            onItemSelected: (item, detail) {
              final canEdit = !vm.vendorHasCompany;
              vm.addOrderItem(item);
              final idx = vm.orderItems.indexWhere(
                (entry) => entry.item.itemId == item.itemId,
              );
              if (idx == -1) return;
              vm.updateItemQuantity(idx, detail.qty);
              if (canEdit) {
                vm.updateItemPrice(idx, detail.price);
                vm.updateItemDescription(idx, detail.description);
              }
            },
            onItemRemoved: (item) {
              final idx = vm.orderItems.indexWhere(
                (entry) => entry.item.itemId == item.itemId,
              );
              if (idx != -1) {
                vm.removeOrderItem(idx);
              }
            },
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final vm = context.read<CreatePurchaseOrderViewModel>();

    if (vm.selectedVendor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 2),
          content: const Text('Please select a vendor'),
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

    // Sync text field values to VM
    vm.setTaxAmount(double.tryParse(_taxController.text.trim()) ?? 0);
    vm.setDiscountAmount(double.tryParse(_discountController.text.trim()) ?? 0);
    vm.setDeliveryCharge(double.tryParse(_deliveryController.text.trim()) ?? 0);

    await vm.submitOrder();

    if (vm.isSuccess && mounted) {
      final navigator = Navigator.of(context);
      await showSuccessPopup(
        context: context,
        message: 'Purchase Order Created Successfully',
      );
      if (!mounted) return;
      navigator.pop(true);
      if (vm.createdOrderId != null) {
        navigator.push(
          MaterialPageRoute(
            builder: (_) => PurchaseOrderDetailPage(
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
    final vm = context.watch<CreatePurchaseOrderViewModel>();

    return Scaffold(
      key: _scaffoldKey,
      drawerEnableOpenDragGesture: false,
      drawer: AppDrawer(vm: dashboardVm),
      backgroundColor: LoginColors.background,
      appBar: AppBar(
        title: Text(
          'New Purchase',
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
                  // Vendor Selection
                  _buildVendorSection(vm),
                  const SizedBox(height: 20),

                  // Order Items
                  _buildOrderItemsSection(vm),
                  const SizedBox(height: 20),

                  // Order Summary (includes editable charges + bill toggle)
                  _buildSummarySection(vm),
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
              _buildCreateOrderButton(vm),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreateOrderButton(CreatePurchaseOrderViewModel vm) {
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
          vm.isLoading ? 'Creating Order...' : 'Create Order',
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

  Widget _buildVendorSection(CreatePurchaseOrderViewModel vm) {
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

  Widget _buildOrderItemsSection(CreatePurchaseOrderViewModel vm) {
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
          // Header row
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
    CreatePurchaseOrderViewModel vm,
    PurchaseOrderItemEntry entry,
    int index,
  ) {
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
                  '${entry.quantity} x ${entry.updatedPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: LoginColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
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
    );
  }

  Widget _buildSummarySection(CreatePurchaseOrderViewModel vm) {
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
          // Title row with Generate Bill toggle
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

// -- Item Detail Result ---------------------------------------

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
        title: Text(
          'Manage Items',
          style: TextStyle(
            color: LoginColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        foregroundColor: LoginColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: LoginColors.background,
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: child,
        ),
      ),
    );
  }
}

// Item selection result

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

// -- Summary Row ----------------------------------------------

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

// -- Item Picker Bottom Sheet ---------------------------------

class _ItemPickerSheet extends StatefulWidget {
  final List<SellableItem> items;
  final Set<int> existingItemIds;
  final Map<int, _ItemDetailResult> existingItemValues;
  final void Function(SellableItem item, _ItemDetailResult detail)
  onItemSelected;
  final ValueChanged<SellableItem> onItemRemoved;
  final int companyId;
  final int vendorId;
  final bool canEditPrice;
  final BuildContext hostContext;
  final Future<void> Function()? onItemsUpdated;

  const _ItemPickerSheet({
    required this.items,
    required this.existingItemIds,
    required this.existingItemValues,
    required this.onItemSelected,
    required this.onItemRemoved,
    required this.companyId,
    required this.vendorId,
    this.canEditPrice = true,
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

  List<SellableItem> _applySearch(List<SellableItem> items) {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) return items;
    return items.where((i) => i.itemName.toLowerCase().contains(q)).toList();
  }

  bool get _hasBaseItems => widget.items.any((i) => i.source == 'ITEM_BASE');
  bool get _hasVendorItems => widget.items.any((i) => i.source != 'ITEM_BASE');

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

  Future<void> _openCreateVendorItemFlow() async {
    Navigator.of(context).pop();

    final created = await Navigator.of(widget.hostContext).push<bool>(
      MaterialPageRoute(
        builder: (_) => SelectVendorCompanyItemPage(
          viewModel: VendorDetailViewModel(
            companyId: widget.companyId,
            vendorId: widget.vendorId,
          ),
        ),
      ),
    );

    if (!widget.hostContext.mounted || created != true) return;
    await widget.onItemsUpdated?.call();
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.75;
    final vendorItems = _applySearch(
      widget.items.where((i) => i.source != 'ITEM_BASE').toList(),
    );
    final baseItems = _showAll
        ? _applySearch(
            widget.items.where((i) => i.source == 'ITEM_BASE').toList(),
          )
        : <SellableItem>[];
    final allEmpty = vendorItems.isEmpty && baseItems.isEmpty;

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
              style: TextStyle(fontSize: 14, color: LoginColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search items...',
                hintStyle: TextStyle(
                  fontSize: 13,
                  color: LoginColors.textTertiary,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: LoginColors.textTertiary,
                  size: 20,
                ),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
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
                              _hasVendorItems
                                  ? 'No items found'
                                  : 'No vendor-specific items found',
                              style: TextStyle(color: LoginColors.textTertiary),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed: _openCreateVendorItemFlow,
                                icon: const Icon(Icons.add_circle_outline),
                                label: const Text('Create Vendor Item'),
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
                        // Vendor-specific items
                        ...vendorItems.map(_buildItemTile),
                        // "Show All Items" button
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
                        // Base items section
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
                  'Add',
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
    const qtyFieldEnabled = true;
    final priceFieldEnabled = widget.canEditPrice;

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
                      color: qtyFieldEnabled
                          ? LoginColors.textPrimary
                          : LoginColors.textTertiary,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '@ ${item.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: LoginColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (widget.canEditPrice) ...[
            SizedBox(
              width: 90,
              child: TextField(
                controller: priceController,
                enabled: priceFieldEnabled,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: TextStyle(
                  fontSize: 12.5,
                  color: priceFieldEnabled
                      ? LoginColors.textPrimary
                      : LoginColors.textTertiary,
                ),
                decoration: InputDecoration(
                  labelText: 'Price',
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 9,
                  ),
                  filled: true,
                  fillColor: priceFieldEnabled
                      ? LoginColors.fieldFill
                      : LoginColors.fieldFill.withValues(alpha: 0.4),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: LoginColors.borderLight),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          SizedBox(
            width: 70,
            child: TextField(
              controller: qtyController,
              enabled: qtyFieldEnabled,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: TextStyle(
                fontSize: 12.5,
                color: qtyFieldEnabled
                    ? LoginColors.textPrimary
                    : LoginColors.textTertiary,
              ),
              decoration: InputDecoration(
                labelText: 'Qty',
                hintText: '0',
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 9,
                ),
                filled: true,
                fillColor: qtyFieldEnabled
                    ? LoginColors.fieldFill
                    : LoginColors.fieldFill.withValues(alpha: 0.4),
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
