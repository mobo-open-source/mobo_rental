import 'package:flutter_test/flutter_test.dart';
import 'package:mobo_rental/features/dashboard/models/recently_created.dart';

void main() {
  group('RecentlyCreatedRentalOrderItem', () {
    test('fromJson creates correct instance with full data', () {
      final json = {
        'id': 123,
        'name': 'ORD-001',
        'partner_id': [1, 'John Doe'],
        'amount_total': 1500.50,
        'rental_status': 'draft',
        'create_date': '2024-01-15T10:30:00',
        'is_late': true,
      };

      final item = RecentlyCreatedRentalOrderItem.fromJson(json);

      expect(item.id, 123);
      expect(item.orderCode, 'ORD-001');
      expect(item.customerName, 'John Doe');
      expect(item.amountTotal, 1500.50);
      expect(item.rentalStatus, 'draft');
      expect(item.isLate, true);
      expect(item.createDate.year, 2024);
    });

    test('fromJson handles null partner_id', () {
      final json = {
        'id': 123,
        'name': 'ORD-001',
        'partner_id': null,
        'amount_total': 1000,
        'rental_status': 'confirmed',
        'create_date': '2024-01-15T10:30:00',
        'is_late': false,
      };

      final item = RecentlyCreatedRentalOrderItem.fromJson(json);

      expect(item.customerName, '');
    });

    test('fromJson handles missing amount_total', () {
      final json = {
        'id': 123,
        'name': 'ORD-001',
        'partner_id': [1, 'Jane Doe'],
        'rental_status': 'confirmed',
        'create_date': '2024-01-15T10:30:00',
        'is_late': false,
      };

      final item = RecentlyCreatedRentalOrderItem.fromJson(json);

      expect(item.amountTotal, 0.0);
    });

    test('fromJson handles is_late as false when not true', () {
      final json = {
        'id': 123,
        'name': 'ORD-001',
        'partner_id': [1, 'Test'],
        'amount_total': 100,
        'rental_status': 'confirmed',
        'create_date': '2024-01-15T10:30:00',
        'is_late': false,
      };

      final item = RecentlyCreatedRentalOrderItem.fromJson(json);

      expect(item.isLate, false);
    });
  });
}
