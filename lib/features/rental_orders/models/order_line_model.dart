import 'package:mobo_rental/features/rental_orders/models/tax_model.dart';

class ProductLine {
  final int id;
  final int productId;
  final String name;
  final double price;
  final int quantity;
  final List<TaxModel> taxes;
  final double subtotal;
  final double tax;
  final double lineTotal;

  ProductLine({
    required this.id,
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.taxes,
    required this.subtotal,
    required this.tax,
    required this.lineTotal,
  });
}
