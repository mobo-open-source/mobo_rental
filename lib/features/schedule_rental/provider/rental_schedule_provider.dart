
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobo_rental/Core/services/odoo_session_manager.dart';
import 'package:mobo_rental/features/schedule_rental/model/renatl_shcedule_model.dart';
import 'package:provider/provider.dart';

/// Provider for managing the rental schedule (Gantt-like view data).
class RentalScheduleProvider extends ChangeNotifier {
  String? error;
  String _mapErrorToMessage(dynamic error) {
    final message = error.toString().toLowerCase();

    if (message.contains('permission') || message.contains('access')) {
      return 'You do not have permission to view rental schedules.';
    }
    if (message.contains('socket') ||
        message.contains('network') ||
        message.contains('timeout')) {
      return 'Unable to connect to server. Please check your internet connection.';
    }
    if (message.contains('session') || message.contains('authentication')) {
      return 'Your session has expired. Please log in again.';
    }

    return 'Failed to load rental schedule. Please try again.';
  }

  /// Resets the provider to its initial state.
  void resetProvider() {
    selectedMonth = DateTime.now();
    loading = false;
    _items.clear();
    error = null;

    notifyListeners();
  }

  DateTime selectedMonth = DateTime.now();
  bool loading = true;

  final List<RentalScheduleItem> _items = [];
  List<RentalScheduleItem> get items => _items;

  Future<void> changeMonth(DateTime month, BuildContext context) async {
    selectedMonth = month;
    await fetchRentalSchedule(context);
  }

  Future<void> fetchRentalSchedule(BuildContext context) async {
    loading = true;
    notifyListeners();

    _items.clear();

    final DateTime monthStart = DateTime(
      selectedMonth.year,
      selectedMonth.month,
      1,
    );

    final DateTime monthEnd = DateTime(
      selectedMonth.year,
      selectedMonth.month + 1,
      0,
      23,
      59,
      59,
    );

    final String startDate = DateFormat(
      'yyyy-MM-dd HH:mm:ss',
    ).format(monthStart.toUtc());
    final String stopDate = DateFormat(
      'yyyy-MM-dd HH:mm:ss',
    ).format(monthEnd.toUtc());

    try {
      error = null;

      final client = await OdooSessionManager.getClient();
      final String serverVersionString = client!.sessionId!.serverVersion;
      // Parse the major version (e.g., 17, 18, 19)
      final int majorVersion = int.parse(serverVersionString.split('.').first);

      final Map<String, dynamic> readSpecification = {
        'display_name': {},
        'start_date': {},
        'return_date': {},
        'product_uom_qty': {},
        'state': {},
        'product_id': {
          'fields': {'display_name': {}, 'image_128': {}},
        },
        'order_id': {
          'fields': {'display_name': {}, 'rental_status': {}},
        },
      };

      if (majorVersion >= 19) {
        readSpecification.addAll({
          'rental_status': {},
          'is_late': {},
          'rental_color': {},
        });
      }

      // 1. Define the base arguments that work for all versions (17, 18, 19)
      final Map<String, dynamic> rpcKwargs = {
        'domain': [
          ['is_rental', '=', true],
          [
            'order_id.rental_status',
            'not in',
            ['draft', 'cancel', 'sent'],
          ],
          ['start_date', '<', stopDate],
          ['return_date', '>', startDate],
        ],
        'groupby': ['product_id'],
        'read_specification': readSpecification,
        'limit': 40,
        'offset': 0,
        'context': {
          'in_rental_schedule': 1,
          'group_by': ['product_id'],
        },
      };

      if (majorVersion >= 18) {
        rpcKwargs['scale'] = 'month';
        rpcKwargs['start_date'] = startDate;
        rpcKwargs['stop_date'] = stopDate;
      }

      final result = await OdooSessionManager.callKwWithCompany({
        'model': 'sale.order.line',
        'method': 'get_gantt_data',
        'args': [],
        'kwargs': rpcKwargs,
      });

      if (result != null && result['records'] != null) {
        final List<dynamic> records = result['records'];

        final parsedItems = records
            .map(
              (data) => RentalScheduleItem.fromGanttRecord(
                data as Map<String, dynamic>,
              ),
            )
            .toList();

        _items.addAll(parsedItems);
      }
    } catch (e) {
      error = _mapErrorToMessage(e);

    }

    loading = false;
    notifyListeners();
  }

  /// Returns a map of schedule items grouped by their product ID.
  Map<String, List<RentalScheduleItem>> get groupedByProduct {
    final Map<String, List<RentalScheduleItem>> map = {};

    for (final item in _items) {
      final key = "${item.productId}|${item.productName}";
      map.putIfAbsent(key, () => []);
      map[key]!.add(item);
    }

    return map;
  }

  /// Called when switching companies to refresh the schedule.
  void scheduleScreenCompanySwitch(BuildContext context) {
    fetchRentalSchedule(context);
  }
}
