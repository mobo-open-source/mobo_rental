import 'package:flutter_test/flutter_test.dart';
import 'package:mobo_rental/features/dashboard/models/todya_dropoff_moder.dart';

void main() {
  group('TodaysDropOffItem', () {
    test('fromJson creates correct instance with full data', () {
      final json = {
        'partner_id': [3, 'Charlie Brown'],
        'name': 'DROP-2024-001',
        'amount_total': 1800.50,
        'rental_status': 'return',
        'next_action_date': '2024-01-21',
      };

      final item = TodaysDropOffItem.fromJson(json);

      expect(item.customer, 'Charlie Brown');
      expect(item.code, 'DROP-2024-001');
      expect(item.amount, 1800.50);
      expect(item.status, 'return');
      expect(item.droppOffDate, '2024-01-21');
    });

    test('fromJson handles null partner_id', () {
      final json = {
        'partner_id': null,
        'name': 'DROP-001',
        'amount_total': 1000,
        'rental_status': 'return',
        'next_action_date': '2024-01-21',
      };

      final item = TodaysDropOffItem.fromJson(json);

      expect(item.customer, 'Unknown Customer');
    });

    test('fromJson handles missing fields with defaults', () {
      final json = {
        'partner_id': [3, 'Test'],
      };

      final item = TodaysDropOffItem.fromJson(json);

      expect(item.code, 'N/A');
      expect(item.amount, 0.0);
      expect(item.status, 'N/A');
      expect(item.droppOffDate, '');
    });
  });
}
