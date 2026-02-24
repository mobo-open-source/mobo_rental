import 'dart:io';

/// Custom HTTP client override that bypasses SSL certificate validation.
///
/// This is useful when connecting to Odoo servers with self-signed certificates
/// or when SSL certificate validation needs to be bypassed for development/testing.
///
/// WARNING: Bypassing SSL certificate validation removes an important security layer.
/// Only use this with trusted servers in development/testing environments.
class CustomHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        // Always accept certificates (bypass SSL verification)
        return true;
      }
      ..connectionTimeout = const Duration(seconds: 12)
      ..idleTimeout = const Duration(seconds: 10)
      ..maxConnectionsPerHost = 5;
  }
}
