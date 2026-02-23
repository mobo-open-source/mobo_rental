import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mobo_rental/features/customer/providers/customer_form_provider.dart';
import 'package:mobo_rental/features/customer/providers/customer_provider.dart';
import 'package:mobo_rental/features/home/provider/company_provider.dart';
import 'package:mobo_rental/app_entry.dart';
import 'package:mobo_rental/Core/providers/logout_view_model.dart';
import 'package:mobo_rental/Core/services/session_service.dart';
import 'package:mobo_rental/Core/services/http_client_override.dart';
import 'package:mobo_rental/Core/theme/theme_provider.dart';
import 'package:mobo_rental/features/company/providers/company_provider.dart';
import 'package:mobo_rental/features/login/pages/credentials_screen.dart';
import 'package:mobo_rental/features/login/pages/server_setup_screen.dart';
import 'package:mobo_rental/features/profile/providers/profile_provider.dart';
import 'package:mobo_rental/features/settings/providers/settings_provider.dart';
import 'package:mobo_rental/features/products/provider/currency_provider.dart';
import 'package:mobo_rental/features/products/provider/product_provider.dart';
import 'package:mobo_rental/features/rental_orders/providers/create_rental_provider.dart';
import 'package:mobo_rental/features/home/provider/navigation_provider.dart';
import 'package:mobo_rental/features/rental_orders/providers/rental_order_provider.dart';
import 'package:mobo_rental/features/dashboard/providers/dashboard_provider.dart';
import 'package:mobo_rental/features/dashboard/providers/user_provider.dart';
import 'package:mobo_rental/features/dashboard/screens/dashboard_screen.dart';
import 'package:mobo_rental/features/home/screens/home_screen.dart';
import 'package:mobo_rental/features/schedule_rental/provider/rental_schedule_provider.dart';
import 'package:mobo_rental/features/splash_screen/splash_screen.dart';
import 'package:mobo_rental/Core/utils/constants/colors.dart';
import 'package:mobo_rental/Core/utils/constants/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Core/navigation/global_keys.dart';
import 'Core/services/review_service.dart';

/// The entry point of the Mobo Rental application.
/// 
/// Initializes Flutter bindings, sets up global HTTP client overrides 
/// for SSL bypass, and runs the [MyApp] widget.
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Apply global HTTP client override to bypass SSL certificate validation
  // This allows connections to Odoo servers with self-signed certificates
  HttpOverrides.global = CustomHttpOverrides();

  runApp(const MyApp());
}

/// The root widget of the application.
/// 
/// Provides global providers for state management and builds the [MaterialApp]
/// with internationalization, themes, and routing.
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LogoutViewModel()),
        ChangeNotifierProvider<SessionService>.value(
          value: SessionService.instance,
        ),

        // Provide CompanyProvider globally and initialize companies on app start
        ChangeNotifierProvider<NavigationProvider>(
          create: (context) => NavigationProvider(),
        ),
        ChangeNotifierProvider<DashboardProvider>(
          create: (context) => DashboardProvider(),
        ),

        ChangeNotifierProvider<UserProvider>(
          create: (context) => UserProvider(),
        ),
        ChangeNotifierProvider<CreateRentalProvider>(
          create: (context) => CreateRentalProvider(),
        ),

        ChangeNotifierProvider<RentalOrderProvider>(
          create: (context) => RentalOrderProvider(),
        ),
        ChangeNotifierProvider<RentalScheduleProvider>(
          create: (context) => RentalScheduleProvider(),
        ),
        ChangeNotifierProvider<CurrencyProvider>(
          create: (context) => CurrencyProvider(),
        ),
        ChangeNotifierProvider<ProductProvider>(
          create: (context) => ProductProvider(),
        ),
        ChangeNotifierProvider<CustomerFormProvider>(
          create: (context) => CustomerFormProvider(),
        ),
        ChangeNotifierProvider<CustomerProvider>(
          create: (context) => CustomerProvider(),
        ),
        ChangeNotifierProvider<CompanyProvider>(
          create: (context) => CompanyProvider()..initialize(),
        ),
      ],

      child: Consumer<ThemeProvider>(
        builder: (context, provider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Mobo Rental App',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: provider.themeMode,
            navigatorKey: navigatorKey,
            scaffoldMessengerKey: scaffoldMessengerKey,
            routes: {
              '/server_setup': (_) => const ServerSetupScreen(),
              '/home': (_) => const HomeScreen(initialIndex: 0),
            },
            // Entry decides between login flow and home based on saved session
            home: const SplashScreen(),
            onGenerateRoute: (settings) {
              if (settings.name == '/login') {
                final args = settings.arguments as Map<String, dynamic>?;
                return MaterialPageRoute(
                  builder: (_) => CredentialsScreen(
                    url: (args?['url'] ?? '') as String,
                    database: (args?['database'] ?? '') as String,
                  ),
                );
              }
              return null;
            },
          );
        },
      ),
    );
  }
}
