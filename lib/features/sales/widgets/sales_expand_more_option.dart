import 'package:coreflow/core/utils/order_share_helper.dart';
import 'package:coreflow/domain/model/customer/customer.dart';
import 'package:coreflow/domain/model/sales/sales_order_detail.dart'
    as sales_detail;
import 'package:coreflow/features/payment/receive_payment/view/create_receive_payment_page.dart';
import 'package:coreflow/features/sales/viewmodel/sales_order_detail_view_model.dart';
import 'package:coreflow/core/theme/colors.dart';
import 'package:flutter/material.dart';

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

class SalesBottomOptionsPanel extends StatefulWidget {
  final sales_detail.SalesOrderDetail order;
  final SalesOrderDetailViewModel vm;

  const SalesBottomOptionsPanel({
    super.key,
    required this.order,
    required this.vm,
  });

  @override
  State<SalesBottomOptionsPanel> createState() =>
      _SalesBottomOptionsPanelState();
}

class _SalesBottomOptionsPanelState extends State<SalesBottomOptionsPanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  bool _sharing = false;
  double _expandedHeight = 0;
  final _expandedKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  OrderShareData get _data => _salesOrderToShareData(widget.order);

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
          label: 'Revert to Ordered',
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
          duration: const Duration(seconds: 1),
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
    final pending = order.pendingAmount < 0 ? 0.0 : order.pendingAmount;

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

  Future<void> _shareText() async {
    if (_sharing) return;
    setState(() => _sharing = true);
    _animCtrl.reverse();
    await OrderShareHelper.shareText(_data);
    if (mounted) setState(() => _sharing = false);
  }

  Future<void> _sharePdf() async {
    if (_sharing) return;
    setState(() => _sharing = true);
    _animCtrl.reverse();
    await OrderShareHelper.shareAsPdf(_data);
    if (mounted) setState(() => _sharing = false);
  }

  void _toggle() {
    if (_animCtrl.isAnimating) return;
    if (_animCtrl.value > 0.5) {
      _animCtrl.reverse();
    } else {
      _measureExpandedHeight();
      _animCtrl.forward();
    }
  }

  void _measureExpandedHeight() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final box =
          _expandedKey.currentContext?.findRenderObject() as RenderBox?;
      if (box != null) _expandedHeight = box.size.height;
    });
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_expandedHeight <= 0) _expandedHeight = 150;
    final delta = -details.primaryDelta! / _expandedHeight;
    _animCtrl.value = (_animCtrl.value + delta).clamp(0.0, 1.0);
  }

  void _onDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity < -300) {
      _animCtrl.forward();
    } else if (velocity > 300) {
      _animCtrl.reverse();
    } else if (_animCtrl.value > 0.5) {
      _animCtrl.forward();
    } else {
      _animCtrl.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final info = _statusInfo;
    final revertInfo = _revertStatusInfo;

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: GestureDetector(
        onVerticalDragUpdate: _onDragUpdate,
        onVerticalDragEnd: _onDragEnd,
        child: Material(
          color: LoginColors.surface,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(16)),
          elevation: 8,
          shadowColor: Colors.black26,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Drag handle ──
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 6),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color:
                        LoginColors.textSecondary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // ── Main action buttons row ──
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                child: Row(
                  children: [
                    // Share button
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: OutlinedButton.icon(
                          onPressed: _sharing ? null : _sharePdf,
                          icon: _sharing
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.share_rounded, size: 18),
                          label: const Text(
                            'Share',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: LoginColors.primary,
                            side: BorderSide(
                              color: LoginColors.primary
                                  .withValues(alpha: 0.4),
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
                      const SizedBox(width: 8),
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

                    // More options toggle
                    const SizedBox(width: 8),
                    AnimatedBuilder(
                      animation: _animCtrl,
                      builder: (context, child) => SizedBox(
                        width: 44,
                        height: 44,
                        child: OutlinedButton(
                          onPressed: _toggle,
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            foregroundColor: LoginColors.textPrimary,
                            side: BorderSide(
                                color: LoginColors.borderLight),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: _animCtrl.value > 0.5
                                ? LoginColors.primary
                                    .withValues(alpha: 0.08)
                                : null,
                          ),
                          child: Icon(
                            _animCtrl.value > 0.5
                                ? Icons.close_rounded
                                : Icons.more_horiz_rounded,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Expandable options (live drag) ──
              SizeTransition(
                sizeFactor: CurvedAnimation(
                  parent: _animCtrl,
                  curve: Curves.easeInOut,
                ),
                axisAlignment: -1.0,
                child: Column(
                  key: _expandedKey,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Divider(height: 1, color: LoginColors.borderLight),
                    _ActionTile(
                      icon: Icons.text_fields_rounded,
                      label: 'Share as Text',
                      color: LoginColors.primary,
                      onTap: _shareText,
                    ),
                    Divider(
                      height: 1,
                      indent: 44,
                      color: LoginColors.borderLight,
                    ),
                    _ActionTile(
                      icon: Icons.picture_as_pdf_rounded,
                      label: _data.isBillStatus
                          ? 'Share Bill PDF'
                          : 'Share Order PDF',
                      color: LoginColors.primary,
                      onTap: _sharePdf,
                    ),
                    if (revertInfo != null) ...[
                      Divider(
                        height: 1,
                        indent: 44,
                        color: LoginColors.borderLight,
                      ),
                      _ActionTile(
                        icon: revertInfo.icon,
                        label: revertInfo.label,
                        color: revertInfo.color,
                        onTap: widget.vm.isStatusUpdating
                            ? () {}
                            : () {
                                _animCtrl.reverse();
                                _doStatusAction(revertInfo.action);
                              },
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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
