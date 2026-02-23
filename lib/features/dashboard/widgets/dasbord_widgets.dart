import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobo_rental/features/rental_orders/models/rental_order_item.dart';
import 'package:mobo_rental/features/dashboard/models/todays_pickup_model.dart';
import 'package:mobo_rental/Core/Widgets/common/textfrom.dart';

class DashboardCard extends StatelessWidget {
  final RentalOrderItem item;

  const DashboardCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, 3),
            blurRadius: 6,
            spreadRadius: 1,
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
                textcolor: const Color.fromARGB(255, 153, 4, 4),
                size: 18,
              ),

              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 6,
                  horizontal: 14,
                ),
                decoration: BoxDecoration(
                  color: _statusColor(item.status).withAlpha(100),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _state(item.status),
                  style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(item.customer, style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 10),
          Row(
            children: [
              HugeIcon(icon: HugeIcons.strokeRoundedCalendar03),
              Text(
                item.startDate,
                style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
              ),
            ],
          ),

          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              "\$ ${item.amount.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
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

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case "sale":
        return const Color.fromARGB(255, 175, 120, 76);
      case "pickup":
        return const Color.fromARGB(255, 91, 156, 7);
      case "cancel":
        return const Color.fromARGB(255, 185, 185, 185);
      case "returned":
        return const Color.fromARGB(255, 185, 185, 185);
      case "draft":
        return const Color.fromARGB(255, 3, 94, 155);
      default:
        return Colors.white;
    }
  }
}
