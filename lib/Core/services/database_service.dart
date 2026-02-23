import 'dart:convert';
import 'dart:io';

/// Service for fetching database lists from Odoo servers.
///
/// This service uses a custom HttpClient with SSL certificate bypass
/// to handle servers with self-signed certificates.
class DatabaseService {
  /// Fetch the list of available databases from an Odoo server.
  ///
  /// [url] - The Odoo server URL (can be with or without http/https prefix)
  ///
  /// Returns a list of database names available on the server.
  /// Throws an Exception if the request fails.
  static Future<List<String>> fetchDatabaseList(String url) async {
    try {
      // Normalize the URL
      String normalizedUrl = url.trim();
      if (!normalizedUrl.startsWith('http://') &&
          !normalizedUrl.startsWith('https://')) {
        normalizedUrl = 'https://$normalizedUrl';
      }
      if (normalizedUrl.endsWith('/')) {
        normalizedUrl = normalizedUrl.substring(0, normalizedUrl.length - 1);
      }

      // Create HTTP client with SSL bypass
      final HttpClient httpClient = HttpClient()
        ..connectionTimeout = const Duration(seconds: 12)
        ..idleTimeout = const Duration(seconds: 10)
        ..maxConnectionsPerHost = 5
        ..badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;

      // Make the request to fetch database list
      final request = await httpClient.postUrl(
        Uri.parse('$normalizedUrl/web/database/list'),
      );

      request.headers.set('Content-Type', 'application/json');
      request.write(
        jsonEncode({'jsonrpc': '2.0', 'method': 'call', 'params': {}, 'id': 1}),
      );

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      httpClient.close();

      final jsonResponse = jsonDecode(responseBody);
      if (jsonResponse['result'] is List) {
        return (jsonResponse['result'] as List)
            .map((db) => db.toString())
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Error fetching database list: $e');
    }
  }
}
