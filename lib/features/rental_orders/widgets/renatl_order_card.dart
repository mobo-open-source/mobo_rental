import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:mobo_rental/features/products/provider/currency_provider.dart';
import 'package:mobo_rental/features/rental_orders/models/rental_order_item.dart';
import 'package:mobo_rental/features/rental_orders/screens/view_rental_order.dart';
import 'package:mobo_rental/Core/Widgets/common/textfrom.dart';
import 'package:provider/provider.dart';

class RentalOrdersCard extends StatelessWidget {
  final RentalOrderItem item;
  final bool isdark;

  const RentalOrdersCard({super.key, required this.item, required this.isdark});

  @override
  Widget build(BuildContext context) {
    String formattedDate = '';
    try {
      formattedDate = item.startDate != 'no date'
          ? DateFormat('MMM dd, yyyy').format(DateTime.parse(item.startDate))
          : 'No Date';
    } catch (_) {
      formattedDate = 'Invalid Date';
    }

    String validUntil = '';
    try {
      validUntil = item.startDate != 'no date'
          ? DateFormat('MMM dd').format(DateTime.parse(item.startDate))
          : 'No Date';
    } catch (_) {
      validUntil = 'Invalid Date';
    }

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ViewRentalOrder(
              orderID: item.id,
              states: state(item.status).toString(),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
        margin: const EdgeInsets.only(bottom: 10, top: 5, left: 6, right: 6),
        decoration: BoxDecoration(
          color: isdark ? Colors.grey[850] : Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: isdark
              ? []
              : [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    offset: const Offset(0, 1),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomText(
                  text: item.code,
                  fontweight: FontWeight.bold,
                  textcolor: isdark
                      ? Colors.white
                      : Theme.of(context).colorScheme.primary,
                  size: 15.6,
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 3.5,
                    horizontal: 10.5,
                  ),
                  decoration: BoxDecoration(
                    color: item.status.toLowerCase() == 'returned'
                        ? (isdark ? Colors.grey[800]! : Colors.grey[200]!)
                        : statusColor(item.status).withAlpha(40),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    state(item.status),
                    style: TextStyle(
                      color: statusColor(item.status),
                      fontWeight: FontWeight.bold,
                      fontSize: 10.4,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              item.customer,
              style: TextStyle(
                color: isdark ? Colors.grey[300] : Colors.grey[800],
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                HugeIcon(
                  icon: HugeIcons.strokeRoundedCalendar03,
                  color: isdark ? Colors.grey[400] : Colors.grey.shade600,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  formattedDate,
                  style: TextStyle(
                    color: isdark ? Colors.grey[400] : Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 10),
                HugeIcon(
                  icon: HugeIcons.strokeRoundedCalendar03,
                  color: isdark ? Colors.grey[400] : Colors.grey.shade600,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  'valid until $validUntil',
                  style: TextStyle(
                    color: isdark ? Colors.grey[400] : Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomText(
                  text: 'Total Amount:',
                  size: 13,
                  textcolor: isdark ? Colors.grey[300] : Colors.black,
                ),
                Consumer<CurrencyProvider>(
                  builder: (context, pro, child) {
                    return Text(
                      "${pro.formatAmount(item.amount, currency: item.currencyName)} ",
                      style: TextStyle(
                        fontSize: 15.6,
                        fontWeight: FontWeight.bold,
                        color: isdark ? Colors.white : Colors.black,
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String state(String state) {
    switch (state.toLowerCase()) {
      case "pickup":
        return 'Reserved';
      case "return":
        return 'Pickedup';
      case "cancel":
        return 'Cancelled';
      case "draft":
        return 'Quotation';
      case "sale":
        return 'Sale Order';
      case "returned":
        return 'Returned';
      default:
        return '';
    }
  }

  Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case "sale":
        return const Color.fromARGB(255, 175, 120, 76);
      case "pickup":
        return const Color.fromARGB(255, 91, 156, 7);
      case "cancel":
        return const Color.fromARGB(255, 185, 185, 185);
      case "return":
        return const Color.fromARGB(255, 245, 166, 35);
      case "draft":
        return const Color.fromARGB(255, 55, 158, 226);
      case "returned":
        return const Color.fromARGB(255, 168, 4, 4);
      default:
        return Colors.white;
    }
  }
}
