import 'package:flutter_test/flutter_test.dart';
import 'package:mobo_rental/features/dashboard/models/todays_pickup_model.dart';

void main() {
  group('TodaysPickUpItem', () {
    test('fromJson creates correct instance with full data', () {
      final json = {
        'partner_id': [1, 'Alice Smith'],
        'name': 'RENT-2024-001',
        'amount_total': 2500.75,
        'rental_status': 'pickup',
        'next_action_date': '2024-01-20T14:30:00',
      };

      final item = TodaysPickUpItem.fromJson(json);

      expect(item.customer, 'Alice Smith');
      expect(item.code, 'RENT-2024-001');
      expect(item.amount, 2500.75);
      expect(item.status, 'pickup');
      expect(item.pickupDate, contains('20-01-2024'));
    });

    test('fromJson handles null partner_id', () {
      final json = {
        'partner_id': null,
        'name': 'RENT-001',
        'amount_total': 1000,
        'rental_status': 'pickup',
        'next_action_date': '2024-01-20T14:30:00',
      };

      final item = TodaysPickUpItem.fromJson(json);

      expect(item.customer, 'Unknown Customer');
    });

    test('fromJson handles missing name', () {
      final json = {
        'partner_id': [1, 'Test Customer'],
        'amount_total': 1000,
        'rental_status': 'pickup',
        'next_action_date': '2024-01-20T14:30:00',
      };

      final item = TodaysPickUpItem.fromJson(json);

      expect(item.code, 'N/A');
    });

    test('fromJson handles missing amount_total', () {
      final json = {
        'partner_id': [1, 'Test Customer'],
        'name': 'RENT-001',
        'rental_status': 'pickup',
        'next_action_date': '2024-01-20T14:30:00',
      };

      final item = TodaysPickUpItem.fromJson(json);

      expect(item.amount, 0.0);
    });

    test('fromJson handles missing rental_status', () {
      final json = {
        'partner_id': [1, 'Test Customer'],
        'name': 'RENT-001',
        'amount_total': 1000,
        'next_action_date': '2024-01-20T14:30:00',
      };

      final item = TodaysPickUpItem.fromJson(json);

      expect(item.status, 'N/A');
    });
  });
}
