import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:odoo_rpc/odoo_rpc.dart';
import 'package:mobo_rental/Core/services/odoo_session_manager.dart';
import 'package:mobo_rental/features/customer/providers/customer_provider.dart';

// Manual Fake
class FakeOdooClient extends Fake implements OdooClient {
  OdooSession? _sessionId;

  @override
  OdooSession? get sessionId => _sessionId;

  void setSessionId(OdooSession session) {
    _sessionId = session;
  }

  // A simple way to allow mocking different callKw behaviors
  // For more complex scenarios, a list of expected calls/returns could be used.
  Future<dynamic> Function(dynamic params)? _callKwHandler;

  void mockCallKw(Future<dynamic> Function(dynamic params) handler) {
    _callKwHandler = handler;
  }

  @override
  Future<dynamic> callKw(dynamic params) async {
    if (_callKwHandler != null) {
      return _callKwHandler!(params);
    }
    // Return true by default for permissions, or mock data
    return true;
  }
}

void main() {
  late FakeOdooClient fakeClient;
  late CustomerProvider provider;

  setUp(() {
    fakeClient = FakeOdooClient();
    provider = CustomerProvider();

    // Inject the mock client
    OdooSessionManager.injectMockClient(fakeClient);
  });

  tearDown(() {
    provider.dispose();
  });

  group('CustomerProvider Tests', () {
    test('loadPermissions handles success', () async {
      // Mock Odoo session ID
      final session = OdooSession(
        id: 'session_id',
        userId: 1,
        partnerId: 1,
        companyId: 1,
        allowedCompanies: [],
        userLogin: 'admin',
        userName: 'Admin',
        userLang: 'en_US',
        userTz: 'UTC',
        isSystem: true,
        dbName: 'test',
        serverVersion: '16.0',
      );

      fakeClient.setSessionId(session);

      // Mock callKw for permissions
      fakeClient.mockCallKw((params) async {
        // Return true for permission checks
        return true;
      });

      await provider.loadPermissions();

      expect(provider.permissionsLoaded, true);
      expect(provider.canViewCustomerDetails, true);
      expect(provider.isAdmin, true);
    });

    //   when(mockClient.callKw(argThat(containsPair('method', 'search_count'))))
    //       .thenAnswer((_) async => 1);

    //   // Mock search_read result
    //   when(mockClient.callKw(argThat(containsPair('method', 'search_read'))))
    //       .thenAnswer((_) async => [
    //             {
    //               'id': 1,
    //               'name': 'Customer 1',
    //               'email': 'c1@example.com',
    //             }
    //           ]);

    //   await provider.loadCustomers();

    //   expect(provider.isLoading, false);
    //   expect(provider.customers.length, 1);
    //   expect(provider.totalCount, 1);
    //   expect(provider.customers[0]['name'], 'Customer 1');
    // });

    // test('clearData resets state', () {
    //   provider.clearData();
    //   expect(provider.customers, isEmpty);
    //   expect(provider.currentOffset, 0);
    //   expect(provider.totalCount, 0);
    // });
  });
}
