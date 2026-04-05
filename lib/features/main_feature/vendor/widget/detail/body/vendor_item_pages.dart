import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/core/widgets/app_drawer.dart';
import 'package:coreflow/core/widgets/custom_button.dart';
import 'package:coreflow/core/widgets/custom_textfield.dart';
import 'package:coreflow/domain/model/main_model/customer/customer_mapped_item.dart';
import 'package:coreflow/domain/model/main_model/items/item.dart';
import 'package:coreflow/features/main_feature/dashboard/dashboard_view_model/dashboard_view_model.dart';
import 'package:coreflow/features/main_feature/vendor/view_model/vendor_detail_view_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SelectVendorCompanyItemPage extends StatefulWidget {
  final VendorDetailViewModel viewModel;

  const SelectVendorCompanyItemPage({super.key, required this.viewModel});

  @override
  State<SelectVendorCompanyItemPage> createState() =>
      _SelectVendorCompanyItemPageState();
}

class _SelectVendorCompanyItemPageState
    extends State<SelectVendorCompanyItemPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late Future<List<Item>> _itemsFuture;
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '',
    decimalDigits: 2,
  );

  @override
  void initState() {
    super.initState();
    _itemsFuture = _loadItems();
  }

  Future<List<Item>> _loadItems() async {
    final items = await widget.viewModel.getActiveCompanyItems();
    final mappedIds = widget.viewModel.mappedItems
        .map((item) => item.itemId)
        .toSet();
    return items.where((item) => !mappedIds.contains(item.itemId)).toList();
  }

  @override
  Widget build(BuildContext context) {
    LoginColors.setBrightness(Theme.of(context).brightness);
    final textSecondary = LoginColors.textSecondary;
    final dashboardVm = context.watch<DashboardViewModel>();

    return Scaffold(
      key: _scaffoldKey,
      drawerEnableOpenDragGesture: false,
      drawer: AppDrawer(vm: dashboardVm),
      backgroundColor: LoginColors.background,
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        surfaceTintColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text('Company Items'),
        leading: IconButton(
          tooltip: 'Menu',
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.menu_rounded, size: 22),
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                DashboardColors.headerGradientStart,
                DashboardColors.headerGradientEnd,
              ],
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<Item>>(
        future: _itemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Failed to load items. Pull to retry.',
                  style: TextStyle(color: textSecondary),
                ),
              ),
            );
          }

          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No active company items available.',
                  style: TextStyle(color: textSecondary),
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              final refreshed = _loadItems();
              setState(() => _itemsFuture = refreshed);
              await refreshed;
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: LoginColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: LoginColors.border),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 18,
                        color: LoginColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Available Items: ${items.length}',
                          style: TextStyle(
                            color: LoginColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                ...List.generate(items.length, (index) {
                  final item = items[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Card(
                      margin: EdgeInsets.zero,
                      elevation: 1.5,
                      color: LoginColors.surface,
                      shadowColor: LoginColors.shadowLight.withValues(alpha:0.15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: LoginColors.borderLight,
                          width: 0.8,
                        ),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        splashColor: LoginColors.primaryLight.withValues(alpha:0.12),
                        highlightColor: LoginColors.primaryLight.withValues(alpha:
                          0.06,
                        ),
                        onTap: () async {
                          final created = await Navigator.of(context)
                              .push<bool>(
                                MaterialPageRoute(
                                  builder: (_) => CreateVendorItemPage(
                                    viewModel: widget.viewModel,
                                    item: item,
                                  ),
                                ),
                              );

                          if (!context.mounted || created != true) return;
                          Navigator.of(context).pop(true);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.itemName,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 15.5,
                                        fontWeight: FontWeight.w600,
                                        color: LoginColors.textPrimary,
                                        letterSpacing: 0.05,
                                        height: 1.25,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      children: [
                                        _buildTag(
                                          '#${item.itemId}',
                                          LoginColors.textTertiary,
                                        ),
                                        _buildTag(
                                          item.unit,
                                          const Color(0xFF0D9488),
                                        ),
                                        _buildTag(
                                          item.itemType,
                                          LoginColors.primaryLight,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    _currencyFormat.format(
                                      item.basePurchasePrice ??
                                          item.baseSalesPrice,
                                    ),
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      color: LoginColors.primary,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Icon(
                                    Icons.edit_outlined,
                                    size: 14,

                                    color: LoginColors.textTertiary,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}

class CreateVendorItemPage extends StatefulWidget {
  final VendorDetailViewModel viewModel;
  final Item item;

  const CreateVendorItemPage({
    super.key,
    required this.viewModel,
    required this.item,
  });

  @override
  State<CreateVendorItemPage> createState() => _CreateVendorItemPageState();
}

class _CreateVendorItemPageState extends State<CreateVendorItemPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final TextEditingController _priceController;
  final TextEditingController _descriptionController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(
      text: (widget.item.basePurchasePrice ?? widget.item.baseSalesPrice)
          .toStringAsFixed(2),
    );
    _descriptionController.text = widget.item.purchaseDescription ?? '';
  }

  @override
  void dispose() {
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String? _priceValidator(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'Please enter purchase price';
    final parsed = double.tryParse(v);
    if (parsed == null) return 'Invalid input. Use numbers only (e.g. 120.50)';
    if (parsed <= 0) return 'Purchase price must be greater than 0';
    return null;
  }

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    final price = double.tryParse(_priceController.text.trim());
    if (price == null || price <= 0) return;

    setState(() => _isSubmitting = true);
    final created = await widget.viewModel.createVendorItem(
      itemId: widget.item.itemId,
      purchasePrice: price,
      purchaseDescription: _descriptionController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (created) {
      Navigator.of(context).pop(true);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(seconds: 2),
        content: Text(
          widget.viewModel.errorMessage ?? 'Failed to create vendor item',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dashboardVm = context.watch<DashboardViewModel>();
    final colorScheme = Theme.of(context).colorScheme;
    final textPrimary = colorScheme.onSurface;
    final textSecondary = colorScheme.onSurface.withValues(alpha:0.72);
    final border = colorScheme.outlineVariant.withValues(alpha:0.7);

    return Scaffold(
      key: _scaffoldKey,
      drawerEnableOpenDragGesture: false,
      drawer: AppDrawer(vm: dashboardVm),
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        surfaceTintColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text('Create Vendor Item'),
        leading: IconButton(
          tooltip: 'Menu',
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha:0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.menu_rounded, size: 22),
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                DashboardColors.headerGradientStart,
                DashboardColors.headerGradientEnd,
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Item Details',
                style: TextStyle(
                  color: textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item.itemName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Item ID: ${widget.item.itemId} • ${widget.item.itemType} • ${widget.item.unit}',
                      style: TextStyle(color: textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Vendor Price Setup',
                style: TextStyle(
                  color: textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _priceController,
                labelText: 'Purchase Price',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                prefixIcon: Icons.sell_outlined,
                prefixText: ' ',
                helperText: 'Enter vendor-specific price',
                validator: _priceValidator,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _descriptionController,
                labelText: 'Purchase Description',
                prefixIcon: Icons.notes_rounded,
                hintText: 'Description: ',
                alignLabelWithHint: true,
                minLines: 3,
                maxLines: 5,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  onPressed: _isSubmitting ? null : _submit,
                  isLoading: _isSubmitting,
                  icon: Icons.check_rounded,
                  text: _isSubmitting ? 'Creating...' : 'Create Vendor Item',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UpdateVendorItemPage extends StatefulWidget {
  final VendorDetailViewModel viewModel;
  final CustomerMappedItem item;

  const UpdateVendorItemPage({
    super.key,
    required this.viewModel,
    required this.item,
  });

  @override
  State<UpdateVendorItemPage> createState() => _UpdateVendorItemPageState();
}

class _UpdateVendorItemPageState extends State<UpdateVendorItemPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final TextEditingController _priceController;
  late final TextEditingController _descriptionController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(
      text: widget.item.salesPrice.toStringAsFixed(2),
    );
    _descriptionController = TextEditingController(
      text: widget.item.salesDescription ?? '',
    );
  }

  @override
  void dispose() {
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String? _priceValidator(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'Please enter purchase price';
    final parsed = double.tryParse(v);
    if (parsed == null) return 'Invalid input. Use numbers only (e.g. 120.50)';
    if (parsed <= 0) return 'Purchase price must be greater than 0';
    return null;
  }

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    final price = double.tryParse(_priceController.text.trim());
    if (price == null || price <= 0) return;

    setState(() => _isSubmitting = true);
    final updated = await widget.viewModel.updateVendorItem(
      itemId: widget.item.itemId,
      purchasePrice: price,
      purchaseDescription: _descriptionController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (updated) {
      Navigator.of(context).pop(true);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(seconds: 2),
        content: Text(
          widget.viewModel.errorMessage ?? 'Failed to update vendor item',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dashboardVm = context.watch<DashboardViewModel>();
    final colorScheme = Theme.of(context).colorScheme;
    final textPrimary = colorScheme.onSurface;
    final textSecondary = colorScheme.onSurface.withValues(alpha: 0.72);
    final border = colorScheme.outlineVariant.withValues(alpha: 0.7);

    return Scaffold(
      key: _scaffoldKey,
      drawerEnableOpenDragGesture: false,
      drawer: AppDrawer(vm: dashboardVm),
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        surfaceTintColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text('Update Vendor Item'),
        leading: IconButton(
          tooltip: 'Menu',
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha:0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.menu_rounded, size: 22),
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                DashboardColors.headerGradientStart,
                DashboardColors.headerGradientEnd,
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Item Details',
                style: TextStyle(
                  color: textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item.itemName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Item ID: ${widget.item.itemId} • ${widget.item.itemType} • ${widget.item.unit}',
                      style: TextStyle(color: textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Vendor Price Setup',
                style: TextStyle(
                  color: textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _priceController,
                labelText: 'Purchase Price',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                prefixIcon: Icons.sell_outlined,
                prefixText: ' ',
                helperText: 'Update vendor-specific price',
                validator: _priceValidator,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _descriptionController,
                labelText: 'Purchase Description',
                alignLabelWithHint: true,
                prefixIcon: Icons.notes_rounded,
                hintText: 'Description: ',
                minLines: 3,
                maxLines: 5,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  onPressed: _isSubmitting ? null : _submit,
                  isLoading: _isSubmitting,
                  icon: Icons.save_rounded,
                  text: _isSubmitting ? 'Updating...' : 'Update Vendor Item',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
