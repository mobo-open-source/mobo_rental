import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:mobo_rental/features/dashboard/models/todya_dropoff_moder.dart';
import 'package:mobo_rental/Core/Widgets/common/textfrom.dart';

class TodaysDropOffCard extends StatelessWidget {
  final TodaysDropOffItem item;
  const TodaysDropOffCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final date = DateFormat('dd-MM-yyyy HH:mm').parse(item.droppOffDate);

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
                  color: Colors.yellow.withAlpha(30),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  state(item.status),
                  style: TextStyle(color: isDark ? Colors.black : Colors.black),
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
          const SizedBox(height: 10),
          Row(
            children: [
              CustomText(
                text: 'Drop Off Date: ',
                size: 13,
                textcolor: isDark ? Colors.grey.shade300 : null,
              ),
              Text(
                DateFormat('MMM dd, yyyy').format(date),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Amount :'),
              Text(
                "\$ ${item.amount.toStringAsFixed(2)}",
                style: TextStyle(
                  fontSize: 16,
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
        return const Color.fromARGB(255, 199, 88, 23);
      case "draft":
        return const Color.fromARGB(255, 55, 158, 226);
      case "returned":
        return const Color.fromARGB(255, 168, 4, 4);
      default:
        return Colors.white;
    }
  }
}
