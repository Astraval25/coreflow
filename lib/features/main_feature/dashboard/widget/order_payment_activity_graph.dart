import 'dart:async';
import 'dart:math' as math;

import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/domain/model/main_model/analytics/order_history.dart';
import 'package:coreflow/domain/model/main_model/analytics/payment_history.dart';
import 'package:flutter/material.dart';

class _ActivityCell {
  final DateTime date;
  final bool inRange;
  final double orders;
  final double payments;
  final double quantity;

  const _ActivityCell({
    required this.date,
    required this.inRange,
    this.orders = 0,
    this.payments = 0,
    this.quantity = 0,
  });

  double get score => orders + payments + quantity;

  _ActivityCell copyWith({double? orders, double? payments, double? quantity}) {
    return _ActivityCell(
      date: date,
      inRange: inRange,
      orders: orders ?? this.orders,
      payments: payments ?? this.payments,
      quantity: quantity ?? this.quantity,
    );
  }
}

class OrderPaymentActivityGraph extends StatefulWidget {
  final List<OrderHistoryEntry> orders;
  final List<PaymentHistoryEntry> payments;
  final DateTime startDate;
  final DateTime endDate;

  const OrderPaymentActivityGraph({
    super.key,
    required this.orders,
    required this.payments,
    required this.startDate,
    required this.endDate,
  });

  @override
  State<OrderPaymentActivityGraph> createState() =>
      _OrderPaymentActivityGraphState();
}

class _OrderPaymentActivityGraphState extends State<OrderPaymentActivityGraph> {
  _ActivityCell? _selectedCell;
  Timer? _dismissTimer;

  @override
  void dispose() {
    _dismissTimer?.cancel();
    super.dispose();
  }

  DateTime _day(DateTime date) => DateTime(date.year, date.month, date.day);

  List<_ActivityCell> _cells() {
    final start = _day(widget.startDate);
    final end = _day(widget.endDate);
    final gridStart = start.subtract(Duration(days: start.weekday % 7));
    final gridEnd = end.add(Duration(days: 6 - end.weekday % 7));
    final cells = <DateTime, _ActivityCell>{};

    for (
      var date = gridStart;
      !date.isAfter(gridEnd);
      date = date.add(const Duration(days: 1))
    ) {
      cells[date] = _ActivityCell(
        date: date,
        inRange: !date.isBefore(start) && !date.isAfter(end),
      );
    }

    for (final order in widget.orders) {
      final date = _day(order.orderDate);
      final current = cells[date];
      if (current == null || !current.inRange) continue;
      cells[date] = current.copyWith(
        orders: current.orders + order.totalAmount,
        quantity: current.quantity + order.totalItemQuantity,
      );
    }

    for (final payment in widget.payments) {
      final date = _day(payment.paymentDate);
      final current = cells[date];
      if (current == null || !current.inRange) continue;
      cells[date] = current.copyWith(
        payments: current.payments + payment.amount,
      );
    }

    return cells.values.toList();
  }

  void _selectCell(_ActivityCell cell) {
    if (!cell.inRange) return;
    _dismissTimer?.cancel();
    setState(() => _selectedCell = cell);
    _dismissTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) setState(() => _selectedCell = null);
    });
  }

  String _money(double value) => 'Rs ${value.toStringAsFixed(2)}';

  String _dateLabel(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }

  String _monthLabel(DateTime date) {
    const months = [
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
    return months[date.month - 1];
  }

  Color _color(_ActivityCell cell, double maximum) {
    if (!cell.inRange) return Colors.transparent;
    if (cell.score <= 0 || maximum <= 0) return LoginColors.surfaceSecondary;
    final ratio = cell.score / maximum;
    if (ratio >= .8) return LoginColors.primaryDark;
    if (ratio >= .55) return LoginColors.primary;
    if (ratio >= .32) return LoginColors.primary.withValues(alpha: .72);
    if (ratio >= .14) return LoginColors.primary.withValues(alpha: .45);
    return LoginColors.primary.withValues(alpha: .2);
  }

  @override
  Widget build(BuildContext context) {
    final cells = _cells();
    final maximum = cells.fold<double>(
      0,
      (value, cell) => math.max(value, cell.score),
    );

    return Container(
      height: 218,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: LoginColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LoginColors.border.withValues(alpha: .5)),
        boxShadow: [
          BoxShadow(
            color: LoginColors.shadowLight.withValues(alpha: .08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order and Payment Activity',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: LoginColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(child: _heatmap(cells, maximum)),
                if (_selectedCell != null)
                  Positioned(
                    left: 30,
                    right: 0,
                    top: 0,
                    child: _SelectedActivity(
                      key: ValueKey(_selectedCell!.date),
                      cell: _selectedCell!,
                      dateLabel: _dateLabel(_selectedCell!.date),
                      moneyFormatter: _money,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _heatmap(List<_ActivityCell> cells, double maximum) {
    const cellSize = 14.0;
    const gap = 3.0;
    const monthGap = 5.0;
    const columnWidth = cellSize + gap;
    final weekCount = (cells.length / 7).ceil();
    final monthLabels = <int, _ActivityCell>{};
    final monthStarts = <int>{};
    final seenMonths = <String>{};

    for (var weekIndex = 0; weekIndex < weekCount; weekIndex++) {
      final week = cells.skip(weekIndex * 7).take(7).toList();
      final inRangeCells = week.where((cell) => cell.inRange).toList();
      if (inRangeCells.isEmpty) continue;

      _ActivityCell? labelCell;
      for (final cell in inRangeCells) {
        if (cell.date.day == 1) {
          labelCell = cell;
          break;
        }
      }
      labelCell ??= inRangeCells.first;

      final monthKey = '${labelCell.date.year}-${labelCell.date.month}';
      if (seenMonths.add(monthKey)) {
        monthLabels[weekIndex] = labelCell;
      }
      if (weekIndex > 0 && inRangeCells.any((cell) => cell.date.day == 1)) {
        monthStarts.add(weekIndex);
      }
    }

    final totalMonthGap = monthStarts.length * monthGap;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: 30 + weekCount * columnWidth + totalMonthGap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 30),
              child: Row(
                children: List.generate(weekCount, (weekIndex) {
                  final labelCell = monthLabels[weekIndex];
                  final leftGap = monthStarts.contains(weekIndex)
                      ? monthGap
                      : 0.0;
                  return Container(
                    width: columnWidth + leftGap,
                    height: 20,
                    padding: EdgeInsets.only(left: leftGap),
                    child: labelCell == null
                        ? null
                        : OverflowBox(
                            alignment: Alignment.centerLeft,
                            maxWidth: 34,
                            child: Text(
                              _monthLabel(labelCell.date),
                              style: TextStyle(
                                fontSize: 9,
                                color: LoginColors.textSecondary,
                              ),
                            ),
                          ),
                  );
                }),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  width: 30,
                  child: Column(
                    children: [
                      _DayLabel(''),
                      _DayLabel('Mon'),
                      _DayLabel(''),
                      _DayLabel('Wed'),
                      _DayLabel(''),
                      _DayLabel('Fri'),
                      _DayLabel(''),
                    ],
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(weekCount, (weekIndex) {
                    final week = cells.skip(weekIndex * 7).take(7).toList();
                    final leftGap = monthStarts.contains(weekIndex)
                        ? monthGap
                        : 0.0;
                    return Padding(
                      padding: EdgeInsets.only(left: leftGap, right: gap),
                      child: Column(
                        children: week.map((cell) {
                          final isSelected = _selectedCell?.date == cell.date;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: gap),
                            child: GestureDetector(
                              onTap: () => _selectCell(cell),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 120),
                                width: cellSize,
                                height: cellSize,
                                decoration: BoxDecoration(
                                  color: _color(cell, maximum),
                                  borderRadius: BorderRadius.circular(3),
                                  border: Border.all(
                                    color: isSelected
                                        ? LoginColors.textPrimary
                                        : cell.inRange
                                        ? LoginColors.border
                                        : Colors.transparent,
                                    width: isSelected ? 1.5 : .6,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedActivity extends StatelessWidget {
  final _ActivityCell cell;
  final String dateLabel;
  final String Function(double) moneyFormatter;

  const _SelectedActivity({
    super.key,
    required this.cell,
    required this.dateLabel,
    required this.moneyFormatter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: LoginColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: LoginColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dateLabel,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: LoginColors.textPrimary,
            ),
          ),
          const SizedBox(height: 5),
          _InlineValue(label: 'Order', value: moneyFormatter(cell.orders)),
          _InlineValue(label: 'Payment', value: moneyFormatter(cell.payments)),
          _InlineValue(
            label: 'Quantity',
            value: cell.quantity.toStringAsFixed(2),
          ),
        ],
      ),
    );
  }
}

class _InlineValue extends StatelessWidget {
  final String label;
  final String value;

  const _InlineValue({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 2),
    child: Text(
      '$label: $value',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(fontSize: 9, color: LoginColors.textSecondary),
    ),
  );
}

class _DayLabel extends StatelessWidget {
  final String label;
  const _DayLabel(this.label);

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 17,
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: TextStyle(fontSize: 8, color: LoginColors.textSecondary),
      ),
    ),
  );
}
