import 'package:flutter_test/flutter_test.dart';
import 'package:mobo_rental/features/products/model/product.dart';

void main() {
  group('Product Model', () {
    test('fromJson creates correct Product with full data', () {
      final json = {
        'id': 1,
        'name': 'Laptop HP',
        'description': 'High performance laptop',
        'standard_price': 800.00,
        'list_price': 1200.50,
        'image_1920': 'base64_image_data',
        'barcode': '123456789',
        'uom_id': [5, 'Unit'],
        'display_price': '\$1,200.50',
      };

      final product = Product.fromJson(json);

      expect(product.id, 1);
      expect(product.name, 'Laptop HP');
      expect(product.description, 'High performance laptop');
      expect(product.cost, 800.00);
      expect(product.listPrice, 1200.50);
      expect(product.imageUrl, 'base64_image_data');
      expect(product.barcode, '123456789');
      expect(product.uomId, 5);
      expect(product.uomName, 'Unit');
      expect(product.displayPrice, '\$1,200.50');
    });

    test('fromJson handles missing name with default', () {
      final json = {'id': 1};

      final product = Product.fromJson(json);

      expect(product.name, 'Unknown Product');
    });

    test('fromJson uses description_sale when description is null', () {
      final json = {
        'id': 1,
        'name': 'Test Product',
        'description_sale': 'Sale description',
      };

      final product = Product.fromJson(json);

      expect(product.description, 'Sale description');
    });

    test('fromJson handles empty uom_id list', () {
      final json = {'id': 1, 'name': 'Test Product', 'uom_id': []};

      final product = Product.fromJson(json);

      expect(product.uomId, null);
      expect(product.uomName, null);
    });

    test('fromJson handles uom_id with only one element', () {
      final json = {
        'id': 1,
        'name': 'Test Product',
        'uom_id': [5],
      };

      final product = Product.fromJson(json);

      expect(product.uomId, 5);
      expect(product.uomName, null);
    });

    test('toJson returns correct map', () {
      final product = Product(
        id: 1,
        name: 'Test Product',
        description: 'Test Description',
        cost: 100.0,
        listPrice: 150.0,
        barcode: '987654321',
        uomId: 3,
        uomName: 'Piece',
      );

      final json = product.toJson();

      expect(json['id'], 1);
      expect(json['name'], 'Test Product');
      expect(json['description'], 'Test Description');
      expect(json['standard_price'], 100.0);
      expect(json['list_price'], 150.0);
      expect(json['barcode'], '987654321');
      expect(json['uom_id'], [3, 'Piece']);
    });

    test('toJson handles null uom fields', () {
      final product = Product(id: 1, name: 'Test Product');

      final json = product.toJson();

      expect(json['uom_id'], null);
    });

    test('toString returns formatted string', () {
      final product = Product(id: 1, name: 'Test Product', listPrice: 99.99);

      expect(
        product.toString(),
        'Product(id: 1, name: Test Product, price: 99.99)',
      );
    });
  });
}
