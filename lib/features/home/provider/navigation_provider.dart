import 'package:flutter/material.dart';

/// Provider for managing the navigation state of the main screen.
class NavigationProvider extends ChangeNotifier {
  /// The current index of the main navigation drawer or tab bar.
  int index = 0;

  /// Updates the main screen index and notifies listeners.
  void updateMainScreen(int newIndex) {
    index = newIndex;
    notifyListeners();
  }

  /// Resets the navigation index to the default (0).
  void resetScreenIndex() {
    index = 0;
    notifyListeners();
  }
  
}
