import 'package:intl/intl.dart';

class TodaysPickUpItem {
  final String customer;
  final String code;
  final double amount;
  final String status;
  final String pickupDate;
  TodaysPickUpItem({
    required this.customer,
    required this.code,
    required this.amount,
    required this.status,
    required this.pickupDate,
  });

  factory TodaysPickUpItem.fromJson(Map<String, dynamic> order) {
    return TodaysPickUpItem(
      customer: order['partner_id'] != null
          ? order['partner_id'][1]?.toString() ?? 'Unknown Customer'
          : 'Unknown Customer',
      code: order['name']?.toString() ?? 'N/A',
      amount: (order['amount_total'] as num?)?.toDouble() ?? 0.0,
      status: order['rental_status']?.toString() ?? 'N/A',
      pickupDate: DateFormat(
        'dd-MM-yyyy HH:mm',
      ).format(DateTime.parse(order['next_action_date'])),
    );
  }
}