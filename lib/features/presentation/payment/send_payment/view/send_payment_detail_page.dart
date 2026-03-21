import 'dart:typed_data';

import 'package:coreflow/core/utils/payment_share_helper.dart';
import 'package:coreflow/core/widgets/skeleton.dart';
import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/data/repositories/auth_repository.dart';
import 'package:coreflow/domain/model/payment/payment_detail.dart';
import 'package:coreflow/features/presentation/payment/send_payment/viewmodel/send_payment_detail_view_model.dart';
import 'package:coreflow/features/presentation/payment/send_payment/view/update_payment_sent_page.dart';
import 'package:coreflow/features/presentation/purchase/view/purchase_order_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SendPaymentDetailPage extends StatelessWidget {
  final int companyId;
  final int paymentId;

  const SendPaymentDetailPage({
    super.key,
    required this.companyId,
    required this.paymentId,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SendPaymentDetailViewModel>(
      create: (_) => SendPaymentDetailViewModel(
        repository: AuthRepository(),
        companyId: companyId,
        paymentId: paymentId,
      ),
      child: const _SendPaymentDetailView(),
    );
  }
}

class _SendPaymentDetailView extends StatelessWidget {
  const _SendPaymentDetailView();

  @override
  Widget build(BuildContext context) {
    LoginColors.setBrightness(Theme.of(context).brightness);

    return Consumer<SendPaymentDetailViewModel>(
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
                  icon: (vm.paymentDetail != null &&
                          DateTime.now()
                                  .difference(vm.paymentDetail!.paymentDate)
                                  .inHours
                                  .abs() >=
                              24)
                      ? Icons.lock_outline_rounded
                      : Icons.edit_rounded,
                  onTap: () async {
                    if (vm.paymentDetail == null) return;
                    final hoursDiff = DateTime.now()
                        .difference(vm.paymentDetail!.paymentDate)
                        .inHours
                        .abs();
                    if (hoursDiff >= 24) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text(
                            'Payments can only be edited within 24 hours of creation'),
                        behavior: SnackBarBehavior.floating,
                      ));
                      return;
                    }
                    final updated = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => UpdatePaymentSentPage(
                          companyId: vm.companyId,
                          initialPayment: vm.paymentDetail!,
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

  Widget _buildBody(SendPaymentDetailViewModel vm) {
    if (vm.isLoading) {
      return const _SendPaymentDetailLoadingSkeleton();
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
        if (payment.notes.trim().isNotEmpty) ...[
          const SizedBox(height: 10),
          _NotesCard(notes: payment.notes),
        ],
        const SizedBox(height: 10),
        _ProofCard(vm: vm),
        const SizedBox(height: 14),
        _BottomActionsBar(payment: payment, vm: vm),
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
                  label: 'Vendor',
                  value: _displayVendor(payment),
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
                  builder: (_) => PurchaseOrderDetailPage(
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
    final stateLabel = payment.isActive ? 'Active' : 'Inactive';

    return _CardBlock(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _HighlightAmount(
                  label: 'Amount',
                  value: _money(payment.amount),
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: _MetaText(label: 'State', value: stateLabel),
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

class _ProofCard extends StatefulWidget {
  final SendPaymentDetailViewModel vm;
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
    // PDF magic bytes: %PDF
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

class _BottomActionsBar extends StatefulWidget {
  final PaymentDetail payment;
  final SendPaymentDetailViewModel vm;

  const _BottomActionsBar({required this.payment, required this.vm});

  @override
  State<_BottomActionsBar> createState() => _BottomActionsBarState();
}

class _BottomActionsBarState extends State<_BottomActionsBar> {
  bool _shareExpanded = false;

  List<({String label, IconData icon, String action, Color color})>
      get _statusActions {
    final status = widget.payment.paymentStatus;
    final list =
        <({String label, IconData icon, String action, Color color})>[];

    if (status == 'PENDING') {
      list.add((
        label: 'Mark as Viewed',
        icon: Icons.visibility_rounded,
        action: 'viewed',
        color: Colors.blue.shade600,
      ));
    }
    if (status == 'VIEWED') {
      list.add((
        label: 'Partially Paid',
        icon: Icons.payments_outlined,
        action: 'partially-paid',
        color: Colors.orange.shade700,
      ));
    }
    if (status == 'PAID' || status == 'PARTIALLY_PAID') {
      list.add((
        label: 'Refund',
        icon: Icons.undo_rounded,
        action: 'refund',
        color: Colors.purple.shade600,
      ));
    }
    if (const ['PENDING', 'VIEWED', 'PARTIALLY_PAID'].contains(status)) {
      list.add((
        label: 'Mark Failed',
        icon: Icons.cancel_outlined,
        action: 'failed',
        color: LoginColors.error,
      ));
    }
    return list;
  }

  Future<void> _doStatusAction(String action) async {
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

  @override
  Widget build(BuildContext context) {
    final actions = _statusActions;

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
                        onTap: () {
                          setState(() => _shareExpanded = false);
                          PaymentShareHelper.shareText(
                            widget.payment,
                            isSent: true,
                          );
                        },
                      ),
                      Divider(height: 1, color: LoginColors.borderLight),
                      _ActionTile(
                        icon: Icons.image_rounded,
                        label: 'Share as Image',
                        color: LoginColors.primary,
                        onTap: () {
                          setState(() => _shareExpanded = false);
                          PaymentShareHelper.shareAsImage(
                            widget.payment,
                            isSent: true,
                          );
                        },
                      ),
                      Divider(height: 1, color: LoginColors.borderLight),
                      _ActionTile(
                        icon: Icons.picture_as_pdf_rounded,
                        label: 'Share as PDF',
                        color: LoginColors.primary,
                        onTap: () {
                          setState(() => _shareExpanded = false);
                          PaymentShareHelper.shareAsPdf(
                            widget.payment,
                            isSent: true,
                          );
                        },
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
            SizedBox(
              height: 44,
              child: OutlinedButton.icon(
                onPressed: () =>
                    setState(() => _shareExpanded = !_shareExpanded),
                icon: Icon(
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

            // Status action buttons
            for (final a in actions) ...[
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: FilledButton.icon(
                    onPressed: widget.vm.isStatusUpdating
                        ? null
                        : () => _doStatusAction(a.action),
                    icon: widget.vm.isStatusUpdating
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Icon(a.icon, size: 16),
                    label: Text(
                      a.label,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: a.color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
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

class _SendPaymentDetailLoadingSkeleton extends StatelessWidget {
  const _SendPaymentDetailLoadingSkeleton();

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

String _displayVendor(PaymentDetail payment) {
  if (payment.vendorName.trim().isNotEmpty) {
    return payment.vendorName;
  }
  if (payment.customerName.trim().isNotEmpty) {
    return payment.customerName;
  }
  return 'Vendor';
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
