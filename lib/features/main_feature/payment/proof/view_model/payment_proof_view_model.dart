import 'dart:io';

import 'package:coreflow/data/repositories/auth_repository/auth_repository.dart';
import 'package:coreflow/domain/model/main_model/payment/payment_proof_response.dart';
import 'package:coreflow/domain/model/main_model/payment/payment_proof_result.dart';
import 'package:flutter/material.dart';

class PaymentProofViewModel extends ChangeNotifier {
  final AuthRepository _repository;
  final int companyId;

  PaymentProofViewModel({
    required AuthRepository repository,
    required this.companyId,
  }) : _repository = repository;

  File? _selectedFile;
  bool _isUploading = false;
  PaymentProofData? _proofData;
  String? _errorMessage;

  // User-editable fields after extraction
  double? _confirmedAmount;
  String? _confirmedTransactionId;

  // Getters
  File? get selectedFile => _selectedFile;
  bool get isUploading => _isUploading;
  PaymentProofData? get proofData => _proofData;
  String? get errorMessage => _errorMessage;
  double? get confirmedAmount => _confirmedAmount;
  String? get confirmedTransactionId => _confirmedTransactionId;

  bool get hasFile => _selectedFile != null;
  bool get hasProofData => _proofData != null;

  bool get isImage {
    if (_selectedFile == null) return false;
    final ext = _selectedFile!.path.toLowerCase();
    return ext.endsWith('.jpg') ||
        ext.endsWith('.jpeg') ||
        ext.endsWith('.png') ||
        ext.endsWith('.gif') ||
        ext.endsWith('.webp');
  }

  String get fileName {
    if (_selectedFile == null) return '';
    return _selectedFile!.path.split(Platform.pathSeparator).last;
  }

  void setFile(File file) {
    _selectedFile = file;
    _proofData = null;
    _errorMessage = null;
    _confirmedAmount = null;
    _confirmedTransactionId = null;
    notifyListeners();
  }

  Future<void> uploadProof() async {
    if (_selectedFile == null) return;

    _isUploading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.uploadPaymentProof(
        companyId,
        _selectedFile!,
      );

      if (result != null) {
        _proofData = result;
        _confirmedAmount = result.amount;
        _confirmedTransactionId = result.transactionId;
      } else {
        _errorMessage = 'Failed to upload payment proof';
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
    }

    _isUploading = false;
    notifyListeners();
  }

  void setConfirmedAmount(double? amount) {
    _confirmedAmount = amount;
  }

  void setConfirmedTransactionId(String? id) {
    _confirmedTransactionId = id;
  }

  PaymentProofResult buildResult() {
    return PaymentProofResult(
      fsId: _proofData!.fsId,
      amount: _confirmedAmount,
      transactionId: _confirmedTransactionId,
      extractedText: _proofData?.extractedText,
    );
  }
}
