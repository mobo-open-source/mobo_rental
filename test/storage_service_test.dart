import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:mobo_rental/Core/services/storage_service.dart';

void main() {
  test('StorageService stores and retrieves accounts correctly', () async {
    SharedPreferences.setMockInitialValues({});
    final storageService = StorageService();

    final account1 = {
      'userId': '1',
      'uri': 'http://test.com',
      'dbName': 'test_db',
      'name': 'User 1',
       'email': 'user1@test.com',
      'image': '',
      'sessionId': 'session1',
    };

    await storageService.saveAccount(account1);

    final accounts = await storageService.getAccounts();
    expect(accounts.length, 1);
    expect(accounts[0]['userId'], '1');
    expect(accounts[0]['uri'], 'http://test.com');
  });
}
