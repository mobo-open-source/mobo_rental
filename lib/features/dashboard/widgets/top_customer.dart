import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobo_rental/features/dashboard/models/top_customer_model.dart';
import 'package:shimmer/shimmer.dart';
import '../../../shared/widgets/odoo_avatar.dart';

class TopCustomersListTile extends StatelessWidget {
  final bool isLoading;
  final bool isdark;
  final List<TopCustomerItem> customers;

  const TopCustomersListTile({
    super.key,
    required this.isLoading,
    required this.isdark,
    required this.customers,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isdark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: isdark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 5,
                  spreadRadius: 3,
                  offset: Offset(1, 2),
                ),
              ],
      ),
      child: isLoading
          ? _buildShimmer()
          : customers.isEmpty
          ? dashbordErrorState(
              isdark: isdark,
              message: 'No rental customers available\nwith confirmed orders',
            )
          : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: customers.length,
              separatorBuilder: (_, __) => const SizedBox.shrink(),
              itemBuilder: (context, index) {
                final customer = customers[index];

                return ListTile(
                  dense: true,
                  leading: OdooAvatar(
                    imageBase64:
                        customer.avatarBase64 ??
                        (customer.avatarBytes != null
                            ? base64Encode(customer.avatarBytes!)
                            : null),
                    size: 36,
                    iconSize: 18,
                    placeholderColor: isdark
                        ? Colors.grey[700]
                        : Colors.grey[100],
                    iconColor: isdark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  title: Text(
                    customer.customerName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isdark ? Colors.white : Colors.black,
                    ),
                  ),
                  subtitle: Text(
                    'Rentals',
                    style: TextStyle(
                      fontSize: 12,
                      color: isdark ? Colors.grey[500] : Colors.black54,
                    ),
                  ),
                  trailing: Text(
                    customer.rentalCount.toString(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isdark ? Colors.white : Colors.black,
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildShimmer() {
    final Color baseColor = isdark ? Colors.grey[850]! : Colors.grey.shade300;
    final Color highlightColor = isdark
        ? Colors.grey[600]!
        : Colors.grey.shade100;
    final Color blockColor = isdark ? Colors.grey[800]! : Colors.white;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      itemBuilder: (_, __) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: Row(
              children: [
                CircleAvatar(radius: 18, backgroundColor: blockColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 12,
                        width: double.infinity,
                        color: blockColor,
                      ),
                      const SizedBox(height: 6),
                      Container(height: 10, width: 80, color: blockColor),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(height: 14, width: 24, color: blockColor),
              ],
            ),
          ),
        );
      },
    );
  }
}

class dashbordErrorState extends StatelessWidget {
  final String message;
  const dashbordErrorState({
    super.key,
    required this.isdark,
    required this.message,
  });

  final bool isdark;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          HugeIcon(
            icon: HugeIcons.strokeRoundedAlert01,
            color: isdark ? Colors.grey[400] : Colors.black54,
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isdark ? Colors.grey[400] : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
