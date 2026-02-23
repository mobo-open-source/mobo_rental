import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobo_rental/features/rental_orders/providers/rental_order_provider.dart';
import 'package:mobo_rental/features/rental_orders/widgets/filters.dart';

class SearchAndPaginationBar extends StatelessWidget {
  final RentalOrderProvider rentalProvider;
  final VoidCallback onOpenFilter;
  final bool isdark;

  const SearchAndPaginationBar({
    super.key,
    required this.rentalProvider,
    required this.onOpenFilter,
    required this.isdark,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isdark
          ? Colors.grey[900]
          : Theme.of(context).colorScheme.secondary,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: isdark ? Colors.grey[850] : Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: isdark
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(.05),
                          offset: const Offset(0, 6),
                          blurRadius: 16,
                          spreadRadius: 2
                        ),
                      ],
              ),
              child: TextField(
                textAlignVertical: TextAlignVertical.center,
                style: TextStyle(color: isdark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  hintText: 'Search by rental ID or customer...',
                  hintStyle: TextStyle(
                    color: isdark ? Colors.grey[400] : Colors.grey.shade700,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  prefixIconConstraints: const BoxConstraints(minWidth: 45),
                  prefixIcon: InkWell(
                    onTap: onOpenFilter,
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedFilterHorizontal,
                      color: isdark ? Colors.grey[400] : Colors.grey.shade500,
                      size: 18,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 13),
                ),
                onChanged: (value) {
                  rentalProvider.searchRentalOrders(
                    context,
                    searchQuery: value,
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                rentalProvider.appliedFilters.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          'No filters applied',
                          style: TextStyle(
                            fontSize: 12,
                            color: isdark
                                ? Colors.white70
                                : Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    : ActivefilterBadge(
                        isdark: isdark,
                        rentalProvider: rentalProvider,
                      ),
                paginationWidget(context, rentalProvider),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ActivefilterBadge extends StatelessWidget {
  const ActivefilterBadge({
    super.key,
    required this.isdark,
    required this.rentalProvider,
  });

  final bool isdark;
  final RentalOrderProvider rentalProvider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isdark ? Colors.white70 : Colors.black,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          //   icon: HugeIcons.strokeRoundedFilterHorizontal,
          //   size: 14,
          //   color: Colors.white,
          // ),
          Text(
            '${rentalProvider.appliedFilters.length} Active',
            style: TextStyle(
              fontSize: 12,
              color: isdark ? Colors.black : Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

//     required this.count,
//     required this.theme,
//   });

//   Widget build(BuildContext context) {

//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: isDark ? Colors.white70 : Colors.black,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//             size: 14,
//             color: Colors.white,
//           ),
//             '$count active',
            // style: TextStyle(
            //   fontSize: 12,
            //   color: isDark ? Colors.black : Colors.white,
            //   fontWeight: FontWeight.w500,
            // ),
//           ),
//         ],
//       ),
