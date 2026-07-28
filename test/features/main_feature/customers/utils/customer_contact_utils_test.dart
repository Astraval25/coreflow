import 'package:coreflow/domain/model/main_model/customer/customer_contact_lookup.dart';
import 'package:coreflow/features/main_feature/customers/utils/customer_contact_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('customer contact utils', () {
    test('sanitizePhoneDigits removes non-digits', () {
      expect(sanitizePhoneDigits('+91 98765-43210'), '919876543210');
      expect(sanitizePhoneDigits('(123) 456'), '123456');
    });

    test('toLast10PhoneKey returns null for short phone', () {
      expect(toLast10PhoneKey('12345'), isNull);
    });

    test('toLast10PhoneKey returns last 10 digits', () {
      expect(toLast10PhoneKey('+91 98765 43210'), '9876543210');
      expect(toLast10PhoneKey('001234567890'), '1234567890');
    });

    test('resolveLookupAction picks open/create/invite correctly', () {
      final open = CustomerContactLookupResult(
        validPhone: true,
        hasAccount: true,
        existingCustomerId: 10,
      );
      final create = CustomerContactLookupResult(
        validPhone: true,
        hasAccount: true,
      );
      final invite = CustomerContactLookupResult(
        validPhone: true,
        hasAccount: false,
      );

      expect(resolveLookupAction(open), CustomerLookupAction.open);
      expect(resolveLookupAction(create), CustomerLookupAction.create);
      expect(resolveLookupAction(invite), CustomerLookupAction.invite);
    });

    test('buildWhatsAppInviteUri encodes phone and message', () {
      final uri = buildWhatsAppInviteUri(phone: '+91 98765 43210');
      expect(uri.toString(), contains('https://wa.me/919876543210?text='));
      expect(uri.toString(), contains('coreflow.astraval.com'));
    });
  });
}
