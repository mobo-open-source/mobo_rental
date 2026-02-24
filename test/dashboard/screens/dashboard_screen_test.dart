import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mobo_rental/features/dashboard/screens/dashboard_screen.dart';
import 'package:mobo_rental/features/dashboard/providers/dashboard_provider.dart';
import 'package:mobo_rental/features/dashboard/providers/user_provider.dart';
import 'package:mobo_rental/features/profile/providers/profile_provider.dart';
import 'package:mobo_rental/features/customer/providers/customer_provider.dart';
import 'package:mobo_rental/features/dashboard/models/top_customer_model.dart';
import 'package:mobo_rental/features/dashboard/models/recently_created.dart';
import 'package:mobo_rental/features/dashboard/models/recently_cancelled.dart';
import 'package:mobo_rental/features/dashboard/models/recently_returned_product.dart';
import 'package:mobo_rental/features/rental_orders/models/rental_order_item.dart';
import 'package:mobo_rental/features/dashboard/models/todays_pickup_model.dart';
import 'package:mobo_rental/features/dashboard/models/todya_dropoff_moder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockCustomerProvider extends ChangeNotifier implements CustomerProvider {
  @override bool get isAdmin => true;
  @override bool get canViewCustomerDetails => true;
  @override bool get permissionsLoaded => true;
  @override List<dynamic> get customers => [];
  @override int get activeFiltersCount => 0;
  @override int get startRecord => 0;
  @override int get endRecord => 0;
  @override int get totalCount => 0;
  @override bool get hasPreviousPage => false;
  @override bool get hasNextPage => false;
  @override bool get isGrouped => false;
  @override Map<String, int> get groupSummary => {};
  @override Map<String, List<dynamic>> get loadedGroups => {};
  @override bool get showActiveOnly => true;
  @override bool get showCompaniesOnly => false;
  @override bool get showIndividualsOnly => false;
  @override bool get showCreditBreachesOnly => false;
  @override DateTime? get startDate => null;
  @override DateTime? get endDate => null;
  @override String? get selectedGroupBy => null;
  @override String get currentSearchQuery => '';
  @override bool get isLoading => false;
  @override String? get error => null;
  @override int get currentOffset => 0;
  @override int get limit => 40;
  @override Map<String, String> get groupByOptions => {};
  @override Future<void> loadCustomers({int offset = 0, String search = ''}) async {}
  @override Future<void> fetchGroupByOptions() async {}
  @override Future<void> searchCustomers(String query) async {}
  @override Future<void> loadPermissions() async {}
  @override Future<void> clearData() async {}
  @override void setFilterState({bool? showActiveOnly, bool? showCompaniesOnly, bool? showIndividualsOnly, DateTime? startDate, DateTime? endDate}) {}
  @override void clearFilters() {}
  @override void setGroupBy(String? groupBy) {}
  @override Future<void> loadGroupContacts(String groupKey) async {}
  @override Future<void> goToNextPage() async {}
  @override Future<void> goToPreviousPage() async {}
  @override Future<Map<String, dynamic>?> getCustomerDetails(int partnerId) async => null;
  @override Future<List<Map<String, dynamic>>> getCountries() async => [];
  @override Future<List<Map<String, dynamic>>> getStatesByCountry(int countryId) async => [];
  @override Future<List<dynamic>> getTitleOptions() async => [];
  @override Future<List<Map<String, dynamic>>> getCurrencies() async => [];
  @override Future<List<Map<String, dynamic>>> getLanguages() async => [];
  @override Future<int> createCustomer(Map<String, dynamic> customerData) async => 0;
  @override Future<bool> updateCustomer(int id, Map<String, dynamic> customerData) async => true;
  @override Future<Map<String, dynamic>> getCustomerStats(int partnerId) async => {};
  @override Future<Map<String, List<dynamic>>> fetchDropdownOptions() async => {};
  @override Future<List<Map<String, dynamic>>> fetchStates(int countryId) async => [];
  @override Future<bool> archiveCustomer(int customerId) async => true;
  @override Future<bool> deleteCustomer(int customerId) async => true;
  @override Future<bool> geoLocalizeCustomer(int customerId) async => true;
}

class MockDashboardProvider extends ChangeNotifier implements DashboardProvider {
  @override double finalTotal = 1250.50;
  @override double upcomingReturns = 5;
  @override int overDueRental = 2;
  @override int rentableProductsCount = 45;
  @override bool isRentalOrderLoading = false;
  @override bool isProductLoading = false;
  @override int todaysPickupCount = 3;
  @override int todaysDropOffCount = 1;
  @override bool todaysPickupCountLoading = false;
  @override bool todyasDropOffCountLoading = false;
  @override int activeCustomerCount = 10;
  @override bool activeCustomersLoading = false;
  @override int overdueCustomerCount = 2;
  @override bool overdueCustomersLoading = false;
  @override bool topCustomersLoading = false;
  @override List<TopCustomerItem> topRentalCustomers = [];
  @override bool isInitialized = true;
  @override List<RecentlyCreatedRentalOrderItem> recentlyCreatedRentalOrders = [];
  @override List<RecentlyCancelledRentalOrderItem> recentlyCancelledRentalOrders = [];
  @override List<ReturnedProductItem> recentlyReturnedProducts = [];
  @override bool fetchingRecentlyCreated = false;
  @override bool fetchingRecentlyCancelled = false;
  @override bool fetchingRecentlyReturned = false;
  @override List<RentalOrderItem> rentalOrders = [];
  @override List<TodaysPickUpItem> todaysPickupItem = [];
  @override List<TodaysDropOffItem> todaysDroppOffItem = [];
  @override String errorMessage = '';
  @override bool isfetchTodaysPickLoading = false;
  @override bool isfetchTodaysDropLoading = false;
  @override int get pickupCurrentPage => 0;
  @override bool get canGoPreviousPickup => false;
  @override bool get canGoNextPickup => false;
  @override int get pickupStartIndex => 0;
  @override int get pickupEndIndex => 0;
  @override int get dropOffCurrentPage => 0;
  @override bool get canGoPreviousDropOff => false;
  @override bool get canGoNextDropOff => false;
  @override int get dropOffStartIndex => 0;
  @override int get dropOffEndIndex => 0;
  @override Future<void> nextPickupPage() async {}
  @override Future<void> previousPickupPage() async {}
  @override Future<void> nextDropOffPage() async {}
  @override Future<void> previousDropOffPage() async {}
  @override Future<void> dashboardCompanySwitch() async {}
  @override Future<void> fetchRentalOrders({int? currentCompanyId, bool isRetry = false}) async {}
  @override Future<void> fetchTotalProducts() async {}
  @override Future<void> fetchTodaysPickupCount() async {}
  @override Future<void> fetchTodaysDropOffCount() async {}
  @override Future<void> fetchActiveCustomersCount() async {}
  @override Future<void> fetchCustomersWithOverduesCount() async {}
  @override Future<void> fetchTopRentalCustomers({int limit = 5}) async {}
  @override Future<void> fetchRecentlyCreatedRentalOrders({int limit = 1}) async {}
  @override Future<void> fetchRecentlyReturnedProducts({int limit = 1}) async {}
  @override Future<void> fetchRecentlyCancelledRentalOrders({int limit = 40}) async {}
  @override void markAsInitialized() {}
  @override void clearAll() {}
  @override Future<void> fetchTodaysPickup({bool resetPage = false}) async {}
  @override Future<void> fetchTodaysDropOff({bool resetPage = false}) async {}
  @override void markAsUninitialized() {} // Added if exists in actual provider
  @override dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockUserProvider extends ChangeNotifier implements UserProvider {
  @override String? userName = 'Test';
  @override String? userImage;
  @override bool userInfoLoading = false;
  @override int? userId = 1;
  @override String getGreeting() => 'Good Morning';
  @override Future<void> getCurrentUserDetails(BuildContext context) async {}
  @override void resetUser() {}
}

class MockProfileProvider extends ChangeNotifier implements ProfileProvider {
  @override bool get isLoading => false;
  @override Map<String, dynamic>? get userData => {'name': 'Test'};
  @override String? get error => null;
  @override bool get hasInternet => true;
  @override Future<void> fetchUserProfile({bool forceRefresh = false}) async {}
  @override dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget createWidgetUnderTest({
    required MockDashboardProvider dashboardProvider,
    required MockUserProvider userProvider,
    required MockProfileProvider profileProvider,
    required MockCustomerProvider customerProvider,
  }) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<DashboardProvider>.value(value: dashboardProvider),
        ChangeNotifierProvider<UserProvider>.value(value: userProvider),
        ChangeNotifierProvider<ProfileProvider>.value(value: profileProvider),
        ChangeNotifierProvider<CustomerProvider>.value(value: customerProvider),
      ],
      child: MaterialApp(
        home: const DashboardScreen(),
      ),
    );
  }

  testWidgets('DashboardScreen renders correctly', (WidgetTester tester) async {
    // Set a larger surface size to avoid RenderFlex overflow during tests
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    
    // Reset the size after the test
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final dashboardProvider = MockDashboardProvider();
    final userProvider = MockUserProvider();
    final profileProvider = MockProfileProvider();
    final customerProvider = MockCustomerProvider();

    await tester.pumpWidget(createWidgetUnderTest(
      dashboardProvider: dashboardProvider,
      userProvider: userProvider,
      profileProvider: profileProvider,
      customerProvider: customerProvider,
    ));
    
    await tester.pump();

    // Verify some text exists to ensure it rendered
    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.textContaining('Test'), findsWidgets);
    expect(find.textContaining('Revenue'), findsWidgets);
  });
}
