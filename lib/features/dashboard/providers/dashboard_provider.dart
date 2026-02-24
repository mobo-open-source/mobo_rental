
import 'package:flutter/material.dart';
import 'package:mobo_rental/features/dashboard/models/recently_cancelled.dart';
import 'package:mobo_rental/features/dashboard/models/recently_created.dart';
import 'package:mobo_rental/features/dashboard/models/recently_returned_product.dart';
import 'package:mobo_rental/features/dashboard/models/todya_dropoff_moder.dart';
import 'package:mobo_rental/features/dashboard/models/top_customer_model.dart';
import 'package:mobo_rental/Core/services/odoo_session_manager.dart';
import 'package:mobo_rental/features/rental_orders/models/rental_order_item.dart';
import 'package:mobo_rental/features/dashboard/models/todays_pickup_model.dart';

/// A provider that manages the data for the application dashboard.
/// 
/// Handles fetching statistics, upcoming pickups, drop-offs, 
/// top customers, and recently created/cancelled rental orders.
class DashboardProvider extends ChangeNotifier {
  List<RentalOrderItem> rentalOrders = [];
  List<TodaysPickUpItem> todaysPickupItem = [];
  List<TodaysDropOffItem> todaysDroppOffItem = [];
  int todaysPickupCount = 0;
  int todaysDropOffCount = 0;
  static const int _pageSize = 40;
  int _pickupCurrentPage = 0;
  int get pickupCurrentPage => _pickupCurrentPage;

  bool get canGoPreviousPickup => _pickupCurrentPage > 0;
  bool get canGoNextPickup =>
      (_pickupCurrentPage + 1) * _pageSize < todaysPickupCount;

  int get pickupStartIndex =>
      todaysPickupCount == 0 ? 0 : (_pickupCurrentPage * _pageSize) + 1;
  int get pickupEndIndex {
    final int end = (_pickupCurrentPage + 1) * _pageSize;
    return end > todaysPickupCount ? todaysPickupCount : end;
  }

  int _dropOffCurrentPage = 0;
  int get dropOffCurrentPage => _dropOffCurrentPage;

  bool get canGoPreviousDropOff => _dropOffCurrentPage > 0;
  bool get canGoNextDropOff =>
      (_dropOffCurrentPage + 1) * _pageSize < todaysDropOffCount;

  int get dropOffStartIndex =>
      todaysDropOffCount == 0 ? 0 : (_dropOffCurrentPage * _pageSize) + 1;
  int get dropOffEndIndex {
    final int end = (_dropOffCurrentPage + 1) * _pageSize;
    return end > todaysDropOffCount ? todaysDropOffCount : end;
  }

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Marks the dashboard as initialized to prevent redundant fetches.
  void markAsInitialized() {
    _isInitialized = true;
    notifyListeners();
  }

  /// Navigates to the next page of today's pickups.
  Future<void> nextPickupPage() async {
    if (canGoNextPickup) {
      _pickupCurrentPage++;
      await fetchTodaysPickup();
    }
  }

  /// Navigates to the previous page of today's pickups.
  Future<void> previousPickupPage() async {
    if (canGoPreviousPickup) {
      _pickupCurrentPage--;
      await fetchTodaysPickup();
    }
  }

  String errorMessage = '';
  double finalTotal = 0;
  double upcomingReturns = 0;
  int overDueRental = 0;
  int rentableProductsCount = 0;

  bool isRentalOrderLoading = true;

  bool isProductLoading = false;
  bool isfetchTodaysPickLoading = false;
  bool isfetchTodaysDropLoading = false;

  bool todaysPickupCountLoading = false;
  bool todyasDropOffCountLoading = false;

  /// Fetches the count of rental orders scheduled for pickup today.
  Future<void> fetchTodaysPickupCount() async {
    if (!OdooSessionManager.hasSession) return;
    todaysPickupCountLoading = true;
    notifyListeners();
    try {
      final count = await OdooSessionManager.callKwWithCompany({
        'model': 'sale.order',
        'method': 'search_count',
        'args': [
          [
            '&',
            ['is_rental_order', '=', true],
            '&',
            ['next_action_date', '>=', 'today'],
            ['rental_status', '=', 'pickup'],
          ],
        ],
        'kwargs': {},
      });
      todaysPickupCountLoading = false;

      todaysPickupCount = count;
      notifyListeners();
    } catch (e) {
      todaysPickupCountLoading = false;
      todaysPickupCount = 0;
      notifyListeners();
    }
  }

  /// Fetches the list of rental orders scheduled for pickup today.
  Future<void> fetchTodaysPickup({bool resetPage = false}) async {
    if (!OdooSessionManager.hasSession) return;
    isfetchTodaysPickLoading = true;
    errorMessage = '';

    if (resetPage) {
      _pickupCurrentPage = 0;
      todaysPickupItem.clear();
    }

    notifyListeners();

    try {
      await fetchTodaysPickupCount();

      final int offset = _pickupCurrentPage * _pageSize;

      final response = await OdooSessionManager.callKwWithCompany({
        'model': 'sale.order',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'fields': [
            'partner_id',
            'name',
            'amount_total',
            'rental_status',
            'is_late',
            'next_action_date',
          ],
          'domain': [
            '&',
            ['is_rental_order', '=', true],
            '&',
            ['next_action_date', '>=', 'today'],
            ['rental_status', '=', 'pickup'],
          ],
          'limit': _pageSize,
          'offset': offset,
          'order': 'next_action_date asc',
        },
      });

      todaysPickupItem = response
          .map<TodaysPickUpItem>((item) => TodaysPickUpItem.fromJson(item))
          .toList();

      isfetchTodaysPickLoading = false;
      notifyListeners();
    } catch (e) {
      isfetchTodaysPickLoading = false;
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Fetches the count of rental orders scheduled for drop-off today.
  Future<void> fetchTodaysDropOffCount() async {
    if (!OdooSessionManager.hasSession) return;
    todyasDropOffCountLoading = true;
    notifyListeners();
    try {
      final count = await OdooSessionManager.callKwWithCompany({
        'model': 'sale.order',
        'method': 'search_count',
        'args': [
          [
            '&',
            ['is_rental_order', '=', true],
            '&',
            '&',
            ['next_action_date', '>=', 'today'],
            ['next_action_date', '<', 'today +1d'],
            ['rental_status', '=', 'return'],
          ],
        ],
        'kwargs': {},
      });
      todyasDropOffCountLoading = false;
      todaysDropOffCount = count;
      notifyListeners();
    } catch (e) {
      todyasDropOffCountLoading = false;
      todaysDropOffCount = 0;
      notifyListeners();
    }
  }

  /// Navigates to the next page of today's drop-offs.
  Future<void> nextDropOffPage() async {
    if (canGoNextDropOff) {
      _dropOffCurrentPage++;
      await fetchTodaysDropOff();
    }
  }

  /// Navigates to the previous page of today's drop-offs.
  Future<void> previousDropOffPage() async {
    if (canGoPreviousDropOff) {
      _dropOffCurrentPage--;
      await fetchTodaysDropOff();
    }
  }

  /// Fetches the list of rental orders scheduled for drop-off today.
  Future<void> fetchTodaysDropOff({bool resetPage = false}) async {
    if (!OdooSessionManager.hasSession) return;
    isfetchTodaysDropLoading = true;
    errorMessage = '';

    if (resetPage) {
      _dropOffCurrentPage = 0;
      todaysDroppOffItem.clear();
    }

    notifyListeners();

    try {
      await fetchTodaysDropOffCount();

      final int offset = _dropOffCurrentPage * _pageSize;

      final response = await OdooSessionManager.callKwWithCompany({
        'model': 'sale.order',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'fields': [
            'partner_id',
            'name',
            'amount_total',
            'rental_status',
            'is_late',
            'next_action_date',
          ],
          'domain': [
            '&',
            ['is_rental_order', '=', true],
            '&',
            '&',
            ['next_action_date', '>=', 'today'],
            ['next_action_date', '<', 'today +1d'],
            ['rental_status', '=', 'return'],
          ],
          'limit': _pageSize,
          'offset': offset,
          'order': 'next_action_date asc',
        },
      });

      todaysDroppOffItem = response
          .map<TodaysDropOffItem>((item) => TodaysDropOffItem.fromJson(item))
          .toList();

      isfetchTodaysDropLoading = false;
      notifyListeners();
    } catch (e) {
      isfetchTodaysDropLoading = false;
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Fetches all rental orders for the dashboard summary.
  Future<void> fetchRentalOrders({
    int? currentCompanyId,
    bool isRetry = false,
  }) async {
    if (!OdooSessionManager.hasSession) return;
    if (!isRetry) {
      isRentalOrderLoading = true;
      finalTotal = 0;
      upcomingReturns = 0;
      overDueRental = 0;
      errorMessage = '';
      notifyListeners();
    }

    try {
      final response = await OdooSessionManager.callKwWithCompany({
        'model': 'sale.order',
        'method': 'search_read',
        'args': [
          [
            ['is_rental_order', '=', true],
          ],
        ],
        'kwargs': {
          'fields': [
            'partner_id',
            'name',
            'amount_total',
            'rental_status',
            'is_late',
          ],
        },
      });

      rentalOrders = [];
      finalTotal = 0;
      upcomingReturns = 0;
      overDueRental = 0;

      for (final order in response) {
        finalTotal += (order['amount_total'] ?? 0).toDouble();

        if (order['is_late'] == true) {
          overDueRental++;
        }

        if (order['rental_status'] == 'pickup') {
          upcomingReturns++;
        }
      }

      rentalOrders = response
          .map<RentalOrderItem>((item) => RentalOrderItem.fromJson(item))
          .toList();

      isRentalOrderLoading = false;
      notifyListeners();
    } catch (e) {
      isRentalOrderLoading = false;
      errorMessage = e.toString();
      rentalOrders = [];
      notifyListeners();
    }
  }

  /// Fetches the total number of active, rentable products.
  Future<void> fetchTotalProducts() async {
    if (!OdooSessionManager.hasSession) return;
    isProductLoading = true;
    rentableProductsCount = 0;
    errorMessage = '';
    notifyListeners();

    try {
      final count = await OdooSessionManager.callKwWithCompany({
        'model': 'product.template',
        'method': 'search_count',
        'args': [
          [
            ['rent_ok', '=', true],
            ['active', '=', true],
          ],
        ],
        'kwargs': {},
      });

      rentableProductsCount = count is int ? count : 0;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isProductLoading = false;
      notifyListeners();
    }
  }

  bool activeCustomersLoading = false;
  int activeCustomerCount = 0;

  /// Fetches the count of customers currently having active rentals.
  Future<void> fetchActiveCustomersCount() async {
    if (!OdooSessionManager.hasSession) return;
    activeCustomersLoading = true;
    notifyListeners();

    try {
      final today = DateTime.now().toIso8601String().split('T').first;

      final result = await OdooSessionManager.callKwWithCompany({
        'model': 'sale.order.line',
        'method': 'search_read',
        'args': [
          [
            ['is_rental', '=', true],
            [
              'state',
              'in',
              ['sale', 'done'],
            ],
            ['start_date', '<=', today],
            ['return_date', '>=', today],
          ],
        ],
        'kwargs': {
          'fields': ['order_partner_id'],
        },
      });

      final Set<int> customerIds = {};

      for (final row in result as List) {
        final partner = row['order_partner_id'];
        if (partner is List && partner.isNotEmpty && partner[0] is int) {
          customerIds.add(partner[0]);
        }
      }

      activeCustomerCount = customerIds.length;
    } catch (e) {
      activeCustomerCount = 0;
    } finally {
      activeCustomersLoading = false;
      notifyListeners();
    }
  }

  // dashboard overdue customer count
  bool overdueCustomersLoading = false;
  int overdueCustomerCount = 0;

  /// Fetches the count of customers with overdue rental returns.
  Future<void> fetchCustomersWithOverduesCount() async {
    if (!OdooSessionManager.hasSession) return;
    overdueCustomersLoading = true;
    notifyListeners();

    try {
      // 1. Get Client and Version
      final client = await OdooSessionManager.getClient();
      int majorVersion = 0;

      if (client != null && client.sessionId != null) {
        final String serverVersionString = client.sessionId!.serverVersion;
        majorVersion = int.tryParse(serverVersionString.split('.').first) ?? 0;
      }

      final now = DateTime.now().toIso8601String();

      List<dynamic> domain = [
        ['is_rental', '=', true],
        [
          'state',
          'in',
          ['sale', 'done'],
        ],
        ['return_date', '<', now],
      ];

      if (majorVersion >= 19) {
        domain.add(['is_late', '=', true]);
      }

      List<String> fieldsToFetch = ['order_partner_id'];
      if (majorVersion < 19) {
        fieldsToFetch.addAll(['qty_delivered', 'qty_returned']);
      }

      final result = await OdooSessionManager.callKwWithCompany({
        'model': 'sale.order.line',
        'method': 'search_read',
        'args': [domain],
        'kwargs': {'fields': fieldsToFetch},
      });

      final Set<int> customerIds = {};

      for (final row in result as List) {
        if (majorVersion < 19) {
          final double delivered = row['qty_delivered'] ?? 0.0;
          final double returned = row['qty_returned'] ?? 0.0;
          if (returned >= delivered) {
            continue;
          }
        }

        final partner = row['order_partner_id'];
        if (partner is List && partner.isNotEmpty && partner[0] is int) {
          customerIds.add(partner[0]);
        }
      }

      overdueCustomerCount = customerIds.length;
    } catch (e) {
      overdueCustomerCount = 0;
    } finally {
      overdueCustomersLoading = false;
      notifyListeners();
    }
  }

  bool topCustomersLoading = false;
  List<TopCustomerItem> topRentalCustomers = [];
  /// Fetches the top customers based on rental frequency.
  Future<void> fetchTopRentalCustomers({int limit = 5}) async {
    if (!OdooSessionManager.hasSession) return;
    topCustomersLoading = true;
    topRentalCustomers.clear();
    notifyListeners();


    try {

      final rentalGroups = await OdooSessionManager.callKwWithCompany({
        'model': 'sale.order.line',
        'method': 'read_group',
        'args': [],
        'kwargs': {
          'domain': [
            ['is_rental', '=', true],
            [
              'order_id.state',
              'in',
              ['sale', 'done'],
            ],
            ['order_partner_id', '!=', false],
          ],
          'fields': ['order_partner_id'],
          'groupby': ['order_partner_id'],
          'orderby': 'order_partner_id_count desc',
          'limit': limit,
        },
      });


      final Map<int, int> rentalCountByPartner = {};

      if (rentalGroups is List) {
        for (final group in rentalGroups) {
          final partnerData = group['order_partner_id'];
          final count = group['order_partner_id_count'];

          if (partnerData is List && partnerData.length == 2 && count is int) {
            rentalCountByPartner[partnerData[0] as int] = count;
          }
        }
      } else {
      }


      if (rentalCountByPartner.isEmpty) {
        topRentalCustomers = [];
        return;
      }

      final partnerIds = rentalCountByPartner.keys.toList();

      final partners = await OdooSessionManager.callKwWithCompany({
        'model': 'res.partner',
        'method': 'read',
        'args': [partnerIds],
        'kwargs': {
          'fields': ['id', 'complete_name', 'image_128'],
        },
      });


      final List<TopCustomerItem> result = [];

      if (partners is List) {
        for (final partner in partners) {
          final partnerId = partner['id'];
          final rentalCount = rentalCountByPartner[partnerId];

          if (partnerId is int && rentalCount != null) {
            result.add(
              TopCustomerItem(
                customerId: partnerId,
                customerName: (partner['complete_name'] as String?) ?? '',
                rentalCount: rentalCount,
                avatarBytes: TopCustomerItem.decodeAvatar(partner['image_128']),
                avatarBase64: partner['image_128'] is String
                    ? partner['image_128']
                    : null,
              ),
            );
          }
        }
      }

      result.sort((a, b) => b.rentalCount.compareTo(a.rentalCount));
      topRentalCustomers = result;

    } catch (e, stackTrace) {
      // Log both the error and the stack trace
      topRentalCustomers = [];
    } finally {
      topCustomersLoading = false;
      notifyListeners();
    }
  }

  List<RecentlyCreatedRentalOrderItem> recentlyCreatedRentalOrders = [];
  bool fetchingRecentlyCreated = true;

  /// Fetches the most recently created rental orders.
  Future<void> fetchRecentlyCreatedRentalOrders({int limit = 1}) async {
    if (!OdooSessionManager.hasSession) return;
    fetchingRecentlyCreated = true;
    recentlyCreatedRentalOrders.clear();
    notifyListeners();

    try {
      final result = await OdooSessionManager.callKwWithCompany({
        'model': 'sale.order',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'domain': [
            ['is_rental_order', '=', true],
            [
              'rental_status',
              'in',
              ['draft', 'pickup'],
            ],
          ],
          'fields': [
            'id',
            'name',
            'partner_id',
            'amount_total',
            'rental_status',
            'date_order',
            'create_date',
            'is_late',
          ],
          'order': 'create_date desc',
          'limit': limit,
        },
      });

      recentlyCreatedRentalOrders = (result as List)
          .map<RecentlyCreatedRentalOrderItem>(
            (e) => RecentlyCreatedRentalOrderItem.fromJson(e),
          )
          .toList();
    } catch (_) {
      recentlyCreatedRentalOrders = [];
    } finally {
      fetchingRecentlyCreated = false;
      notifyListeners();
    }
  }

  List<ReturnedProductItem> recentlyReturnedProducts = [];
  bool fetchingRecentlyReturned = true;

  /// Fetches products that have been recently returned.
  Future<void> fetchRecentlyReturnedProducts({int limit = 1}) async {
    if (!OdooSessionManager.hasSession) return;
    fetchingRecentlyReturned = true;
    recentlyReturnedProducts.clear();
    notifyListeners();

    try {
      final result = await OdooSessionManager.callKwWithCompany({
        'model': 'sale.order.line',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'domain': [
            ['is_rental', '=', true],
            ['order_id.is_rental_order', '=', true],
            ['order_id.rental_status', '=', 'return'],
          ],
          'fields': ['id', 'product_id', 'order_id', 'write_date'],
          'order': 'write_date desc',
          'limit': limit,
        },
      });
      recentlyReturnedProducts = (result as List)
          .map<ReturnedProductItem>((e) => ReturnedProductItem.fromJson(e))
          .toList();
    } catch (e) {

      recentlyReturnedProducts = [];
    } finally {
      fetchingRecentlyReturned = false;
      notifyListeners();
    }
  }

  List<RecentlyCancelledRentalOrderItem> recentlyCancelledRentalOrders = [];
  bool fetchingRecentlyCancelled = true;

  /// Fetches the most recently cancelled rental orders.
  Future<void> fetchRecentlyCancelledRentalOrders({int limit = 40}) async {
    if (!OdooSessionManager.hasSession) return;
    fetchingRecentlyCancelled = true;
    recentlyCancelledRentalOrders.clear();
    notifyListeners();

    try {
      final result = await OdooSessionManager.callKwWithCompany({
        'model': 'sale.order',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'domain': [
            ['is_rental_order', '=', true],
            ['state', '=', 'cancel'],
          ],
          'fields': [
            'id',
            'name',
            'partner_id',
            'amount_total',
            'state',
            'write_date',
          ],
          'order': 'write_date desc',
          'limit': limit,
        },
      });

      recentlyCancelledRentalOrders = (result as List)
          .map<RecentlyCancelledRentalOrderItem>((e) {
            final data = Map<String, dynamic>.from(e);
            if (data['rental_status'] == null) data['rental_status'] = 'cancel';
            return RecentlyCancelledRentalOrderItem.fromJson(data);
          })
          .toList();
    } catch (e) {
      recentlyCancelledRentalOrders = [];
    } finally {
      fetchingRecentlyCancelled = false;
      notifyListeners();
    }
  }

  /// Resets all dashboard data to initial states.
  void clearAll() {
    _isInitialized = false;
    rentalOrders.clear();
    todaysPickupItem.clear();
    todaysDroppOffItem.clear();

    recentlyCreatedRentalOrders.clear();
    recentlyReturnedProducts.clear();
    recentlyCancelledRentalOrders.clear();

    topRentalCustomers.clear();

    finalTotal = 0;
    upcomingReturns = 0;
    overDueRental = 0;
    rentableProductsCount = 0;
    activeCustomerCount = 0;
    overdueCustomerCount = 0;

    errorMessage = '';

    isRentalOrderLoading = false;
    isProductLoading = false;
    isfetchTodaysPickLoading = false;
    isfetchTodaysDropLoading = false;
    activeCustomersLoading = false;
    overdueCustomersLoading = false;
    topCustomersLoading = false;
    fetchingRecentlyCreated = false;
    fetchingRecentlyCancelled = false;
    fetchingRecentlyReturned = false;

    notifyListeners();
  }

  /// Refreshes all dashboard data, typically called after a company switch.
  Future<void> dashboardCompanySwitch() async {
    await Future.wait([
      fetchRentalOrders(),
      fetchTotalProducts(),
      fetchTodaysDropOff(),
      fetchTodaysPickup(),
      fetchActiveCustomersCount(),
      fetchCustomersWithOverduesCount(),
      fetchTopRentalCustomers(),
      fetchRecentlyCreatedRentalOrders(limit: 1),
      fetchRecentlyReturnedProducts(limit: 1),
      fetchRecentlyCancelledRentalOrders(limit: 1),
    ]);
  }
}
