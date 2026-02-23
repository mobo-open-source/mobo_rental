
import 'package:flutter/foundation.dart';
import 'package:mobo_rental/features/company/company_local_data_source.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../Core/services/odoo_session_manager.dart';
import '../../../Core/services/haptics_service.dart';
// Using raw maps for companies to avoid model dependency and ensure UI compatibility

/// A provider that manages Odoo company selection and multi-company context.
class CompanyProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _companies = [];
  int? _selectedCompanyId;

  // Multi-company selection for request context (allowed_company_ids)
  List<int> _selectedAllowedCompanyIds = [];
  bool _loading = false;
  bool _switching = false;
  String? _error;

  List<Map<String, dynamic>> get companies => _companies;

  int? get selectedCompanyId => _selectedCompanyId;

  List<int> get selectedAllowedCompanyIds => _selectedAllowedCompanyIds;

  bool get isLoading => _loading;

  bool get isSwitching => _switching;

  String? get error => _error;

  Map<String, dynamic>? get selectedCompany {
    if (_selectedCompanyId == null) return null;
    try {
      return _companies.firstWhere((c) => c['id'] == _selectedCompanyId);
    } catch (e) {
      return null;
    }
  }

  /// Updates the selected allowed companies for RPC context injection.
  /// 
  /// This doesn't change the active company, but controls which companies 
  /// are included in the 'allowed_company_ids' context.
  Future<void> setAllowedCompanies(List<int> allowedIds) async {
    // Filter to companies available to the user
    final availableIds = _companies.map((c) => c['id'] as int).toSet();
    final filtered = allowedIds
        .where((id) => availableIds.contains(id))
        .toList();
    // Ensure active company is present
    if (_selectedCompanyId != null && !filtered.contains(_selectedCompanyId)) {
      filtered.add(_selectedCompanyId!);
    }
    _selectedAllowedCompanyIds = filtered;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'selected_allowed_company_ids',
      _selectedAllowedCompanyIds.map((e) => e.toString()).toList(),
    );

    // Update session context
    if (_selectedCompanyId != null) {
      await OdooSessionManager.updateCompanySelection(
        companyId: _selectedCompanyId!,
        allowedCompanyIds: _selectedAllowedCompanyIds,
      );
    }
    HapticsService.light();
    notifyListeners();
  }

  /// Initializes the provider by loading companies from backend or local cache.
  Future<void> initialize() async {
    _loading = true;
    _error = null;
    notifyListeners();
    final local = const CompanyLocalDataSource();
    try {
      final session = await OdooSessionManager.getCurrentSession();
      if (session == null || session.userId == null) {
        // No session -> show local cache if available
        _companies = await local.getAllCompanies();
        _selectedCompanyId = null;
        _loading = false;
        notifyListeners();
        return;
      }

      // 1) Load companies from backend (network-first) using centralized logic
      // This ensures we only get companies allowed for the current user
      final serverCompanies =
          await OdooSessionManager.getAllowedCompaniesList();

      if (serverCompanies.isNotEmpty) {
        _companies = serverCompanies;
        // Save to local DB on success
        await local.putAllCompanies(_companies);
      } else {
        _companies = await local.getAllCompanies();
      }

      // Ensure we have a valid list of IDs for logic below
      final companyIds = _companies.map((c) => c['id'] as int).toList();
      int? currentCompanyId = session.selectedCompanyId;

      // Restore selection from SharedPreferences and ensure invariants
      final prefs = await SharedPreferences.getInstance();
      final restoredId = prefs.getInt('selected_company_id');
      // We no longer use pending_company_id as switching is local-only
      await prefs.remove('pending_company_id');

      final restoredAllowed =
          prefs
              .getStringList('selected_allowed_company_ids')
              ?.map((e) => int.tryParse(e) ?? -1)
              .where((e) => e > 0)
              .toList() ??
          [];

      // Selected company precedence: restored -> server current -> first
      int? desiredId =
          restoredId ??
          currentCompanyId ??
          (companyIds.isNotEmpty ? companyIds.first : null);
      _selectedCompanyId = desiredId;

      // Allowed companies: restored subset or all
      List<int> defaultAllowed = companyIds;
      final restoredValid = restoredAllowed
          .where((id) => companyIds.contains(id))
          .toList();
      _selectedAllowedCompanyIds = restoredValid.isNotEmpty
          ? restoredValid
          : defaultAllowed;
      if (_selectedCompanyId != null &&
          !_selectedAllowedCompanyIds.contains(_selectedCompanyId)) {
        _selectedAllowedCompanyIds = [
          ..._selectedAllowedCompanyIds,
          _selectedCompanyId!,
        ];
      }

      // Enforce invariants: ensure we always have a valid selected company.
      if (_selectedCompanyId == null ||
          !companyIds.contains(_selectedCompanyId)) {
        if (companyIds.isNotEmpty) {
          _selectedCompanyId = companyIds.first;
        }
      }

      // Ensure allowed list includes the active company and persist immediately
      if (_selectedCompanyId != null &&
          !_selectedAllowedCompanyIds.contains(_selectedCompanyId)) {
        _selectedAllowedCompanyIds = [
          ..._selectedAllowedCompanyIds,
          _selectedCompanyId!,
        ];
      }

      // Persist selection and allowed ids for stability across app launches
      final prefs2 = await SharedPreferences.getInstance();
      if (_selectedCompanyId != null) {
        await prefs2.setInt('selected_company_id', _selectedCompanyId!);
      }
      await prefs2.setStringList(
        'selected_allowed_company_ids',
        _selectedAllowedCompanyIds.map((e) => e.toString()).toList(),
      );

      // Update session company context immediately (best-effort)
      if (_selectedCompanyId != null) {
        await OdooSessionManager.updateCompanySelection(
          companyId: _selectedCompanyId!,
          allowedCompanyIds: _selectedAllowedCompanyIds,
        );
      }
    } catch (e) {
      // Network/API failed -> fallback to local DB
      try {
        _companies = await local.getAllCompanies();
        if (_companies.isEmpty) {
          _error = e.toString();
        }
      } catch (_) {
        _error = e.toString();
      }
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Refresh only the companies list from the server/cache without altering
  /// current selection or allowed companies. Use after switching company to
  /// avoid race conditions that reset selection.
  /// Refreshes the companies list without changing current selection.
  Future<void> refreshCompaniesList() async {
    _loading = true;
    notifyListeners();
    final local = const CompanyLocalDataSource();
    try {
      // Try server first
      final list = await OdooSessionManager.getAllowedCompaniesList();
      if (list.isNotEmpty) {
        _companies = list;
        await local.putAllCompanies(_companies);
      } else {
        // Fallback to local cache
        _companies = await local.getAllCompanies();
      }
    } catch (_) {
      // Fallback to local cache on any error
      try {
        _companies = await local.getAllCompanies();
      } catch (_) {}
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Switches the active company to the one specified by [companyId].
  Future<bool> switchCompany(int companyId) async {
    if (_selectedCompanyId == companyId) return true;

    try {
      _switching = true;
      _error = null;
      notifyListeners();

      // 1. Update local state
      _selectedCompanyId = companyId;

      // Ensure active company is part of allowed selection
      if (!_selectedAllowedCompanyIds.contains(companyId)) {
        _selectedAllowedCompanyIds = [..._selectedAllowedCompanyIds, companyId];
      }

      // 2. Persist to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('selected_company_id', companyId);
      await prefs.setStringList(
        'selected_allowed_company_ids',
        _selectedAllowedCompanyIds.map((e) => e.toString()).toList(),
      );

      // Remove legacy pending key if it exists
      await prefs.remove('pending_company_id');

      // 3. Update Session Context
      await OdooSessionManager.updateCompanySelection(
        companyId: companyId,
        allowedCompanyIds: _selectedAllowedCompanyIds,
      );

      // 4. Refresh companies list (optional, but good for consistency)
      await refreshCompaniesList();

      HapticsService.success();
      return true;
    } catch (e) {
      _error = e.toString();
      HapticsService.error();
      notifyListeners();
      return false;
    } finally {
      _switching = false;
      notifyListeners();
    }
  }

  /// Toggles a company's inclusion in the allowed companies list.
  Future<void> toggleAllowedCompany(int companyId) async {
    if (_selectedAllowedCompanyIds.contains(companyId)) {
      // Cannot remove active company from allowed companies
      if (companyId == _selectedCompanyId) {
        return;
      }
      _selectedAllowedCompanyIds = _selectedAllowedCompanyIds
          .where((id) => id != companyId)
          .toList();
    } else {
      _selectedAllowedCompanyIds = [..._selectedAllowedCompanyIds, companyId];
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'selected_allowed_company_ids',
      _selectedAllowedCompanyIds.map((e) => e.toString()).toList(),
    );

    if (_selectedCompanyId != null) {
      await OdooSessionManager.updateCompanySelection(
        companyId: _selectedCompanyId!,
        allowedCompanyIds: _selectedAllowedCompanyIds,
      );
    }

    HapticsService.selection();
    notifyListeners();
  }

  /// Select all available companies as allowed companies for the request context.
  Future<void> selectAllCompanies() async {
    final allIds = _companies.map((c) => c['id'] as int).toList();
    await setAllowedCompanies(allIds);
  }

  /// Deselect all companies except the currently active company.
  Future<void> deselectAllCompanies() async {
    if (_selectedCompanyId != null) {
      await setAllowedCompanies([_selectedCompanyId!]);
    }
  }

  /// Checks if a company is currently in the allowed list.
  bool isCompanyAllowed(int companyId) {
    return _selectedAllowedCompanyIds.contains(companyId);
  }

  /// Resets the company provider to its initial state.
  void resetCompanyProvider() {
    _companies.clear();
    _selectedCompanyId = null;
    _selectedAllowedCompanyIds.clear();
    _loading = false;
    _switching = false;
    _error = null;
    notifyListeners();
  }
}
