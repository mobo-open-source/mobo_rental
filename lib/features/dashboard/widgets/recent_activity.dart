import 'package:flutter/material.dart';
import 'package:mobo_rental/features/dashboard/models/recently_created.dart';
import 'package:mobo_rental/features/dashboard/models/recently_cancelled.dart';
import 'package:mobo_rental/features/dashboard/models/recently_returned_product.dart';
import 'package:mobo_rental/features/dashboard/widgets/top_customer.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import 'package:mobo_rental/features/dashboard/providers/dashboard_provider.dart';
import 'package:mobo_rental/features/dashboard/screens/dashboard_screen.dart';

class RecentActivitySection extends StatelessWidget {
  final bool isDark;

  const RecentActivitySection({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = context.watch<DashboardProvider>();

    final backgroundColor = isDark ? Colors.grey[900] : Colors.white;
    final primaryTextColor = isDark ? Colors.white : Colors.black87;
    final secondaryTextColor = isDark ? Colors.white70 : Colors.black54;

    final isLoadingData =
        dashboardProvider.fetchingRecentlyCreated ||
        dashboardProvider.fetchingRecentlyReturned ||
        dashboardProvider.fetchingRecentlyCancelled;

    final hasNoActivities =
        dashboardProvider.recentlyCreatedRentalOrders.isEmpty &&
        dashboardProvider.recentlyReturnedProducts.isEmpty &&
        dashboardProvider.recentlyCancelledRentalOrders.isEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 5,
            spreadRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isLoadingData)
            _buildShimmerEffect(isDark)
          else if (hasNoActivities)
            dashbordErrorState(
              isdark: isDark,
              message: 'No rental activities available',
            )
          else ...[
            if (dashboardProvider.recentlyCreatedRentalOrders.isNotEmpty)
              _activityTile(
                isDark: isDark,
                child: _createdOrderBlock(
                  title: 'Recently Created Rental Orders',
                  item: dashboardProvider.recentlyCreatedRentalOrders.first,
                  textColor: primaryTextColor,
                  subTextColor: secondaryTextColor,
                ),
              ),

            if (dashboardProvider.recentlyReturnedProducts.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: _activityTile(
                  isDark: isDark,
                  child: _returnedProductBlock(
                    title: 'Recently Returned Products',
                    product: dashboardProvider.recentlyReturnedProducts.first,
                    textColor: primaryTextColor,
                    subTextColor: secondaryTextColor,
                  ),
                ),
              ),

            if (dashboardProvider.recentlyCancelledRentalOrders.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: _activityTile(
                  isDark: isDark,
                  child: _cancelledOrderBlock(
                    title: 'Recently Cancelled Rentals',
                    item: dashboardProvider.recentlyCancelledRentalOrders.first,
                    textColor: primaryTextColor,
                    subTextColor: secondaryTextColor,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _activityTile({required Widget child, required bool isDark}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
        ),
      ),
      child: child,
    );
  }

  Widget _createdOrderBlock({
    required String title,
    required RecentlyCreatedRentalOrderItem item,
    required Color textColor,
    required Color subTextColor,
  }) {
    return _simpleBlock(
      title: title,
      line1: item.orderCode,
      line2: 'Order for ${item.customerName}',
      time: item.createDate,
      textColor: textColor,
      subTextColor: subTextColor,
    );
  }

  Widget _cancelledOrderBlock({
    required String title,
    required RecentlyCancelledRentalOrderItem item,
    required Color textColor,
    required Color subTextColor,
  }) {
    return _simpleBlock(
      title: title,
      line1: item.orderCode,
      line2: 'Order for ${item.customerName}',
      time: item.writeDate,
      textColor: textColor,
      subTextColor: subTextColor,
    );
  }

  Widget _returnedProductBlock({
    required String title,
    required ReturnedProductItem product,
    required Color textColor,
    required Color subTextColor,
  }) {
    return _simpleBlock(
      title: title,
      line1: product.productName,
      line2: 'Returned from ${product.orderCode}',
      time: product.writeDate,
      textColor: textColor,
      subTextColor: subTextColor,
    );
  }

  Widget _simpleBlock({
    required String title,
    required String line1,
    required String line2,
    required DateTime time,
    required Color textColor,
    required Color subTextColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: subTextColor,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    line1,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    line2,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13, color: subTextColor),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _timeAgo(time),
              style: TextStyle(fontSize: 12, color: subTextColor),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildShimmerEffect(bool isDark) {
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: Column(
        children: List.generate(
          3,
          (_) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    // Handle negative differences (future times due to timezone issues)
    if (difference.isNegative) {
      final absDiff = difference.abs();
      if (absDiff.inSeconds < 60) return '-${absDiff.inSeconds}s';
      if (absDiff.inMinutes < 60) return '-${absDiff.inMinutes}m';
      if (absDiff.inHours < 24) return '-${absDiff.inHours}h';
      return '-${absDiff.inDays}d';
    }

    // Handle positive differences (past times)
    if (difference.inSeconds < 30) return 'Just now';
    if (difference.inSeconds < 60) return '${difference.inSeconds}s ago';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }
}
