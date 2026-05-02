import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/core/utils/common_formatters.dart';
import 'package:coreflow/domain/model/main_model/customer/customer_orders_payments.dart';
import 'package:coreflow/features/main_feature/customers/view_model/customer_detail_view_model.dart';
import 'package:coreflow/features/main_feature/payment/receive_payment/view/pay_received_detail_page.dart';
import 'package:coreflow/features/main_feature/sales/view/sales_order_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum TransactionFilter { orders, payments, all }

class CustomerOrdersPaymentsSection extends StatelessWidget {
  final TransactionFilter filter;

  const CustomerOrdersPaymentsSection({super.key, required this.filter});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CustomerDetailViewModel>();

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
      TransactionFilter.orders =>
        vm.ordersOnly.map(OrderPaymentEntry.fromOrder).toList(growable: false),
      TransactionFilter.payments =>
        vm.paymentsOnly
            .map(OrderPaymentEntry.fromPayment)
            .toList(growable: false),
      TransactionFilter.all => vm.ordersPayments,
    };
    final totalCount =
        filteredEntries.length + (vm.isOrdersPaymentsLoadingMore ? 1 : 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (filteredEntries.isEmpty)
          Padding(
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
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            itemCount: totalCount,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
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
              return _buildEntryCard(
                context,
                filteredEntries[index],
                vm.companyId,
              );
            },
          ),
      ],
    );
  }

  String get _emptyStateText {
    switch (filter) {
      case TransactionFilter.orders:
        return 'No orders yet';
      case TransactionFilter.payments:
        return 'No payments yet';
      case TransactionFilter.all:
        return 'No orders or payments yet';
    }
  }

  Widget _buildEntryCard(
    BuildContext context,
    OrderPaymentEntry entry,
    int companyId,
  ) {
    if (entry.isOrder && entry.order != null) {
      return _buildOrderTile(context, entry.order!, companyId);
    }
    if (entry.payment != null) {
      return _buildPaymentTile(context, entry.payment!, companyId);
    }
    return const SizedBox.shrink();
  }

  Widget _buildOrderTile(
    BuildContext context,
    CustomerOrder order,
    int companyId,
  ) {
    final due = order.dueAmount;
    final isPaid = due <= 0;

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SalesOrderDetailPage(
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
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
            Icon(
              Icons.chevron_right_rounded,
              size: 19,
              color: LoginColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentTile(
    BuildContext context,
    CustomerPayment payment,
    int companyId,
  ) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PayReceivedDetailPage(
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
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
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              size: 19,
              color: LoginColors.textTertiary,
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
