import 'package:flutter_test/flutter_test.dart';
import 'package:mobo_rental/features/dashboard/models/recently_cancelled.dart';

void main() {
  group('RecentlyCancelledRentalOrderItem', () {
    test('fromJson creates correct instance with full data', () {
      final json = {
        'id': 456,
        'name': 'CANC-001',
        'partner_id': [2, 'Bob Johnson'],
        'amount_total': 3200.00,
        'write_date': '2024-01-18T16:45:00',
      };

      final item = RecentlyCancelledRentalOrderItem.fromJson(json);

      expect(item.id, 456);
      expect(item.orderCode, 'CANC-001');
      expect(item.customerName, 'Bob Johnson');
      expect(item.amountTotal, 3200.00);
      expect(item.writeDate.year, 2024);
      expect(item.writeDate.month, 1);
      expect(item.writeDate.day, 18);
    });

    test('fromJson handles null partner_id', () {
      final json = {
        'id': 456,
        'name': 'CANC-001',
        'partner_id': null,
        'amount_total': 1500,
        'write_date': '2024-01-18T16:45:00',
      };

      final item = RecentlyCancelledRentalOrderItem.fromJson(json);

      expect(item.customerName, '');
    });

    test('fromJson handles missing amount_total', () {
      final json = {
        'id': 456,
        'name': 'CANC-001',
        'partner_id': [2, 'Test User'],
        'write_date': '2024-01-18T16:45:00',
      };

      final item = RecentlyCancelledRentalOrderItem.fromJson(json);

      expect(item.amountTotal, 0.0);
    });
  });
}
