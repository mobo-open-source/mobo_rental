class Product {
  final int id;
  final String name;
  final String? description;
  final double? cost;
  final double? listPrice;
  final String? imageUrl;
  final String? barcode;
  final int? uomId;
  final String? uomName;
  final String? displayPrice;


  Product({
      this.displayPrice,

    required this.id,
    required this.name,
    this.description,
    this.cost,
    this.listPrice,
    this.imageUrl,
    this.barcode,
    this.uomId,
    this.uomName,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
       displayPrice: json['display_price']?.toString(),
      id: json['id'] as int,
      name: json['name']?.toString() ?? 'Unknown Product',
      description:
          json['description']?.toString() ??
          json['description_sale']?.toString(),
      cost: (json['standard_price'] as num?)?.toDouble(),
      listPrice: (json['list_price'] as num?)?.toDouble(),
      imageUrl: json['image_1920']?.toString(),
      barcode: json['barcode']?.toString(),
      uomId: json['uom_id'] is List && (json['uom_id'] as List).isNotEmpty
          ? json['uom_id'][0] as int?
          : null,
      uomName: json['uom_id'] is List && (json['uom_id'] as List).length > 1
          ? json['uom_id'][1]?.toString()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'standard_price': cost,
      'list_price': listPrice,
      'image_1920': imageUrl,
      'barcode': barcode,
      'uom_id': uomId != null && uomName != null ? [uomId, uomName] : null,
    };
  }

  @override
  String toString() {
    return 'Product(id: $id, name: $name, price: $listPrice)';
  }
}
