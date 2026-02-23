
import 'package:flutter/material.dart';
import 'package:mobo_rental/Core/services/odoo_session_manager.dart';

/// A provider that manages product data, search, and filtering logic.
class ProductProvider extends ChangeNotifier {
  bool _hasProductAdminAccess = false;
  bool _permissionsLoaded = false;

  bool get canCreateProduct => _hasProductAdminAccess;
  bool get permissionsLoaded => _permissionsLoaded;

  /// Loads the user's permissions for product creation from Odoo.
  Future<void> loadPermissions() async {
    try {
      final client = await OdooSessionManager.getClient();

      if (client == null || client.sessionId == null) {
        _hasProductAdminAccess = false;
        _permissionsLoaded = true;
        notifyListeners();
        return;
      }

      final bool canCreateProduct = await client.callKw({
        'model': 'product.product',
        'method': 'check_access_rights',
        'args': ['create'],
        'kwargs': {'raise_exception': false},
      });

      _hasProductAdminAccess = canCreateProduct;
    } catch (error) {
      _hasProductAdminAccess = false;
    } finally {
      _permissionsLoaded = true;
      notifyListeners();
    }
  }
 
  List<dynamic> _products = [];
  bool _isLoading = true;
  String? _error;

  // Pagination
  int _currentOffset = 0;
  final int _limit = 40;
  int _totalCount = 0;
  String _currentSearchQuery = '';

  // Filter State
  bool _showServicesOnly = false;
  bool _showConsumablesOnly = false;
  bool _showStorableOnly = false;
  bool _showAvailableOnly = false;

  // Group By State
  final Map<String, String> _groupByOptions = {};
  String? _selectedGroupBy;
  final Map<String, int> _groupSummary = {};
  final Map<String, List<dynamic>> _loadedGroups = {};

  // Getters
  List<dynamic> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalCount => _totalCount;
  int get currentOffset => _currentOffset;
  int get limit => _limit;

  // Filter Getters
  bool get showServicesOnly => _showServicesOnly;
  bool get showConsumablesOnly => _showConsumablesOnly;
  bool get showStorableOnly => _showStorableOnly;
  bool get showAvailableOnly => _showAvailableOnly;

  // Group By Getters
  Map<String, String> get groupByOptions => _groupByOptions;
  String? get selectedGroupBy => _selectedGroupBy;
  bool get isGrouped => _selectedGroupBy != null;
  Map<String, int> get groupSummary => _groupSummary;

  bool get hasNextPage => _currentOffset + _limit < _totalCount;
  bool get hasPreviousPage => _currentOffset > 0;

  int get startRecord => _totalCount == 0 ? 0 : _currentOffset + 1;
  int get endRecord => (_currentOffset + _limit) > _totalCount
      ? _totalCount
      : (_currentOffset + _limit);

  // Clear all data (used when switching accounts)
  /// Clears all product data and resets filters.
  Future<void> clearData() async {
    _products.clear();
    _isLoading = false;
    _error = null;

    _currentOffset = 0;
    _totalCount = 0;
    _currentSearchQuery = '';

    _showServicesOnly = false;
    _showConsumablesOnly = false;
    _showStorableOnly = false;
    _showAvailableOnly = false;

    _selectedGroupBy = null;
    _groupSummary.clear();
    _loadedGroups.clear();

    notifyListeners();
  }

  bool _hasStockModule = false;
  bool get hasStockModule => _hasStockModule;

  int get activeFiltersCount {
    int count = 0;

    if (_showServicesOnly) count++;
    if (_showConsumablesOnly) count++;
    if (_showStorableOnly) count++;
    if (_showAvailableOnly) count++;

    return count;
  }

  Future<void> checkStockModuleInstalled() async {
    final result = await OdooSessionManager.callKwWithCompany({
      'model': 'ir.module.module',
      'method': 'search_count',
      'args': [
        [
          ['name', '=', 'stock'],
          ['state', '=', 'installed'],
        ],
      ],
      'kwargs': {},
    });

    _hasStockModule = result is int && result > 0;
  }

  /// Fetches a paginated list of products from Odoo.
  Future<void> loadProducts({int offset = 0, String search = ''}) async {
    final fields = [
      'name',
      'default_code',
      'list_price',
      'display_price',
      'image_128',
      'uom_id',
      'taxes_id',
      'categ_id',
      'currency_id',
    ];

    if (_hasStockModule) {
      fields.add('qty_available');
    }
    try {
      _isLoading = true;
      _error = null;
      _currentOffset = offset;
      _currentSearchQuery = search;
      notifyListeners();

      final domain = _buildDomain(search);

      // Get total count first
      final countResult = await OdooSessionManager.callKwWithCompany({
        'model': 'product.product',
        'method': 'search_count',
        'args': [domain],
        'kwargs': {},
      });
      _totalCount = countResult is int ? countResult : 0;

      // Get records
      final result = await OdooSessionManager.callKwWithCompany({
        'model': 'product.product',
        'method': 'search_read',
        'args': [domain],
        'kwargs': {
          'fields': fields,
          'offset': offset,
          'limit': _limit,
          'order': 'name asc',
        },
      });

      if (result is List) {
        _products = result;
      } else {
        _products = [];
      }
    } catch (e) {

      _error = _getUserFriendlyErrorMessage(e);
      _products = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Convert technical errors to user-friendly messages
  String _getUserFriendlyErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('socketexception') ||
        errorString.contains('failed host lookup') ||
        errorString.contains('no address associated') ||
        errorString.contains('connection refused') ||
        errorString.contains('connection timeout') ||
        errorString.contains('host unreachable') ||
        errorString.contains('no route to host') ||
        errorString.contains('network is unreachable') ||
        errorString.contains('failed to connect') ||
        errorString.contains('connection failed')) {
      return 'Unable to connect to server. Please check your internet connection.';
    } else if (errorString.contains('timeout') ||
        errorString.contains('timed out')) {
      return 'Connection timed out. Please check your internet connection and try again.';
    } else if (errorString.contains('html instead of json') ||
        errorString.contains('formatexception')) {
      return 'Server configuration issue. Please contact your administrator.';
    } else if (errorString.contains('session') ||
        errorString.contains('authentication')) {
      return 'Your session has expired. Please log in again.';
    } else if (errorString.contains('access') ||
        errorString.contains('permission')) {
      return 'You do not have permission to access products. Please contact your administrator.';
    }

    return 'Unable to load products. Please try again or contact support.';
  }

  /// Searches for products matching the given [query].
  Future<void> searchProducts(String query) async {
    await loadProducts(offset: 0, search: query);
  }

  /// Navigates to the next page of products.
  Future<void> goToNextPage() async {
    if (hasNextPage) {
      await loadProducts(
        offset: _currentOffset + _limit,
        search: _currentSearchQuery,
      );
    }
  }

  /// Navigates to the previous page of products.
  Future<void> goToPreviousPage() async {
    if (hasPreviousPage) {
      await loadProducts(
        offset: _currentOffset - _limit,
        search: _currentSearchQuery,
      );
    }
  }

  List<dynamic> _buildDomain(String search) {
    final List<dynamic> domain = [
      ['rent_ok', '=', true],
      ['active', '=', true],
    ];

    if (search.isNotEmpty) {
      domain.add('|');
      domain.add(['name', 'ilike', search]);
      domain.add(['default_code', 'ilike', search]);
    }

    if (_showServicesOnly) {
      domain.add(['type', '=', 'service']);
    }
    if (_showConsumablesOnly) {
      domain.add(['type', '=', 'consu']);
    }
    if (_showStorableOnly) {
      domain.add(['type', '=', 'product']);
    }
    if (_showAvailableOnly) {
      domain.add(['qty_available', '>', 0]);
    }

    return domain;
  }

  /// Updates the current filter state and notifies listeners.
  void setFilterState({
    bool? showServicesOnly,
    bool? showConsumablesOnly,
    bool? showStorableOnly,
    bool? showAvailableOnly,
  }) {
    if (showServicesOnly != null) _showServicesOnly = showServicesOnly;
    if (showConsumablesOnly != null) _showConsumablesOnly = showConsumablesOnly;
    if (showStorableOnly != null) _showStorableOnly = showStorableOnly;
    if (showAvailableOnly != null) _showAvailableOnly = showAvailableOnly;
    notifyListeners();
  }

  /// Resets all active filters.
  void clearFilters() {
    _showServicesOnly = false;
    _showConsumablesOnly = false;
    _showStorableOnly = false;
    _showAvailableOnly = false;

    _selectedGroupBy = null;
    _groupSummary.clear();
    _loadedGroups.clear();

    _currentOffset = 0;

    notifyListeners();
  }

  /// Sets the "Group By" field and fetches the group summary.
  Future<void> setGroupBy(String? groupBy) async {
    _selectedGroupBy = groupBy;
    _groupSummary.clear();
    _loadedGroups.clear();

    if (groupBy != null) {
      await _fetchGroupSummary();
    } else {
      await loadProducts(search: _currentSearchQuery);
    }
  }

  Future<void> _fetchGroupSummary() async {
    if (_selectedGroupBy == null) return;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final domain = _buildDomain(_currentSearchQuery);

      final result = await OdooSessionManager.callKwWithCompany({
        'model': 'product.product',
        'method': 'read_group',
        'args': [domain],
        'kwargs': {
          'fields': [_selectedGroupBy],
          'groupby': [_selectedGroupBy],
        },
      });

      if (result is List) {
        _groupSummary.clear();
        for (final group in result) {
          if (group is Map) {
            final groupMap = Map<String, dynamic>.from(group);
            final groupKey = getGroupKeyFromReadGroup(groupMap);
            final count = groupMap['${_selectedGroupBy}_count'] ?? 0;
            _groupSummary[groupKey] = count;
          }
        }
      }
    } catch (e) {
      _error = _getUserFriendlyErrorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Map<String, List<dynamic>> get loadedGroups => _loadedGroups;

  String getGroupKeyFromReadGroup(Map<String, dynamic> groupData) {
    if (_selectedGroupBy == null) return '';

    final groupVal = groupData[_selectedGroupBy];

    if (groupVal is List && groupVal.isNotEmpty) {
      return groupVal[1].toString();
    } else if (groupVal is String) {
      if (_selectedGroupBy == 'type') {
        switch (groupVal) {
          case 'consu':
            return 'Goods';
          case 'service':
            return 'Service';
          case 'product':
            return 'Storable Product';
          case 'combo':
            return 'Combo';
          default:
            return groupVal;
        }
      }

      return groupVal;
    }

    return 'Undefined';
  }

  /// Loads products for a specific group identified in the [context].
  Future<void> loadGroupProducts(Map<String, dynamic> context) async {
    if (_selectedGroupBy == null) return;

    final groupKey = context['key'] as String;
    if (_loadedGroups.containsKey(groupKey)) return;
    final fields = [
      'name',
      'default_code',
      'list_price',
      'image_128',
      'uom_id',
      'taxes_id',
      'categ_id',
      'currency_id',
    ];

    if (_hasStockModule) {
      fields.add('qty_available');
    }

    try {
      final domain = _buildGroupDomain(groupKey);
      final result = await OdooSessionManager.callKwWithCompany({
        'model': 'product.product',
        'method': 'search_read',
        'args': [domain],
        'kwargs': {'fields': fields, 'order': 'name asc'},
      });

      if (result is List) {
        _loadedGroups[groupKey] = result;
        notifyListeners();
      }
    } catch (e) {
    }
  }

  List<dynamic> _buildGroupDomain(String groupKey) {
    final domain = _buildDomain(_currentSearchQuery);

    if (_selectedGroupBy != null) {
      dynamic searchValue = groupKey;

      if (groupKey == 'Undefined') {
        searchValue = false;
      } else if (_selectedGroupBy == 'type') {
        switch (groupKey) {
          case 'Goods':
            searchValue = 'consu';
            break;
          case 'Service':
            searchValue = 'service';
            break;
          case 'Storable Product':
            searchValue = 'product';
            break;
          case 'Combo':
            searchValue = 'combo';
            break;
        }
      }

      domain.add([_selectedGroupBy, '=', searchValue]);
    }

    return domain;
  }

  /// Fetches available "Group By" options for products.
  Future<void> fetchGroupByOptions() async {
    _groupByOptions.clear();
    _groupByOptions.addAll({
      'categ_id': 'Category',
      'type': 'Product Type',
      'uom_id': 'Unit of Measure',
    });
    notifyListeners();
  }
}
