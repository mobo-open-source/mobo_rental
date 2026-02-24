class RecentlyCreatedRentalOrderItem {
  final int id;
  final String orderCode;
  final String customerName;
  final double amountTotal;
  final String rentalStatus;
  final DateTime createDate;
  final bool isLate;

  RecentlyCreatedRentalOrderItem({
    required this.id,
    required this.orderCode,
    required this.customerName,
    required this.amountTotal,
    required this.rentalStatus,
    required this.createDate,
    required this.isLate,
  });

  factory RecentlyCreatedRentalOrderItem.fromJson(Map<String, dynamic> json) {
    final partner = json['partner_id'] as List?;

    return RecentlyCreatedRentalOrderItem(
      id: json['id'] as int,
      orderCode: json['name'] as String,
      customerName: partner != null ? partner[1] as String : '',
      amountTotal: (json['amount_total'] ?? 0).toDouble(),
      rentalStatus: json['rental_status'] as String,
      createDate: DateTime.parse(json['create_date'] + 'Z').toLocal(),
      isLate: json['is_late'] == true,
    );
  }
}
