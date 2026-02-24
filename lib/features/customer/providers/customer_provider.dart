import 'package:flutter/material.dart';
import 'package:mobo_rental/Core/services/odoo_session_manager.dart';
import 'package:mobo_rental/Core/services/review_service.dart';
import 'package:mobo_rental/features/customer/providers/cusyomer_field_get_service.dart';

/// Provider for managing customer lists, search, pagination, and grouping.
class CustomerProvider extends ChangeNotifier {
  // ==========================================
  // STATE VARIABLES
  // ==========================================
  List<dynamic> _customers = [];
  bool _isLoading = true;
  String? _error;
  bool _isAdmin = false;
  // Pagination
  int _currentOffset = 0;
  final int _limit = 40;
  int _totalCount = 0;
  String _currentSearchQuery = '';

  // Filter State
  bool _showActiveOnly = true;
  bool _showCompaniesOnly = false;
  bool _showIndividualsOnly = false;
  bool _showCreditBreachesOnly = false;
  DateTime? _startDate;
  DateTime? _endDate;

  // Grouping State
  Map<String, String> _groupByOptions = {};
  String? _selectedGroupBy;
  Map<String, int> _groupSummary = {};
  Map<String, List<dynamic>> _loadedGroups = {};

  // [UPDATED] Stores the specific Odoo domain for each group
  final Map<String, dynamic> _groupDomainLookup = {};

  bool _isFieldsFetched = false;
  List<String> _availableFields = [];

  // ==========================================
  // GETTERS
  // ==========================================
  List<dynamic> get customers => _customers;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalCount => _totalCount;
  int get currentOffset => _currentOffset;
  int get limit => _limit;
  bool get isAdmin => _isAdmin;
  bool get showActiveOnly => _showActiveOnly;
  bool get showCompaniesOnly => _showCompaniesOnly;
  bool get showIndividualsOnly => _showIndividualsOnly;
  bool get showCreditBreachesOnly => _showCreditBreachesOnly;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;

  Map<String, String> get groupByOptions => _groupByOptions;
  String? get selectedGroupBy => _selectedGroupBy;
  Map<String, int> get groupSummary => _groupSummary;
  Map<String, List<dynamic>> get loadedGroups => _loadedGroups;
  bool get isGrouped => _selectedGroupBy != null;

  bool get hasNextPage => _currentOffset + _limit < _totalCount;
  bool get hasPreviousPage => _currentOffset > 0;

  int get activeFiltersCount {
    int count = 0;
    if (_showActiveOnly) count++;
    if (_showCompaniesOnly) count++;
    if (_showIndividualsOnly) count++;
    if (_showCreditBreachesOnly) count++;
    if (_startDate != null || _endDate != null) count++;
    return count;
  }

  int get startRecord => _totalCount == 0 ? 0 : _currentOffset + 1;
  int get endRecord => (_currentOffset + _limit) > _totalCount
      ? _totalCount
      : (_currentOffset + _limit);

  // ==========================================
  // CORE METHODS
  // ==========================================

  /// Clears all customer data and resets filters/pagination.
  Future<void> clearData() async {
    _customers.clear();
    _isLoading = false;
    _error = null;
    _currentOffset = 0;
    _totalCount = 0;
    _currentSearchQuery = '';
    _showActiveOnly = true;
    _showCompaniesOnly = false;
    _showIndividualsOnly = false;
    _showCreditBreachesOnly = false;
    _startDate = null;
    _endDate = null;
    _selectedGroupBy = null;
    _groupSummary.clear();
    _loadedGroups.clear();
    _groupDomainLookup.clear(); // Clear domains
    _isFieldsFetched = false;
    _availableFields.clear();
    notifyListeners();
  }

  bool get canViewCustomerDetails => _canViewCustomerDetails;
  bool get permissionsLoaded => _permissionsLoaded;

  bool _canViewCustomerDetails = false;
  bool _permissionsLoaded = false;

  /// Loads user permissions for viewing customer details and admin features.
  Future<void> loadPermissions() async {
    try {
      final client = await OdooSessionManager.getClient();
      final userId = client?.sessionId?.userId;

      if (userId == null) {
        _canViewCustomerDetails = false;
        _isAdmin = false;
        _permissionsLoaded = true;
        notifyListeners();
        return;
      }

      // Check for Partner Manager Group
      final bool hasPartnerManagerGroup = await client!.callKw({
        'model': 'res.users',
        'method': 'has_group',
        'args': [
          [userId],
          'base.group_partner_manager',
        ],
        'kwargs': {},
      });

      // Check for System Admin Group (Settings Access)
      final bool hasSystemGroup = await client.callKw({
        'model': 'res.users',
        'method': 'has_group',
        'args': [
          [userId],
          'base.group_system', // This is the standard "Administration / Settings" group
        ],
        'kwargs': {},
      });
      // Check for Accounting Readonly
      final bool hasAccountingReadonly = await client.callKw({
        'model': 'res.users',
        'method': 'has_group',
        'args': [
          [userId],
          'account.group_account_readonly',
        ],
        'kwargs': {},
      });

      // Check for Accounting User
      final bool hasAccountingUser = await client.callKw({
        'model': 'res.users',
        'method': 'has_group',
        'args': [
          [userId],
          'account.group_account_user',
        ],
        'kwargs': {},
      });

      _isAdmin = hasAccountingReadonly || hasAccountingUser;

      _canViewCustomerDetails = hasPartnerManagerGroup;
    } catch (e) {
      _canViewCustomerDetails = false;
      _isAdmin = false;
    } finally {
      _permissionsLoaded = true;
      notifyListeners();
    }
  }

  /// Helper method to build the list of fields based on permissions
  List<String> _getFieldsToFetch() {
    List<String> fields = [
      'name',
      'email',
      'phone',
      'vat',
      'street',
      'street2',
      'city',
      'zip',
      'website',
      'comment',
      'function',
      'industry_id',
      'company_name',
      'lang',
      'tz',
      'user_id',
      'property_payment_term_id',
      'country_id',
      'state_id',
      'image_128',
      'customer_rank',
      'supplier_rank',
      'is_company',
      'create_date',
      'write_date',
      'currency_id',
      'active',
      'partner_latitude',
      'partner_longitude',
    ];

    // Only add financial fields if the user is an Admin
    if (_isAdmin) {
      fields.add('total_invoiced');
    }

    return fields;
  }
  //   try {

  //       'model': 'res.partner',
  //       'method': 'search_count',
  //       'args': [domain],
  //       'kwargs': {},
  //     });

  //       'model': 'res.partner',
  //       'method': 'fields_get',
  //       'args': [],
  //       'kwargs': {},
  //     });

  //       'model': 'res.partner',
  //       'method': 'search_read',
  //       'args': [domain],
  //       'kwargs': {
  //         'fields': [
  //           'name',
  //           'email',
  //           'phone',
  //           'vat',
  //           'street',
  //           'street2',
  //           'city',
  //           'zip',
  //           'website',
  //           'comment',
  //           'function',
  //           // 'credit_limit',
  //           'industry_id',
  //           'company_name',
  //           'lang',
  //           'tz',
  //           'user_id',
  //           'property_payment_term_id',
  //           'country_id',
  //           'state_id',
  //           'image_128',
  //           'customer_rank',
  //           'supplier_rank',
  //           'is_company',
  //           'create_date',
  //           'write_date',
  //           'currency_id',
  //           'active',
  //           // 'total_invoiced',
  //           // 'credit',
  //           // 'debit',
  //           'partner_latitude',
  //           'partner_longitude',
  //         ],
  //         'offset': offset,
  //         'limit': _limit,
  //         'order': 'name asc',
  //       },
  //     });

  //     } else {
  //   } catch (e) {
  //   } finally {
  /// Fetches customers from Odoo with optional [offset] and [search] query.
  Future<void> loadCustomers({int offset = 0, String search = ''}) async {
    // Ensure permissions are loaded before fetching data if they haven't been already
    if (!_permissionsLoaded) {
      await loadPermissions();
    }

    try {
      _isLoading = true;
      _error = null;
      _currentOffset = offset;
      _currentSearchQuery = search;
      notifyListeners();

      final List<dynamic> domain = _buildDomain(search);

      final countResult = await OdooSessionManager.callKwWithCompany({
        'model': 'res.partner',
        'method': 'search_count',
        'args': [domain],
        'kwargs': {},
      });

      // (Optional) You can keep fields_get if you use it for metadata,
      // but for reading data, we use the specific list below.

      _totalCount = countResult is int ? countResult : 0;

      // Get fields dynamically based on admin status
      final List<String> fieldsToRead = _getFieldsToFetch();

      final result = await OdooSessionManager.callKwWithCompany({
        'model': 'res.partner',
        'method': 'search_read',
        'args': [domain],
        'kwargs': {
          'fields': fieldsToRead,
          'offset': offset,
          'limit': _limit,
          'order': 'name asc',
        },
      });

      if (result is List) {
        _customers = result;
      } else {
        _customers = [];
      }
    } catch (e) {
      _error = _getUserFriendlyErrorMessage(e);
      _customers = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  //   try {

  //     // Fetch field metadata
  //       'model': 'res.partner',
  //       'method': 'fields_get',
  //       'args': [],
  //       'kwargs': {
  //         'attributes': ['store', 'type'],
  //       },
  //     });

  //     // Get safe fields using the filter service

  //       // Use the service to filter out problematic fields
  //         fieldsResult,
  //         includeBinary: true, // Skip binary fields (images)
  //         includeRelational: true, // Include one2many/many2many

  //       // Optional: Log problematic fields for debugging
  //         fieldsResult,

  //     } else {
  //       // Fallback

  //       'model': 'res.partner',
  //       'method': 'search_count',
  //       'args': [domain],
  //       'kwargs': {},
  //     });

  //       'model': 'res.partner',
  //       'method': 'search_read',
  //       'args': [domain],
  //       'kwargs': {
  //         'offset': offset,
  //         'limit': _limit,
  //         'order': 'name asc',
  //         'fields': fields,
  //       },
  //     });

  //     } else {
  //   } catch (e) {
  //   } finally {

  // ==========================================
  // GROUPING LOGIC (SILVER BULLET FIX)
  // ==========================================

  void setGroupBy(String? groupBy) {
    _selectedGroupBy = groupBy;
    _groupSummary.clear();
    _loadedGroups.clear();
    _groupDomainLookup.clear();

    if (_selectedGroupBy != null) {
      _fetchGroupSummary();
    } else {
      loadCustomers(search: _currentSearchQuery);
    }
    notifyListeners();
  }

  Future<void> _fetchGroupSummary() async {
    if (_selectedGroupBy == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      final domain = _buildDomain(_currentSearchQuery);

      // FIXED: Added 'fields' to kwargs
      final result = await OdooSessionManager.callKwWithCompany({
        'model': 'res.partner',
        'method': 'read_group',
        'args': [domain],
        'kwargs': {
          'fields': [_selectedGroupBy],
          'groupby': [_selectedGroupBy],
          'lazy': false,
        },
      });

      if (result is List) {
        _groupSummary.clear();
        _groupDomainLookup.clear();

        for (final group in result) {
          if (group is Map) {
            final rawValue = group[_selectedGroupBy];

            // 1. Determine the Group Name (Key)
            String groupKey;
            if (rawValue == null || rawValue == false) {
              groupKey = 'Undefined';
            } else if (rawValue is List && rawValue.isNotEmpty) {
              // [ID, Name] tuple
              groupKey = rawValue.length > 1
                  ? rawValue[1].toString()
                  : 'Unknown';
            } else {
              groupKey = rawValue.toString();
            }

            if (groupKey.isEmpty) groupKey = 'Undefined';

            // 2. Store Count
            _groupSummary[groupKey] =
                group['${_selectedGroupBy}_count'] ?? group['__count'] ?? 0;

            // 3. Store the Odoo-provided Domain
            if (group.containsKey('__domain')) {
              _groupDomainLookup[groupKey] = group['__domain'];
            } else {
              _groupDomainLookup[groupKey] = _buildFallbackGroupDomain(
                rawValue,
                _selectedGroupBy!,
              );
            }
          }
        }
      }
    } catch (e) {
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Loads contacts for a specific group identified by [groupKey].
  Future<void> loadGroupContacts(String groupKey) async {
    if (_selectedGroupBy == null) return;
    if (_loadedGroups.containsKey(groupKey)) return;

    try {
      // 1. Retrieve the exact domain Odoo gave us
      List<dynamic> targetDomain = [];

      if (_groupDomainLookup.containsKey(groupKey)) {
        targetDomain = _groupDomainLookup[groupKey];
      } else {
        // Should not happen, but safe fallback
        targetDomain = _buildDomain(_currentSearchQuery);
      }

      final result = await OdooSessionManager.callKwWithCompany({
        'model': 'res.partner',
        'method': 'search_read',
        'args': [targetDomain], // Use the captured domain directly
        'kwargs': {
          'fields': [
            'name',
            'email',
            'phone',
            'vat',
            'street',
            'street2',
            'city',
            'zip',
            'website',
            'comment',
            'function',
            'industry_id',
            'company_name',
            'lang',
            'tz',
            'user_id',
            'property_payment_term_id',
            'country_id',
            'state_id',
            'image_128',
            'customer_rank',
            'supplier_rank',
            'is_company',
            'create_date',
            'write_date',
            'currency_id',
            'active',
            'partner_latitude',
            'partner_longitude',
          ],
          'order': 'name asc',
        },
      });

      if (result is List) {
        _loadedGroups[groupKey] = result;
        notifyListeners();
      }
    } catch (e) {}
  }

  /// Fetches available "Group By" options for the UI.
  Future<void> fetchGroupByOptions() async {
    _groupByOptions = {
      'user_id': 'Salesperson',
      'country_id': 'Country',
      'state_id': 'State',
      'parent_id': 'Company',
    };
    notifyListeners();
  }

  // ==========================================
  // HELPERS & DOMAIN BUILDER
  // ==========================================

  List<dynamic> _buildDomain(String search) {
    final List<dynamic> domain = [];
    domain.add(['customer_rank', '>', 0]);

    if (_showActiveOnly) domain.add(['active', '=', true]);
    if (_showCompaniesOnly) domain.add(['is_company', '=', true]);
    if (_showIndividualsOnly) domain.add(['is_company', '=', false]);

    if (_startDate != null || _endDate != null) {
      if (_startDate != null) {
        final startStr = _startDate!.toIso8601String().split('T')[0];
        domain.add(['create_date', '>=', '$startStr 00:00:00']);
      }
      if (_endDate != null) {
        final endStr = _endDate!.toIso8601String().split('T')[0];
        domain.add(['create_date', '<=', '$endStr 23:59:59']);
      }
    }

    if (search.isNotEmpty) {
      domain.add('|');
      domain.add(['name', 'ilike', search]);
      domain.add('|');
      domain.add(['email', 'ilike', search]);
      domain.add('|');
      domain.add(['phone', 'ilike', search]);
      domain.add(['company_name', 'ilike', search]);
    }

    return domain;
  }

  List<dynamic> _buildFallbackGroupDomain(dynamic rawValue, String groupBy) {
    final List<dynamic> domain = _buildDomain(_currentSearchQuery);

    dynamic searchValue = rawValue;

    if (rawValue == null || rawValue == false) {
      searchValue = false;
    } else if (rawValue is List && rawValue.isNotEmpty) {
      // For relational fields (Many2one), take the ID
      searchValue = rawValue[0];
    }

    domain.add([groupBy, '=', searchValue]);
    return domain;
  }

  /// Updates the filter state and notifies listeners.
  void setFilterState({
    bool? showActiveOnly,
    bool? showCompaniesOnly,
    bool? showIndividualsOnly,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    if (showActiveOnly != null) _showActiveOnly = showActiveOnly;
    if (showCompaniesOnly != null) _showCompaniesOnly = showCompaniesOnly;
    if (showIndividualsOnly != null) _showIndividualsOnly = showIndividualsOnly;
    if (startDate != null) _startDate = startDate;
    if (endDate != null) _endDate = endDate;
    notifyListeners();
  }

  /// Clears all active filters and grouping settings.
  void clearFilters() {
    // 1. Keep "Active Only" as TRUE
    _showActiveOnly = true;

    // 2. Reset other filters to FALSE/NULL
    _showCompaniesOnly = false;
    _showIndividualsOnly = false;
    _showCreditBreachesOnly = false;
    _startDate = null;
    _endDate = null;

    // 3. Reset Grouping
    _selectedGroupBy = null;
    _groupSummary.clear();
    _loadedGroups.clear();
    _groupDomainLookup.clear();

    // 4. Reset Pagination (Crucial for a clean reload)
    _currentOffset = 0;

    notifyListeners();
  }

  /// Performs a search for customers based on the [query] string.
  Future<void> searchCustomers(String query) async {
    await loadCustomers(offset: 0, search: query);
  }

  /// Navigates to the next page of results.
  Future<void> goToNextPage() async {
    if (hasNextPage) {
      await loadCustomers(
        offset: _currentOffset + _limit,
        search: _currentSearchQuery,
      );
    }
  }

  /// Navigates to the previous page of results.
  Future<void> goToPreviousPage() async {
    if (hasPreviousPage) {
      await loadCustomers(
        offset: _currentOffset - _limit,
        search: _currentSearchQuery,
      );
    }
  }

  String _getUserFriendlyErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();
    if (errorString.contains('socketexception') ||
        errorString.contains('connection')) {
      return 'Unable to connect to server. Please check your internet connection.';
    }
    return 'Unable to load data. Please try again.';
  }

  // ==========================================
  // UNCHANGED HELPER METHODS (Create, Update, Dropdowns, etc)
  // ==========================================

  Future<Map<String, dynamic>?> getCustomerDetails(int partnerId) async {
    try {
      final result = await OdooSessionManager.callKwWithCompany({
        'model': 'res.partner',
        'method': 'read',
        'args': [
          [partnerId],
        ],
        'kwargs': {
          'fields': [
            // 'name',
            // 'email',
            // 'phone',
            // 'vat',
            // 'street',
            // 'street2',
            // 'city',
            // 'zip',
            // 'website',
            // 'comment',
            // 'function',
            // // 'credit_limit',
            // 'industry_id',
            // 'parent_id',
            // 'lang',
            // 'tz',
            // 'user_id',
            // 'property_payment_term_id',
            // 'country_id',
            // 'state_id',
            // 'image_128',
            // 'customer_rank',
            // 'supplier_rank',
            // 'is_company',
            // 'create_date',
            // 'write_date',
            // 'currency_id',
            // 'active',
            // 'total_invoiced',
            // 'credit',
            // 'debit',
            // 'partner_latitude',
            // 'partner_longitude',
          ],
        },
      });
      if (result is List && result.isNotEmpty) {
        return result[0] as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Fetches the list of all available countries from Odoo.
  Future<List<Map<String, dynamic>>> getCountries() async {
    final result = await OdooSessionManager.callKwWithCompany({
      'model': 'res.country',
      'method': 'search_read',
      'args': [[]],
      'kwargs': {
        'fields': ['id', 'name', 'code'],
        'order': 'name asc',
      },
    });
    return result is List
        ? result.cast<Map<String, dynamic>>()
        : <Map<String, dynamic>>[];
  }

  Future<List<Map<String, dynamic>>> getStatesByCountry(int countryId) async {
    final result = await OdooSessionManager.callKwWithCompany({
      'model': 'res.country.state',
      'method': 'search_read',
      'args': [
        [
          ['country_id', '=', countryId],
        ],
      ],
      'kwargs': {
        'fields': ['id', 'name', 'code', 'country_id'],
        'order': 'name asc',
      },
    });
    return result is List
        ? result.cast<Map<String, dynamic>>()
        : <Map<String, dynamic>>[];
  }

  Future<List<dynamic>> getTitleOptions() async {
    final result = await OdooSessionManager.callKwWithCompany({
      'model': 'res.partner.title',
      'method': 'search_read',
      'args': [[]],
      'kwargs': {
        'fields': ['id', 'name'],
        'order': 'name asc',
      },
    });
    return result is List ? result : [];
  }

  Future<List<Map<String, dynamic>>> getCurrencies() async {
    final result = await OdooSessionManager.callKwWithCompany({
      'model': 'res.currency',
      'method': 'search_read',
      'args': [[]],
      'kwargs': {
        'fields': ['id', 'name', 'symbol'],
        'order': 'name asc',
      },
    });
    return result is List
        ? result.cast<Map<String, dynamic>>()
        : <Map<String, dynamic>>[];
  }

  Future<List<Map<String, dynamic>>> getLanguages() async {
    final result = await OdooSessionManager.callKwWithCompany({
      'model': 'res.lang',
      'method': 'search_read',
      'args': [[]],
      'kwargs': {
        'fields': ['code', 'name'],
        'order': 'name asc',
      },
    });
    return result is List
        ? result.cast<Map<String, dynamic>>()
        : <Map<String, dynamic>>[];
  }

  /// Creates a new customer record in Odoo with the provided [customerData].
  Future<int> createCustomer(Map<String, dynamic> customerData) async {
    try {
      _isLoading = true;
      notifyListeners();
      final result = await OdooSessionManager.callKwWithCompany({
        'model': 'res.partner',
        'method': 'create',
        'args': [customerData],
        'kwargs': {},
      });
      await loadCustomers();
      ReviewService().trackSignificantEvent();
      return result is int ? result : 0;
    } catch (e) {
      _error = _getUserFriendlyErrorMessage(e);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateCustomer(int id, Map<String, dynamic> customerData) async {
    try {
      _isLoading = true;
      notifyListeners();
      final result = await OdooSessionManager.callKwWithCompany({
        'model': 'res.partner',
        'method': 'write',
        'args': [
          [id],
          customerData,
        ],
        'kwargs': {},
      });
      if (result == true) {
        await loadCustomers(
          offset: _currentOffset,
          search: _currentSearchQuery,
        );
        ReviewService().trackSignificantEvent();
        return true;
      }
      return false;
    } catch (e) {
      _error = _getUserFriendlyErrorMessage(e);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> getCustomerStats(int partnerId) async {
    try {
      final result = await OdooSessionManager.callKwWithCompany({
        'model': 'sale.order',
        'method': 'search_read',
        'args': [
          [
            ['partner_id', '=', partnerId],
          ],
        ],
        'kwargs': {
          'fields': ['state', 'amount_total'],
        },
      });

      int totalOrdersCount = 0;
      int confirmedOrdersCount = 0;
      int draftOrdersCount = 0;
      double totalAmountValue = 0.0;

      if (result is List) {
        totalOrdersCount = result.length;

        for (final orderData in result) {
          if (orderData is Map) {
            final String state = orderData['state']?.toString() ?? '';
            final double amount = (orderData['amount_total'] is num)
                ? (orderData['amount_total'] as num).toDouble()
                : 0.0;

            if (state == 'sale' || state == 'done') {
              confirmedOrdersCount++;
              totalAmountValue += amount;
            } else if (state == 'draft' || state == 'sent') {
              draftOrdersCount++;
            }
          }
        }
      }



      return {
        'total_orders': totalOrdersCount,
        'confirmed_orders': confirmedOrdersCount,
        'draft_orders': draftOrdersCount,
        'total_amount': totalAmountValue,
      };
    } catch (error) {
      return {
        'total_orders': 0,
        'confirmed_orders': 0,
        'draft_orders': 0,
        'total_amount': 0.0,
      };
    }
  }

  Future<Map<String, List<dynamic>>> fetchDropdownOptions() async {
    final results = await Future.wait([
      getCountries(),
      getTitleOptions(),
      getCurrencies(),
      getLanguages(),
    ]);
    return {
      'countries': results[0],
      'titles': results[1],
      'currencies': results[2],
      'languages': results[3],
    };
  }

  Future<List<Map<String, dynamic>>> fetchStates(int countryId) async {
    // Duplicate of getStatesByCountry but kept for compatibility
    return getStatesByCountry(countryId);
  }

  Future<bool> archiveCustomer(int customerId) async {
    try {
      final result = await OdooSessionManager.callKwWithCompany({
        'model': 'res.partner',
        'method': 'write',
        'args': [
          [customerId],
          {'active': false},
        ],
        'kwargs': {},
      });
      return result == true;
    } catch (_) {
      rethrow;
    }
  }

  Future<bool> deleteCustomer(int customerId) async {
    try {
      final result = await OdooSessionManager.callKwWithCompany({
        'model': 'res.partner',
        'method': 'unlink',
        'args': [
          [customerId],
        ],
        'kwargs': {},
      });
      if (result == true) {
        _customers.removeWhere((customer) => customer['id'] == customerId);
        _totalCount--;
        notifyListeners();
      }
      return result == true;
    } catch (_) {
      rethrow;
    }
  }

  Future<bool> geoLocalizeCustomer(int customerId) async {
    try {
      final result = await OdooSessionManager.callKwWithCompany({
        'model': 'res.partner',
        'method': 'geo_localize',
        'args': [
          [customerId],
        ],
        'kwargs': {
          'context': {'force_geo_localize': true},
        },
      });
      return result == true;
    } catch (_) {
      rethrow;
    }
  }
}
