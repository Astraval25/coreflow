import 'package:coreflow/domain/model/main_model/vendors/vendor_contact_lookup.dart';

enum VendorLookupAction { open, create, invite }

String sanitizePhoneDigits(String input) {
  return input.replaceAll(RegExp(r'[^0-9]'), '');
}

String? toLast10PhoneKey(String input) {
  final digits = sanitizePhoneDigits(input);
  if (digits.length < 10) return null;
  return digits.substring(digits.length - 10);
}

VendorLookupAction resolveLookupAction(VendorContactLookupResult result) {
  if (result.existingVendorId != null) {
    return VendorLookupAction.open;
  }
  if (result.hasAccount) {
    return VendorLookupAction.create;
  }
  return VendorLookupAction.invite;
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
