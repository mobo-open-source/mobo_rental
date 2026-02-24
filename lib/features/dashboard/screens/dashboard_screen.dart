import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobo_rental/features/customer/providers/customer_provider.dart';
import 'package:mobo_rental/features/dashboard/widgets/dashboard_title.dart';
import 'package:mobo_rental/features/dashboard/widgets/recent_activity.dart';
import 'package:mobo_rental/features/dashboard/widgets/top_customer.dart';
import 'package:mobo_rental/features/profile/providers/profile_provider.dart';
import 'package:mobo_rental/features/dashboard/providers/dashboard_provider.dart';
import 'package:mobo_rental/features/dashboard/providers/user_provider.dart';
import 'package:mobo_rental/features/dashboard/screens/todays_droppoff.dart';
import 'package:mobo_rental/features/dashboard/screens/todays_pickup.dart';
import 'package:mobo_rental/features/dashboard/widgets/dashboard_container.dart';
import 'package:mobo_rental/features/dashboard/widgets/dashboard_main_cards.dart';
import 'package:provider/provider.dart';

import '../widgets/dashboard_greeting_card.dart';
import '../../../shared/widgets/odoo_avatar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    _checkAndLoadData();
    super.initState();
  }

  void _checkAndLoadData() {
    final dashboardProvider = context.read<DashboardProvider>();

    if (!dashboardProvider.isInitialized) {

      _refreshData();
    } else {}
  }

  void _refreshData() {
    final dashboardProvider = context.read<DashboardProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().getCurrentUserDetails(context);
      context.read<ProfileProvider>().fetchUserProfile(forceRefresh: true);
      context.read<DashboardProvider>().fetchCustomersWithOverduesCount();
      context.read<DashboardProvider>().fetchActiveCustomersCount();

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      context.read<DashboardProvider>().fetchRentalOrders();
      context.read<DashboardProvider>().fetchTotalProducts();
      userProvider.getCurrentUserDetails(context);
      context.read<DashboardProvider>().fetchTodaysDropOffCount();
      context.read<DashboardProvider>().fetchTodaysPickupCount();


      context.read<DashboardProvider>().fetchTopRentalCustomers();

      ///
      context.read<DashboardProvider>().fetchRecentlyCreatedRentalOrders();
      context.read<DashboardProvider>().fetchRecentlyReturnedProducts();
      context.read<DashboardProvider>().fetchRecentlyCancelledRentalOrders();
      dashboardProvider.markAsInitialized();
    });
  }

  void _refreshDashboardData() {
    final dashboardProvider = Provider.of<DashboardProvider>(
      context,
      listen: false,
    );

    dashboardProvider.clearAll();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final rentalProvider = Provider.of<DashboardProvider>(context);
    final revenueFormat = rentalProvider..finalTotal.toStringAsFixed(2);
    final customerProvider = context.watch<CustomerProvider>();
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<UserProvider>().getCurrentUserDetails(context);
          context.read<ProfileProvider>().fetchUserProfile(forceRefresh: true);

          final dashboardProv = context.read<DashboardProvider>();
          await Future.wait([
            dashboardProv.fetchRentalOrders(),
            dashboardProv.fetchTotalProducts(),
            dashboardProv.fetchTodaysDropOff(),
            dashboardProv.fetchTodaysPickup(),
            dashboardProv.fetchCustomersWithOverduesCount(),
            dashboardProv.fetchActiveCustomersCount(),
            dashboardProv.fetchTopRentalCustomers(),
            dashboardProv.fetchRecentlyCreatedRentalOrders(),
            dashboardProv.fetchRecentlyReturnedProducts(),
            dashboardProv.fetchRecentlyCancelledRentalOrders(),
          ]);
        },
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Consumer<UserProvider>(
                  builder: (context, userProv, _) {
                    return DashboardGreetingCard(
                      isLoading: userProv.userInfoLoading,
                      userName: userProv.userName,
                      userAvatarWidget: OdooAvatar(
                        imageBase64: userProv.userImage,
                        size: 56,
                        iconSize: 28,
                        borderRadius: BorderRadius.circular(28),
                      ),
                    );
                  },
                ),

                SizedBox(
                  height: 180,

                  child: ListView(
                    physics: AlwaysScrollableScrollPhysics(),
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    children: [
                      analyticCardWidget(
                        isdark: isDark,
                        isLoading: rentalProvider.isRentalOrderLoading,
                        amount:
                            '\$ ${rentalProvider.finalTotal.toStringAsFixed(2)}',
                        title: 'Total Revenue',
                        dollar: true,
                        sub: 'Total revenue',
                        color: Colors.green,
                      ),
                      analyticCardWidget(
                        isLoading: rentalProvider.isRentalOrderLoading,
                        isdark: isDark,
                        amount: rentalProvider.upcomingReturns.toStringAsFixed(
                          0,
                        ),
                        title: 'Upcoming Returns ',
                        dollar: true,
                        sub: 'Total upcoming returns',
                        color: Colors.blue,
                      ),
                      analyticCardWidget(
                        isLoading: rentalProvider.isRentalOrderLoading,
                        isdark: isDark,
                        amount: rentalProvider.overDueRental.toString(),
                        title: 'Overdue Rentals',
                        dollar: true,
                        sub: 'Total Overdue Rentals',
                        color: Colors.red,
                      ),
                      analyticCardWidget(
                        isLoading: rentalProvider.isProductLoading,
                        isdark: isDark,
                        amount: rentalProvider.rentableProductsCount.toString(),
                        title: 'Products',
                        dollar: true,
                        sub: 'Total Products Available',
                        color: Colors.purple,
                      ),
                    ],
                  ),
                ),
                DashbordTitle(dashboard: 'Today’s Activities', isdark: isDark),
                GridView(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    childAspectRatio: 1.2,
                  ),
                  children: [
                    dashBordMainCard(
                      ctx: context,
                      isLoading: rentalProvider.todaysPickupCountLoading,
                      title: 'Today\'s Pickup ',
                      amount: rentalProvider.todaysPickupCount.toString(),
                      subtitle: 'Track todays\npickup items',
                      icon: HugeIcon(
                        icon: HugeIcons.strokeRoundedPickup01,
                        color: Colors.green,
                      ),
                      bgColor: Colors.green.withAlpha(100),
                      ontap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => TodaysPickup()),
                        );
                      },
                      isdark: isDark,
                    ),
                    dashBordMainCard(
                      isdark: isDark,
                      ctx: context,
                      isLoading: rentalProvider.todyasDropOffCountLoading,

                      title: 'Today\'s DropOff ',
                      amount: rentalProvider.todaysDropOffCount.toString(),
                      subtitle: 'Track todays\ndrop off items',
                      icon: HugeIcon(
                        icon: HugeIcons.strokeRoundedDeliveredSent,
                        color: Color.fromARGB(255, 20, 109, 211),
                      ),
                      bgColor: const Color.fromARGB(
                        255,
                        20,
                        109,
                        211,
                      ).withAlpha(100),
                      ontap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => TodaysDroppoff()),
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(height: 10),
                DashbordTitle(dashboard: 'Customer Insights', isdark: isDark),
                GridView(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    childAspectRatio: 1.2,
                  ),
                  children: [
                    dashBordMainCard(
                      isdark: isDark,
                      ctx: context,
                      isLoading: rentalProvider.activeCustomersLoading,
                      title: 'Active Customers',
                      amount: rentalProvider.activeCustomerCount.toString(),
                      subtitle: 'Customers with\nongoing rentals',
                      icon: HugeIcon(
                        icon: HugeIcons.strokeRoundedUser,
                        color: const Color.fromARGB(255, 175, 140, 76),
                      ),
                      bgColor: const Color.fromARGB(
                        255,
                        175,
                        140,
                        76,
                      ).withAlpha(100),
                      ontap: () {},
                    ),
                    dashBordMainCard(
                      isdark: isDark,
                      ctx: context,
                      isLoading: rentalProvider.overdueCustomersLoading,

                      title: 'Overdues Customers',
                      amount: rentalProvider.overdueCustomerCount.toString(),
                      subtitle: 'Customers with\nOverdues',
                      icon: HugeIcon(
                        icon: HugeIcons.strokeRoundedAlertDiamond,
                        color: const Color.fromARGB(255, 175, 76, 76),
                      ),
                      bgColor: const Color.fromARGB(
                        255,
                        175,
                        76,
                        76,
                      ).withAlpha(100),
                      ontap: () {},
                    ),
                  ],
                ),
                SizedBox(height: 5),
                //     ?
                DashbordTitle(dashboard: 'Top Customers', isdark: isDark),
                // : SizedBox.shrink(),

                //     ?
                TopCustomersListTile(
                  isLoading: rentalProvider.topCustomersLoading,
                  customers: rentalProvider.topRentalCustomers,
                  isdark: isDark,
                ),
                // : SizedBox.shrink(),
                SizedBox(height: 5),
                DashbordTitle(dashboard: 'Recent Activity', isdark: isDark),
                RecentActivitySection(isDark: isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
