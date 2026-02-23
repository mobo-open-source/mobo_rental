import 'package:flutter/material.dart';

/// Provider for managing the active tab index in the main navigation screen.
class HomeTabProvider extends ChangeNotifier {
  int _currentIndex = 0;

  /// The current active tab index.
  int get currentIndex => _currentIndex;

  /// Updates the active tab index and notifies listeners if it changed.
  void setTab(int index) {
    if (_currentIndex != index) {
      _currentIndex = index;
      notifyListeners();
    }
  }
}
