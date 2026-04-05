import 'dart:async';
import 'dart:io';

import 'package:coreflow/core/share_intent/share_intent_service.dart';
import 'package:coreflow/domain/model/main_model/payment/payment_proof_result.dart';
import 'package:coreflow/features/main_feature/payment/proof/view/payment_proof_page.dart';
import 'package:coreflow/features/main_feature/payment/receive_payment/view/create_receive_payment_page.dart';
import 'package:coreflow/features/main_feature/payment/send_payment/view/create_payment_sent_page.dart';
import 'package:coreflow/core/theme/colors.dart';
import 'package:flutter/material.dart';

class ShareIntentHandler {
  final ShareIntentService _service;
  final List<File> _pendingFiles = [];
  StreamSubscription<File>? _subscription;
  bool _isHandling = false;
  int? _companyId;

  ShareIntentHandler({ShareIntentService? service})
      : _service = service ?? ShareIntentService.instance;

  Future<void> start(BuildContext context) async {
    await _service.init();

    final initialFiles = await _service.getInitialFiles();
    if (initialFiles.isNotEmpty) {
      _pendingFiles.addAll(initialFiles);
    }

    _subscription ??= _service.fileStream.listen((file) {
      _pendingFiles.add(file);
      _drainQueue(context);
    });

    _drainQueue(context);
  }

  void updateCompanyId(int? companyId, BuildContext context) {
    if (_companyId == companyId) return;
    _companyId = companyId;
    _drainQueue(context);
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
  }

  Future<void> _drainQueue(BuildContext context) async {
    if (_isHandling || _companyId == null) return;
    _isHandling = true;

    try {
      while (_pendingFiles.isNotEmpty &&
          _companyId != null &&
          context.mounted) {
        final file = _pendingFiles.removeAt(0);
        await _handleFile(context, file, _companyId!);
      }
    } finally {
      _isHandling = false;
    }
  }

  Future<void> _handleFile(
    BuildContext context,
    File file,
    int companyId,
  ) async {
    if (!context.mounted) return;

    // Ask user which payment type to create
    final paymentType = await _showPaymentTypeDialog(context);
    if (paymentType == null || !context.mounted) {
      await _service.clearReceivedFiles();
      return;
    }

    final result = await Navigator.push<PaymentProofResult>(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentProofPage(
          companyId: companyId,
          initialFile: file,
        ),
      ),
    );

    if (!context.mounted) return;

    if (result != null) {
      final Widget page = paymentType == _PaymentType.send
          ? CreatePaymentSentPage(
              companyId: companyId,
              proofResult: result,
            )
          : CreateReceivePaymentPage(
              companyId: companyId,
              proofResult: result,
            );

      await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => page),
      );
    }

    await _service.clearReceivedFiles();
  }

  Future<_PaymentType?> _showPaymentTypeDialog(BuildContext context) {
    return showModalBottomSheet<_PaymentType>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Create Payment',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'What type of payment would you like to create?',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: LoginColors.primary.withValues(alpha: 0.1),
                child: Icon(Icons.call_made_rounded,
                    color: LoginColors.primary),
              ),
              title: const Text('Send Payment',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Payment made to a vendor'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey[300]!),
              ),
              onTap: () => Navigator.pop(ctx, _PaymentType.send),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.green.withValues(alpha: 0.1),
                child: const Icon(Icons.call_received_rounded,
                    color: Colors.green),
              ),
              title: const Text('Receive Payment',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Payment received from a customer'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey[300]!),
              ),
              onTap: () => Navigator.pop(ctx, _PaymentType.receive),
            ),
          ],
        ),
      ),
    );
  }
}

enum _PaymentType { send, receive }
