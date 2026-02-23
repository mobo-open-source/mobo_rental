import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobo_rental/features/dashboard/providers/dashboard_provider.dart';

extension DashboardRefresh on BuildContext {

  void refreshDashboard() {
    try {

      read<DashboardProvider>().clearAll();
    } catch (e) {
    }
  }
}
