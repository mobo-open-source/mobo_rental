import 'package:flutter_test/flutter_test.dart';
import 'package:mobo_rental/features/rental_orders/models/tax_model.dart';

void main() {
  group('TaxModel', () {
    test('fromJson creates correct instance', () {
      final json = {'id': 1, 'display_name': 'VAT 15%', 'amount': 15.0};

      final tax = TaxModel.fromJson(json);

      expect(tax.id, 1);
      expect(tax.name, 'VAT 15%');
      expect(tax.amount, 15.0);
    });

    test('fromJson handles missing display_name with default', () {
      final json = {'id': 2, 'amount': 10.0};

      final tax = TaxModel.fromJson(json);

      expect(tax.name, 'Unknown Tax');
    });

    test('fromJson handles missing amount with default', () {
      final json = {'id': 3, 'display_name': 'GST'};

      final tax = TaxModel.fromJson(json);

      expect(tax.amount, 0.0);
    });

    test('equality operator works correctly', () {
      final tax1 = TaxModel(id: 1, name: 'Tax', amount: 10.0);
      final tax2 = TaxModel(id: 1, name: 'Different Name', amount: 20.0);
      final tax3 = TaxModel(id: 2, name: 'Tax', amount: 10.0);

      expect(tax1 == tax2, true); // Same ID
      expect(tax1 == tax3, false); // Different ID
    });

    test('hashCode is based on id', () {
      final tax1 = TaxModel(id: 1, name: 'Tax', amount: 10.0);
      final tax2 = TaxModel(id: 1, name: 'Different', amount: 20.0);

      expect(tax1.hashCode, tax2.hashCode);
    });
  });
}
