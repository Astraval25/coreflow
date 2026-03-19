import 'package:coreflow/core/widgets/skeleton.dart';
import 'package:coreflow/data/repositories/auth_repository.dart';
import 'package:coreflow/domain/model/payment/payment_detail.dart';
import 'package:coreflow/features/presentation/payment/send_payment/viewmodel/send_payment_detail_view_model.dart';
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
    return Consumer<SendPaymentDetailViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF3F4F6),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: const Text(
              'Payment Detail',
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
        _OverviewCard(payment: payment),
        const SizedBox(height: 10),
        _MetaCard(payment: payment),
        const SizedBox(height: 10),
        _TransferCard(payment: payment),
        const SizedBox(height: 10),
        _AmountCard(payment: payment),
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

class _OverviewCard extends StatelessWidget {
  final PaymentDetail payment;

  const _OverviewCard({required this.payment});

  @override
  Widget build(BuildContext context) {
    final vendor = _displayVendor(payment);

    return _CardBlock(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Send Payment',
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
                  Icons.payments_outlined,
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
                      vendor,
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
                      _formatDate(payment.paymentDate),
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

class _TransferCard extends StatelessWidget {
  final PaymentDetail payment;

  const _TransferCard({required this.payment});

  @override
  Widget build(BuildContext context) {
    final orderIdsText = payment.orderIds.isEmpty
        ? '-'
        : payment.orderIds.map((id) => '#$id').join(', ');

    return _CardBlock(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _MetaText(
                  label: 'Vendor',
                  value: _displayVendor(payment),
                ),
              ),
              Expanded(
                child: _MetaText(
                  label: 'Mode',
                  value: payment.modeOfPayment.trim().isEmpty
                      ? '-'
                      : payment.modeOfPayment,
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
                  label: 'Reference',
                  value: payment.referenceNumber.trim().isEmpty
                      ? '-'
                      : payment.referenceNumber,
                ),
              ),
              Expanded(
                child: _MetaText(
                  label: 'Linked Orders',
                  value: orderIdsText,
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

class _AmountCard extends StatelessWidget {
  final PaymentDetail payment;

  const _AmountCard({required this.payment});

  @override
  Widget build(BuildContext context) {
    final stateLabel = payment.isActive ? 'Active' : 'Inactive';

    return _CardBlock(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _MetaText(
                  label: 'Amount',
                  value: _money(payment.amount),
                ),
              ),
              Expanded(
                child: _MetaText(
                  label: 'Status',
                  value: payment.paymentStatus.trim().isEmpty
                      ? '-'
                      : payment.paymentStatus,
                  textAlignEnd: true,
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

class _NotesCard extends StatelessWidget {
  final String notes;

  const _NotesCard({required this.notes});

  @override
  Widget build(BuildContext context) {
    return _CardBlock(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Notes',
            style: TextStyle(
              color: Color(0xFF111827),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            notes,
            style: const TextStyle(
              color: Color(0xFF374151),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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
