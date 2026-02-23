import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobo_rental/Core/services/odoo_session_manager.dart';

/// A provider that handles currency fetching and formatting.
class CurrencyProvider extends ChangeNotifier {
  String _currency = 'USD';
  late NumberFormat _currencyFormat;
  bool _isLoading = false;
  String? _error;
  List<dynamic>? _lastCurrencyIdList;

  final Map<String, String> currencyToLocale = {
    'USD': 'en_US',
    'EUR': 'de_DE',
    'GBP': 'en_GB',
    'INR': 'en_IN',
    'JPY': 'ja_JP',
    'CNY': 'zh_CN',
    'AUD': 'en_AU',
    'CAD': 'en_CA',
    'CHF': 'de_CH',
    'SGD': 'en_SG',
    'AED': 'ar_AE',
    'SAR': 'ar_SA',
    'QAR': 'ar_QA',
    'KWD': 'ar_KW',
    'BHD': 'ar_BH',
    'OMR': 'ar_OM',
    'MYR': 'ms_MY',
    'THB': 'th_TH',
    'IDR': 'id_ID',
    'PHP': 'fil_PH',
    'VND': 'vi_VN',
    'KRW': 'ko_KR',
    'TWD': 'zh_TW',
    'HKD': 'zh_HK',
    'NZD': 'en_NZ',
    'ZAR': 'en_ZA',
    'BRL': 'pt_BR',
    'MXN': 'es_MX',
    'ARS': 'es_AR',
    'CLP': 'es_CL',
    'COP': 'es_CO',
    'PEN': 'es_PE',
    'UYU': 'es_UY',
    'TRY': 'tr_TR',
    'ILS': 'he_IL',
    'EGP': 'ar_EG',
    'PKR': 'ur_PK',
    'BDT': 'bn_BD',
    'LKR': 'si_LK',
    'NPR': 'ne_NP',
    'MMK': 'my_MM',
    'KHR': 'km_KH',
    'LAK': 'lo_LA',
  };

  CurrencyProvider() {
    final locale = currencyToLocale['USD'] ?? 'en_US';
    _currencyFormat = NumberFormat.currency(locale: locale, decimalDigits: 2);
    fetchCompanyCurrency();
  }

  String get currency => _currency;

  NumberFormat get currencyFormat => _currencyFormat;

  bool get isLoading => _isLoading;

  String? get error => _error;
  String get companyCurrencyId => _currency;
  List<dynamic>? get companyCurrencyIdList => _lastCurrencyIdList;
  /// Fetches the company's default currency from Odoo.
  Future<void> fetchCompanyCurrency() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await OdooSessionManager.callKwWithCompany({
        'model': 'res.company',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'fields': ['currency_id'],
          'limit': 1,
        },
      });

      if (result is List && result.isNotEmpty) {
        final currencyField = result.first['currency_id'];
        if (currencyField is List && currencyField.length > 1) {
          _currency = currencyField[1].toString();
          _lastCurrencyIdList = currencyField;

          final locale = currencyToLocale[_currency] ?? 'en_US';
          _currencyFormat = NumberFormat.currency(
            locale: locale,
            decimalDigits: 2,
          );
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Returns the currency symbol for a given [currencyCode].
  String getCurrencySymbol(String currencyCode) {
    final Map<String, String> currencySymbols = {
      'USD': '\$',
      'EUR': '€',
      'GBP': '£',
      'INR': '₹',
      'JPY': '¥',
      'CNY': '¥',
      'AUD': 'A\$',
      'CAD': 'C\$',
      'CHF': 'CHF',
      'SGD': 'S\$',
      'AED': 'AED',
      'SAR': 'SR',
      'QAR': 'QR',
      'KWD': 'KD',
      'BHD': 'BD',
      'OMR': 'OMR',
      'MYR': 'RM',
      'THB': '฿',
      'IDR': 'Rp',
      'PHP': '₱',
      'VND': '₫',
      'KRW': '₩',
      'TWD': 'NT\$',
      'HKD': 'HK\$',
      'NZD': 'NZ\$',
      'ZAR': 'R',
      'BRL': 'R\$',
      'MXN': 'MX\$',
      'ARS': '\$',
      'CLP': '\$',
      'COP': '\$',
      'PEN': 'S/',
      'UYU': '\$U',
      'TRY': '₺',
      'ILS': '₪',
      'EGP': 'E£',
      'PKR': '₨',
      'BDT': '৳',
      'LKR': 'Rs',
      'NPR': 'रु',
      'MMK': 'K',
      'KHR': '៛',
      'LAK': '₭',
    };

    return currencySymbols[currencyCode] ?? currencyCode;
  }

  /// Formats a [double] amount into a currency string with symbol.
  String formatAmount(double amount, {String? currency}) {
    final currencyCode = currency ?? _currency;
    final symbol = getCurrencySymbol(currencyCode);
    final locale = currencyToLocale[currencyCode] ?? 'en_US';
    final formattedAmount = NumberFormat.currency(
      locale: locale,
      symbol: '',
      decimalDigits: 2,
    ).format(amount);

    return '$symbol $formattedAmount';
  }

  /// Resets the currency data to default (USD).
  Future<void> clearData() async {
    _currency = 'USD';
    final locale = currencyToLocale['USD'] ?? 'en_US';
    _currencyFormat = NumberFormat.currency(locale: locale, decimalDigits: 2);
    _isLoading = false;
    _error = null;
    _lastCurrencyIdList = null;
    notifyListeners();
  }

  /// Debug utility to test currency formatting for various locales.
  void debugCurrencyFormatting() {
    final testAmount = 1234.56;
    final testCurrencies = ['USD', 'INR', 'EUR', 'GBP'];
    for (final currency in testCurrencies) {
      final locale = currencyToLocale[currency] ?? 'en_US';
      try {
        final formatter = NumberFormat.currency(
          locale: locale,
          decimalDigits: 2,
        );
        final formatted = formatter.format(testAmount);
      } catch (e) {
      }
    }
  }
}
