class ReturnedProductItem {
  final int id;
  final String productName;
  final int productId;
  final String orderCode;
  final int orderId;
  final DateTime writeDate;

  ReturnedProductItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.orderId,
    required this.orderCode,
    required this.writeDate,
  });

  factory ReturnedProductItem.fromJson(Map<String, dynamic> json) {
    final productData = json['product_id'] as List?;
    final orderData = json['order_id'] as List?;

    return ReturnedProductItem(
      id: json['id'] as int,
      productId: productData != null ? productData[0] as int : 0,
      productName: productData != null ? productData[1] as String : '',
      orderId: orderData != null ? orderData[0] as int : 0,
      orderCode: orderData != null ? orderData[1] as String : '',
      writeDate: DateTime.parse(json['write_date'] + 'Z').toLocal(),
    );
  }
}
