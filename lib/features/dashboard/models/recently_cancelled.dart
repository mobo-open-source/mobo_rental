class RecentlyCancelledRentalOrderItem {
  final int id;
  final String orderCode;
  final String customerName;
  final double amountTotal;
  final DateTime writeDate;

  RecentlyCancelledRentalOrderItem({
    required this.id,
    required this.orderCode,
    required this.customerName,
    required this.amountTotal,
    required this.writeDate,
  });

 factory RecentlyCancelledRentalOrderItem.fromJson(Map<String, dynamic> json) {
    final partner = json['partner_id'] as List?;

    return RecentlyCancelledRentalOrderItem(
      id: json['id'] as int,
      orderCode: json['name'] as String,
      customerName: partner != null ? partner[1] as String : '',
      amountTotal: (json['amount_total'] ?? 0).toDouble(),
      writeDate: DateTime.parse(
        json['write_date'] + 'Z',
      ).toLocal(), 
    );
  }
}
