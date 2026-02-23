import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobo_rental/features/company/providers/company_provider.dart';
import 'package:mobo_rental/features/profile/providers/profile_provider.dart';
import 'package:mobo_rental/features/customer/providers/customer_provider.dart';
import 'package:mobo_rental/features/dashboard/providers/dashboard_provider.dart';
import 'package:mobo_rental/features/dashboard/providers/user_provider.dart';
import 'package:mobo_rental/features/home/provider/navigation_provider.dart';
import 'package:mobo_rental/features/home/screens/home_screen.dart';
import 'package:mobo_rental/features/products/provider/product_provider.dart';
import 'package:mobo_rental/features/rental_orders/providers/rental_order_provider.dart';
import 'package:mobo_rental/features/schedule_rental/provider/rental_schedule_provider.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets("dashboard testing ", (WidgetTester tester) async {
    final navigationProvider = NavigationProvider();

    // navigationProvider.updateMainScreen(0);
    await tester.pumpWidget(
      ChangeNotifierProvider<NavigationProvider>.value(
        value: navigationProvider,
        child: MaterialApp(home: HomeScreen(initialIndex: 0, isTest: true)),
      ),
    );

    // expect(find.byType(AppBar), findsOneWidget);
    // first page

    expect(navigationProvider.index, 0);
    expect(find.text('Dashboard'), findsNWidgets(2));
    // bottom nav bar 2 nd page ontap
    await tester.tap(find.text('Orders'));
    await tester.pumpAndSettle();
    // expect index to change 1

    expect(navigationProvider.index, 1);
    expect(find.text('Rental Orders'), findsOneWidget);

    await tester.tap(find.text('Products'));
    await tester.pumpAndSettle();

    expect(navigationProvider.index, 2);
    expect(find.text('Products'), findsNWidgets(2));

    await tester.tap(find.text('Customers'));
    await tester.pumpAndSettle();

    expect(navigationProvider.index, 3);
    expect(find.text('Customers'), findsNWidgets(2)); // app bar  and bottom bar 

    await tester.tap(find.text('Schedule'));
    await tester.pumpAndSettle();

    expect(navigationProvider.index, 4);
    expect(find.text('Schedule'), findsNWidgets(1)); // bottom bar 
    expect(find.text('Scheduled Rentals'), findsOneWidget); // app bar 
  });
}
