import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mobo_rental/features/rental_orders/screens/rental_orders_screen.dart';
import 'package:mobo_rental/features/rental_orders/providers/rental_order_provider.dart';
import 'package:mobo_rental/features/dashboard/providers/dashboard_provider.dart';
import 'package:mobo_rental/features/dashboard/providers/user_provider.dart';
import 'package:mobo_rental/features/rental_orders/models/rental_order_item.dart';
import 'package:mobo_rental/features/products/provider/currency_provider.dart';
import 'package:mobo_rental/features/rental_orders/screens/view_rental_order.dart';
import 'package:mobo_rental/features/rental_orders/models/fetched_order_line_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';

class MockRentalOrderProvider extends ChangeNotifier implements RentalOrderProvider {
  @override bool isRentalOrderScreenLoading = false;
  @override List<RentalOrderItem> rentalOrderScreenList = [];
  @override String? error;
  @override int totalCount = 0;
  @override int startIndex = 0;
  @override int endIndex = 0;
  @override bool canGoPrevious = false;
  @override bool canGoNext = false;
  @override Set<String> tempFilters = {};
  @override Set<String> appliedFilters = {};
  @override String tempStartDateLabel = 'Select Start Date';
  @override String tempEndDateLabel = 'Select End Date';
  @override String appliedStartDateLabel = 'Select Start Date';
  @override String appliedEndDateLabel = 'Select End Date';

  Future<void> Function(BuildContext context, {String? searchQuery})? searchRentalOrdersStub;
  Future<void> Function(BuildContext context)? nextPageStub;
  Future<void> Function(BuildContext context)? previousPageStub;

  @override Future<void> searchRentalOrders(BuildContext context, {String? searchQuery}) async {
    if (searchRentalOrdersStub != null) {
      return searchRentalOrdersStub!(context, searchQuery: searchQuery);
    }
  }
  @override void toggleTempFilter(String filter) {}
  @override void applyFilters() {}
  @override void resetTempFiltersToApplied() {}
  @override void clearFilters() {}
  @override void setStartDate(DateTime selectedDate) {}
  @override void setEndDate(DateTime selectedDate) {}
  @override bool isViewOrderLoading = false;
  @override RentalOrderItem? selectedOrder;
  @override List<FetchedOrderLineModel> fetchOrderline = [];
  @override List<FetchedOrderLineModel> orderLines = [];

  Future<void> Function(BuildContext context, int id)? fetchOrderByIdStub;

  @override Future<void> fetchOrderById(BuildContext context, int id) async {
    if (fetchOrderByIdStub != null) {
      return fetchOrderByIdStub!(context, id);
    }
  }

  @override Future<void> confirmOrder(BuildContext context, int id) async {}
  @override Future<void> cancelOrder(BuildContext context, int id) async {}
  @override Future<void> convertToRental(BuildContext context, int id) async {}
  @override Future<void> nextStageOnOrder(BuildContext context, int id, String status) async {}
  @override Future<void> shareRentalOrderViaWhatsapp(BuildContext context, int id) async {}
  @override Future<void> sendRentalOrderByEmail(BuildContext context, int id) async {}
  @override Future<void> downloadQuotationWithDialog(BuildContext context, int id) async {}
  @override Future<void> confirmDeleteOrder(BuildContext context, int id, RentalOrderProvider provider) async {}
  @override Future<void> nextPage(BuildContext context) async {
    if (nextPageStub != null) {
      return nextPageStub!(context);
    }
  }
  @override Future<void> previousPage(BuildContext context) async {
    if (previousPageStub != null) {
      return previousPageStub!(context);
    }
  }
  
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockDashboardProvider extends ChangeNotifier implements DashboardProvider {
  @override bool isInitialized = true;
  @override dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockUserProvider extends ChangeNotifier implements UserProvider {
  @override int? userId = 1;
  @override dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockCurrencyProvider extends ChangeNotifier implements CurrencyProvider {
  @override String get currency => 'USD';
  @override String formatAmount(double amount, {String? currency}) => '\$ ${amount.toStringAsFixed(2)}';
  @override dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget createWidgetUnderTest({
    required MockRentalOrderProvider rentalProvider,
    required MockDashboardProvider dashboardProvider,
    required MockUserProvider userProvider,
    required MockCurrencyProvider currencyProvider,
  }) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<RentalOrderProvider>.value(value: rentalProvider),
        ChangeNotifierProvider<DashboardProvider>.value(value: dashboardProvider),
        ChangeNotifierProvider<UserProvider>.value(value: userProvider),
        ChangeNotifierProvider<CurrencyProvider>.value(value: currencyProvider),
      ],
      child: MaterialApp(
        home: const RentalOrdersScreen(),
      ),
    );
  }

  testWidgets('RentalOrdersScreen shows loading state', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final rentalProvider = MockRentalOrderProvider();
    rentalProvider.isRentalOrderScreenLoading = true;
    final dashboardProvider = MockDashboardProvider();
    final userProvider = MockUserProvider();

    await tester.pumpWidget(createWidgetUnderTest(
      rentalProvider: rentalProvider,
      dashboardProvider: dashboardProvider,
      userProvider: userProvider,
      currencyProvider: MockCurrencyProvider(),
    ));

    expect(find.byType(Shimmer), findsWidgets);
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('RentalOrdersScreen shows empty state', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final rentalProvider = MockRentalOrderProvider();
    rentalProvider.isRentalOrderScreenLoading = false;
    rentalProvider.rentalOrderScreenList = [];
    final dashboardProvider = MockDashboardProvider();
    final userProvider = MockUserProvider();

    await tester.pumpWidget(createWidgetUnderTest(
      rentalProvider: rentalProvider,
      dashboardProvider: dashboardProvider,
      userProvider: userProvider,
      currencyProvider: MockCurrencyProvider(),
    ));
    await tester.pump();

    expect(find.text('No Order Available'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('RentalOrdersScreen shows rental orders list', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final rentalProvider = MockRentalOrderProvider();
    rentalProvider.isRentalOrderScreenLoading = false;
    rentalProvider.rentalOrderScreenList = [
      RentalOrderItem(
        id: 1,
        currencyName: 'USD',
        customerId: 101,
        customer: 'John Doe',
        customerAddress: '123 Main St',
        street: 'Main St',
        street2: '',
        city: 'New York',
        state: 'NY',
        zip: '10001',
        country: 'USA',
        code: 'RO001',
        amount: 100.0,
        status: 'pickup',
        startDate: '2023-10-01 10:00:00',
        endDate: '2023-10-02 10:00:00',
        orderLine: [],
        salesperson: 'Test Seller',
        salesTeam: 'Direct',
        onlineSignature: false,
        onlinePayment: false,
        reference: '',
        tagIds: [],
        fiscalPosition: '',
        incoterm: '',
        warehouse: '',
        deliveryDate: '',
        sourceDocument: '',
        opportunity: '',
        campaign: '',
        source: '',
        medium: '',
        signedBy: '',
        signedOn: '',
        signatureBytes: '',
        deliveryCount: 0,
        invoiceCount: 0,
      ),
    ];
    final dashboardProvider = MockDashboardProvider();
    final userProvider = MockUserProvider();

    await tester.pumpWidget(createWidgetUnderTest(
      rentalProvider: rentalProvider,
      dashboardProvider: dashboardProvider,
      userProvider: userProvider,
      currencyProvider: MockCurrencyProvider(),
    ));
    await tester.pump();

    expect(find.textContaining('RO001'), findsOneWidget);
    expect(find.textContaining('John Doe'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('RentalOrdersScreen shows error state', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final rentalProvider = MockRentalOrderProvider();
    rentalProvider.isRentalOrderScreenLoading = false;
    rentalProvider.error = 'Something Went Wrong!';
    final dashboardProvider = MockDashboardProvider();
    final userProvider = MockUserProvider();

    await tester.pumpWidget(createWidgetUnderTest(
      rentalProvider: rentalProvider,
      dashboardProvider: dashboardProvider,
      userProvider: userProvider,
      currencyProvider: MockCurrencyProvider(),
    ));
    await tester.pump();

    expect(find.text('Something Went Wrong!'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('RentalOrdersScreen triggers search on text change', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final rentalProvider = MockRentalOrderProvider();
    bool searchCalled = false;
    rentalProvider.searchRentalOrdersStub = (context, {searchQuery}) {
      searchCalled = true;
      return Future.value();
    };

    await tester.pumpWidget(createWidgetUnderTest(
      rentalProvider: rentalProvider,
      dashboardProvider: MockDashboardProvider(),
      userProvider: MockUserProvider(),
      currencyProvider: MockCurrencyProvider(),
    ));

    await tester.enterText(find.byType(TextField), 'RO001');
    await tester.pump();

    expect(searchCalled, isTrue);
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('ViewRentalOrder shows order details', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final rentalProvider = MockRentalOrderProvider();
    rentalProvider.isViewOrderLoading = false;
    final order = RentalOrderItem(
      id: 1,
      currencyName: 'USD',
      customerId: 101,
      customer: 'John Doe',
      customerAddress: '123 Main St',
      street: 'Main St',
      street2: '',
      city: 'New York',
      state: 'NY',
      zip: '10001',
      country: 'USA',
      code: 'RO001',
      amount: 100.0,
      status: 'sale',
      startDate: '2023-10-01 10:00:00',
      endDate: '2023-10-02 10:00:00',
      orderLine: [],
      salesperson: 'Seller',
      salesTeam: 'Direct',
      onlineSignature: false,
      onlinePayment: false,
      reference: '',
      tagIds: [],
      fiscalPosition: '',
      incoterm: '',
      warehouse: '',
      deliveryDate: '',
      sourceDocument: '',
      opportunity: '',
      campaign: '',
      source: '',
      medium: '',
      signedBy: '',
      signedOn: '',
      signatureBytes: '',
      deliveryCount: 0,
      invoiceCount: 0,
      orderDate: DateTime(2023, 10, 1),
    );
    rentalProvider.selectedOrder = order;
    rentalProvider.fetchOrderline = [];

    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider<RentalOrderProvider>.value(value: rentalProvider),
        ChangeNotifierProvider<DashboardProvider>.value(value: MockDashboardProvider()),
        ChangeNotifierProvider<UserProvider>.value(value: MockUserProvider()),
        ChangeNotifierProvider<CurrencyProvider>.value(value: MockCurrencyProvider()),
      ],
      child: MaterialApp(
        home: ViewRentalOrder(orderID: 1, states: 'sale'),
      ),
    ));
    await tester.pump();

    expect(find.text('RO001'), findsOneWidget);
    expect(find.text('John Doe'), findsOneWidget);
    expect(find.text('Sale Order'), findsWidgets); // Status badge and state text
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('RentalOrdersScreen triggers pagination', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final rentalProvider = MockRentalOrderProvider();
    rentalProvider.rentalOrderScreenList = [
      RentalOrderItem(id: 1, currencyName: 'USD', customerId: 101, customer: 'A', customerAddress: '', street: '', street2: '', city: '', state: '', zip: '', country: '', code: 'A', amount: 0, status: 'draft', startDate: '', endDate: '', orderLine: [], salesperson: '', salesTeam: '', onlineSignature: false, onlinePayment: false, reference: '', tagIds: [], fiscalPosition: '', incoterm: '', warehouse: '', deliveryDate: '', sourceDocument: '', opportunity: '', campaign: '', source: '', medium: '', signedBy: '', signedOn: '', signatureBytes: '', deliveryCount: 0, invoiceCount: 0)
    ];
    rentalProvider.canGoNext = true;
    bool nextPageCalled = false;
    rentalProvider.nextPageStub = (context) {
      nextPageCalled = true;
      return Future.value();
    };

    await tester.pumpWidget(createWidgetUnderTest(
      rentalProvider: rentalProvider,
      dashboardProvider: MockDashboardProvider(),
      userProvider: MockUserProvider(),
      currencyProvider: MockCurrencyProvider(),
    ));
    await tester.pump();

    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pump();

    expect(nextPageCalled, isTrue);
    await tester.pump(const Duration(seconds: 1));
  });
}
