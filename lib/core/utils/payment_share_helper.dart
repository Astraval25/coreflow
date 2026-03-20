import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:coreflow/domain/model/payment/payment_detail.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

class PaymentShareHelper {
  PaymentShareHelper._();

  // ── Text template ──

  static String buildShareText(PaymentDetail payment, {required bool isSent}) {
    final date = _fmtDate(payment.paymentDate);
    final mode = payment.modeOfPayment.trim();
    final name = isSent
        ? (payment.vendorName.trim().isNotEmpty
            ? payment.vendorName
            : 'Vendor')
        : (payment.customerName.trim().isNotEmpty
            ? payment.customerName
            : 'Customer');
    final amount = 'INR ${payment.amount.toStringAsFixed(2)}';
    final notes = payment.notes.trim();

    final buffer = StringBuffer();
    buffer.writeln('$date${mode.isNotEmpty ? ' - $mode' : ''}');
    buffer.writeln(name);
    buffer.writeln(amount);
    if (notes.isNotEmpty) {
      buffer.writeln(notes);
    } else {
      buffer.writeln('Thank you.');
    }
    return buffer.toString().trimRight();
  }

  // ── 1. Share Text ──

  static Future<void> shareText(PaymentDetail payment,
      {required bool isSent}) async {
    final text = buildShareText(payment, isSent: isSent);
    await Share.share(text);
  }

  // ── 2. Share Proof with Text ──

  static Future<void> shareProofWithText(
    PaymentDetail payment,
    Uint8List proofBytes, {
    required bool isSent,
  }) async {
    final text = buildShareText(payment, isSent: isSent);
    final dir = await getTemporaryDirectory();
    final ext = _isPdf(proofBytes) ? 'pdf' : 'jpg';
    final file = File('${dir.path}/payment_proof.$ext');
    await file.writeAsBytes(proofBytes);
    await Share.shareXFiles(
      [XFile(file.path)],
      text: text,
    );
  }

  // ── 3. Share as Image ──

  static Future<void> shareAsImage(
    PaymentDetail payment, {
    required bool isSent,
  }) async {
    final bytes = await _renderPaymentImage(payment, isSent: isSent);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/payment_receipt.png');
    await file.writeAsBytes(bytes);
    await Share.shareXFiles([XFile(file.path)]);
  }

  // ── 4. Share as PDF ──

  static Future<void> shareAsPdf(
    PaymentDetail payment, {
    required bool isSent,
  }) async {
    final bytes = await _generatePdf(payment, isSent: isSent);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/payment_receipt.pdf');
    await file.writeAsBytes(bytes);
    await Share.shareXFiles([XFile(file.path)]);
  }

  // ────────────────────── PDF generation ──────────────────────

  static Future<Uint8List> _generatePdf(PaymentDetail payment,
      {required bool isSent}) async {
    final pdf = pw.Document();
    final partyLabel = isSent ? 'Vendor' : 'Customer';
    final partyName = isSent
        ? (payment.vendorName.trim().isNotEmpty
            ? payment.vendorName
            : 'Vendor')
        : (payment.customerName.trim().isNotEmpty
            ? payment.customerName
            : 'Customer');

    final paymentLabel = payment.paymentNumber.trim().isNotEmpty
        ? payment.paymentNumber
        : '#${payment.paymentId}';

    final mode = payment.modeOfPayment.trim();
    final reference = payment.referenceNumber.trim();
    final notes = payment.notes.trim();
    final status = payment.paymentStatus.trim();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#1a73e8'),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Payment Receipt',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      paymentLabel,
                      style: pw.TextStyle(
                        color: PdfColor.fromHex('#cce0ff'),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 24),

              // Details table
              _pdfRow('Date', _fmtDate(payment.paymentDate)),
              _pdfRow('Time', _fmtTime(payment.paymentDate)),
              _pdfRow(partyLabel, partyName),
              if (mode.isNotEmpty) _pdfRow('Mode of Payment', mode),
              if (reference.isNotEmpty)
                _pdfRow('Reference Number', reference),
              if (status.isNotEmpty) _pdfRow('Status', status),
              _pdfRow('State', payment.isActive ? 'Active' : 'Inactive'),

              pw.SizedBox(height: 16),
              pw.Divider(color: PdfColor.fromHex('#e0e0e0')),
              pw.SizedBox(height: 8),

              // Amount
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Total Amount',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    'INR ${payment.amount.toStringAsFixed(2)}',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromHex('#1a73e8'),
                    ),
                  ),
                ],
              ),

              // Order allocations
              if (payment.orderAllocations.isNotEmpty) ...[
                pw.SizedBox(height: 20),
                pw.Divider(color: PdfColor.fromHex('#e0e0e0')),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Order Allocations',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.TableHelper.fromTextArray(
                  headerStyle: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 10,
                    color: PdfColors.white,
                  ),
                  headerDecoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#1a73e8'),
                  ),
                  cellStyle: const pw.TextStyle(fontSize: 10),
                  cellPadding: const pw.EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  headers: ['Order', 'Amount', 'Date', 'Remarks'],
                  data: payment.orderAllocations.map((a) {
                    final label = a.orderNumber.trim().isNotEmpty
                        ? a.orderNumber
                        : '#${a.orderId}';
                    return [
                      label,
                      'INR ${a.amountApplied.toStringAsFixed(2)}',
                      _fmtDate(a.allocationDate),
                      a.allocationRemarks.trim(),
                    ];
                  }).toList(),
                ),
              ],

              // Notes
              if (notes.isNotEmpty) ...[
                pw.SizedBox(height: 20),
                pw.Divider(color: PdfColor.fromHex('#e0e0e0')),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Notes',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(notes, style: const pw.TextStyle(fontSize: 11)),
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
              style: pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────── Image generation ──────────────────────

  static Future<Uint8List> _renderPaymentImage(
    PaymentDetail payment, {
    required bool isSent,
  }) async {
    final partyLabel = isSent ? 'Vendor' : 'Customer';
    final partyName = isSent
        ? (payment.vendorName.trim().isNotEmpty
            ? payment.vendorName
            : 'Vendor')
        : (payment.customerName.trim().isNotEmpty
            ? payment.customerName
            : 'Customer');
    final paymentLabel = payment.paymentNumber.trim().isNotEmpty
        ? payment.paymentNumber
        : '#${payment.paymentId}';
    final mode = payment.modeOfPayment.trim();
    final reference = payment.referenceNumber.trim();
    final notes = payment.notes.trim();
    final amount = 'INR ${payment.amount.toStringAsFixed(2)}';

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const width = 600.0;

    // Calculate height dynamically
    var y = 0.0;
    y += 80; // header
    y += 20; // gap
    y += 30; // date
    y += 30; // party
    if (mode.isNotEmpty) y += 30;
    if (reference.isNotEmpty) y += 30;
    y += 20; // divider gap
    y += 40; // amount
    if (payment.orderAllocations.isNotEmpty) {
      y += 20; // gap + label
      y += 30; // header row
      y += payment.orderAllocations.length * 28.0;
    }
    if (notes.isNotEmpty) y += 50;
    y += 40; // footer
    final height = y;

    // Background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, width, height),
      Paint()..color = Colors.white,
    );

    y = 0;

    // Header bar
    canvas.drawRect(
      Rect.fromLTWH(0, 0, width, 70),
      Paint()..color = const Color(0xFF1a73e8),
    );
    _drawText(canvas, 'Payment Receipt', 20, 16,
        fontSize: 20, color: Colors.white, bold: true);
    _drawText(canvas, paymentLabel, 20, 42,
        fontSize: 12, color: const Color(0xFFcce0ff));
    y = 80;

    // Details
    y = _drawDetailRow(canvas, 'Date', _fmtDate(payment.paymentDate), y);
    y = _drawDetailRow(canvas, partyLabel, partyName, y);
    if (mode.isNotEmpty) {
      y = _drawDetailRow(canvas, 'Mode', mode, y);
    }
    if (reference.isNotEmpty) {
      y = _drawDetailRow(canvas, 'Reference', reference, y);
    }

    // Divider
    y += 8;
    canvas.drawLine(
      Offset(20, y),
      Offset(width - 20, y),
      Paint()
        ..color = const Color(0xFFE0E0E0)
        ..strokeWidth = 1,
    );
    y += 12;

    // Amount
    _drawText(canvas, 'Total Amount', 20, y,
        fontSize: 12, color: const Color(0xFF666666));
    _drawText(canvas, amount, width - 20, y,
        fontSize: 18,
        color: const Color(0xFF1a73e8),
        bold: true,
        alignRight: true);
    y += 36;

    // Order allocations
    if (payment.orderAllocations.isNotEmpty) {
      _drawText(canvas, 'Order Allocations', 20, y,
          fontSize: 13, bold: true);
      y += 24;
      for (final a in payment.orderAllocations) {
        final label = a.orderNumber.trim().isNotEmpty
            ? a.orderNumber
            : '#${a.orderId}';
        _drawText(canvas, label, 20, y, fontSize: 11);
        _drawText(
            canvas,
            'INR ${a.amountApplied.toStringAsFixed(2)}',
            width - 20,
            y,
            fontSize: 11,
            alignRight: true);
        y += 24;
      }
    }

    // Notes
    if (notes.isNotEmpty) {
      y += 8;
      _drawText(canvas, 'Notes: $notes', 20, y,
          fontSize: 11, color: const Color(0xFF666666));
      y += 24;
    }

    // Footer
    y += 8;
    _drawText(canvas, 'Generated by CoreFlow', width / 2, y,
        fontSize: 9, color: const Color(0xFF999999), center: true);

    final picture = recorder.endRecording();
    final img = await picture.toImage(width.toInt(), height.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  static void _drawText(
    Canvas canvas,
    String text,
    double x,
    double y, {
    double fontSize = 12,
    Color color = Colors.black,
    bool bold = false,
    bool alignRight = false,
    bool center = false,
  }) {
    final builder = ui.ParagraphBuilder(
      ui.ParagraphStyle(
        textAlign:
            center ? TextAlign.center : (alignRight ? TextAlign.right : TextAlign.left),
        fontSize: fontSize,
        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      ),
    )
      ..pushStyle(ui.TextStyle(color: color, fontSize: fontSize))
      ..addText(text);

    final paragraph = builder.build();
    final maxWidth = alignRight || center ? x : 560.0;
    paragraph.layout(ui.ParagraphConstraints(width: maxWidth));

    final dx = alignRight
        ? x - paragraph.maxIntrinsicWidth
        : center
            ? x - paragraph.maxIntrinsicWidth / 2
            : x;
    canvas.drawParagraph(paragraph, Offset(dx, y));
  }

  static double _drawDetailRow(
      Canvas canvas, String label, String value, double y) {
    _drawText(canvas, '$label:', 20, y,
        fontSize: 11, color: const Color(0xFF666666));
    _drawText(canvas, value, 140, y, fontSize: 11, bold: true);
    return y + 26;
  }

  // ── Helpers ──

  static bool _isPdf(List<int> bytes) {
    if (bytes.length < 4) return false;
    return bytes[0] == 0x25 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x44 &&
        bytes[3] == 0x46;
  }

  static String _fmtDate(DateTime d) {
    const m = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${m[(d.month - 1).clamp(0, 11)]} ${d.day}, ${d.year}';
  }

  static String _fmtTime(DateTime d) {
    var h = d.hour;
    final min = d.minute.toString().padLeft(2, '0');
    final suf = h >= 12 ? 'PM' : 'AM';
    h = h % 12;
    if (h == 0) h = 12;
    return '$h:$min $suf';
  }
}
