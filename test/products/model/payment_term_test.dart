import 'package:flutter_test/flutter_test.dart';
import 'package:mobo_rental/features/products/model/payment_term.dart';

void main() {
  group('PaymentTerm Model', () {
    test('fromJson creates correct PaymentTerm', () {
      final json = {'id': 1, 'name': 'Immediate Payment'};

      final paymentTerm = PaymentTerm.fromJson(json);

      expect(paymentTerm.id, 1);
      expect(paymentTerm.name, 'Immediate Payment');
    });

    test('fromJson handles missing name with default', () {
      final json = {'id': 2};

      final paymentTerm = PaymentTerm.fromJson(json);

      expect(paymentTerm.id, 2);
      expect(paymentTerm.name, 'Unknown');
    });

    test('toJson returns correct map', () {
      final paymentTerm = PaymentTerm(id: 3, name: '30 Days');

      final json = paymentTerm.toJson();

      expect(json['id'], 3);
      expect(json['name'], '30 Days');
    });

    test('toString returns formatted string', () {
      final paymentTerm = PaymentTerm(id: 4, name: 'Net 60');

      expect(paymentTerm.toString(), 'PaymentTerm(id: 4, name: Net 60)');
    });
  });
}
