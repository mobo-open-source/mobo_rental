import 'package:flutter/material.dart';
import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobo_rental/Core/Widgets/common/snack_bar.dart';
import 'package:mobo_rental/Core/Widgets/common/text_styles.dart';
import 'package:mobo_rental/features/customer/providers/customer_provider.dart';
import 'package:mobo_rental/features/dashboard/providers/dashboard_provider.dart';
import 'package:mobo_rental/features/dashboard/providers/user_provider.dart';

import 'package:mobo_rental/features/company/providers/company_provider.dart';
import 'package:mobo_rental/features/company/widgets/company_selector_widget.dart';
import 'package:mobo_rental/features/profile/pages/profile_screen.dart';
import 'package:mobo_rental/features/profile/providers/profile_provider.dart';
import 'package:mobo_rental/features/products/provider/product_provider.dart';
import 'package:mobo_rental/features/home/provider/navigation_provider.dart';
import 'package:mobo_rental/features/customer/screens/customer_screen.dart';
import 'package:mobo_rental/features/dashboard/screens/dashboard_screen.dart';
import 'package:mobo_rental/features/products/screen/products_screen.dart';
import 'package:mobo_rental/features/rental_orders/providers/rental_order_provider.dart';
import 'package:mobo_rental/features/rental_orders/screens/rental_orders_screen.dart';
import 'package:mobo_rental/features/routing/page_transition.dart';
import 'package:mobo_rental/features/schedule_rental/provider/rental_schedule_provider.dart';
import 'package:mobo_rental/features/schedule_rental/screens/scheduled_rental.dart';
import 'package:mobo_rental/features/home/widgets/floating_action_widgets.dart';
import 'package:mobo_rental/Core/Widgets/common/textfrom.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../Core/services/review_service.dart';
import '../../../shared/widgets/odoo_avatar.dart';

class HomeScreen extends StatefulWidget {
  final int initialIndex;
  final bool isTest;
  const HomeScreen({
    super.key,
    required this.initialIndex,
    this.isTest = false,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static final List<Widget> mainScreens = [
    DashboardScreen(),
    RentalOrdersScreen(),
    ProductsScreen(),
    CustomersScreen(),
    ScheduledRental(),
  ];
  static const List<String> appBarTitles = [
    'Dashboard',
    'Rental Orders',
    'Products',
    'Customers',
    'Scheduled Rentals',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.isTest) {
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<NavigationProvider>().updateMainScreen(
          widget.initialIndex,
        );
        context.read<UserProvider>().getCurrentUserDetails(context);
        context.read<CompanyProvider>().refreshCompaniesList();
        context.read<CompanyProvider>().initialize();

        // Track app open for review system after the UI is stable
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            ReviewService().trackAppOpen(context);
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomNavProvider = Provider.of<NavigationProvider>(context);
    int index = bottomNavProvider.index;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark
            ? Colors.grey[900]
            : Theme.of(context).colorScheme.secondary,
        automaticallyImplyLeading: false,
        title: Text(
          appBarTitles[index],
          style: CommonTextStyles().appBarStyle.copyWith(
            color: isDark
                ? Theme.of(context).colorScheme.secondary
                : Colors.black,
          ),
        ),
        actionsPadding: const EdgeInsets.only(right: 10),
        actions: widget.isTest ? const [] : _buildProfileActions(context),
        elevation: 0,
      ),
      body: widget.isTest ? const SizedBox() : mainScreens[index],
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(top: 0, left: 5, right: 5),
        child: SnakeNavigationBar.color(
          backgroundColor: isDark
              ? Colors.grey[900]!
              : Theme.of(context).colorScheme.secondary,
          unselectedItemColor: isDark ? Colors.grey[400]! : Colors.black,
          selectedItemColor: isDark
              ? Theme.of(context).colorScheme.secondary
              : Theme.of(context).primaryColor,
          snakeViewColor: Theme.of(context).primaryColor,
          showSelectedLabels: true,

          currentIndex: bottomNavProvider.index,
          showUnselectedLabels: true,
          onTap: (index) => bottomNavProvider.updateMainScreen(index),
          snakeShape: SnakeShape.indicator,
          selectedLabelStyle: textStyle.copyWith(
            color: isDark ? Colors.white : null,
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
          height: 60,
          unselectedLabelStyle: GoogleFonts.montserrat(
            fontSize: 11,
            color: isDark ? Colors.grey[400] : Colors.black,
          ),
          items: [
            BottomNavigationBarItem(
              icon: HugeIcon(icon: HugeIcons.strokeRoundedDashboardSquare02),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: HugeIcon(icon: HugeIcons.strokeRoundedFiles01),
              label: 'Orders',
            ),
            BottomNavigationBarItem(
              icon: HugeIcon(icon: HugeIcons.strokeRoundedPackageOpen),
              label: 'Products',
            ),
            BottomNavigationBarItem(
              icon: HugeIcon(icon: HugeIcons.strokeRoundedContactBook),
              label: 'Customers',
            ),
            BottomNavigationBarItem(
              icon: HugeIcon(icon: HugeIcons.strokeRoundedDateTime),
              label: 'Schedule',
            ),
          ],
        ),
      ),
      // floatingActionButton: buildFab(bottomNavProvider.index),
    );
  }

  List<Widget> _buildProfileActions(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return [
      CompanySelectorWidget(
        onCompanyChanged: () async {
          if (!mounted) return;
          final navigationProvider = context.read<NavigationProvider>();

          final provider = context.read<CompanyProvider>();
          final companyName =
              provider.selectedCompany?['name']?.toString() ?? 'company';

          await context.read<ProfileProvider>().fetchUserProfile(
            forceRefresh: true,
          );

          await context.read<DashboardProvider>().dashboardCompanySwitch();
          await context.read<RentalOrderProvider>().searchRentalOrders(
            context,
            searchQuery: null,
          );
          context.read<CustomerProvider>().loadCustomers();
          context
              .read<RentalScheduleProvider>()
              .scheduleScreenCompanySwitch(context);
          context.read<ProductProvider>().loadProducts();
          CustomSnackbar.showSuccess(context, 'Switched to $companyName');
        },
      ),
      Container(
        margin: const EdgeInsets.only(right: 8),
        child: Consumer<ProfileProvider>(
          builder: (context, profileProvider, child) {
            final userAvatar = profileProvider.userAvatar;
            final isLoading = profileProvider.isLoading && userAvatar == null;

            return IconButton(
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: isLoading
                    ? SizedBox(
                        key: const ValueKey('avatar_loading'),
                        width: 32,
                        height: 32,
                        child: Shimmer.fromColors(
                          baseColor: isDark
                              ? Colors.grey[700]!
                              : Colors.grey[300]!,
                          highlightColor: isDark
                              ? Colors.grey[600]!
                              : Colors.grey[200]!,
                          child: Container(
                            decoration: BoxDecoration(
                              color: isDark ? Colors.grey[800] : Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      )
                    : SizedBox(
                        key: const ValueKey('avatar_with_image'),
                        width: 32,
                        height: 32,
                        child: ClipOval(
                          child: OdooAvatar(
                            imageBase64: profileProvider.userData?['image_1920']
                                ?.toString(),
                            size: 32,
                            iconSize: 18,
                            placeholderColor: isDark
                                ? Colors.grey[800]
                                : Colors.grey[300],
                            iconColor: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  dynamicRoute(context, const ProfileScreen()),
                ).then((_) {
                  // Refresh profile data after returning from profile screen
                  if (mounted) {
                    context.read<ProfileProvider>().fetchUserProfile(
                      forceRefresh: true,
                    );
                  }
                });
              },
            );
          },
        ),
      ),
    ];
  }

  Widget buildFab(int index) {
    switch (index) {
      case 1:
        return ordersFab(context);

      default:
        return SizedBox.shrink();
    }
  }
}
