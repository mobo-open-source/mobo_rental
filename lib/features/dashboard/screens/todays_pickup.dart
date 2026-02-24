import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobo_rental/features/dashboard/providers/dashboard_provider.dart';
import 'package:mobo_rental/features/dashboard/screens/todays_droppoff.dart';
import 'package:mobo_rental/features/dashboard/widgets/pagination_controllers.dart';
import 'package:mobo_rental/features/dashboard/widgets/todays_pickup_card.dart';
import 'package:mobo_rental/Core/Widgets/common/text_styles.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class TodaysPickup extends StatefulWidget {
  const TodaysPickup({super.key});

  @override
  State<TodaysPickup> createState() => _TodaysPickupState();
}

class _TodaysPickupState extends State<TodaysPickup> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().fetchTodaysPickup(resetPage: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark
            ? Colors.grey[900]
            : Theme.of(context).colorScheme.secondary,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: HugeIcon(
            size: 30,
            icon: HugeIcons.strokeRoundedArrowLeft01,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        title: Text(
          'Today\'s Pickup',
          style: CommonTextStyles().appBarStyle.copyWith(
            color: isDark
                ? Theme.of(context).colorScheme.secondary
                : Colors.black,
          ),
        ),
      ),
      body: Consumer<DashboardProvider>(
        builder: (context, provider, child) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                if (!provider.isfetchTodaysPickLoading &&
                    provider.todaysPickupItem.isNotEmpty)
                  PaginationControlsDashboard(
                    startIndex: provider.pickupStartIndex,
                    endIndex: provider.pickupEndIndex,
                    totalCount: provider.todaysPickupCount,
                    canGoNext: provider.canGoNextPickup,
                    canGoPrevious: provider.canGoPreviousPickup,
                    onNext: () => provider.nextPickupPage(),
                    onPrevious: () => provider.previousPickupPage(),
                  ),

                if (!provider.isfetchTodaysPickLoading &&
                    provider.todaysPickupItem.isNotEmpty)
                  const SizedBox(height: 10),

                Expanded(
                  child: provider.isfetchTodaysPickLoading
                      ? ListView.builder(
                          padding: const EdgeInsets.only(bottom: 20),
                          itemCount: 6,
                          itemBuilder: (context, index) =>
                              shimmerDropOffCard(isDark: isDark),
                        )
                      : provider.todaysPickupItem.isNotEmpty
                      ? ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 20),
                          itemCount: provider.todaysPickupItem.length,
                          itemBuilder: (context, index) {
                            return TodaysPickupCard(
                              item: provider.todaysPickupItem[index],
                            );
                          },
                        )
                      : NoDataState(
                          title: 'No Pickups for Today.....!',
                          messgae: 'Please Come again tommorrow',
                          icon: [],
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget shimmerDropOffCard({required bool isDark}) {
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;
    final containerColor = isDark ? Colors.grey[850]! : Colors.white;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black12,
              offset: Offset(0, 3),
              blurRadius: 6,
              spreadRadius: 1,
            ),
        ],
      ),
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 100,
                  height: 20,
                  decoration: BoxDecoration(
                    color: baseColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const Spacer(),
                Container(
                  width: 60,
                  height: 20,
                  decoration: BoxDecoration(
                    color: baseColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: 200,
              height: 16,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: baseColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 120,
                  height: 16,
                  decoration: BoxDecoration(
                    color: baseColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              width: 80,
              height: 16,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
