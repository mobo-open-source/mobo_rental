import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mobo_rental/features/customer/screens/customer_screen.dart';
import 'package:mobo_rental/features/customer/providers/customer_provider.dart';
import 'package:mobo_rental/features/products/provider/product_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Mock CustomerProvider
class MockCustomerProvider extends ChangeNotifier implements CustomerProvider {
  bool isLoading = false;
  List<dynamic> customers = [];
  String? error;
  int activeFiltersCount = 0;
  int startRecord = 0;
  int endRecord = 0;
  int totalCount = 0;
  bool hasPreviousPage = false;
  bool hasNextPage = false;
  bool isGrouped = false;
  Map<String, int> groupSummary = {};
  Map<String, List<dynamic>> loadedGroups = {};
  bool showActiveOnly = true;
  bool showCompaniesOnly = false;
  bool showIndividualsOnly = false;
  bool showCreditBreachesOnly = false;
  DateTime? startDate;
  DateTime? endDate;
  String? selectedGroupBy;
  String currentSearchQuery = '';

  @override
  bool get isAdmin => false;
  
  @override
  bool get canViewCustomerDetails => true;

  @override
  bool get permissionsLoaded => true;

  @override
  Future<void> loadCustomers({int offset = 0, String search = ''}) async {}

  @override
  Future<void> fetchGroupByOptions() async {}
  
  @override
  Future<void> searchCustomers(String query) async {}

  @override
  Future<void> loadPermissions() async {}

  @override
  Future<void> clearData() async {}
  
  @override
  void setFilterState({
    bool? showActiveOnly,
    bool? showCompaniesOnly,
    bool? showIndividualsOnly,
    DateTime? startDate,
    DateTime? endDate,
  }) {}

  @override
  void clearFilters() {}

  @override
  void setGroupBy(String? groupBy) {}

  @override
  Future<void> loadGroupContacts(String groupKey) async {}
  
  @override
  Future<void> goToNextPage() async {}
  
  @override
  Future<void> goToPreviousPage() async {}
  
  @override
  Map<String, String> get groupByOptions => {};

  @override
  int get currentOffset => 0;

  @override
  int get limit => 40;

  @override
  Future<Map<String, dynamic>?> getCustomerDetails(int partnerId) async => null;

  @override
  Future<List<Map<String, dynamic>>> getCountries() async => [];

  @override
  Future<List<Map<String, dynamic>>> getStatesByCountry(int countryId) async => [];

  @override
  Future<List<dynamic>> getTitleOptions() async => [];

  @override
  Future<List<Map<String, dynamic>>> getCurrencies() async => [];

  @override
  Future<List<Map<String, dynamic>>> getLanguages() async => [];

  @override
  Future<int> createCustomer(Map<String, dynamic> customerData) async => 0;

  @override
  Future<bool> updateCustomer(int id, Map<String, dynamic> customerData) async => true;

  @override
  Future<Map<String, dynamic>> getCustomerStats(int partnerId) async => {
    'total_orders': 0,
    'confirmed_orders': 0,
    'draft_orders': 0,
    'total_amount': 0.0,
  };

  @override
  Future<Map<String, List<dynamic>>> fetchDropdownOptions() async => {
    'countries': [],
    'titles': [],
    'currencies': [],
    'languages': [],
  };

  @override
  Future<List<Map<String, dynamic>>> fetchStates(int countryId) async => [];

  @override
  Future<bool> archiveCustomer(int customerId) async => true;

  @override
  Future<bool> deleteCustomer(int customerId) async => true;

  @override
  Future<bool> geoLocalizeCustomer(int customerId) async => true;
}

// Mock ProductProvider
class MockProductProvider extends ChangeNotifier implements ProductProvider {
  @override
  bool get canCreateProduct => false;

  @override
  bool get permissionsLoaded => true;

  @override
  Future<void> loadPermissions() async {}

  @override
  List<dynamic> get products => [];

  @override
  bool get isLoading => false;

  @override
  String? get error => null;

  @override
  int get totalCount => 0;

  @override
  int get currentOffset => 0;

  @override
  int get limit => 40;

  @override
  bool get showServicesOnly => false;

  @override
  bool get showConsumablesOnly => false;

  @override
  bool get showStorableOnly => false;

  @override
  bool get showAvailableOnly => false;

  @override
  Map<String, String> get groupByOptions => {};

  @override
  String? get selectedGroupBy => null;

  @override
  bool get isGrouped => false;

  @override
  Map<String, int> get groupSummary => {};

  @override
  bool get hasNextPage => false;

  @override
  bool get hasPreviousPage => false;

  @override
  int get startRecord => 0;

  @override
  int get endRecord => 0;

  @override
  Future<void> clearData() async {}

  @override
  bool get hasStockModule => false;

  @override
  int get activeFiltersCount => 0;

  @override
  Future<void> checkStockModuleInstalled() async {}

  @override
  Future<void> loadProducts({int offset = 0, String search = ''}) async {}

  @override
  Future<void> searchProducts(String query) async {}

  @override
  Future<void> goToNextPage() async {}

  @override
  Future<void> goToPreviousPage() async {}

  @override
  void setFilterState({
    bool? showServicesOnly,
    bool? showConsumablesOnly,
    bool? showStorableOnly,
    bool? showAvailableOnly,
  }) {}

  @override
  void clearFilters() {}

  @override
  Future<void> setGroupBy(String? groupBy) async {}

  @override
  Map<String, List<dynamic>> get loadedGroups => {};

  @override
  Future<void> loadGroupProducts(Map<String, dynamic> context) async {}
  
  @override
  Future<void> fetchGroupByOptions() async {}

  @override
  String getGroupKeyFromReadGroup(Map<String, dynamic> groupData) => '';
  
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget createWidgetUnderTest(MockCustomerProvider customerProvider, MockProductProvider productProvider) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CustomerProvider>.value(value: customerProvider),
        ChangeNotifierProvider<ProductProvider>.value(value: productProvider),
      ],
      child: MaterialApp(
        home: CustomersScreen(),
      ),
    );
  }

  testWidgets('CustomersScreen renders correctly', (WidgetTester tester) async {
    final mockCustomerProvider = MockCustomerProvider();
    final mockProductProvider = MockProductProvider();

    await tester.pumpWidget(createWidgetUnderTest(mockCustomerProvider, mockProductProvider));
    await tester.pump();

    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.text('Search customers...'), findsOneWidget);
  });

  testWidgets('CustomersScreen shows empty state when no customers', (WidgetTester tester) async {
    final mockCustomerProvider = MockCustomerProvider();
    mockCustomerProvider.customers = [];
    final mockProductProvider = MockProductProvider();

    await tester.pumpWidget(createWidgetUnderTest(mockCustomerProvider, mockProductProvider));
    await tester.pump();

    expect(find.text('Something Went Wrong!'), findsOneWidget); // EmptyState title
  });

  testWidgets('CustomersScreen shows customers list', (WidgetTester tester) async {
    final mockCustomerProvider = MockCustomerProvider();
    mockCustomerProvider.customers = [
      {'id': 1, 'name': 'John Doe', 'email': 'john@example.com', 'phone': '1234567890'},
      {'id': 2, 'name': 'Jane Doe', 'email': 'jane@example.com', 'phone': '0987654321'},
    ];
    final mockProductProvider = MockProductProvider();

    await tester.pumpWidget(createWidgetUnderTest(mockCustomerProvider, mockProductProvider));
    await tester.pump();

    expect(find.text('John Doe'), findsOneWidget);
    expect(find.text('Jane Doe'), findsOneWidget);
  });
}
