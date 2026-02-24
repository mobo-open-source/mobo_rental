class ProductModel {
  final int id;
  final String name;
  final String displayPrice;
  final double qty;
  final int variantCount;

  ProductModel({
    required this.id,
    required this.name,
    required this.displayPrice,
    required this.qty,
    required this.variantCount,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as int,
      name: json['name'] as String,
      displayPrice: json['display_price'] as String,
      qty: (json['qty_available'] as num?)?.toDouble() ?? 0.0,
      variantCount: json['product_variant_count'] as int? ?? 0,
    );
  }
}
