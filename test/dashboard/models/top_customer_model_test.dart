import 'package:flutter_test/flutter_test.dart';
import 'package:mobo_rental/features/dashboard/models/top_customer_model.dart';
import 'dart:convert';

void main() {
  group('TopCustomerItem', () {
    test('creates instance with required fields', () {
      final item = TopCustomerItem(
        customerId: 1,
        customerName: 'Test Customer',
        rentalCount: 5,
      );

      expect(item.customerId, 1);
      expect(item.customerName, 'Test Customer');
      expect(item.rentalCount, 5);
      expect(item.avatarBytes, null);
      expect(item.avatarBase64, null);
    });

    test('decodeAvatar returns null for null input', () {
      expect(TopCustomerItem.decodeAvatar(null), null);
    });

    test('decodeAvatar returns null for false input', () {
      expect(TopCustomerItem.decodeAvatar(false), null);
    });

    test('decodeAvatar returns null for empty string', () {
      expect(TopCustomerItem.decodeAvatar(''), null);
    });

    test('decodeAvatar decodes valid base64 string', () {
      final testString = 'SGVsbG8gV29ybGQ='; // "Hello World" in base64
      final result = TopCustomerItem.decodeAvatar(testString);

      expect(result, isNotNull);
      expect(String.fromCharCodes(result!), 'Hello World');
    });

    test('decodeAvatar returns null for invalid base64', () {
      expect(TopCustomerItem.decodeAvatar('invalid!!!'), null);
    });
  });
}
