class TodaysDropOffItem {
  final String customer;
  final String code;
  final double amount;
  final String status;
  final String droppOffDate;
  TodaysDropOffItem({
    required this.customer,
    required this.code,
    required this.amount,
    required this.status,
    required this.droppOffDate,
  });

  factory TodaysDropOffItem.fromJson(Map<String, dynamic> order) {
    return TodaysDropOffItem(
      customer: order['partner_id'] != null
          ? order['partner_id'][1]?.toString() ?? 'Unknown Customer'
          : 'Unknown Customer',
      code: order['name']?.toString() ?? 'N/A',
      amount: (order['amount_total'] as num?)?.toDouble() ?? 0.0,
      status: order['rental_status']?.toString() ?? 'N/A',
      droppOffDate: order['next_action_date'] ?? '',
    );
  }
}
