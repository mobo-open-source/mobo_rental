import 'package:flutter_test/flutter_test.dart';
import 'package:mobo_rental/features/dashboard/models/recently_returned_product.dart';

void main() {
  group('ReturnedProductItem', () {
    test('fromJson creates correct instance with full data', () {
      final json = {
        'id': 789,
        'product_id': [10, 'Laptop Dell XPS'],
        'order_id': [50, 'ORD-2024-050'],
        'write_date': '2024-01-19T09:15:00',
      };

      final item = ReturnedProductItem.fromJson(json);

      expect(item.id, 789);
      expect(item.productId, 10);
      expect(item.productName, 'Laptop Dell XPS');
      expect(item.orderId, 50);
      expect(item.orderCode, 'ORD-2024-050');
      expect(item.writeDate.year, 2024);
    });

    test('fromJson handles null product_id', () {
      final json = {
        'id': 789,
        'product_id': null,
        'order_id': [50, 'ORD-2024-050'],
        'write_date': '2024-01-19T09:15:00',
      };

      final item = ReturnedProductItem.fromJson(json);

      expect(item.productId, 0);
      expect(item.productName, '');
    });

    test('fromJson handles null order_id', () {
      final json = {
        'id': 789,
        'product_id': [10, 'Test Product'],
        'order_id': null,
        'write_date': '2024-01-19T09:15:00',
      };

      final item = ReturnedProductItem.fromJson(json);

      expect(item.orderId, 0);
      expect(item.orderCode, '');
    });
  });
}
