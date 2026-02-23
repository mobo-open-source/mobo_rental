import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobo_rental/features/company/isar_database.dart';
import 'package:mobo_rental/features/login/models/account_entity.dart';
import 'package:isar_community/isar.dart';
import 'package:odoo_rpc/odoo_rpc.dart';

class StorageService {
  /// Persists a core Odoo session object to shared preferences.
  Future<void> saveSession(OdooSession session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('sessionId', session.id);
    await prefs.setInt('userId', session.userId);
    await prefs.setInt('partnerId', session.partnerId);
    await prefs.setString('userLogin', session.userLogin);
    await prefs.setString('userName', session.userName);
    await prefs.setString('userLang', session.userLang);
    await prefs.setString('userTz', session.userTz);
    await prefs.setBool('isSystem', session.isSystem);
    await prefs.setString('dbName', session.dbName);
    await prefs.setString('serverVersion', session.serverVersion);
    await prefs.setInt('companyId', session.companyId);
  }

  /// Saves basic login state and credentials to shared preferences.
  Future<void> saveLoginState({
    required bool isLoggedIn,
    required String database,
    required String url,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', isLoggedIn);
    await prefs.setString('dbName', database);
    await prefs.setString('uri', url);
    await prefs.setString('password', password);
  }

  /// Retrieves the persisted login status and credentials.
  Future<Map<String, dynamic>> getLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'isLoggedIn': prefs.getBool('isLoggedIn') ?? false,
      'logoutAction': prefs.getBool('logoutAction') ?? false,
      'dbName': prefs.getString('dbName') ?? '',
      'uri': prefs.getString('uri') ?? '',
      'password': prefs.getString('password') ?? '',
    };
  }

  static const _accountsKey = 'loggedInAccounts';

  /// Adds or updates an account in the stored accounts list.
  Future<void> saveAccount(Map<String, dynamic> account) async {
    final prefs = await SharedPreferences.getInstance();
    final accounts = await getAccounts();

    accounts.removeWhere((a) =>
        a['userId'].toString() == account['userId'].toString() &&
        a['uri'] == account['uri'] &&
        a['dbName'] == account['dbName']);

    accounts.add(account);

    await prefs.setString(_accountsKey, jsonEncode(accounts));
    
    // Also save to Isar for backward compatibility if needed, or if Isar is used for profile data
    try {
       // We can keep the existing Isar saving logic if acceptable, or adapt it.
       // The user's code snippet uses a different Isar approach. 
       // However, the user provided a 'StorageService' that replaces the existing one's logic for 'saveAccount'.
       // I will comment out the old Isar logic to avoid conflicts for now, or adapt it if I can import IsarDatabase.
       // The user's provided code for StorageService DOES NOT have the Isar logic in it, it fully replaces it.
       // So I will append the NEW methods and if the old one conflicts, I will replace it.
       // Wait, the user provided a FULL StorageService file content in the prompt. 
       // I should probably REPLACE the entire file content or merge strictly.
       // The user's provided StorageService has 'saveSession', 'saveLoginState', 'getLoginStatus', 'saveAccount', 'getAccounts', 'clearAccounts'.
       // The existing file has 'saveSession', 'saveLoginState', 'saveAccount' (Isar).
       // I will merge them. The user's 'saveAccount' saves to SharedPreferences list. The existing 'saveAccount' saves to Isar.
       // I will rename existing 'saveAccount' to 'saveAccountToIsar' if needed, OR just use the user's version since that's what's requested for switching.
       // Actually, the prompt says "Storage Service... handles the underlying storage of the account list via saveAccount and getAccounts".
       // So I should implement the list-based saveAccount.
    } catch (e) {
    }
  }

  /// Retrieves the list of all stored accounts.
  Future<List<Map<String, dynamic>>> getAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final accountsJson = prefs.getString(_accountsKey);
    if (accountsJson == null) return [];
    try {
      final decoded = jsonDecode(accountsJson) as List<dynamic>;
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  /// Clears the list of stored accounts from shared preferences.
  Future<void> clearAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accountsKey);
  }
}

