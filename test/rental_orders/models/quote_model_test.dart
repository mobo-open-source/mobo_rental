import 'package:flutter_test/flutter_test.dart';
import 'package:mobo_rental/features/rental_orders/models/quote_model.dart';

void main() {
  group('QuoteDocument', () {
    test('fromJson creates correct instance', () {
      final json = {'id': 1, 'name': 'Quote Template', 'is_selected': true};

      final doc = QuoteDocument.fromJson(json);

      expect(doc.id, 1);
      expect(doc.name, 'Quote Template');
      expect(doc.isSelected, true);
    });

    test('fromJson handles missing is_selected with default false', () {
      final json = {'id': 2, 'name': 'Another Template'};

      final doc = QuoteDocument.fromJson(json);

      expect(doc.isSelected, false);
    });

    test('isSelected can be modified', () {
      final doc = QuoteDocument(id: 1, name: 'Test');

      expect(doc.isSelected, false);
      doc.isSelected = true;
      expect(doc.isSelected, true);
    });
  });

  group('QuoteLine', () {
    test('fromJson creates correct instance with files', () {
      final json = {
        'id': 10,
        'name': 'Product Line',
        'files': [
          {'id': 1, 'name': 'File 1'},
          {'id': 2, 'name': 'File 2', 'is_selected': true},
        ],
      };

      final line = QuoteLine.fromJson(json);

      expect(line.lineId, 10);
      expect(line.productName, 'Product Line');
      expect(line.files.length, 2);
      expect(line.files[0].name, 'File 1');
      expect(line.files[1].isSelected, true);
    });
  });

  group('QuoteBuilderData', () {
    test('initializes with empty lists', () {
      final data = QuoteBuilderData();

      expect(data.headers, isEmpty);
      expect(data.footers, isEmpty);
      expect(data.lines, isEmpty);
    });
  });
}
