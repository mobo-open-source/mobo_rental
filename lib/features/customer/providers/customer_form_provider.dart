import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:mobo_rental/Core/services/odoo_session_manager.dart';
import 'package:mobo_rental/features/customer/model/customer.dart';

/// Provider for managing the state of the customer creation/edition form.
class CustomerFormProvider extends ChangeNotifier {
  final ImagePickerPlatform _picker = ImagePickerPlatform.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isDropdownLoading = false;
  bool get isDropdownLoading => _isDropdownLoading;

  bool _isOcrLoading = false;
  bool get isOcrLoading => _isOcrLoading;

  String? _error;
  String? get error => _error;

  // Dropdown options
  List<Map<String, dynamic>> _countryOptions = [];
  List<Map<String, dynamic>> get countryOptions => _countryOptions;

  List<Map<String, dynamic>> _stateOptions = [];
  List<Map<String, dynamic>> get stateOptions => _stateOptions;

  List<Map<String, String>> _titleOptions = [];
  List<Map<String, String>> get titleOptions => _titleOptions;

  List<Map<String, String>> _currencyOptions = [];
  List<Map<String, String>> get currencyOptions => _currencyOptions;

  List<Map<String, String>> _languageOptions = [];
  List<Map<String, String>> get languageOptions => _languageOptions;

  File? _pickedImage;
  File? get pickedImage => _pickedImage;

  /// Sets the picked image file for the customer avatar.
  void setPickedImage(File? file) {
    _pickedImage = file;
    notifyListeners();
  }

  /// Loads all required dropdown data (countries, titles, etc.) from Odoo.
  Future<void> loadDropdownData() async {
    _isDropdownLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.wait([
        _fetchCountries().catchError((e) {}),
        _fetchTitles().catchError((e) {}),
        _fetchCurrencies().catchError(
          (e) {},
        ),
        _fetchLanguages().catchError((e) {}),
      ]);
    } catch (e) {
      _error = "Failed to load some options: $e";
    } finally {
      _isDropdownLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchCountries() async {
    try {
      final result = await OdooSessionManager.callKwWithCompany({
        'model': 'res.country',
        'method': 'search_read',
        'args': [[]],
        'kwargs': {
          'fields': ['id', 'name', 'code'],
          'limit': 300,
          'order': 'name asc',
        },
      });

      _countryOptions = List<Map<String, dynamic>>.from(result);
    } catch (e) {
    }
  }

  /// Fetches states for a given [countryId] from Odoo.
  Future<void> fetchStates(int countryId) async {
    _stateOptions = [];
    notifyListeners();

    try {
      final result = await OdooSessionManager.callKwWithCompany({
        'model': 'res.country.state',
        'method': 'search_read',
        'args': [
          [
            ['country_id', '=', countryId],
          ],
        ],
        'kwargs': {
          'fields': ['id', 'name', 'code'],
          'limit': 300,
          'order': 'name asc',
        },
      });

      _stateOptions = List<Map<String, dynamic>>.from(result);
      notifyListeners();
    } catch (e) {
    }
  }

  Future<void> _fetchTitles() async {
    try {
      final result = await OdooSessionManager.callKwWithCompany({
        'model': 'res.partner.title',
        'method': 'search_read',
        'args': [[]],
        'kwargs': {
          'fields': ['id', 'name'],
        },
      });

      _titleOptions = result
          .map<Map<String, String>>(
            (e) => {'value': e['id'].toString(), 'label': e['name'].toString()},
          )
          .toList();
    } catch (e) {
      _titleOptions = [];
    }
  }

  Future<void> _fetchCurrencies() async {
    try {
      final result = await OdooSessionManager.callKwWithCompany({
        'model': 'res.currency',
        'method': 'search_read',
        'args': [
          [
            ['active', '=', true],
          ],
        ],
        'kwargs': {
          'fields': ['id', 'name'],
        },
      });

      _currencyOptions = result
          .map<Map<String, String>>(
            (e) => {'value': e['id'].toString(), 'label': e['name'].toString()},
          )
          .toList();
    } catch (e) {
    }
  }

  Future<void> _fetchLanguages() async {
    try {
      final result = await OdooSessionManager.callKwWithCompany({
        'model': 'res.lang',
        'method': 'search_read',
        'args': [
          [
            ['active', '=', true],
          ],
        ],
        'kwargs': {
          'fields': ['code', 'name'],
        },
      });

      _languageOptions = result
          .map<Map<String, String>>(
            (e) => {
              'value': e['code'].toString(),
              'label': e['name'].toString(),
            },
          )
          .toList();
    } catch (e) {
    }
  }

  /// Picks an image from the specified [source] (camera or gallery).
  Future<File?> pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.getImageFromSource(
        source: source,
        options: const ImagePickerOptions(imageQuality: 70, maxWidth: 800),
      );
      if (pickedFile != null) {
        _pickedImage = File(pickedFile.path);
        notifyListeners();
        return _pickedImage;
      }
    } catch (e) {
    }
    return null;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Resets the form provider to its initial empty state.
  void reset() {
    _pickedImage = null;
    _error = null;

    _isLoading = false;
    _isDropdownLoading = false;
    _isOcrLoading = false;

    _countryOptions.clear();
    _stateOptions.clear();
    _titleOptions.clear();
    _currencyOptions.clear();
    _languageOptions.clear();

    notifyListeners();
  }

  /// Populates the form state from an existing [customer] object.
  void populateFromCustomer(Customer customer) {
    // This is mainly for UI state that the provider manages,
    // like the picked image. The controllers are managed by the screen.
    _pickedImage = null;
    if (customer.countryId != null) {
      fetchStates(customer.countryId!);
    }
    notifyListeners();
  }
}
