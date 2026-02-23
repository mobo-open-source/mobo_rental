
import 'package:flutter/material.dart';
import 'package:mobo_rental/Core/services/odoo_session_manager.dart';
import 'package:provider/provider.dart';

/// A provider that manages the information of the currently logged-in user.
class UserProvider extends ChangeNotifier {
  String? userName;
  String? userImage;
  bool userInfoLoading = false;
  int? userId;

  /// Returns a time-appropriate greeting for the user.
  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'Good Morning';
    if (hour >= 12 && hour < 18) return 'Good Afternoon';
    return 'Good Evening';
  }

  /// Fetches the details (name and image) of the current user from Odoo.
  Future<void> getCurrentUserDetails(BuildContext context) async {
    if (!OdooSessionManager.hasSession) return;
    userInfoLoading = true;
    notifyListeners();

    try {
      final session = await OdooSessionManager.getCurrentSession();
      if (session == null || session.userId == null) {
        userInfoLoading = false;
        notifyListeners();
        return;
      }

      final response = await OdooSessionManager.callKwWithCompany({
        'model': 'res.users',
        'method': 'search_read',

        'args': [
          [
            ['id', '=', session.userId],
          ],
        ],
        'kwargs': {
          'fields': ['name', 'image_1920'],
          'limit': 1,
        },
      });
      if (response is List && response.isNotEmpty) {
        final user = response[0] as Map<String, dynamic>;
        userId = session.userId;
        userName = user['name'];

        if (user['image_1920'] is String) {
          userImage = user['image_1920'];
        } else {
          userImage = null;
        }
      }
    } catch (e) {
    } finally {
      userInfoLoading = false;
      notifyListeners();
    }
  }

  /// Resets user information to initial state.
  /// Resets user information and notifies listeners.
  void resetUser() {
    userName = null;
    userImage = null;
    userId = null;
    userInfoLoading = false;
    notifyListeners();
  }
}
