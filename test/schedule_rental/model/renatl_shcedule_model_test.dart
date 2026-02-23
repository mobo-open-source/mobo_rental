import 'package:flutter_test/flutter_test.dart';
import 'package:mobo_rental/features/schedule_rental/model/renatl_shcedule_model.dart';

void main() {
  group('RentalScheduleItem', () {
    test('fromGanttRecord creates correct instance with full data', () {
      final json = {
        'product_id': {
          'id': 10,
          'display_name': 'MacBook Pro',
          'image_128': 'base64_image_data',
        },
        'order_id': {'id': 50, 'display_name': 'ORD-2024-050'},
        'display_name': 'Product Rental (John Doe)',
        'start_date': '2024-01-20T09:00:00',
        'return_date': '2024-01-25T17:00:00',
        'is_late': false,
        'rental_status': 'confirmed',
      };

      final item = RentalScheduleItem.fromGanttRecord(json);

      expect(item.productId, 10);
      expect(item.productName, 'MacBook Pro');
      expect(item.productImageBase64, 'base64_image_data');
      expect(item.customerName, 'John Doe');
      expect(item.orderName, 'ORD-2024-050');
      expect(item.startDate.year, 2024);
      expect(item.endDate.year, 2024);
      expect(item.status, RentalScheduleStatus.normal);
    });

    test('fromGanttRecord handles late status', () {
      final json = {
        'product_id': {'id': 10, 'display_name': 'Product'},
        'order_id': {'id': 50, 'display_name': 'Order'},
        'display_name': 'Rental (Customer)',
        'start_date': '2024-01-20T09:00:00',
        'return_date': '2024-01-25T17:00:00',
        'is_late': true,
        'rental_status': 'confirmed',
      };

      final item = RentalScheduleItem.fromGanttRecord(json);

      expect(item.status, RentalScheduleStatus.warning);
    });

    test('fromGanttRecord handles pickup status', () {
      final json = {
        'product_id': {'id': 10, 'display_name': 'Product'},
        'order_id': {'id': 50, 'display_name': 'Order'},
        'display_name': 'Rental (Customer)',
        'start_date': '2024-01-20T09:00:00',
        'return_date': '2024-01-25T17:00:00',
        'is_late': false,
        'rental_status': 'pickup',
      };

      final item = RentalScheduleItem.fromGanttRecord(json);

      expect(item.status, RentalScheduleStatus.info);
    });

    test('fromGanttRecord handles non-Map product_id', () {
      final json = {
        'product_id': 'invalid',
        'order_id': {'id': 50, 'display_name': 'Order'},
        'display_name': 'Rental',
        'start_date': '2024-01-20T09:00:00',
        'return_date': '2024-01-25T17:00:00',
      };

      final item = RentalScheduleItem.fromGanttRecord(json);

      expect(item.productId, 0);
      expect(item.productName, 'Unknown');
    });

    test('fromGanttRecord handles non-Map order_id', () {
      final json = {
        'product_id': {'id': 10, 'display_name': 'Product'},
        'order_id': 'invalid',
        'display_name': 'Rental',
        'start_date': '2024-01-20T09:00:00',
        'return_date': '2024-01-25T17:00:00',
      };

      final item = RentalScheduleItem.fromGanttRecord(json);

      expect(item.orderName, 'Unknown');
    });

    test('fromGanttRecord handles null dates', () {
      final json = {
        'product_id': {'id': 10, 'display_name': 'Product'},
        'order_id': {'id': 50, 'display_name': 'Order'},
        'display_name': 'Rental',
      };

      final item = RentalScheduleItem.fromGanttRecord(json);

      expect(item.startDate, isNotNull);
      expect(item.endDate, isNotNull);
    });

    test('customerName extraction from display_name with parentheses', () {
      final json = {
        'product_id': {'id': 10, 'display_name': 'Product'},
        'order_id': {'id': 50, 'display_name': 'Order'},
        'display_name': 'Product Rental (Alice Brown)',
        'start_date': '2024-01-20T09:00:00',
        'return_date': '2024-01-25T17:00:00',
      };

      final item = RentalScheduleItem.fromGanttRecord(json);

      expect(item.customerName, 'Alice Brown');
    });

    test('customerName extraction from display_name without parentheses', () {
      final json = {
        'product_id': {'id': 10, 'display_name': 'Product'},
        'order_id': {'id': 50, 'display_name': 'Order'},
        'display_name': 'Customer Name, Extra Info',
        'start_date': '2024-01-20T09:00:00',
        'return_date': '2024-01-25T17:00:00',
      };

      final item = RentalScheduleItem.fromGanttRecord(json);

      expect(item.customerName, 'Customer Name');
    });
  });
}
