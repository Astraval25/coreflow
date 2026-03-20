import 'dart:typed_data';

import 'package:coreflow/core/widgets/skeleton.dart';
import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/data/repositories/auth_repository.dart';
import 'package:coreflow/domain/model/payment/payment_detail.dart';
import 'package:coreflow/features/presentation/payment/receive_payment/viewmodel/receive_payment_detail_view_model.dart';
import 'package:coreflow/features/presentation/sales/view/sales_order_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PayReceivedDetailPage extends StatelessWidget {
  final int companyId;
  final int paymentId;

  const PayReceivedDetailPage({
    super.key,
    required this.companyId,
    required this.paymentId,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ReceivePaymentDetailViewModel>(
      create: (_) => ReceivePaymentDetailViewModel(
        repository: AuthRepository(),
        companyId: companyId,
        paymentId: paymentId,
      ),
      child: const _PayReceivedDetailView(),
    );
  }
}

class _PayReceivedDetailView extends StatelessWidget {
  const _PayReceivedDetailView();

  @override
  Widget build(BuildContext context) {
    LoginColors.setBrightness(Theme.of(context).brightness);

    return Consumer<ReceivePaymentDetailViewModel>(
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
            title: _PaymentAppBarTitle(payment: vm.paymentDetail),
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

  Widget _buildBody(ReceivePaymentDetailViewModel vm) {
    if (vm.isLoading) {
      return const _PayReceivedDetailLoadingSkeleton();
    }

    if (vm.hasError) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          const SizedBox(height: 120),
          _StateMessage(
            icon: Icons.error_outline_rounded,
            title: 'Failed to load payment detail',
            subtitle: vm.errorMessage ?? 'Please try again.',
          ),
        ],
      );
    }

    final payment = vm.paymentDetail;
    if (vm.isNoData || payment == null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: const [
          SizedBox(height: 120),
          _StateMessage(
            icon: Icons.receipt_long_outlined,
            title: 'No payment detail found',
            subtitle: 'This payment may not exist or is not accessible.',
          ),
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 20),
      children: [
        _MetaCard(payment: payment),
        const SizedBox(height: 10),
        _TransferCard(payment: payment),
        if (payment.orderAllocations.isNotEmpty) ...[
          const SizedBox(height: 10),
          _OrderAllocationsCard(
            allocations: payment.orderAllocations,
            companyId: vm.companyId,
          ),
        ],
        const SizedBox(height: 10),
        _AmountCard(payment: payment),
        const SizedBox(height: 10),
        _ProofCard(vm: vm),
        if (payment.notes.trim().isNotEmpty) ...[
          const SizedBox(height: 10),
          _NotesCard(notes: payment.notes),
        ],
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

class _PaymentAppBarTitle extends StatelessWidget {
  final PaymentDetail? payment;

  const _PaymentAppBarTitle({required this.payment});

  @override
  Widget build(BuildContext context) {
    if (payment == null) {
      return Text(
        'Payment Detail',
        style: TextStyle(
          color: DashboardColors.textWhite,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    final label = _paymentLabel(payment!);

    return Column(
      children: [
        Text(
          'Payment $label',
          style: TextStyle(
            color: DashboardColors.textWhite,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          _formatDate(payment!.paymentDate),
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



class _MetaCard extends StatelessWidget {
  final PaymentDetail payment;

  const _MetaCard({required this.payment});

  @override
  Widget build(BuildContext context) {
    final paymentLabel = payment.paymentNumber.trim().isNotEmpty
        ? payment.paymentNumber
        : payment.paymentId.toString();

    return _CardBlock(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment ID: $paymentLabel',
            style: TextStyle(
              color: LoginColors.textPrimary,
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
                  value: _formatDate(payment.paymentDate),
                ),
              ),
              Expanded(
                child: _MetaText(
                  label: 'Time',
                  value: _formatTime(payment.paymentDate),
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

class _TransferCard extends StatelessWidget {
  final PaymentDetail payment;

  const _TransferCard({required this.payment});

  @override
  Widget build(BuildContext context) {
    final allocationOrders = payment.orderAllocations
        .map((allocation) => _orderLabel(allocation))
        .toList();
    final orderIdsText = allocationOrders.isNotEmpty
        ? allocationOrders.join(', ')
        : payment.orderIds.isEmpty
        ? ''
        : payment.orderIds.map((id) => '#$id').join(', ');
    final mode = payment.modeOfPayment.trim();
    final reference = payment.referenceNumber.trim();
    final hasMode = mode.isNotEmpty;
    final hasReference = reference.isNotEmpty;
    final hasOrders = orderIdsText.isNotEmpty;

    return _CardBlock(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _MetaText(
                  label: 'Customer',
                  value: _displayCustomer(payment),
                ),
              ),
              if (hasMode)
                Expanded(
                  child: _MetaText(
                    label: 'Mode',
                    value: mode,
                    textAlignEnd: true,
                  ),
                ),
            ],
          ),
          if (hasReference || hasOrders) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                if (hasReference)
                  Expanded(
                    child: _MetaText(label: 'Reference', value: reference),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _OrderAllocationsCard extends StatelessWidget {
  final List<PaymentOrderAllocation> allocations;
  final int companyId;

  const _OrderAllocationsCard({
    required this.allocations,
    required this.companyId,
  });

  @override
  Widget build(BuildContext context) {
    return _CardBlock(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Allocations',
            style: TextStyle(
              color: LoginColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          for (int i = 0; i < allocations.length; i++) ...[
            _OrderAllocationRow(
              allocation: allocations[i],
              companyId: companyId,
            ),
            if (i != allocations.length - 1)
              Divider(height: 14, color: LoginColors.borderLight),
          ],
        ],
      ),
    );
  }
}

class _OrderAllocationRow extends StatelessWidget {
  final PaymentOrderAllocation allocation;
  final int companyId;

  const _OrderAllocationRow({
    required this.allocation,
    required this.companyId,
  });

  @override
  Widget build(BuildContext context) {
    final orderLabel = _orderLabel(allocation);
    final remarks = allocation.allocationRemarks.trim();

    return InkWell(
      onTap: allocation.orderId > 0
          ? () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => SalesOrderDetailPage(
                    companyId: companyId,
                    orderId: allocation.orderId,
                  ),
                ),
              );
            }
          : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    orderLabel,
                    style: TextStyle(
                      color: LoginColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  _money(allocation.amountApplied),
                  style: TextStyle(
                    color: LoginColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              _formatDate(allocation.allocationDate),
              style: TextStyle(
                color: LoginColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (remarks.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                remarks,
                style: TextStyle(
                  color: LoginColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AmountCard extends StatelessWidget {
  final PaymentDetail payment;

  const _AmountCard({required this.payment});

  @override
  Widget build(BuildContext context) {

    return _CardBlock(
      child: Row(
        children: [
          Expanded(
            child: _HighlightAmount(
              label: 'Amount',
              value: _money(payment.amount),
              color: LoginColors.success,
            ),
          ),
        ],
      ),
    );
  }
}

class _HighlightAmount extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _HighlightAmount({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label:',
          style: TextStyle(
            color: LoginColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _NotesCard extends StatelessWidget {
  final String notes;

  const _NotesCard({required this.notes});

  @override
  Widget build(BuildContext context) {
    return _CardBlock(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notes',
            style: TextStyle(
              color: LoginColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            notes,
            style: TextStyle(
              color: LoginColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _PayReceivedDetailLoadingSkeleton extends StatelessWidget {
  const _PayReceivedDetailLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 20),
      children: const [
        Skeleton(height: 78, width: double.infinity, borderRadius: 12),
        SizedBox(height: 10),
        Skeleton(height: 72, width: double.infinity, borderRadius: 12),
        SizedBox(height: 10),
        Skeleton(height: 86, width: double.infinity, borderRadius: 12),
        SizedBox(height: 10),
        Skeleton(height: 72, width: double.infinity, borderRadius: 12),
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

class _ProofCard extends StatefulWidget {
  final ReceivePaymentDetailViewModel vm;
  const _ProofCard({required this.vm});

  @override
  State<_ProofCard> createState() => _ProofCardState();
}

class _ProofCardState extends State<_ProofCard> {
  bool _loading = false;
  String? _error;

  Future<void> _viewProof() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final bytes = await widget.vm.fetchProofBytes();

    if (!mounted) return;
    setState(() => _loading = false);

    if (bytes == null || bytes.isEmpty) {
      setState(() => _error = 'Unable to load proof file');
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _ProofViewerPage(bytes: bytes),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _CardBlock(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.receipt_long_rounded,
                  size: 16, color: LoginColors.textPrimary),
              const SizedBox(width: 8),
              Text(
                'Payment Proof',
                style: TextStyle(
                  color: LoginColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              _buildAction(),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(
                color: LoginColors.error,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAction() {
    final fsId = widget.vm.paymentDetail?.fsId;
    final hasProof = fsId != null && fsId.isNotEmpty;

    if (!hasProof) {
      return Text(
        'No proof attached',
        style: TextStyle(
          color: LoginColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      );
    }

    if (_loading) {
      return SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: LoginColors.primary,
        ),
      );
    }

    return FilledButton.icon(
      onPressed: _viewProof,
      icon: const Icon(Icons.visibility_rounded, size: 16),
      label: const Text(
        'View',
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
      style: FilledButton.styleFrom(
        backgroundColor: LoginColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

class _ProofViewerPage extends StatelessWidget {
  final List<int> bytes;
  const _ProofViewerPage({required this.bytes});

  bool get _isPdf {
    if (bytes.length < 4) return false;
    return bytes[0] == 0x25 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x44 &&
        bytes[3] == 0x46;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text(
          'Payment Proof',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: _isPdf
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.picture_as_pdf_rounded,
                      size: 64, color: Colors.white54),
                  const SizedBox(height: 16),
                  const Text(
                    'PDF proof attached',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(bytes.length / 1024).toStringAsFixed(1)} KB',
                    style: const TextStyle(
                        color: Colors.white38, fontSize: 13),
                  ),
                ],
              ),
            )
          : InteractiveViewer(
              minScale: 0.5,
              maxScale: 5.0,
              child: Center(
                child: Image.memory(
                  Uint8List.fromList(bytes),
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Text(
                      'Unable to display image',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

String _money(double value) => 'INR ${value.toStringAsFixed(2)}';

String _paymentLabel(PaymentDetail payment) {
  return payment.paymentNumber.trim().isNotEmpty
      ? payment.paymentNumber
      : payment.paymentId.toString();
}

String _orderLabel(PaymentOrderAllocation allocation) {
  return allocation.orderNumber.trim().isNotEmpty
      ? allocation.orderNumber
      : '#${allocation.orderId}';
}

String _displayCustomer(PaymentDetail payment) {
  if (payment.customerName.trim().isNotEmpty) {
    return payment.customerName;
  }
  if (payment.vendorName.trim().isNotEmpty) {
    return payment.vendorName;
  }
  return 'Customer';
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
