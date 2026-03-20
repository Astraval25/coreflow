import 'package:coreflow/domain/model/payment/create_payment_sent_request.dart';

class CreatePaymentReceivedRequest {
  final int customerId;
  final PaymentDetailsRequest paymentDetails;

  CreatePaymentReceivedRequest({
    required this.customerId,
    required this.paymentDetails,
  });

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'paymentDetails': paymentDetails.toJson(),
    };
  }
}
