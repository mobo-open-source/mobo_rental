import 'package:flutter_test/flutter_test.dart';
import 'package:mobo_rental/features/customer/model/customer.dart';

void main() {
  group('Customer Model', () {
    test('fromJson creates correct Customer object', () {
      final json = {
        'id': 1,
        'name': 'Test Customer',
        'email': 'test@example.com',
        'phone': '1234567890',
        'is_company': true,
        'customer_rank': 1,
        'supplier_rank': 0,
        'active': true,
      };

      final customer = Customer.fromJson(json);

      expect(customer.id, 1);
      expect(customer.name, 'Test Customer');
      expect(customer.email, 'test@example.com');
      expect(customer.phone, '1234567890');
      expect(customer.isCompany, true);
      expect(customer.customerRank, 1);
      expect(customer.supplierRank, 0);
      expect(customer.active, true);
    });

    test('fromJson handles null values gracefully', () {
      final json = {'id': 1, 'name': 'Test Customer'};

      final customer = Customer.fromJson(json);

      expect(customer.id, 1);
      expect(customer.name, 'Test Customer');
      expect(customer.email, null);
      expect(customer.phone, null);
      expect(customer.active, true); // Default value
    });

    test('toJson returns correct map', () {
      final customer = Customer(
        id: 1,
        name: 'Test Customer',
        email: 'test@example.com',
        isCompany: false,
        active: true,
      );

      final json = customer.toJson();

      expect(json['name'], 'Test Customer');
      expect(json['email'], 'test@example.com');
      expect(json['is_company'], false);
      expect(json['active'], true);
    });

    test('copyWith creates new object with updated values', () {
      final customer = Customer(
        id: 1,
        name: 'Original Name',
        email: 'original@example.com',
      );

      final updatedCustomer = customer.copyWith(name: 'Updated Name');

      expect(updatedCustomer.id, 1);
      expect(updatedCustomer.name, 'Updated Name');
      expect(updatedCustomer.email, 'original@example.com');
    });
  });
}
