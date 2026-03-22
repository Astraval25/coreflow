import 'package:coreflow/core/utils/order_share_helper.dart';
import 'package:coreflow/core/widgets/skeleton.dart';
import 'package:coreflow/data/repositories/auth_repository.dart';
import 'package:coreflow/domain/model/customer/customer.dart';
import 'package:coreflow/domain/model/sales/sales_order_detail.dart'
    as sales_detail;
import 'package:coreflow/domain/model/sales/sales_order_item.dart'
    as sales_item;
import 'package:coreflow/features/presentation/payment/receive_payment/view/create_receive_payment_page.dart';
import 'package:coreflow/features/presentation/sales/viewmodel/sales_order_detail_view_model.dart';
import 'package:coreflow/features/presentation/sales/view/update_sales_order_page.dart';
import 'package:coreflow/features/items/view/item_detail_view.dart';
import 'package:coreflow/core/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SalesOrderDetailPage extends StatelessWidget {
  final int companyId;
  final int orderId;

  const SalesOrderDetailPage({
    super.key,
    required this.companyId,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SalesOrderDetailViewModel>(
      create: (_) => SalesOrderDetailViewModel(
        repository: AuthRepository(),
        companyId: companyId,
        orderId: orderId,
      ),
      child: const _SalesOrderDetailView(),
    );
  }
}

class _SalesOrderDetailView extends StatelessWidget {
  const _SalesOrderDetailView();

  @override
  Widget build(BuildContext context) {
    LoginColors.setBrightness(Theme.of(context).brightness);

    return Consumer<SalesOrderDetailViewModel>(
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
            title: _OrderAppBarTitle(order: vm.order),
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
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Fully paid orders cannot be edited'),
                        behavior: SnackBarBehavior.floating,
                      ));
                      return;
                    }
                    final updated = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => UpdateSalesOrderPage(
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
          body: RefreshIndicator(onRefresh: vm.refresh, child: _buildBody(vm)),
        );
      },
    );
  }

  Widget _buildBody(SalesOrderDetailViewModel vm) {
    if (vm.isLoading) {
      return const _SalesOrderDetailLoadingSkeleton();
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

    if (vm.isNoData || vm.order == null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: const [
          SizedBox(height: 120),
          _StateMessage(
            icon: Icons.receipt_long_outlined,
            title: 'No order detail found',
            subtitle: 'This order may not exist or is not accessible.',
          ),
        ],
      );
    }

    final sales_detail.SalesOrderDetail order = vm.order!;
    final items = vm.items;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 20),
      children: [
        _CustomerDetailsCard(order: order),
        const SizedBox(height: 10),
        _ItemDetailsCard(items: items, companyId: vm.companyId),
        const SizedBox(height: 10),
        _PaymentSummaryCard(order: order),
        const SizedBox(height: 14),
        _BottomActionsBar(order: order, vm: vm),
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
      color: DashboardColors.textWhite.withOpacity(0.18),
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
  final sales_detail.SalesOrderDetail? order;

  const _OrderAppBarTitle({required this.order});

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

    final orderLabel = _orderLabel(order!);
    final overdueDays = _overdueDays(order!.orderDate);
    final overdueText = overdueDays > 0
        ? 'Overdue by $overdueDays day${overdueDays == 1 ? '' : 's'}'
        : 'Overdue by 0 days';

    return Column(
      // mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Order $orderLabel',
          style: TextStyle(
            color: DashboardColors.textWhite,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        // const SizedBox(height: 2),
        Text(
          overdueText,
          style: TextStyle(
            color: DashboardColors.textWhite.withOpacity(0.85),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _CustomerDetailsCard extends StatelessWidget {
  final sales_detail.SalesOrderDetail order;

  const _CustomerDetailsCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final customer = _displayCustomer(order);
    final customerCompany = _displayCustomerCompany(order);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        _CardBlock(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Customer Details',
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
                        _MetaText(label: 'Customer Name', value: customer),
                        const SizedBox(height: 8),
                        _MetaText(
                          label: 'Order Date',
                          value: _formatDate(order.orderDate),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MetaText(
                      label: 'Customer Company',
                      value: customerCompany,
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

class _ItemDetailsCard extends StatelessWidget {
  final List<sales_item.SalesOrderItem> items;
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
  final sales_item.SalesOrderItem item;
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

    return InkWell(
      onTap: item.itemId > 0
          ? () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      ItemDetailView(companyId: companyId, itemId: item.itemId),
                ),
              );
            }
          : null,
      child: Padding(
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
                    value: _money(item.unitPrice),
                    textAlignEnd: true,
                  ),
                ),
                Expanded(
                  child: _ItemValue(
                    label: 'Amount',
                    value: _money(item.itemTotal),
                    textAlignEnd: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentSummaryCard extends StatelessWidget {
  final sales_detail.SalesOrderDetail order;

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
              _paymentRow(context, 'Sub Total', _money(order.orderAmount)),
              _paymentRow(context, 'Tax Amount', _money(order.taxAmount)),
              _paymentRow(context, 'Discount', _money(order.discountAmount)),
              _paymentRow(
                context,
                'Delivery Charge',
                _money(order.deliveryCharge),
              ),
              _paymentRow(
                context,
                'Total',
                _money(order.totalAmount),
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
                _money(order.paidAmount),
                valueColor: LoginColors.success,
                valueSize: 14,
              ),
              _paymentRow(
                context,
                'Balance',
                _money(pending),
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

OrderShareData _salesOrderToShareData(sales_detail.SalesOrderDetail order) {
  final customer = order.customerDisplayName.trim().isNotEmpty
      ? order.customerDisplayName
      : order.customerName.trim().isNotEmpty
      ? order.customerName
      : 'Customer';

  return OrderShareData(
    orderNumber: order.orderNumber,
    orderId: order.orderId,
    orderDate: order.orderDate,
    partyName: customer,
    partyLabel: 'Customer',
    sellerCompanyName: order.sellerCompanyName,
    buyerCompanyName: order.buyerCompanyName,
    items: order.orderItems
        .map(
          (i) => OrderShareItemData(
            itemName: i.itemName,
            quantity: i.quantity,
            unitPrice: i.unitPrice,
            itemTotal: i.itemTotal,
          ),
        )
        .toList(),
    orderAmount: order.orderAmount,
    taxAmount: order.taxAmount,
    discountAmount: order.discountAmount,
    deliveryCharge: order.deliveryCharge,
    totalAmount: order.totalAmount,
    paidAmount: order.paidAmount,
    orderStatus: order.orderStatus,
  );
}

class _BottomActionsBar extends StatefulWidget {
  final sales_detail.SalesOrderDetail order;
  final SalesOrderDetailViewModel vm;

  const _BottomActionsBar({required this.order, required this.vm});

  @override
  State<_BottomActionsBar> createState() => _BottomActionsBarState();
}

class _BottomActionsBarState extends State<_BottomActionsBar> {
  bool _shareExpanded = false;
  bool _sharing = false;

  OrderShareData get _data => _salesOrderToShareData(widget.order);

  Future<void> _shareText() async {
    if (_sharing) return;
    setState(() {
      _sharing = true;
      _shareExpanded = false;
    });
    await OrderShareHelper.shareText(_data);
    if (mounted) setState(() => _sharing = false);
  }

  Future<void> _sharePdf() async {
    if (_sharing) return;
    setState(() {
      _sharing = true;
      _shareExpanded = false;
    });
    await OrderShareHelper.shareAsPdf(_data);
    if (mounted) setState(() => _sharing = false);
  }

  ({String label, IconData icon, String action, Color color})? get _statusInfo {
    switch (widget.order.orderStatus) {
      case 'ORDER':
        return (
          label: 'Mark as Viewed',
          icon: Icons.visibility_rounded,
          action: 'viewed',
          color: Colors.blue.shade600,
        );
      case 'ORDER_VIEWED':
        return (
          label: 'Mark as Invoiced',
          icon: Icons.receipt_long_outlined,
          action: 'invoiced',
          color: Colors.orange.shade700,
        );
      case 'ORDER_INVOICED':
        return (
          label: 'Record Payment',
          icon: Icons.payments_rounded,
          action: 'record-payment',
          color: LoginColors.primary,
        );
      default:
        // Non-standard status → offer "Set as Sales Order"
        if (widget.order.orderStatus.isNotEmpty &&
            !const ['ORDER_PAYED'].contains(widget.order.orderStatus)) {
          return (
            label: 'Set as Sales Order',
            icon: Icons.assignment_turned_in_rounded,
            action: 'sales-order',
            color: Colors.indigo.shade600,
          );
        }
        return null;
    }
  }

  ({String label, IconData icon, String action, Color color})?
  get _revertStatusInfo {
    switch (widget.order.orderStatus) {
      case 'ORDER_INVOICED':
        return (
          label: 'Mark as Ordered',
          icon: Icons.undo_rounded,
          action: 'viewed',
          color: Colors.grey.shade600,
        );
      default:
        return null;
    }
  }

  Future<void> _doStatusAction(String action) async {
    if (action == 'record-payment') {
      await _navigateToReceivePayment();
      return;
    }
    final success = await widget.vm.updateStatus(action);
    if (!success && mounted && widget.vm.statusError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.vm.statusError!),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _navigateToReceivePayment() async {
    final order = widget.order;
    final displayName = order.customerDisplayName.trim().isNotEmpty
        ? order.customerDisplayName
        : order.customerName.trim().isNotEmpty
            ? order.customerName
            : 'Customer';
    final companyName = order.buyerCompanyName.trim().isNotEmpty
        ? order.buyerCompanyName
        : order.sellerCompanyName;
    final companyId =
        order.buyerCompanyId > 0 ? order.buyerCompanyId : null;
    final pending =
        order.pendingAmount < 0 ? 0.0 : order.pendingAmount;

    final customer = Customer(
      customerId: order.customerId,
      displayName: displayName,
      customerCompanyName: companyName,
      customerCompanyId: companyId,
      dueAmount: pending.toStringAsFixed(2),
      isActive: true,
    );

    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CreateReceivePaymentPage(
          companyId: widget.vm.companyId,
          initialCustomer: customer,
          initialOrderId: order.orderId,
          initialAmount: pending > 0 ? pending : null,
        ),
      ),
    );

    if (mounted) {
      widget.vm.refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final info = _statusInfo;
    final revertInfo = _revertStatusInfo;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Share options dropdown
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: _shareExpanded
              ? Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: LoginColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: LoginColors.borderLight),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _ActionTile(
                        icon: Icons.text_fields_rounded,
                        label: 'Share as Text',
                        color: LoginColors.primary,
                        onTap: _shareText,
                      ),
                      Divider(height: 1, color: LoginColors.borderLight),
                      _ActionTile(
                        icon: Icons.picture_as_pdf_rounded,
                        label: _data.isBillStatus
                            ? 'Share Bill PDF'
                            : 'Share Order PDF',
                        color: LoginColors.primary,
                        onTap: _sharePdf,
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),

        // Status error
        if (widget.vm.statusError != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              widget.vm.statusError!,
              style: TextStyle(
                color: LoginColors.error,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

        // Action buttons row
        Row(
          children: [
            // Share button
            Expanded(
              child: SizedBox(
                height: 44,
                child: OutlinedButton.icon(
                  onPressed: _sharing
                      ? null
                      : () => setState(
                          () => _shareExpanded = !_shareExpanded),
                  icon: _sharing
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: LoginColors.primary,
                          ),
                        )
                      : Icon(
                          _shareExpanded
                              ? Icons.close_rounded
                              : Icons.share_rounded,
                          size: 18,
                        ),
                  label: Text(
                    _shareExpanded ? 'Close' : 'Share',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: LoginColors.primary,
                    side: BorderSide(
                      color: LoginColors.primary.withValues(alpha: 0.4),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),

            // Status action button
            if (info != null) ...[
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 44,
                  child: FilledButton.icon(
                    onPressed: widget.vm.isStatusUpdating
                        ? null
                        : () => _doStatusAction(info.action),
                    icon: widget.vm.isStatusUpdating
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Icon(info.icon, size: 18),
                    label: Text(
                      info.label,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: info.color,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),

        // Revert status button
        if (revertInfo != null) ...[
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: OutlinedButton.icon(
              onPressed: widget.vm.isStatusUpdating
                  ? null
                  : () => _doStatusAction(revertInfo.action),
              icon: widget.vm.isStatusUpdating
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(revertInfo.icon, size: 16),
              label: Text(
                revertInfo.label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: revertInfo.color,
                side: BorderSide(
                  color: revertInfo.color.withValues(alpha: 0.4),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: LoginColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SalesOrderDetailLoadingSkeleton extends StatelessWidget {
  const _SalesOrderDetailLoadingSkeleton();

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

String _money(double value) => ' ₹${value.toStringAsFixed(2)}';

String _trimNumber(double value) {
  final rounded = value.roundToDouble();
  if ((value - rounded).abs() < 0.000001) {
    return rounded.toInt().toString();
  }
  return value.toStringAsFixed(2);
}

String _displayCustomer(sales_detail.SalesOrderDetail order) {
  if (order.customerDisplayName.trim().isNotEmpty) {
    return order.customerDisplayName;
  }
  if (order.customerName.trim().isNotEmpty) {
    return order.customerName;
  }
  return 'Customer';
}

String _displayCustomerCompany(sales_detail.SalesOrderDetail order) {
  if (order.buyerCompanyName.trim().isNotEmpty) {
    return order.buyerCompanyName;
  }
  if (order.sellerCompanyName.trim().isNotEmpty) {
    return order.sellerCompanyName;
  }
  return 'Company';
}

String _orderLabel(sales_detail.SalesOrderDetail order) {
  return order.orderNumber.trim().isNotEmpty
      ? order.orderNumber
      : order.orderId.toString();
}

int _overdueDays(DateTime orderDate) {
  final now = DateTime.now();
  final diff = now.difference(orderDate).inDays;
  return diff < 0 ? 0 : diff;
}

String _formatDate(DateTime date) {
  const months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final month = months[(date.month - 1).clamp(0, 12)];
  return '$month ${date.day}, ${date.year}';
}
