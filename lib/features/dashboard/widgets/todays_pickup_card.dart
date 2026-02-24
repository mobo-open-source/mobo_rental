import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:mobo_rental/features/dashboard/models/todays_pickup_model.dart';
import 'package:mobo_rental/Core/Widgets/common/textfrom.dart';
import 'package:mobo_rental/features/rental_orders/models/rental_order_item.dart';

class TodaysPickupCard extends StatelessWidget {
  final TodaysPickUpItem item;
  const TodaysPickupCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final date = DateFormat('dd-MM-yyyy HH:mm').parse(item.pickupDate);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withAlpha(120)
                : Colors.black.withAlpha(30),
            offset: const Offset(-1, 0),
            blurRadius: 10,
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
                textcolor: Theme.of(context).colorScheme.primary,
                size: 15.6,
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 3.5,
                  horizontal: 10.5,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withAlpha(30),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _state(item.status),
                  style: const TextStyle(
                    color: Color.fromARGB(255, 91, 156, 7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item.customer,
            style: TextStyle(
              color: isDark ? Colors.grey.shade300 : Colors.grey[800],
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 3),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(6)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                HugeIcon(
                  icon: HugeIcons.strokeRoundedCalendar03,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  DateFormat('MMM dd, yyyy').format(date),
                  style: TextStyle(
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 10),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(
                text: 'Total Amount:',
                size: 13,
                textcolor: isDark ? Colors.grey.shade300 : null,
              ),
              Text(
                "\$ ${item.amount.toStringAsFixed(2)}",
                style: TextStyle(
                  fontSize: 15.6,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _state(String state) {
    switch (state.toLowerCase()) {
      case "pickup":
        return 'Reserved';
      case "returned":
        return 'Returned';
      case "cancel":
        return 'Cancelled';
      case "draft":
        return 'Qutation';
      default:
        return '';
    }
  }
}
