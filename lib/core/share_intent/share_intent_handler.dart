import 'dart:async';
import 'dart:io';

import 'package:coreflow/core/share_intent/share_intent_service.dart';
import 'package:coreflow/domain/model/payment/payment_proof_result.dart';
import 'package:coreflow/features/presentation/payment/proof/view/payment_proof_page.dart';
import 'package:coreflow/features/presentation/payment/send_payment/view/create_payment_sent_page.dart';
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
      await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => CreatePaymentSentPage(
            companyId: companyId,
            proofResult: result,
          ),
        ),
      );
    }

    await _service.clearReceivedFiles();
  }
}
