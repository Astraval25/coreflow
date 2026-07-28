import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

/// Lightweight DTO so the helper doesn't depend on either model directly.
class OrderShareData {
  final String orderNumber;
  final int orderId;
  final DateTime orderDate;
  final String partyName; // customer or vendor display name
  final String partyLabel; // "Customer" or "Vendor"
  final String sellerCompanyName;
  final String buyerCompanyName;
  final List<OrderShareItemData> items;
  final double orderAmount;
  final double taxAmount;
  final double discountAmount;
  final double deliveryCharge;
  final double totalAmount;
  final double paidAmount;
  final String orderStatus;

  OrderShareData({
    required this.orderNumber,
    required this.orderId,
    required this.orderDate,
    required this.partyName,
    required this.partyLabel,
    required this.sellerCompanyName,
    required this.buyerCompanyName,
    required this.items,
    required this.orderAmount,
    required this.taxAmount,
    required this.discountAmount,
    required this.deliveryCharge,
    required this.totalAmount,
    required this.paidAmount,
    required this.orderStatus,
  });

  String get displayOrderNumber =>
      orderNumber.trim().isNotEmpty ? orderNumber : '#$orderId';

  bool get isBillStatus {
    final s = orderStatus.toUpperCase().replaceAll(' ', '_');
    return s == 'ORDER_INVOICED' || s == 'ORDERPAID' || s == 'ORDER_PAID';
  }

  String get documentTitle => isBillStatus ? 'Bill / Invoice' : 'Order';
}

class OrderShareItemData {
  final String itemName;
  final double quantity;
  final double unitPrice;
  final double itemTotal;

  OrderShareItemData({
    required this.itemName,
    required this.quantity,
    required this.unitPrice,
    required this.itemTotal,
  });
}

class OrderShareHelper {
  OrderShareHelper._();

  // ── Text template ──

  static String buildShareText(OrderShareData data) {
    final buf = StringBuffer();
    buf.writeln(_fmtDate(data.orderDate));
    buf.writeln(data.partyName);

    for (final item in data.items) {
      final name = item.itemName.trim().isNotEmpty ? item.itemName : 'Item';
      buf.writeln(
        '$name = ${_trimNum(item.quantity)} x ${_money(item.unitPrice)} = ${_money(item.itemTotal)}',
      );
    }

    if (data.deliveryCharge > 0) {
      buf.writeln('Delivery amount = ${_money(data.deliveryCharge)}');
    }
    if (data.taxAmount > 0) {
      buf.writeln('Tax amount = ${_money(data.taxAmount)}');
    }
    if (data.discountAmount > 0) {
      buf.writeln('Discount amount = ${_money(data.discountAmount)}');
    }

    buf.writeln('TOTAL = ${_money(data.totalAmount)}');
    return buf.toString().trimRight();
  }

  // ── 1. Share Text ──

  static Future<void> shareText(OrderShareData data) async {
    final text = buildShareText(data);
    await SharePlus.instance.share(ShareParams(text: text));
  }

  // ── 2. Share as PDF ──

  static Future<void> shareAsPdf(OrderShareData data) async {
    final bytes = await _generatePdf(data);
    final dir = await getTemporaryDirectory();
    final fileName = data.isBillStatus ? 'invoice' : 'order';
    final file = File('${dir.path}/${fileName}_${data.orderId}.pdf');
    await file.writeAsBytes(bytes);
    await SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));
  }

  // ────────────────────── PDF generation ──────────────────────

  static Future<Uint8List> _generatePdf(OrderShareData data) async {
    final pdf = pw.Document();
    final title = data.documentTitle;
    final accentHex = data.isBillStatus ? '#2e7d32' : '#1a73e8';
    final accent = PdfColor.fromHex(accentHex);
    final accentLight = data.isBillStatus
        ? PdfColor.fromHex('#c8e6c9')
        : PdfColor.fromHex('#cce0ff');
    final pending = data.totalAmount - data.paidAmount;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // ── Header ──
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: accent,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          title,
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 22,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          data.displayOrderNumber,
                          style: pw.TextStyle(color: accentLight, fontSize: 12),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          _fmtDate(data.orderDate),
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'Status: ${data.orderStatus}',
                          style: pw.TextStyle(color: accentLight, fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // ── Party details ──
              _pdfRow(data.partyLabel, data.partyName),
              if (data.sellerCompanyName.trim().isNotEmpty)
                _pdfRow('Seller', data.sellerCompanyName),
              if (data.buyerCompanyName.trim().isNotEmpty)
                _pdfRow('Buyer', data.buyerCompanyName),

              pw.SizedBox(height: 16),
              pw.Divider(color: PdfColor.fromHex('#e0e0e0')),
              pw.SizedBox(height: 8),

              // ── Items table ──
              pw.Text(
                'Items',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              if (data.items.isNotEmpty)
                pw.TableHelper.fromTextArray(
                  headerStyle: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 10,
                    color: PdfColors.white,
                  ),
                  headerDecoration: pw.BoxDecoration(color: accent),
                  cellStyle: const pw.TextStyle(fontSize: 10),
                  cellPadding: const pw.EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  cellAlignments: {
                    0: pw.Alignment.centerLeft,
                    1: pw.Alignment.centerRight,
                    2: pw.Alignment.centerRight,
                    3: pw.Alignment.centerRight,
                  },
                  headers: ['Item', 'Qty', 'Rate', 'Amount'],
                  data: data.items.map((item) {
                    final name = item.itemName.trim().isNotEmpty
                        ? item.itemName
                        : 'Item';
                    return [
                      name,
                      _trimNum(item.quantity),
                      _money(item.unitPrice),
                      _money(item.itemTotal),
                    ];
                  }).toList(),
                ),

              pw.SizedBox(height: 16),
              pw.Divider(color: PdfColor.fromHex('#e0e0e0')),
              pw.SizedBox(height: 8),

              // ── Amount summary ──
              _pdfAmountRow('Sub Total', _money(data.orderAmount)),
              if (data.deliveryCharge > 0)
                _pdfAmountRow('Delivery Charge', _money(data.deliveryCharge)),
              if (data.taxAmount > 0)
                _pdfAmountRow('Tax Amount', _money(data.taxAmount)),
              if (data.discountAmount > 0)
                _pdfAmountRow('Discount', '- ${_money(data.discountAmount)}'),

              pw.SizedBox(height: 8),
              pw.Divider(color: PdfColor.fromHex('#e0e0e0')),
              pw.SizedBox(height: 4),

              // Total
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Total',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    _money(data.totalAmount),
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: accent,
                    ),
                  ),
                ],
              ),

              // Paid & Balance (for bill)
              if (data.isBillStatus) ...[
                pw.SizedBox(height: 12),
                _pdfAmountRow('Amount Paid', _money(data.paidAmount)),
                pw.SizedBox(height: 4),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Balance Due',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex('#c62828'),
                      ),
                    ),
                    pw.Text(
                      _money(pending < 0 ? 0 : pending),
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex('#c62828'),
                      ),
                    ),
                  ],
                ),
              ],

              pw.Spacer(),

              // Footer
              pw.Center(
                child: pw.Text(
                  'Generated by CoreFlow',
                  style: pw.TextStyle(
                    fontSize: 9,
                    color: PdfColor.fromHex('#999999'),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    return await pdf.save();
  }

  static pw.Widget _pdfRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 140,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 11,
                color: PdfColor.fromHex('#666666'),
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _pdfAmountRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 11,
              color: PdfColor.fromHex('#666666'),
            ),
          ),
          pw.Text(value, style: pw.TextStyle(fontSize: 11)),
        ],
      ),
    );
  }

  // ── Helpers ──

  static String _money(double value) => '${value.toStringAsFixed(2)}';

  static String _trimNum(double value) {
    final rounded = value.roundToDouble();
    if ((value - rounded).abs() < 0.000001) {
      return rounded.toInt().toString();
    }
    return value.toStringAsFixed(2);
  }

  static String _fmtDate(DateTime d) {
    const m = [
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
    return '${m[(d.month - 1).clamp(0, 11)]} ${d.day}, ${d.year}';
  }
}
