class ProductVariantModel {
  final int id;
  final String name;
  final String? sku;
  final double price;
  final double stock;
  final List<int> taxes;

  ProductVariantModel({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    required this.taxes,
    this.sku,
  });

  factory ProductVariantModel.fromJson(Map<String, dynamic> json) {
    return ProductVariantModel(
      id: json['id'] as int,
      name: json['display_name']?.toString() ?? '',
      sku: json['default_code'] is String
          ? json['default_code'] as String
          : null,
      price: (json['list_price'] as num?)?.toDouble() ?? 0.0,
      stock: (json['qty_available'] as num?)?.toDouble() ?? 0.0,
      taxes:
          (json['taxes_id'] as List?)?.map((item) => item as int).toList() ??
          [],
    );
  }
}
