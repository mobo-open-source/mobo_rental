import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobo_rental/features/login/pages/credentials_screen.dart';
import 'package:mobo_rental/features/login/providers/login_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Mock LoginProvider to avoid network calls
class TestLoginProvider extends LoginProvider {
  bool loginCalled = false;
  bool shouldLoginSucceed = true;

  @override
  Future<bool> login(BuildContext context) async {
    loginCalled = true;
    if (shouldLoginSucceed) {
      return true;
    } else {
      errorMessage = "Login failed";
      notifyListeners();
      return false;
    }
  }

  @override
  Future<void> fetchDatabaseList() async {
    // Mock implementation
    return;
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('CredentialsScreen rendering test', (WidgetTester tester) async {
    final testProvider = TestLoginProvider();

    await tester.pumpWidget(
      MaterialApp(
        home: CredentialsScreen(
          url: 'https://demo.odoo.com',
          database: 'demo',
          provider: testProvider,
        ),
      ),
    );

    // Verify Title
    expect(find.text('Sign In'), findsNWidgets(2));

    // Verify Text Fields
    expect(find.byType(TextFormField), findsNWidgets(2)); // Email and Password

    // Verify Button
    expect(find.widgetWithText(ElevatedButton, 'Sign In'), findsOneWidget);
  });

  testWidgets('CredentialsScreen validation test', (WidgetTester tester) async {
    final testProvider = TestLoginProvider();

    await tester.pumpWidget(
      MaterialApp(
        home: CredentialsScreen(
          url: 'https://demo.odoo.com',
          database: 'demo',
          provider: testProvider,
        ),
      ),
    );

    // Tap Sign In without entering data
    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
    await tester.pump();

    // Verify validation errors (standard validator messages)
    // Note: The actual error text depends on the validator implementation in CredentialsScreen
    // Based on code: 'Email is required', 'Password is required'
    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
  });

  testWidgets('CredentialsScreen successful login interactions', (
    WidgetTester tester,
  ) async {
    final testProvider = TestLoginProvider();
    testProvider.shouldLoginSucceed = true;

    await tester.pumpWidget(
      MaterialApp(
        home: CredentialsScreen(
          url: 'https://demo.odoo.com',
          database: 'demo',
          provider: testProvider,
        ),
      ),
    );
    await tester.pumpAndSettle(); // Ensure init callbacks run

    // Enter valid data
    // Find text fields by type since hints might not be reliably found as text widgets
    final emailField = find.byType(TextFormField).at(0);
    final passwordField = find.byType(TextFormField).at(1);

    await tester.enterText(emailField, 'user@example.com');
    await tester.enterText(passwordField, 'password');
    await tester.pumpAndSettle();

    // Verify database is set in provider (if possible, or just assume)
    // Tap Sign In button (it's the only ElevatedButton)
    await tester.tap(find.byType(ElevatedButton));

    // Allow the Future.delayed(100ms) in _handleSubmit to complete
    await tester.pump(); // Process tap
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(); // Process navigation

    expect(
      testProvider.loginCalled,
      isTrue,
      reason:
          "Login method was not called. Error: ${testProvider.errorMessage}",
    );

    // ConnectivityService might have started a 3s timeout timer during login/navigation.
    // We wait for it to finish to avoid the "Timer still pending" leak.
    await tester.pump(const Duration(seconds: 4));
  });
}
