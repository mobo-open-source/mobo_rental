import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:mockito/mockito.dart';
import 'package:mobo_rental/Core/services/connectivity_service.dart';
import 'package:mobo_rental/features/login/pages/add_account_screen.dart';
import 'package:mobo_rental/features/login/providers/login_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Mock ConnectivityService
class MockConnectivityService extends Mock implements ConnectivityService {
  @override
  Future<void> ensureInternetOrThrow() async {}

  @override
  Future<void> ensureServerReachable(String? serverUrl) async {}

  @override
  void startMonitoring() {}
  
  @override
  Stream<bool> get onInternetChanged => const Stream.empty();
  
  @override
  Stream<bool> get onServerChanged => const Stream.empty();
}

// Mock HttpOverrides
class MockHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return MockHttpClient();
  }
}

class MockHttpClient extends Mock implements HttpClient {
  @override
  Future<HttpClientRequest> postUrl(Uri url) async {
    return MockHttpClientRequest(url);
  }
  
  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async {
     if (method == 'POST') return MockHttpClientRequest(url);
     return MockHttpClientRequest(url);
  }
}

class MockHttpClientRequest extends Mock implements HttpClientRequest {
  final Uri url;
  MockHttpClientRequest(this.url);

  @override
  HttpHeaders get headers => MockHttpHeaders();

  @override
  Future<HttpClientResponse> close() async {
    return MockHttpClientResponse(url);
  }

  @override
  void add(List<int> data) {}

  @override
  void write(Object? obj) {}
}

class MockHttpHeaders extends Mock implements HttpHeaders {
  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {}
  
  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {}
}

class MockHttpClientResponse extends Mock implements HttpClientResponse {
  final Uri url;
  MockHttpClientResponse(this.url);

  @override
  int get statusCode => 200;

  @override
  @override
  Stream<S> transform<S>(StreamTransformer<List<int>, S> streamTransformer) {
    return Stream.value(utf8.encode(_getResponseString(url))).cast<List<int>>().transform(streamTransformer);
  }

  @override
  HttpClientResponseCompressionState get compressionState => HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(void Function(List<int> event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    return Stream.value(utf8.encode(_getResponseString(url))).listen(
        onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }
  
  String _getResponseString(Uri url) {
    final path = url.path;
    if (path.contains('/json/rpc') || path.contains('/web/database/list')) {
        return jsonEncode({
            "jsonrpc": "2.0",
            "result": ["db1", "db2"],
        });
    }
    if (path.contains('/web/session/authenticate')) {
        return jsonEncode({
            "jsonrpc": "2.0",
            "result": {
                "uid": 1,
                "partner_id": 5,
                "company_id": 1,
                "username": "admin",
                "name": "Administrator",
                "user_context": {"lang": "en_US", "tz": "UTC"},
                "is_system": true,
                "server_version": "16.0",
                "session_id": "mock_session_id"
            }
        });
    }
    return jsonEncode({"jsonrpc": "2.0", "result": {}});
  }
}


void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    HttpOverrides.global = MockHttpOverrides();
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    ConnectivityService.instance = MockConnectivityService();
  });

  testWidgets('AddAccountScreen renders initial state correctly', (WidgetTester tester) async {
    // Wrap with LoginProvider if needed or just Material
    
    await tester.pumpWidget(
      const MaterialApp(
        home: AddAccountScreen(),
      ),
    );

    // Verify Title
    expect(find.text('Add New Account'), findsOneWidget);
    
    // Verify initial step URL input
    expect(find.byType(TextFormField), findsOneWidget); // URL field
    expect(find.text('Server Address (e.g. odoo.com)'), findsOneWidget);
    
    // Check next button exists
    expect(find.text('Next'), findsOneWidget);
  });

  testWidgets('AddAccountScreen inputs URL and shows database dropdown', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AddAccountScreen(),
      ),
    );

    final urlField = find.byType(TextFormField).first;
    await tester.enterText(urlField, 'demo.odoo.com');
    await tester.pump();
    
    // Wait for debounce and async fetch
    await tester.pump(const Duration(milliseconds: 1000)); 
    await tester.pumpAndSettle();

    // After fetch, dropdown should appear if databases found
    // Our mock returns ["db1", "db2"]
    
    // Dropdown is usually DropdownButtonFormField or custom
    // In LoginLayout, it might be custom.
    // It auto-selects first DB, so we should see 'db1'
    expect(find.text('db1'), findsOneWidget);
  });

  // More tests can be added for credentials step
}
