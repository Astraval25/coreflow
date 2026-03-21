class PaymentProofResult {
  final String fsId;
  final double? amount;
  final String? transactionId;
  final String? extractedText;

  PaymentProofResult({
    required this.fsId,
    this.amount,
    this.transactionId,
    this.extractedText,
  });
}
