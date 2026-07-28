import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/core/utils/common_formatters.dart';
import 'package:coreflow/domain/model/main_model/vendors/vendor_orders_payments.dart';
import 'package:coreflow/features/main_feature/payment/send_payment/view/send_payment_detail_page.dart';
import 'package:coreflow/features/main_feature/purchase/view/purchase_order_detail_page.dart';
import 'package:coreflow/features/main_feature/vendor/view_model/vendor_detail_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum VendorTransactionFilter { orders, payments, all }

class VendorOrdersPaymentsSection extends StatelessWidget {
  final VendorTransactionFilter filter;

  const VendorOrdersPaymentsSection({super.key, required this.filter});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<VendorDetailViewModel>();

    if (vm.isOrdersPaymentsLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: CircularProgressIndicator(
            color: LoginColors.primary,
            strokeWidth: 2.5,
          ),
        ),
      );
    }

    final filteredEntries = switch (filter) {
      VendorTransactionFilter.orders =>
        vm.ordersOnly
            .map(VendorOrderPaymentEntry.fromOrder)
            .toList(growable: false),
      VendorTransactionFilter.payments =>
        vm.paymentsOnly
            .map(VendorOrderPaymentEntry.fromPayment)
            .toList(growable: false),
      VendorTransactionFilter.all => vm.ordersPayments,
    };

    if (filteredEntries.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          decoration: BoxDecoration(
            color: LoginColors.surfaceSecondary,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: LoginColors.borderLight),
          ),
          child: Column(
            children: [
              Icon(
                Icons.receipt_long_rounded,
                size: 38,
                color: LoginColors.textTertiary.withValues(alpha: 0.6),
              ),
              const SizedBox(height: 10),
              Text(
                _emptyStateText,
                style: TextStyle(
                  color: LoginColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final totalCount =
        filteredEntries.length + (vm.isOrdersPaymentsLoadingMore ? 1 : 0);

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      itemCount: totalCount,
      itemBuilder: (context, index) {
        if (index >= filteredEntries.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Center(
              child: CircularProgressIndicator(
                color: LoginColors.primary,
                strokeWidth: 2.2,
              ),
            ),
          );
        }
        final entry = filteredEntries[index];
        final previous = index > 0 ? filteredEntries[index - 1] : null;
        final showDateHeader =
            previous == null || !_isSameCalendarDay(previous.date, entry.date);

        Widget child = const SizedBox.shrink();
        if (entry.isOrder && entry.order != null) {
          child = _OrderTile(order: entry.order!, companyId: vm.companyId);
        } else if (entry.payment != null) {
          child = _PaymentTile(
            payment: entry.payment!,
            companyId: vm.companyId,
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showDateHeader) ...[
              if (index != 0) const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Center(
                  child: Text(
                    formatDate(entry.date),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: LoginColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
            child,
            const SizedBox(height: 10),
          ],
        );
      },
    );
  }

  bool _isSameCalendarDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String get _emptyStateText {
    switch (filter) {
      case VendorTransactionFilter.orders:
        return 'No orders yet';
      case VendorTransactionFilter.payments:
        return 'No payments yet';
      case VendorTransactionFilter.all:
        return 'No orders or payments yet';
    }
  }
}

class _OrderTile extends StatelessWidget {
  final VendorOrder order;
  final int companyId;

  const _OrderTile({required this.order, required this.companyId});

  @override
  Widget build(BuildContext context) {
    final due = order.dueAmount;
    final isPaid = due <= 0;

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PurchaseOrderDetailPage(
              companyId: companyId,
              orderId: order.orderId,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: LoginColors.surfaceSecondary,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: LoginColors.borderLight),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _TypeBadge(label: 'ORD', color: LoginColors.primary),
                      Expanded(
                        child: Text(
                          order.orderNumber,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: LoginColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formatDate(order.orderDate),
                        style: TextStyle(
                          fontSize: 12,
                          color: LoginColors.textSecondary,
                        ),
                      ),
                      _ValueChip(
                        label: isPaid
                            ? 'Fully Paid'
                            : 'Due ${formatMoney(due)}',
                        color: isPaid ? LoginColors.success : LoginColors.error,
                      ),
                      Text(
                        formatMoney(order.totalAmount),
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: LoginColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Icon(
                Icons.chevron_right_rounded,
                size: 19,
                color: LoginColors.textTertiary,
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: _ViewedTick(isViewed: order.isViewed),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  final VendorPayment payment;
  final int companyId;

  const _PaymentTile({required this.payment, required this.companyId});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SendPaymentDetailPage(
              companyId: companyId,
              paymentId: payment.paymentId,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: LoginColors.surfaceSecondary,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: LoginColors.borderLight),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _TypeBadge(label: 'PAY', color: LoginColors.success),
                      Expanded(
                        child: Text(
                          payment.paymentPlatformRef,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: LoginColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formatDate(payment.paymentDate),
                        style: TextStyle(
                          fontSize: 12,
                          color: LoginColors.textSecondary,
                        ),
                      ),
                      Text(
                        formatMoney(payment.amount),
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: LoginColors.success,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Icon(
                Icons.chevron_right_rounded,
                size: 19,
                color: LoginColors.textTertiary,
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: _ViewedTick(isViewed: payment.isViewed),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _TypeBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _ValueChip extends StatelessWidget {
  final String label;
  final Color color;

  const _ValueChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _ViewedTick extends StatelessWidget {
  final bool isViewed;

  const _ViewedTick({required this.isViewed});

  @override
  Widget build(BuildContext context) {
    return Icon(
      isViewed ? Icons.done_all_rounded : Icons.done_rounded,
      size: 20,
      fill: 1,
      weight: 700,
      grade: 200,
      color: isViewed ? LoginColors.primary : LoginColors.textTertiary,
    );
  }
}
