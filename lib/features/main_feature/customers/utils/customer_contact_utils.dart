import 'package:coreflow/domain/model/main_model/customer/customer_contact_lookup.dart';

enum CustomerLookupAction { open, create, invite }

String sanitizePhoneDigits(String input) {
  return input.replaceAll(RegExp(r'[^0-9]'), '');
}

String? toLast10PhoneKey(String input) {
  final digits = sanitizePhoneDigits(input);
  if (digits.length < 10) return null;
  return digits.substring(digits.length - 10);
}

CustomerLookupAction resolveLookupAction(CustomerContactLookupResult result) {
  if (result.existingCustomerId != null) {
    return CustomerLookupAction.open;
  }
  if (result.hasAccount) {
    return CustomerLookupAction.create;
  }
  return CustomerLookupAction.invite;
}

String buildWhatsAppInviteMessage({
  String appUrl = 'https://coreflow.astraval.com',
}) {
  return 'Hi! Please download CoreFlow and connect with us on $appUrl';
}

Uri buildWhatsAppInviteUri({
  required String phone,
  String appUrl = 'https://coreflow.astraval.com',
}) {
  final digits = sanitizePhoneDigits(phone);
  final message = buildWhatsAppInviteMessage(appUrl: appUrl);
  return Uri.parse(
    'https://wa.me/$digits?text=${Uri.encodeComponent(message)}',
  );
}
