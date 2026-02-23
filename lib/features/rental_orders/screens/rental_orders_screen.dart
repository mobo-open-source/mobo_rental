import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobo_rental/shared/widgets/empty_state.dart';
import 'package:mobo_rental/features/home/widgets/floating_action_widgets.dart';
import 'package:mobo_rental/features/products/widgets/permission_error_view.dart';
import 'package:mobo_rental/features/rental_orders/providers/rental_order_provider.dart';
import 'package:mobo_rental/features/dashboard/providers/dashboard_provider.dart';
import 'package:mobo_rental/features/rental_orders/widgets/filters.dart';
import 'package:mobo_rental/features/rental_orders/widgets/pagination.dart';
import 'package:mobo_rental/features/rental_orders/widgets/renatl_order_card.dart';
import 'package:mobo_rental/Core/Widgets/common/textfrom.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class RentalOrdersScreen extends StatefulWidget {
  final isTest;

  const RentalOrdersScreen({super.key, this.isTest = false});

  @override
  State<RentalOrdersScreen> createState() => _RentalOrdersScreenState();
}

class _RentalOrdersScreenState extends State<RentalOrdersScreen> {
  String search = '';

  @override
  void initState() {
    final provider = Provider.of<RentalOrderProvider>(context, listen: false);
    // TODO: implement initState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (provider.rentalOrderScreenList.isEmpty) {
        provider.searchRentalOrders(context, searchQuery: null);
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final mediaQuery = MediaQuery.of(context);
    final width = mediaQuery.size.width;
    final height = mediaQuery.size.height;

    return Consumer<RentalOrderProvider>(
      builder: (context, rentalProvider, child) {
        return Scaffold(
          floatingActionButton:
              rentalProvider.error != null ||
                  rentalProvider.isRentalOrderScreenLoading
              ? SizedBox.shrink()
              : ordersFab(context),
          body: Column(
            children: [
              SearchAndPaginationBar(
                rentalProvider: rentalProvider,
                onOpenFilter: () => openFilter(context),
                isdark: isDark,
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await rentalProvider.searchRentalOrders(
                      context,
                      searchQuery: null,
                    );
                  },
                  child: Builder(
                    builder: (context) {
                      if (rentalProvider.isRentalOrderScreenLoading) {
                        return orderCardsShimmer(isdark: isDark);
                      }
                      final isPermissionError =
                          rentalProvider.error != null &&
                          (rentalProvider.error!.toLowerCase().contains(
                                'permission',
                              ) ||
                              rentalProvider.error!.toLowerCase().contains(
                                'access',
                              ));

                      if (isPermissionError) {
                        return ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: height * 0.15),
                              child: PermissionErrorView(
                                title: 'Access Error',
                                message: rentalProvider.error!,
                                onRetry: () {
                                  rentalProvider.searchRentalOrders(
                                    context,
                                    searchQuery: null,
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      } else if (rentalProvider.error != null) {
                        return RefreshIndicator(
                          onRefresh: () async {
                            await rentalProvider.searchRentalOrders(
                              context,
                              searchQuery: null,
                            );
                          },
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              EmptyState(
                                title: "Something Went Wrong!",
                                subtitle:
                                    'Server side is not responding please check',
                                lottieAsset: 'assets/lotties/Error 404.json',
                                onAction: () {
                                  rentalProvider.searchRentalOrders(context, searchQuery: null);
                                },
                                actionLabel: 'Retry',
                              ),
                            ],
                          ),
                        );

                      } else if (rentalProvider.isRentalOrderScreenLoading ==
                              false &&
                          rentalProvider.rentalOrderScreenList.isEmpty) {
                        return ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(
                              height: height * 0.6,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    HugeIcon(
                                      icon: HugeIcons.strokeRoundedDocumentCode,
                                      size: 60,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      'No Order Available',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      'No orders match your search criteria.',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      'Try different keywords',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      } else {
                        return ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 15,
                          ),
                          itemCount:
                              rentalProvider.rentalOrderScreenList.length,
                          itemBuilder: (context, index) {
                            return RentalOrdersCard(
                              item: rentalProvider.rentalOrderScreenList[index],
                              isdark: isDark,
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget orderCardsShimmer({required bool isdark}) {
    final Color baseColor = isdark ? Colors.grey[850]! : Colors.grey.shade300;
    final Color highlightColor = isdark
        ? Colors.grey[600]!
        : Colors.grey.shade100;
    final Color blockColor = isdark ? Colors.grey[800]! : Colors.white;

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
          margin: const EdgeInsets.only(bottom: 10, top: 5),
          decoration: BoxDecoration(
            color: isdark ? Colors.grey[850] : Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: isdark
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withAlpha(30),
                      offset: const Offset(-1, 0),
                      blurRadius: 5,
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
                    Container(width: 120, height: 20, color: blockColor),
                    const Spacer(),
                    Container(width: 80, height: 30, color: blockColor),
                  ],
                ),
                const SizedBox(height: 10),
                Container(width: 180, height: 15, color: blockColor),
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 14, height: 14, color: blockColor),
                    const SizedBox(width: 4),
                    Container(width: 100, height: 15, color: blockColor),
                    const SizedBox(width: 10),
                    Container(width: 14, height: 14, color: blockColor),
                    const SizedBox(width: 4),
                    Container(width: 100, height: 15, color: blockColor),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(width: 80, height: 15, color: blockColor),
                    Container(width: 100, height: 20, color: blockColor),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  openFilter(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final mediaQuery = MediaQuery.of(context);
    final height = mediaQuery.size.height;
    final provider = context.read<DashboardProvider>;
    final rentalProvider = Provider.of<RentalOrderProvider>(
      context,
      listen: false,
    );

    rentalProvider.resetTempFiltersToApplied();

    showModalBottomSheet(
      isDismissible: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      context: context,
      isScrollControlled: true,
      barrierColor: Colors.black38,
      constraints: BoxConstraints.expand(height: height * 0.9),
      builder: (sheetContext) {
        return DefaultTabController(
          length: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomText(
                      text: 'Filter',
                      size: 20,
                      fontweight: FontWeight.bold,
                      textcolor: isDark ? Colors.white : Colors.black,
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E1E1E)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ButtonsTabBar(
                  backgroundColor: Theme.of(context).primaryColor,
                  labelStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  radius: 10,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 65),
                  tabs: const [Tab(text: "Filter")],
                ),
              ),
              Expanded(child: TabBarView(children: [buildFilterView(context)])),
              buildBottomButtons(context),
            ],
          ),
        );
      },
    );
  }

  Widget buildFilterView(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<RentalOrderProvider>(
      builder: (context, provider, child) {
        final List<String> activeStatusFilters = provider.tempFilters
            .where(
              (filterName) => [
                'To Do Today',
                'Late',
                'Quotation',
                'Pickup',
                'Return',
                'Cancelled',
                'My Orders',
              ].contains(filterName),
            )
            .toList();

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (activeStatusFilters.isNotEmpty) ...[
              Text(
                "Active Filters",
                style: TextStyle(
                  color: isDark ? Colors.grey.shade400 : Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: activeStatusFilters.map((filterName) {
                  return activeFilterChip(
                    label: filterName,
                    onTap: () {
                      provider.toggleTempFilter(filterName);
                    },
                    context: context,
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],
            Text(
              "Status",
              style: TextStyle(
                color: isDark ? Colors.grey.shade400 : Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                statusFilterContainer(
                  'To Do Today',
                  isSelected: provider.tempFilters.contains('To Do Today'),
                  ontap: () {
                    provider.toggleTempFilter('To Do Today');
                  },
                  context: context,
                ),
                statusFilterContainer(
                  'Late',
                  isSelected: provider.tempFilters.contains('Late'),
                  ontap: () {
                    provider.toggleTempFilter('Late');
                  },
                  context: context,
                ),
                statusFilterContainer(
                  'Quotation',
                  isSelected: provider.tempFilters.contains('Quotation'),
                  ontap: () {
                    provider.toggleTempFilter('Quotation');
                  },
                  context: context,
                ),
                statusFilterContainer(
                  'Pickup',
                  isSelected: provider.tempFilters.contains('Pickup'),
                  ontap: () {
                    provider.toggleTempFilter('Pickup');
                  },
                  context: context,
                ),
                statusFilterContainer(
                  'Return',
                  isSelected: provider.tempFilters.contains('Return'),
                  ontap: () {
                    provider.toggleTempFilter('Return');
                  },
                  context: context,
                ),
                statusFilterContainer(
                  'Cancelled',
                  isSelected: provider.tempFilters.contains('Cancelled'),
                  ontap: () {
                    provider.toggleTempFilter('Cancelled');
                  },
                  context: context,
                ),
              ],
            ),
            const SizedBox(height: 20),
            CustomText(
              text: "Date Range (Creation Date)",
              textcolor: isDark ? Colors.grey.shade400 : Colors.grey,
              fontweight: FontWeight.w600,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: filterDateField(
                    provider.tempStartDateLabel,
                    () => chooseStartDate(context),
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: filterDateField(
                    provider.tempEndDateLabel,
                    () => chooseEndDate(context),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget activeFilterChip({
    required String label,
    required VoidCallback onTap,
    required BuildContext context,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isDark
              ? Theme.of(context).primaryColor.withAlpha(80)
              : Theme.of(context).primaryColor.withAlpha(40),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Theme.of(context).primaryColor.withAlpha(120),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.close,
              size: 16,
              color: isDark ? Colors.white : Colors.black,
            ),
          ],
        ),
      ),
    );
  }

  Widget filterDateField(String dateText, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final mediaQuery = MediaQuery.of(context);
    final width = mediaQuery.size.width;
    final height = mediaQuery.size.height;
    return InkWell(
      onTap: onTap,
      child: Container(
        width: width * 0.3,
        padding: EdgeInsets.symmetric(horizontal: 9, vertical: 9),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark ? Colors.grey.shade600 : Colors.grey,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: isDark ? Colors.grey.shade400 : Colors.grey,
              size: 18,
            ),
            SizedBox(width: 5),
            Text(
              dateText,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey.shade300 : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> chooseStartDate(BuildContext context) async {
    final provider = Provider.of<RentalOrderProvider>(context, listen: false);

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
            datePickerTheme: DatePickerThemeData(
              dividerColor: Colors.transparent,
              headerBackgroundColor: Theme.of(context).primaryColor,
              headerForegroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      provider.setStartDate(pickedDate);
    }
  }

  Future<void> chooseEndDate(BuildContext context) async {
    final provider = Provider.of<RentalOrderProvider>(context, listen: false);

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Theme.of(context).colorScheme.secondary,
              surface: Theme.of(context).colorScheme.secondary,
              onSurface: Colors.black87,
            ),
            datePickerTheme: DatePickerThemeData(
              dividerColor: Colors.transparent,
              headerBackgroundColor: Theme.of(context).primaryColor,
              headerForegroundColor: Theme.of(context).secondaryHeaderColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      provider.setEndDate(pickedDate);
    }
  }
}
