import 'package:flutter_test/flutter_test.dart';
import 'package:mobo_rental/features/rental_orders/models/product_model.dart';

void main() {
  group('ProductModel', () {
    test('fromJson creates correct instance with full data', () {
      final json = {
        'id': 100,
        'name': 'Gaming Laptop',
        'display_price': '\$1,299.99',
        'qty_available': 25.0,
        'product_variant_count': 3,
      };

      final product = ProductModel.fromJson(json);

      expect(product.id, 100);
      expect(product.name, 'Gaming Laptop');
      expect(product.displayPrice, '\$1,299.99');
      expect(product.qty, 25.0);
      expect(product.variantCount, 3);
    });

    test('fromJson handles missing qty_available with default', () {
      final json = {
        'id': 101,
        'name': 'Test Product',
        'display_price': '\$100',
      };

      final product = ProductModel.fromJson(json);

      expect(product.qty, 0.0);
    });

    test('fromJson handles missing product_variant_count with default', () {
      final json = {
        'id': 102,
        'name': 'Simple Product',
        'display_price': '\$50',
      };

      final product = ProductModel.fromJson(json);

      expect(product.variantCount, 0);
    });
  });
}
