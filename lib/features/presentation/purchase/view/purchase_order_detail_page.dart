import 'package:coreflow/core/widgets/skeleton.dart';
import 'package:coreflow/data/repositories/auth_repository.dart';
import 'package:coreflow/domain/model/purchase/purchase_order_detail.dart';
import 'package:coreflow/domain/model/purchase/purchase_order_item.dart';
import 'package:coreflow/features/presentation/purchase/viewmodel/purchase_order_detail_view_model.dart';
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
    return Consumer<PurchaseOrderDetailViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF3F4F6),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: const Text(
              'Order Detail',
              style: TextStyle(
                color: Color(0xFF1F2937),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
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
                  icon: Icons.more_horiz_rounded,
                  onTap: () {},
                ),
              ),
            ],
          ),
          body: RefreshIndicator(onRefresh: vm.refresh, child: _buildBody(vm)),
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

    final order = vm.orderDetail;
    if (vm.isNoData || order == null) {
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

    final PurchaseOrderDetail detail = order;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 20),
      children: [
        _ItemDetailsCard(items: detail.orderItems),
        const SizedBox(height: 10),
        _OrderSummaryCard(order: detail),
        const SizedBox(height: 10),
        _OrderMetaCard(order: detail),
        const SizedBox(height: 10),
        _PartyInfoCard(order: detail),
        const SizedBox(height: 10),
        _PaymentSummaryCard(order: detail),
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
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(icon, size: 18, color: const Color(0xFF4B5563)),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: child,
    );
  }
}

class _OrderSummaryCard extends StatelessWidget {
  final PurchaseOrderDetail order;

  const _OrderSummaryCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final seller = _displaySeller(order);

    return _CardBlock(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Purchase Detail',
            style: TextStyle(
              color: Color(0xFF111827),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  size: 20,
                  color: Color(0xFF4B5563),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      seller,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(order.orderDate),
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OrderMetaCard extends StatelessWidget {
  final PurchaseOrderDetail order;

  const _OrderMetaCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final orderLabel = order.orderNumber.trim().isNotEmpty
        ? order.orderNumber
        : order.orderId.toString();

    return _CardBlock(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order ID: $orderLabel',
            style: const TextStyle(
              color: Color(0xFF111827),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _MetaText(
                  label: 'Date',
                  value: _formatDate(order.orderDate),
                ),
              ),
              Expanded(
                child: _MetaText(
                  label: 'Time',
                  value: _formatTime(order.orderDate),
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
          style: const TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          textAlign: textAlignEnd ? TextAlign.end : TextAlign.start,
          style: const TextStyle(
            color: Color(0xFF111827),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ItemDetailsCard extends StatelessWidget {
  final List<PurchaseOrderItem> items;

  const _ItemDetailsCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return _CardBlock(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 16,
                color: Color(0xFF111827),
              ),
              SizedBox(width: 6),
              Text(
                'Item Details',
                style: TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (items.isEmpty)
            const Text(
              'No items available.',
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            )
          else
            for (int i = 0; i < items.length; i++) ...[
              _ItemDetailRow(item: items[i], index: i),
              if (i != items.length - 1)
                const Divider(height: 14, color: Color(0xFFE5E7EB)),
            ],
        ],
      ),
    );
  }
}

class _ItemDetailRow extends StatelessWidget {
  final PurchaseOrderItem item;
  final int index;

  const _ItemDetailRow({required this.item, required this.index});

  @override
  Widget build(BuildContext context) {
    final itemName = item.itemName.trim().isNotEmpty
        ? item.itemName
        : 'Item ${index + 1}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Item ${index + 1}: $itemName',
          style: const TextStyle(
            color: Color(0xFF111827),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (item.itemDescription != null &&
            item.itemDescription!.trim().isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text(
              item.itemDescription!,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        const SizedBox(height: 5),
        Text(
          'Quantity: ${_trimNumber(item.quantity)}',
          style: const TextStyle(
            color: Color(0xFF374151),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          'Rate: ${_money(item.unitPrice)}',
          style: const TextStyle(
            color: Color(0xFF374151),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          'Amount: ${_money(item.itemTotal)}',
          style: const TextStyle(
            color: Color(0xFF374151),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _PartyInfoCard extends StatelessWidget {
  final PurchaseOrderDetail order;

  const _PartyInfoCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return _CardBlock(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _MetaText(
                  label: 'Seller Company',
                  value: _displaySeller(order),
                ),
              ),
              Expanded(
                child: _MetaText(
                  label: 'Buyer Company',
                  value: _displayBuyer(order),
                  textAlignEnd: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _MetaText(label: 'Vendor', value: _displayVendor(order)),
              ),
              Expanded(
                child: _MetaText(
                  label: 'Customer',
                  value: _displayCustomer(order),
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
        children: [
          Row(
            children: [
              Expanded(
                child: _MetaText(
                  label: 'Order amount',
                  value: _money(order.orderAmount),
                ),
              ),
              Expanded(
                child: _MetaText(
                  label: 'Tax',
                  value: _money(order.taxAmount),
                  textAlignEnd: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _MetaText(
                  label: 'Discount',
                  value: _money(order.discountAmount),
                ),
              ),
              Expanded(
                child: _MetaText(
                  label: 'Shipment cost',
                  value: _money(order.deliveryCharge),
                  textAlignEnd: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: _MetaText(
              label: 'Time',
              value: _formatTime(order.orderDate),
            ),
          ),
          const Divider(height: 18, color: Color(0xFFE5E7EB)),
          Row(
            children: [
              Expanded(
                child: _MetaText(
                  label: 'Total',
                  value: _money(order.totalAmount),
                ),
              ),
              Expanded(
                child: _MetaText(
                  label: 'Amount paid',
                  value: _money(order.paidAmount),
                  textAlignEnd: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: _MetaText(label: 'Balance', value: _money(pending)),
          ),
        ],
      ),
    );
  }
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
        Skeleton(height: 82, width: double.infinity, borderRadius: 12),
        SizedBox(height: 10),
        Skeleton(height: 120, width: double.infinity, borderRadius: 12),
        SizedBox(height: 10),
        Skeleton(height: 148, width: double.infinity, borderRadius: 12),
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
        Icon(icon, size: 40, color: const Color(0xFF6B7280)),
        const SizedBox(height: 8),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

String _money(double value) => 'INR ${value.toStringAsFixed(2)}';

String _trimNumber(double value) {
  final rounded = value.roundToDouble();
  if ((value - rounded).abs() < 0.000001) {
    return rounded.toInt().toString();
  }
  return value.toStringAsFixed(2);
}

String _displaySeller(PurchaseOrderDetail order) {
  if (order.sellerCompanyName.trim().isNotEmpty) {
    return order.sellerCompanyName;
  }
  if (order.vendorDisplayName.trim().isNotEmpty) {
    return order.vendorDisplayName;
  }
  if (order.vendorName.trim().isNotEmpty) {
    return order.vendorName;
  }
  return 'Seller';
}

String _displayBuyer(PurchaseOrderDetail order) {
  if (order.buyerCompanyName.trim().isNotEmpty) {
    return order.buyerCompanyName;
  }
  if (order.customerDisplayName.trim().isNotEmpty) {
    return order.customerDisplayName;
  }
  if (order.customerName.trim().isNotEmpty) {
    return order.customerName;
  }
  return 'Buyer';
}

String _displayVendor(PurchaseOrderDetail order) {
  if (order.vendorDisplayName.trim().isNotEmpty) {
    return order.vendorDisplayName;
  }
  if (order.vendorName.trim().isNotEmpty) {
    return order.vendorName;
  }
  return '-';
}

String _displayCustomer(PurchaseOrderDetail order) {
  if (order.customerDisplayName.trim().isNotEmpty) {
    return order.customerDisplayName;
  }
  if (order.customerName.trim().isNotEmpty) {
    return order.customerName;
  }
  return '-';
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
  final month = months[(date.month - 1).clamp(0, 11)];
  return '$month ${date.day}, ${date.year}';
}

String _formatTime(DateTime date) {
  int hour = date.hour;
  final minute = date.minute.toString().padLeft(2, '0');
  final suffix = hour >= 12 ? 'PM' : 'AM';

  hour = hour % 12;
  if (hour == 0) {
    hour = 12;
  }

  return '$hour:$minute $suffix';
}
