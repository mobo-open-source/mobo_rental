import 'package:flutter/material.dart';
import 'package:mobo_rental/features/home/screens/home_screen.dart';
import 'package:mobo_rental/features/routing/page_transition.dart';
import 'package:mobo_rental/Core/utils/module_missing_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'shared/widgets/loaders/loading_indicator.dart';
import 'features/login/pages/server_setup_screen.dart';
import 'features/login/pages/app_lock_screen.dart';
import 'Core/services/session_service.dart';
import 'Core/services/odoo_session_manager.dart';
import 'Core/services/biometric_context_service.dart';

import 'Core/services/connectivity_service.dart';

/// The entry point for authenticated/unauthenticated routing.
///
/// Handles biometric authentication, session validation, and checks for
/// required Odoo modules before navigating to the appropriate screen.
class AppEntry extends StatefulWidget {
  /// Whether to skip the biometric authentication step.
  final bool skipBiometric;

  const AppEntry({super.key, this.skipBiometric = false});

  @override
  State<AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<AppEntry> {
  late Future<Map<String, dynamic>> _initFuture;

  @override
  void initState() {
    super.initState();
    ConnectivityService.instance.startMonitoring();
    _initFuture = _checkAuthStatus();
  }

  Future<Map<String, dynamic>> _checkAuthStatus() async {
    try {
      await SessionService.instance.initialize();

      final prefs = await SharedPreferences.getInstance();
      final session = SessionService.instance.currentSession;
      final isLoggedIn = session != null;
      final biometricEnabled = prefs.getBool('biometric_enabled') ?? false;

      bool sessionValid = false;
      if (isLoggedIn) {
        sessionValid = await OdooSessionManager.isSessionValid();

        if (sessionValid) {
          try {
            final client = await OdooSessionManager.getClientEnsured();
            final sessionInfo = await client.callRPC(
              '/web/session/get_session_info',
              'call',
              {},
            );
          } catch (e) {}
        }
      }

      bool rentalInstalled = true; // Default to true to be safe

      if (isLoggedIn && sessionValid) {
        try {
          final client = await OdooSessionManager.getClientEnsured();
          final result = await client.callKw({
            'model': 'ir.module.module',
            'method': 'search_count',
            'args': [
              [
                ['name', '=', 'sale_renting'],
                ['state', '=', 'installed'],
              ],
            ],
            'kwargs': {},
          });

          if (result is int) {
            rentalInstalled = result > 0;
          } else {}
        } catch (e) {
          rentalInstalled =
              true; // Don't block user if check fails (network/permissions)
        }
      }

      final finalResult = {
        'isLoggedIn': isLoggedIn && sessionValid,
        'biometricEnabled': biometricEnabled,
        'rentalInstalled': rentalInstalled,
      };

      return finalResult;
    } catch (e) {
      return {
        'isLoggedIn': false,
        'biometricEnabled': false,
        'rentalInstalled': false,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: LoadingIndicator()));
        }

        if (!snapshot.hasData) {
          return const ServerSetupScreen();
        }

        final isLoggedIn = snapshot.data!['isLoggedIn'] as bool;
        final biometricEnabled = snapshot.data!['biometricEnabled'] as bool;
        final rentalInstalled =
            snapshot.data!['rentalInstalled'] as bool? ?? false;

        final biometricContext = BiometricContextService();
        final shouldSkipBiometric =
            widget.skipBiometric || biometricContext.shouldSkipBiometric;

        if (biometricEnabled && isLoggedIn && !shouldSkipBiometric) {
          return AppLockScreen(
            onAuthenticationSuccess: () {
              Navigator.pushReplacement(
                context,
                dynamicRoute(context, const AppEntry(skipBiometric: true)),
              );
            },
          );
        }

        if (isLoggedIn && !rentalInstalled) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => const ModuleMissingDialog(),
            );
          });

          return const ServerSetupScreen();
        }

        if (isLoggedIn) {
          return const HomeScreen(initialIndex: 0);
        }

        return const ServerSetupScreen();
      },
    );
  }
}
