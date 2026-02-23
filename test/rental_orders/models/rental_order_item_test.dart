import 'package:flutter_test/flutter_test.dart';
import 'package:mobo_rental/features/rental_orders/models/rental_order_item.dart';

void main() {
  group('RentalOrderItem', () {
    test('fromJson creates correct instance with full data', () {
      final json = {
        'id': 123,
        'currency_id': [1, 'USD'],
        'create_date': '2024-01-15T10:30:00',
        'write_date': '2024-01-16T14:20:00',
        'partner_id': [10, 'John Doe'],
        'partner_phone': '+1234567890',
        'partner_email': 'john@example.com',
        'partner_image_1920': 'base64_image',
        'name': 'ORD-2024-001',
        'amount_total': 5000.50,
        'rental_status': 'confirmed',
        'rental_start_date': '2024-02-01',
        'rental_return_date': '2024-02-10',
        'payment_term_id': [1, 'Immediate Payment'],
        'date_order': '2024-01-15',
        'partner_shipping_id': [5, '123 Main St'],
        'is_pdf_quote_builder_available': true,
        'user_id': [2, 'Sales Person'],
        'team_id': [3, 'Sales Team'],
        'require_signature': true,
        'require_payment': false,
        'client_order_ref': 'REF-001',
        'tag_ids': [1, 2, 3],
        'fiscal_position_id': [1, 'Domestic'],
        'incoterm': [1, 'EXW'],
        'warehouse_id': [1, 'Main Warehouse'],
        'commitment_date': '2024-02-01',
        'origin': 'Website',
        'opportunity_id': [1, 'Opp-001'],
        'campaign_id': [1, 'Campaign-001'],
        'source_id': [1, 'Google'],
        'medium_id': [1, 'CPC'],
        'signed_by': 'John Doe',
        'signed_on': '2024-01-15',
        'signature': 'signature_data',
        'delivery_count': 2,
        'invoice_count': 1,
      };

      final order = RentalOrderItem.fromJson(json);

      expect(order.id, 123);
      expect(order.currencyName, 'USD');
      expect(order.customerId, 10);
      expect(order.customer, 'John Doe');
      expect(order.customerPhone, '+1234567890');
      expect(order.customerEmail, 'john@example.com');
      expect(order.code, 'ORD-2024-001');
      expect(order.amount, 5000.50);
      expect(order.status, 'confirmed');
      expect(order.startDate, '2024-02-01');
      expect(order.endDate, '2024-02-10');
      expect(order.paymentTerm, 'Immediate Payment');
      expect(order.deliveryAddress, '123 Main St');
      expect(order.isQuoteAvailable, true);
      expect(order.onlineSignature, true);
      expect(order.onlinePayment, false);
      expect(order.reference, 'REF-001');
      expect(order.tagIds, [1, 2, 3]);
      expect(order.deliveryCount, 2);
      expect(order.invoiceCount, 1);
    });

    test('fromJson handles missing currency with USD default', () {
      final json = {'id': 1, 'name': 'ORD-001', 'amount_total': 100};

      final order = RentalOrderItem.fromJson(json);

      expect(order.currencyName, 'USD');
    });

    test('fromJson handles currency as Map', () {
      final json = {
        'id': 1,
        'currency_id': {'display_name': 'EUR'},
        'name': 'ORD-001',
        'amount_total': 100,
      };

      final order = RentalOrderItem.fromJson(json);

      expect(order.currencyName, 'EUR');
    });

    test('fromJson handles null partner_id', () {
      final json = {
        'id': 1,
        'name': 'ORD-001',
        'amount_total': 100,
        'partner_id': null,
      };

      final order = RentalOrderItem.fromJson(json);

      expect(order.customerId, 0);
      expect(order.customer, 'Unknown Customer');
    });

    test('fromJson handles missing amount_total', () {
      final json = {'id': 1, 'name': 'ORD-001'};

      final order = RentalOrderItem.fromJson(json);

      expect(order.amount, 0.0);
    });

    test('fromJson handles missing rental_status with draft default', () {
      final json = {'id': 1, 'name': 'ORD-001', 'amount_total': 100};

      final order = RentalOrderItem.fromJson(json);

      expect(order.status, 'draft');
    });

    test('fromJson handles false values for partner fields', () {
      final json = {
        'id': 1,
        'name': 'ORD-001',
        'amount_total': 100,
        'partner_phone': false,
        'partner_email': false,
        'partner_image_1920': false,
      };

      final order = RentalOrderItem.fromJson(json);

      expect(order.customerPhone, null);
      expect(order.customerEmail, null);
      expect(order.customerImage1920, null);
    });

    test('fromJson handles require_signature and require_payment', () {
      final json1 = {
        'id': 1,
        'name': 'ORD-001',
        'amount_total': 100,
        'require_signature': true,
        'require_payment': true,
      };

      final order1 = RentalOrderItem.fromJson(json1);

      expect(order1.onlineSignature, true);
      expect(order1.onlinePayment, true);

      final json2 = {'id': 2, 'name': 'ORD-002', 'amount_total': 200};

      final order2 = RentalOrderItem.fromJson(json2);

      expect(order2.onlineSignature, false);
      expect(order2.onlinePayment, false);
    });

    test('copyWith creates new instance with updated values', () {
      final original = RentalOrderItem.fromJson({
        'id': 1,
        'name': 'ORD-001',
        'amount_total': 100,
      });

      final updated = original.copyWith(amount: 200.0, status: 'confirmed');

      expect(updated.id, 1);
      expect(updated.code, 'ORD-001');
      expect(updated.amount, 200.0);
      expect(updated.status, 'confirmed');
    });

    test('_parsePaymentTerm handles null', () {
      final json = {
        'id': 1,
        'name': 'ORD-001',
        'amount_total': 100,
        'payment_term_id': null,
      };

      final order = RentalOrderItem.fromJson(json);

      expect(order.paymentTerm, null);
    });

    test('_parseDeliveryAddress handles null', () {
      final json = {
        'id': 1,
        'name': 'ORD-001',
        'amount_total': 100,
        'partner_shipping_id': null,
      };

      final order = RentalOrderItem.fromJson(json);

      expect(order.deliveryAddress, null);
    });

    test('_parseOrderDate handles null', () {
      final json = {
        'id': 1,
        'name': 'ORD-001',
        'amount_total': 100,
        'date_order': null,
      };

      final order = RentalOrderItem.fromJson(json);

      expect(order.orderDate, null);
    });

    test('_parseOrderDate handles valid date', () {
      final json = {
        'id': 1,
        'name': 'ORD-001',
        'amount_total': 100,
        'date_order': '2024-01-15',
      };

      final order = RentalOrderItem.fromJson(json);

      expect(order.orderDate, isNotNull);
      expect(order.orderDate!.year, 2024);
      expect(order.orderDate!.month, 1);
      expect(order.orderDate!.day, 15);
    });
  });
}
