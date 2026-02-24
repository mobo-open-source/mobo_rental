import 'package:odoo_rpc/odoo_rpc.dart';

/// Service for handling Odoo authentication.
class AuthService {
  /// Authenticates with an Odoo server using the provided credentials.
  ///
  /// [url] - The Odoo server URL.
  /// [database] - The database name.
  /// [username] - The user's email or username.
  /// [password] - The user's password.
  ///
  /// Returns an [OdooSession] if successful.
  Future<OdooSession?> authenticateOdoo({
    required String url,
    required String database,
    required String username,
    required String password,
  }) async {
    final client = OdooClient(url);
    final session = await client.authenticate(database, username, password);
    return session;
  }
}
