import 'dart:async';
import 'package:isar_community/isar.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:odoo_rpc/odoo_rpc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/appsession.dart';
import 'odoo_session_manager.dart';
import 'secure_storage_service.dart';
import '../../features/company/isar_database.dart';
import '../../features/login/models/account_entity.dart';

/// A service that manages the application session and stored accounts.
/// 
/// It acts as a central hub for session state, account persistence, 
/// and coordinate logout operations across the app.
class SessionService extends ChangeNotifier {
  static final SessionService instance = SessionService._internal();
  factory SessionService() => instance;
  SessionService._internal();

  AppSessionData? _currentSession;
  bool _isInitialized = false;
  List<Map<String, dynamic>> _storedAccounts = [];

  AppSessionData? get currentSession => _currentSession;
  bool get isInitialized => _isInitialized;
  bool get hasValidSession => _currentSession != null;
  List<Map<String, dynamic>> get storedAccounts => _storedAccounts;

  /// Initializes the session service and loads stored accounts.
  Future<void> initialize() async {
    if (_isInitialized) return;

    OdooSessionManager.setSessionCallbacks(
      onSessionUpdated: (sessionModel) {
        updateSession(sessionModel);
      },
      onSessionCleared: () {
        clearSession();
      },
    );

    // Load current session
    _currentSession = await OdooSessionManager.getCurrentSession();

    // Load stored accounts
    await _loadStoredAccounts();

    // Migrate passwords from SharedPreferences to secure storage
    await _migratePasswordsToSecureStorage();

    // Auto-store current session if not already stored
    if (_currentSession != null) {
      await _autoStoreCurrentSession();
    }

    _isInitialized = true;

    notifyListeners();
  }

  /// Updates the currently active session state.
  void updateSession(AppSessionData newSession) {
    _currentSession = newSession;
    notifyListeners();
  }

  /// Clears the currently active session state.
  void clearSession() {
    _currentSession = null;
    notifyListeners();
  }

  /// Logs out the current user and clears session data.
  Future<void> logout() async {
    try {
      final currentServerUrl = _currentSession?.serverUrl;
      final currentDatabase = _currentSession?.database;

      // Clear the session on the backend
      await OdooSessionManager.logout();

      // Clear stored accounts for privacy
      await _clearStoredAccountsData();

      // Clear password caches
      await _clearPasswordCaches();

      // Clear session service state
      clearSession();

      if (currentServerUrl != null && currentServerUrl.isNotEmpty) {
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('lastServerUrl', currentServerUrl);

          if (currentDatabase != null && currentDatabase.isNotEmpty) {
            await prefs.setString('lastDatabase', currentDatabase);
            // Also save server-database mapping
            await prefs.setString(
              'server_db_$currentServerUrl',
              currentDatabase,
            );
          }

          List<String> urls = prefs.getStringList('previous_server_urls') ?? [];
          if (!urls.contains(currentServerUrl)) {
            urls.insert(0, currentServerUrl);
            if (urls.length > 10) {
              urls = urls.take(10).toList();
            }
            await prefs.setStringList('previous_server_urls', urls);
          }
        } catch (_) {}
      }
    } catch (e, stackTrace) {}
  }

  // Account management methods

  /// Internal method to load accounts stored in SharedPreferences and Isar database.
  Future<void> _loadStoredAccounts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> storedAccountsJson =
          prefs.getStringList('stored_accounts') ?? [];

      final spAccounts = storedAccountsJson
          .map((json) {
            try {
              return Map<String, dynamic>.from(jsonDecode(json));
            } catch (_) {
              return null;
            }
          })
          .where((account) => account != null)
          .cast<Map<String, dynamic>>()
          .toList();

      // Also load from Isar
      final isar = await IsarDatabase.instance();
      final isarAccountsCount = await isar.accountEntitys.count();
      if (isarAccountsCount > 0) {
        final isarAccounts = await isar.accountEntitys.where().findAll();
        for (final account in isarAccounts) {
          final accountMap = {
            'id': account.userId,
            'name': account.userName,
            'email': account.userLogin,
            'url': account.url,
            'database': account.dbName,
            'username': account.userLogin,
            'isCurrent': account.userId == _currentSession?.userId.toString() &&
                         account.url == _currentSession?.serverUrl &&
                         account.dbName == _currentSession?.database,
            'lastLogin': account.lastLogin?.toIso8601String(),
            'imageBase64': account.image?.isNotEmpty == true ? account.image : null,
            'userId': account.userId,
            'userName': account.userName,
            'serverUrl': account.url,
            'sessionId': account.sessionId,
          };

          // Merge: if account already in SP, skip or update? 
          // Prefer keeping SP as source of truth for "known" accounts but augment with Isar
          final existsInSp = spAccounts.any((a) => 
            a['id'] == accountMap['id'] && 
            a['url'] == accountMap['url'] && 
            a['database'] == accountMap['database']
          );
          if (!existsInSp) {
            spAccounts.add(accountMap);
          }
        }
      }

      _storedAccounts = spAccounts;

      // Clean up any duplicate accounts
      await _cleanupDuplicateAccounts();

      notifyListeners();
    } catch (e) {
      _storedAccounts = [];
    }
  }

  Future<void> _autoStoreCurrentSession() async {
    if (_currentSession == null) return;

    final currentExists = _storedAccounts.any(
      (account) =>
          account['userId'] == _currentSession!.userId.toString() &&
          account['serverUrl'] == _currentSession!.serverUrl &&
          account['database'] == _currentSession!.database,
    );

    if (!currentExists) {
      await storeAccount(
        _currentSession!,
        '',
      ); // Store with empty password initially
    }
  }

  Future<void> _cleanupDuplicateAccounts() async {
    final uniqueAccounts = <String, Map<String, dynamic>>{};

    for (final account in _storedAccounts) {
      final userId = account['userId']?.toString() ?? '';
      final serverUrl = account['serverUrl']?.toString() ?? '';
      final database = account['database']?.toString() ?? '';

      if (userId.isEmpty || serverUrl.isEmpty || database.isEmpty) {
        continue;
      }

      final key = '${userId}_${serverUrl}_$database';

      if (!uniqueAccounts.containsKey(key)) {
        uniqueAccounts[key] = account;
      } else {
        final existing = uniqueAccounts[key]!;
        final currentHasPassword =
            account['password']?.toString().isNotEmpty == true;
        final existingHasPassword =
            existing['password']?.toString().isNotEmpty == true;

        if (currentHasPassword && !existingHasPassword) {
          uniqueAccounts[key] = account;
        }
      }
    }

    final originalCount = _storedAccounts.length;
    _storedAccounts = uniqueAccounts.values.toList();

    if (_storedAccounts.length != originalCount) {
      await _saveStoredAccountsWithRetry();
    }
  }

  /// Stores a new account's session and password.
  Future<void> storeAccount(
    AppSessionData session,
    String password, {
    bool markAsCurrent = true,
  }) async {
    try {
      String? imageBase64;
      // Prefer the userName from the session object as the primary source
      String userDisplayName =
          (session.userName.isNotEmpty && session.userName != 'false')
              ? session.userName
              : session.userLogin;

      // Try to fetch user details including image
      try {
        // Create a fresh client scoped to THIS specific session, not the
        // globally active one. This prevents using the wrong user's session
        // when multiple accounts are stored in sequence.
        final OdooClient client = OdooClient(
          session.serverUrl,
          sessionId: session.odooSession,
        );

        if (session.userId != null) {
          final userDetails = await client.callKw({
            'model': 'res.users',
            'method': 'read',
            'args': [
              [session.userId],
              ['name', 'image_1920'],
            ],
            'kwargs': {},
          });

          if (userDetails is List && userDetails.isNotEmpty) {
            final user = userDetails.first as Map;
            final n = user['name'];
            if (n != null && n != false) {
              userDisplayName = n.toString();
            }
            final img = user['image_1920'];
            if (img != null && img != false) {
              imageBase64 = img.toString();
            }
          }
        }
      } catch (e) {
      }

      // Create account data (WITHOUT password - stored securely)
      final accountData = {
        'id': session.userId.toString(),
        'name': userDisplayName,
        'email': session.userLogin,
        'url': session.serverUrl.trim(),
        'database': session.database,
        'username': session.userLogin,
        'isCurrent': markAsCurrent,
        'lastLogin': DateTime.now().toIso8601String(),
        'imageBase64': imageBase64?.isNotEmpty == true ? imageBase64 : null,
        // Keep compatibility fields
        'userId': session.userId.toString(),
        'userName': userDisplayName,
        'serverUrl': session.serverUrl,
        // DON'T store password here - use secure storage
        'sessionId': session.sessionId,
      };

      // Mark all other accounts as not current only if this account is being marked as current
      if (markAsCurrent) {
        for (var account in _storedAccounts) {
          account['isCurrent'] = false;
        }
      }

      // Check if account already exists
      final existingIndex = _storedAccounts.indexWhere(
        (account) =>
            account['id'] == accountData['id'] &&
            account['url'] == accountData['url'] &&
            account['database'] == accountData['database'],
      );

      if (existingIndex != -1) {
        _storedAccounts[existingIndex] = accountData;
      } else {
        _storedAccounts.insert(0, accountData);
      }

      await _saveStoredAccountsWithRetry();

      // Store password with multiple patterns
      if (password.isNotEmpty) {
        await _storePasswordWithMultiplePatterns(session, password);
      }

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  /// Internal helper to store a session password under multiple key patterns.
  Future<void> _storePasswordWithMultiplePatterns(
    AppSessionData session,
    String password,
  ) async {
    if (password.isEmpty) return;

    try {
      final secureStorage = SecureStorageService.instance;

      // Store password with multiple patterns for reliable retrieval
      await secureStorage.storePassword(
        'password_${session.userId}_${session.database}',
        password,
      );
      await secureStorage.storePassword(
        'password_${session.userLogin}_${session.database}',
        password,
      );

    } catch (e) {
    }
  }

  /// Attempts to retrieve a stored password using several known key patterns.
  Future<String?> retrievePasswordWithMultiplePatterns(
    Map<String, dynamic> accountData,
  ) async {
    try {
      final secureStorage = SecureStorageService.instance;
      final userId = accountData['id'] ?? accountData['userId'];
      final username = accountData['username'] ?? accountData['email'];
      final database = accountData['database'];

      // Standardized password patterns
      List<String> passwordKeys = [
        'password_${userId}_$database',
        'password_${username}_$database',
      ];

      // Try each password key pattern
      for (String key in passwordKeys) {
        final password = await secureStorage.getPassword(key);
        if (password != null && password.isNotEmpty) {
          return password;
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _saveStoredAccountsWithRetry() async {
    int maxRetries = 3;
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {

        final prefs = await SharedPreferences.getInstance();

        // JSON encode accounts
        final updatedAccountsJson = _storedAccounts
            .map((account) => jsonEncode(account))
            .toList();

        await prefs.setStringList('stored_accounts', updatedAccountsJson);

        return; // Success
      } catch (e) {
        if (attempt == maxRetries) {
        } else {
          await Future.delayed(Duration(milliseconds: 100 * attempt));
        }
      }
    }
  }

  Future<void> removeStoredAccount(int accountIndex) async {
    if (accountIndex < 0 || accountIndex >= _storedAccounts.length) {
      return;
    }

    final accountData = _storedAccounts[accountIndex];

    _storedAccounts.removeAt(accountIndex);
    await _saveStoredAccountsWithRetry();
    notifyListeners();
  }

  /// Directly updates the active session without triggering a full re-authentication.
  Future<bool> updateSessionDirectly(AppSessionData newSession) async {
    try {
      // Update the current session
      _currentSession = newSession;

      // Update OdooSessionManager
      await OdooSessionManager.updateSession(newSession);

      // Also store this session as the active one in SharedPreferences for compatibility
      final prefs = await SharedPreferences.getInstance();
      try {
        // We use a custom JSON format here as expected by some walkthrough patterns
        await prefs.setString('session_data', jsonEncode({
          'user_login': newSession.userLogin,
          'server_url': newSession.serverUrl,
          'database': newSession.database,
          'user_id': newSession.userId,
          'session_id': newSession.sessionId,
          // Add other relevant fields if available in toJson() or manually
        }));
      } catch (e) {
      }

      // Notify listeners
      notifyListeners();

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Switches the active session to a different stored account.
  Future<bool> switchToAccount(AppSessionData newSession) async {
    return await updateSessionDirectly(newSession);
  }

  // Legacy method for compatibility with login provider
  Future<void> updateAccountCredentials(
    String username,
    String password,
  ) async {
    if (_currentSession != null) {
      await _storePasswordWithMultiplePatterns(_currentSession!, password);
    }
  }

  Future<void> _clearStoredAccountsData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('stored_accounts');
      _storedAccounts = [];
    } catch (e) {
    }
  }

  /// Clears all secure password storage.
  Future<void> _clearPasswordCaches() async {
    try {
      // Clear all passwords from secure storage
      await SecureStorageService.instance.clearAll();

    } catch (e) {
    }
  }

  /// Migrate passwords from SharedPreferences to secure storage
  Future<void> _migratePasswordsToSecureStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check if migration already done
      if (prefs.getBool('passwords_migrated') == true) {
        return;
      }

      final secureStorage = SecureStorageService.instance;
      int migratedCount = 0;

      // Migrate all password keys from SharedPreferences
      final allKeys = prefs.getKeys();
      for (final key in allKeys) {
        if (key.startsWith('password_')) {
          final password = prefs.getString(key);
          if (password != null && password.isNotEmpty) {
            await secureStorage.storePassword(key, password);
            await prefs.remove(key);
            migratedCount++;
          }
        }
      }

      // Mark migration as complete
      await prefs.setBool('passwords_migrated', true);
    } catch (e) {
    }
  }
}
