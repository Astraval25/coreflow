class CreatePaymentSentRequest {
  final int vendorId;
  final PaymentDetailsRequest paymentDetails;

  CreatePaymentSentRequest({
    required this.vendorId,
    required this.paymentDetails,
  });

  Map<String, dynamic> toJson() {
    return {
      'vendorId': vendorId,
      'paymentDetails': paymentDetails.toJson(),
    };
  }
}

class PaymentDetailsRequest {
  final double amount;
  final DateTime paymentDate;
  final String modeOfPayment;
  final String? referenceNumber;
  final String? paymentRemarks;
  final String? fsId;
  final List<OrderAllocationRequest> orderAllocations;

  PaymentDetailsRequest({
    required this.amount,
    required this.paymentDate,
    required this.modeOfPayment,
    this.referenceNumber,
    this.paymentRemarks,
    this.fsId,
    required this.orderAllocations,
  });

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'paymentDate': paymentDate.toIso8601String(),
      'modeOfPayment': modeOfPayment,
      if (referenceNumber != null && referenceNumber!.trim().isNotEmpty)
        'referenceNumber': referenceNumber!.trim(),
      if (paymentRemarks != null && paymentRemarks!.trim().isNotEmpty)
        'paymentRemarks': paymentRemarks!.trim(),
      if (fsId != null && fsId!.trim().isNotEmpty)
        'paymentProofFsId': fsId!.trim(),
      'orderAllocations':
          orderAllocations.map((a) => a.toJson()).toList(),
    };
  }
}

class OrderAllocationRequest {
  final int orderId;
  final double amountApplied;
  final DateTime allocationDate;
  final String? allocationRemarks;

  OrderAllocationRequest({
    required this.orderId,
    required this.amountApplied,
    required this.allocationDate,
    this.allocationRemarks,
  });

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'amountApplied': amountApplied,
      'allocationDate': allocationDate.toIso8601String(),
      if (allocationRemarks != null && allocationRemarks!.trim().isNotEmpty)
        'allocationRemarks': allocationRemarks!.trim(),
    };
  }
}
