import 'package:coreflow/core/widgets/skeleton.dart';
import 'package:coreflow/core/utils/common_formatters.dart';
import 'package:coreflow/data/repositories/auth_repository.dart';
import 'package:coreflow/domain/model/main_model/company_ref/order_ref.dart';
import 'package:coreflow/domain/model/main_model/company_ref/payment_ref.dart';
import 'package:coreflow/domain/model/main_model/purchase/purchase_order_detail.dart';
import 'package:coreflow/domain/model/main_model/purchase/purchase_order_item.dart';
import 'package:coreflow/features/main_feature/payment/send_payment/view/send_payment_detail_page.dart';
import 'package:coreflow/features/main_feature/purchase/viewmodel/purchase_order_detail_view_model.dart';
import 'package:coreflow/features/main_feature/purchase/widgets/purchase_expand_more_option.dart';
import 'package:coreflow/features/main_feature/purchase/view/update_purchase_order_page.dart';
import 'package:coreflow/core/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PurchaseOrderDetailPage extends StatelessWidget {
  final int companyId;
  final int orderId;

  const PurchaseOrderDetailPage({
    super.key,
    required this.companyId,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PurchaseOrderDetailViewModel>(
      create: (_) => PurchaseOrderDetailViewModel(
        repository: AuthRepository(),
        companyId: companyId,
        orderId: orderId,
      ),
      child: const _PurchaseOrderDetailView(),
    );
  }
}

class _PurchaseOrderDetailView extends StatelessWidget {
  const _PurchaseOrderDetailView();

  @override
  Widget build(BuildContext context) {
    LoginColors.setBrightness(Theme.of(context).brightness);

    return Consumer<PurchaseOrderDetailViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          backgroundColor: LoginColors.background,
          appBar: AppBar(
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            backgroundColor: Colors.transparent,
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
            title: _OrderAppBarTitle(
              order: vm.orderDetail,
              orderRef: vm.orderRef,
            ),
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: _RoundActionIcon(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: () => Navigator.of(context).maybePop(),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: _RoundActionIcon(
                  icon: (vm.orderDetail != null && vm.orderDetail!.isPaid)
                      ? Icons.lock_outline_rounded
                      : Icons.edit_rounded,
                  onTap: () async {
                    if (vm.orderDetail == null) return;
                    if (vm.orderDetail!.isPaid) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          duration: Duration(seconds: 2),
                          content: Text('Fully paid orders cannot be edited'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return;
                    }
                    final updated = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => UpdatePurchaseOrderPage(
                          companyId: vm.companyId,
                          initialOrder: vm.orderDetail!,
                        ),
                      ),
                    );
                    if (updated == true) vm.refresh();
                  },
                ),
              ),
            ],
          ),
          body: Stack(
            children: [
              RefreshIndicator(onRefresh: vm.refresh, child: _buildBody(vm)),
              if (!vm.isLoading &&
                  !vm.hasError &&
                  !vm.isNoData &&
                  vm.orderDetail != null)
                PurchaseBottomOptionsPanel(order: vm.orderDetail!, vm: vm),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(PurchaseOrderDetailViewModel vm) {
    if (vm.isLoading) {
      return const _PurchaseOrderDetailLoadingSkeleton();
    }

    if (vm.hasError) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          const SizedBox(height: 120),
          _StateMessage(
            icon: Icons.error_outline_rounded,
            title: 'Failed to load order detail',
            subtitle: vm.errorMessage ?? 'Please try again.',
          ),
        ],
      );
    }

    if (vm.isNoData || vm.orderDetail == null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: const [
          SizedBox(height: 120),
          _StateMessage(
            icon: Icons.receipt_long_outlined,
            title: 'No order detail found',
            subtitle: 'This purchase order may not exist or is not accessible.',
          ),
        ],
      );
    }

    final PurchaseOrderDetail order = vm.orderDetail!;
    final items = order.orderItems;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 20),
      children: [
        _CustomerDetailsCard(order: order),
        const SizedBox(height: 10),
        _ItemDetailsCard(items: items, companyId: vm.companyId),
        const SizedBox(height: 10),
        _PaymentSummaryCard(order: order),
        const SizedBox(height: 10),
        _OrderPaymentLinksSection(
          companyId: vm.companyId,
          payments: vm.orderPayments,
          isLoading: vm.isOrderPaymentsLoading,
        ),
        const SizedBox(height: 100),
      ],
    );
  }
}

class _RoundActionIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RoundActionIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: DashboardColors.textWhite.withValues(alpha: 0.18),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(icon, size: 18, color: DashboardColors.textWhite),
        ),
      ),
    );
  }
}

class _CardBlock extends StatelessWidget {
  final Widget child;

  const _CardBlock({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: LoginColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: LoginColors.borderLight),
      ),
      child: child,
    );
  }
}

class _OrderAppBarTitle extends StatelessWidget {
  final PurchaseOrderDetail? order;
  final OrderRef? orderRef;

  const _OrderAppBarTitle({required this.order, this.orderRef});

  @override
  Widget build(BuildContext context) {
    if (order == null) {
      return Text(
        'Order Detail',
        style: TextStyle(
          color: DashboardColors.textWhite,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    final localNumber = orderRef?.localOrderNumber ?? '';
    final overdueDaysCount = overdueDays(order!.orderDate);
    final overdueText = overdueDaysCount > 0
        ? 'Overdue by $overdueDaysCount day${overdueDaysCount == 1 ? '' : 's'}'
        : 'Overdue by 0 days';

    return Column(
      children: [
        Text(
          localNumber.isNotEmpty ? localNumber : 'Order Detail',
          style: TextStyle(
            color: DashboardColors.textWhite,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          overdueText,
          style: TextStyle(
            color: DashboardColors.textWhite.withValues(alpha: 0.85),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _CustomerDetailsCard extends StatelessWidget {
  final PurchaseOrderDetail order;

  const _CustomerDetailsCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final vendor = _displayVendor(order);
    final sellerCompany = _displaySellerCompany(order);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        _CardBlock(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Vendor Details',
                style: TextStyle(
                  color: LoginColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _MetaText(label: 'Vendor Name', value: vendor),
                        const SizedBox(height: 8),
                        _MetaText(
                          label: 'Order Date',
                          value: formatDate(order.orderDate),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MetaText(
                      label: 'Seller Company',
                      value: sellerCompany,
                      textAlignEnd: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (order.hasBill)
          Positioned(
            right: -20,
            top: 6,
            child: Transform.rotate(
              angle: 0.6,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.grey, Colors.grey],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: LoginColors.shadowLight,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.receipt_long_rounded,
                      size: 12,
                      color: DashboardColors.textWhite,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Order Billed',
                      style: TextStyle(
                        color: DashboardColors.textWhite,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _MetaText extends StatelessWidget {
  final String label;
  final String value;
  final bool textAlignEnd;

  const _MetaText({
    required this.label,
    required this.value,
    this.textAlignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: textAlignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          '$label:',
          style: TextStyle(
            color: LoginColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          textAlign: textAlignEnd ? TextAlign.end : TextAlign.start,
          style: TextStyle(
            color: LoginColors.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _CompanyRefCard extends StatefulWidget {
  final OrderRef? orderRef;
  final PurchaseOrderDetailViewModel vm;

  const _CompanyRefCard({required this.orderRef, required this.vm});

  @override
  State<_CompanyRefCard> createState() => _CompanyRefCardState();
}

class _CompanyRefCardState extends State<_CompanyRefCard> {
  bool _editing = false;
  late TextEditingController _remarksCtrl;
  late TextEditingController _statusCtrl;
  late TextEditingController _tagsCtrl;
  late TextEditingController _customRefCtrl;

  @override
  void initState() {
    super.initState();
    _remarksCtrl = TextEditingController(
      text: widget.orderRef?.internalRemarks ?? '',
    );
    _statusCtrl = TextEditingController(
      text: widget.orderRef?.internalStatus ?? '',
    );
    _tagsCtrl = TextEditingController(
      text: widget.orderRef?.internalTags ?? '',
    );
    _customRefCtrl = TextEditingController(
      text: widget.orderRef?.customReference ?? '',
    );
  }

  @override
  void didUpdateWidget(covariant _CompanyRefCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_editing && oldWidget.orderRef != widget.orderRef) {
      _remarksCtrl.text = widget.orderRef?.internalRemarks ?? '';
      _statusCtrl.text = widget.orderRef?.internalStatus ?? '';
      _tagsCtrl.text = widget.orderRef?.internalTags ?? '';
      _customRefCtrl.text = widget.orderRef?.customReference ?? '';
    }
  }

  @override
  void dispose() {
    _remarksCtrl.dispose();
    _statusCtrl.dispose();
    _tagsCtrl.dispose();
    _customRefCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final body = <String, dynamic>{};
    final remarks = _remarksCtrl.text.trim();
    final status = _statusCtrl.text.trim();
    final tags = _tagsCtrl.text.trim();
    final customRef = _customRefCtrl.text.trim();

    if (remarks.isNotEmpty) body['internalRemarks'] = remarks;
    if (status.isNotEmpty) body['internalStatus'] = status;
    if (tags.isNotEmpty) body['internalTags'] = tags;
    if (customRef.isNotEmpty) body['customReference'] = customRef;

    final success = await widget.vm.updateOrderRef(body);
    if (mounted) {
      setState(() => _editing = false);
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            duration: Duration(seconds: 2),
            content: Text('Failed to update reference'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ref = widget.orderRef;
    final localNumber = ref?.localOrderNumber ?? '';

    return _CardBlock(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Company Reference',
                  style: TextStyle(
                    color: LoginColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (!_editing)
                InkWell(
                  onTap: () => setState(() => _editing = true),
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.edit_rounded,
                      size: 16,
                      color: LoginColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          if (localNumber.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.numbers_rounded,
                  size: 12,
                  color: LoginColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  localNumber,
                  style: TextStyle(
                    color: LoginColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
          if (_editing) ...[
            const SizedBox(height: 10),
            _RefTextField(controller: _remarksCtrl, label: 'Internal Remarks'),
            const SizedBox(height: 8),
            _RefTextField(controller: _statusCtrl, label: 'Internal Status'),
            const SizedBox(height: 8),
            _RefTextField(
              controller: _tagsCtrl,
              label: 'Tags (comma-separated)',
            ),
            const SizedBox(height: 8),
            _RefTextField(
              controller: _customRefCtrl,
              label: 'Custom Reference',
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() => _editing = false);
                    _remarksCtrl.text = widget.orderRef?.internalRemarks ?? '';
                    _statusCtrl.text = widget.orderRef?.internalStatus ?? '';
                    _tagsCtrl.text = widget.orderRef?.internalTags ?? '';
                    _customRefCtrl.text =
                        widget.orderRef?.customReference ?? '';
                  },
                  child: const Text('Cancel', style: TextStyle(fontSize: 12)),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: widget.vm.isRefUpdating ? null : _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: LoginColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: widget.vm.isRefUpdating
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Save',
                          style: TextStyle(fontSize: 12, color: Colors.white),
                        ),
                ),
              ],
            ),
          ] else ...[
            if (_hasRefData(ref)) ...[
              const SizedBox(height: 8),
              if (ref!.internalRemarks != null &&
                  ref.internalRemarks!.isNotEmpty)
                _RefDisplayRow(label: 'Remarks', value: ref.internalRemarks!),
              if (ref.internalStatus != null && ref.internalStatus!.isNotEmpty)
                _RefDisplayRow(label: 'Status', value: ref.internalStatus!),
              if (ref.internalTags != null && ref.internalTags!.isNotEmpty)
                _RefDisplayRow(label: 'Tags', value: ref.internalTags!),
              if (ref.customReference != null &&
                  ref.customReference!.isNotEmpty)
                _RefDisplayRow(
                  label: 'Custom Ref',
                  value: ref.customReference!,
                ),
            ],
          ],
        ],
      ),
    );
  }

  bool _hasRefData(OrderRef? ref) {
    if (ref == null) return false;
    return (ref.internalRemarks?.isNotEmpty == true) ||
        (ref.internalStatus?.isNotEmpty == true) ||
        (ref.internalTags?.isNotEmpty == true) ||
        (ref.customReference?.isNotEmpty == true);
  }
}

class _RefTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  const _RefTextField({required this.controller, required this.label});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: TextStyle(fontSize: 12, color: LoginColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 11, color: LoginColors.textSecondary),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: LoginColors.borderLight),
        ),
      ),
    );
  }
}

class _RefDisplayRow extends StatelessWidget {
  final String label;
  final String value;

  const _RefDisplayRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                color: LoginColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: LoginColors.textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemDetailsCard extends StatelessWidget {
  final List<PurchaseOrderItem> items;
  final int companyId;

  const _ItemDetailsCard({required this.items, required this.companyId});

  @override
  Widget build(BuildContext context) {
    return _CardBlock(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 16,
                color: LoginColors.textPrimary,
              ),
              SizedBox(width: 6),
              Text(
                'Item Details',
                style: TextStyle(
                  color: LoginColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (items.isEmpty)
            Text(
              'No items available.',
              style: TextStyle(
                color: LoginColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            )
          else
            for (int i = 0; i < items.length; i++) ...[
              _ItemDetailRow(item: items[i], index: i, companyId: companyId),
              if (i != items.length - 1)
                Divider(height: 14, color: LoginColors.borderLight),
            ],
        ],
      ),
    );
  }
}

class _ItemDetailRow extends StatelessWidget {
  final PurchaseOrderItem item;
  final int index;
  final int companyId;

  const _ItemDetailRow({
    required this.item,
    required this.index,
    required this.companyId,
  });

  @override
  Widget build(BuildContext context) {
    final itemName = item.itemName.trim().isNotEmpty
        ? item.itemName
        : 'Item ${index + 1}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            itemName,
            style: TextStyle(
              color: LoginColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (item.itemDescription != null &&
              item.itemDescription!.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(
                item.itemDescription!,
                style: TextStyle(
                  color: LoginColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _ItemValue(
                  label: 'Qty',
                  value: _trimNumber(item.quantity),
                ),
              ),
              Expanded(
                child: _ItemValue(
                  label: 'Rate',
                  value: formatMoney(item.unitPrice),
                  textAlignEnd: true,
                ),
              ),
              Expanded(
                child: _ItemValue(
                  label: 'Amount',
                  value: formatMoney(item.itemTotal),
                  textAlignEnd: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaymentSummaryCard extends StatelessWidget {
  final PurchaseOrderDetail order;

  const _PaymentSummaryCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final pending = order.pendingAmount < 0 ? 0.0 : order.pendingAmount;

    return _CardBlock(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Amount Details',
              style: TextStyle(
                color: LoginColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            columnWidths: const {
              0: FixedColumnWidth(150),
              1: IntrinsicColumnWidth(),
            },
            children: [
              _paymentRow(context, 'Sub Total', formatMoney(order.orderAmount)),
              _paymentRow(context, 'Tax Amount', formatMoney(order.taxAmount)),
              _paymentRow(
                context,
                'Discount',
                formatMoney(order.discountAmount),
              ),
              _paymentRow(
                context,
                'Delivery Charge',
                formatMoney(order.deliveryCharge),
              ),
              _paymentRow(
                context,
                'Total',
                formatMoney(order.totalAmount),
                isEmphasized: true,
                valueColor: LoginColors.textPrimary,
                valueSize: 14,
              ),
            ],
          ),
          Divider(height: 18, color: LoginColors.borderLight),
          Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            columnWidths: const {
              0: FixedColumnWidth(140),
              1: IntrinsicColumnWidth(),
            },
            children: [
              _paymentRow(
                context,
                'Amount Paid',
                formatMoney(order.paidAmount),
                valueColor: LoginColors.success,
                valueSize: 14,
              ),
              _paymentRow(
                context,
                'Balance',
                formatMoney(pending),
                isEmphasized: true,
                valueColor: LoginColors.error,
                valueSize: 14,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ItemValue extends StatelessWidget {
  final String label;
  final String value;
  final bool textAlignEnd;

  const _ItemValue({
    required this.label,
    required this.value,
    this.textAlignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: textAlignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: LoginColors.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          textAlign: textAlignEnd ? TextAlign.end : TextAlign.start,
          style: TextStyle(
            color: LoginColors.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

TableRow _paymentRow(
  BuildContext context,
  String label,
  String value, {
  bool isEmphasized = false,
  Color? valueColor,
  double? valueSize,
}) {
  final valueStyle = TextStyle(
    color: valueColor ?? LoginColors.textPrimary,
    fontSize: valueSize ?? 12,
    fontWeight: isEmphasized ? FontWeight.w700 : FontWeight.w600,
  );

  return TableRow(
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 24, top: 4, bottom: 4),
        child: Align(
          alignment: Alignment.centerRight,
          child: Text(
            label,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: LoginColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Align(
          alignment: Alignment.centerRight,
          child: Text(value, textAlign: TextAlign.right, style: valueStyle),
        ),
      ),
    ],
  );
}

class _PurchaseOrderDetailLoadingSkeleton extends StatelessWidget {
  const _PurchaseOrderDetailLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 20),
      children: const [
        Skeleton(height: 92, width: double.infinity, borderRadius: 12),
        SizedBox(height: 10),
        Skeleton(height: 76, width: double.infinity, borderRadius: 12),
        SizedBox(height: 10),
        Skeleton(height: 180, width: double.infinity, borderRadius: 12),
        SizedBox(height: 10),
        Skeleton(height: 128, width: double.infinity, borderRadius: 12),
        SizedBox(height: 10),
        Skeleton(height: 110, width: double.infinity, borderRadius: 12),
      ],
    );
  }
}

class _OrderPaymentLinksSection extends StatefulWidget {
  final int companyId;
  final List<PaymentRef> payments;
  final bool isLoading;

  const _OrderPaymentLinksSection({
    required this.companyId,
    required this.payments,
    required this.isLoading,
  });

  @override
  State<_OrderPaymentLinksSection> createState() =>
      _OrderPaymentLinksSectionState();
}

class _OrderPaymentLinksSectionState extends State<_OrderPaymentLinksSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return _CardBlock(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet_rounded,
                    size: 16,
                    color: LoginColors.textPrimary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Payments Made',
                      style: TextStyle(
                        color: LoginColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    '${widget.payments.length}',
                    style: TextStyle(
                      color: LoginColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _expanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    color: LoginColors.textSecondary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            const SizedBox(height: 8),
            if (widget.isLoading)
              Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: LoginColors.primary,
                  ),
                ),
              )
            else if (widget.payments.isEmpty)
              Text(
                'No payments linked to this order.',
                style: TextStyle(
                  color: LoginColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              )
            else
              for (int i = 0; i < widget.payments.length; i++) ...[
                _PaymentLinkRow(
                  payment: widget.payments[i],
                  onTap: () {
                    final paymentId = widget.payments[i].paymentId;
                    if (paymentId == null || paymentId <= 0) return;
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => SendPaymentDetailPage(
                          companyId: widget.companyId,
                          paymentId: paymentId,
                        ),
                      ),
                    );
                  },
                ),
                if (i != widget.payments.length - 1)
                  Divider(height: 12, color: LoginColors.borderLight),
              ],
          ],
        ],
      ),
    );
  }
}

class _PaymentLinkRow extends StatelessWidget {
  final PaymentRef payment;
  final VoidCallback onTap;

  const _PaymentLinkRow({required this.payment, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final linkLabel = payment.localPaymentNumber.isNotEmpty
        ? payment.localPaymentNumber
        : 'Payment #${payment.paymentId ?? '-'}';
    final dateText = formatPaymentDate(payment.paymentDate);
    final amountText = payment.amount != null
        ? 'INR ${payment.amount!.toStringAsFixed(2)}'
        : '';
    final meta = [dateText, amountText].where((e) => e.isNotEmpty).join(' | ');
    final canOpen = (payment.paymentId ?? 0) > 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.link_rounded, size: 14, color: LoginColors.primary),
          const SizedBox(width: 6),
          InkWell(
            onTap: canOpen ? onTap : null,
            borderRadius: BorderRadius.circular(6),
            child: Text(
              linkLabel,
              style: TextStyle(
                color: canOpen
                    ? LoginColors.primary
                    : LoginColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                decoration: canOpen
                    ? TextDecoration.underline
                    : TextDecoration.none,
                decorationColor: LoginColors.primary,
              ),
            ),
          ),
          if (meta.isNotEmpty) ...[
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                meta,
                style: TextStyle(
                  color: LoginColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ] else
            const Spacer(),
          if (canOpen)
            Icon(
              Icons.open_in_new_rounded,
              size: 14,
              color: LoginColors.textSecondary,
            ),
        ],
      ),
    );
  }
}

class _StateMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _StateMessage({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 40, color: LoginColors.textSecondary),
        const SizedBox(height: 8),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: LoginColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: LoginColors.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

String _trimNumber(double value) {
  final rounded = value.roundToDouble();
  if ((value - rounded).abs() < 0.000001) {
    return rounded.toInt().toString();
  }
  return value.toStringAsFixed(2);
}

String _displayVendor(PurchaseOrderDetail order) {
  if (order.vendorDisplayName.trim().isNotEmpty) {
    return order.vendorDisplayName;
  }
  if (order.vendorName.trim().isNotEmpty) {
    return order.vendorName;
  }
  if (order.sellerCompanyName.trim().isNotEmpty) {
    return order.sellerCompanyName;
  }
  return 'Vendor';
}

String _displaySellerCompany(PurchaseOrderDetail order) {
  if (order.sellerCompanyName.trim().isNotEmpty) {
    return order.sellerCompanyName;
  }
  // if (order.buyerCompanyName.trim().isNotEmpty) {
  //   return order.buyerCompanyName;
  // }
  return ' ';
}
