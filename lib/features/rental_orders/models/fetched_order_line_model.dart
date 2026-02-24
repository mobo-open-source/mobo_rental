import 'package:mobo_rental/features/rental_orders/models/tax_model.dart';

class FetchedOrderLineModel {
  final int orderLineId;
  final int productId;

  final String name;
  final String productName;

  final double priceUnit;
  final double priceTotal;
  final double qtyDelivered;
  final double quantity;

  final double taxAmount;
  final List<int> taxIds;
  List<TaxModel> taxes;

  FetchedOrderLineModel({
    required this.orderLineId,
    required this.productId,
    required this.name,
    required this.productName,
    required this.priceUnit,
    required this.priceTotal,
    required this.qtyDelivered,
    required this.quantity,
    required this.taxAmount,
    required this.taxIds,
    this.taxes = const [],
  });

  factory FetchedOrderLineModel.fromJson(Map<String, dynamic> json) {
    final productField = json['product_id'];

    return FetchedOrderLineModel(
      orderLineId: json['id'] as int,
      productId: (productField is List && productField.isNotEmpty)
          ? productField[0] as int
          : 0,

      name: json['name'] ?? '',
      productName: (productField is List && productField.length > 1)
          ? productField[1]
          : '',

      priceUnit: (json['price_unit'] as num?)?.toDouble() ?? 0.0,
      priceTotal: (json['price_total'] as num?)?.toDouble() ?? 0.0,
      qtyDelivered: (json['qty_delivered'] as num?)?.toDouble() ?? 0.0,
      quantity: (json['product_uom_qty'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (json['price_tax'] as num?)?.toDouble() ?? 0.0,
      taxIds: (json['tax_ids'] as List?)?.cast<int>() ?? [],
      taxes: [],
    );
  }
}
