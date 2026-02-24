import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mobo_rental/features/company/providers/company_provider.dart';
import 'package:mobo_rental/Core/Widgets/common/alert_dialog.dart';
import 'package:mobo_rental/Core/Widgets/common/snack_bar.dart';
import 'package:mobo_rental/features/dashboard/providers/user_provider.dart';
import 'package:mobo_rental/features/home/screens/home_screen.dart';
import 'package:mobo_rental/Core/services/odoo_session_manager.dart';
import 'package:mobo_rental/features/rental_orders/models/fetched_order_line_model.dart';
import 'package:mobo_rental/features/rental_orders/models/quote_model.dart';
import 'package:mobo_rental/features/rental_orders/models/rental_order_item.dart';
import 'package:mobo_rental/features/rental_orders/models/tax_model.dart';
import 'package:mobo_rental/features/rental_orders/service/pdf_service_custom.dart';
import 'package:mobo_rental/Core/utils/dashbord_clear_helper.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

/// A provider that manages rental order data and related operations.
/// 
/// Handles fetching rental orders, filtering, pagination, order details, 
/// cancellation, and status transitions (pickup/return).
class RentalOrderProvider extends ChangeNotifier {
  Set<String> tempFilters = {};
  Set<String> appliedFilters = {};

  DateTime? tempStartDate;
  DateTime? tempEndDate;

  DateTime? appliedStartDate;
  DateTime? appliedEndDate;

  String tempStartDateLabel = 'Select Start Date';
  String tempEndDateLabel = 'Select End Date';

  String appliedStartDateLabel = 'Select Start Date';
  String appliedEndDateLabel = 'Select End Date';

  DateTime? startDate;
  DateTime? endDate;

  bool isRentalOrderScreenLoading = true;
  List<RentalOrderItem> rentalOrderScreenList = [];

  String? _activeSearchQuery;
  String? error;
  String _getUserFriendlyErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('socketexception') ||
        errorString.contains('failed host lookup') ||
        errorString.contains('connection timeout')) {
      return 'Unable to connect to server. Please check your internet connection.';
    } else if (errorString.contains('permission') ||
        errorString.contains('access')) {
      return 'You do not have permission to view rental orders. Please contact your administrator.';
    } else if (errorString.contains('session') ||
        errorString.contains('authentication')) {
      return 'Your session has expired. Please log in again.';
    }

    return 'Unable to load rental orders. Please try again.';
  }

  /// Toggles a temporary filter and notifies listeners.
  void toggleTempFilter(String filter) {
    if (tempFilters.contains(filter)) {
      tempFilters.remove(filter);
    } else {
      tempFilters.add(filter);
    }
    notifyListeners();
  }

  /// Applies the temporary filters to the active filter set and resets pagination.
  void applyFilters() {
    appliedFilters = {...tempFilters};

    appliedStartDate = tempStartDate;
    appliedEndDate = tempEndDate;
    appliedStartDateLabel = tempStartDateLabel;
    appliedEndDateLabel = tempEndDateLabel;

    _currentPage = 0;
    notifyListeners();
  }

  /// Resets the temporary filter set to match the currently applied filters.
  void resetTempFiltersToApplied() {
    tempFilters = {...appliedFilters};
    tempStartDate = appliedStartDate;
    tempEndDate = appliedEndDate;
    tempStartDateLabel = appliedStartDateLabel;
    tempEndDateLabel = appliedEndDateLabel;

    notifyListeners();
  }

  /// Clears all active and temporary filters and resets labels.
  void clearFilters() {
    tempFilters.clear();
    appliedFilters.clear();
    startDate = null;
    endDate = null;
    tempStartDate = null;
    tempEndDate = null;
    appliedStartDate = null;
    appliedEndDate = null;

    tempStartDateLabel = 'Select Start Date';
    tempEndDateLabel = 'Select End Date';
    appliedStartDateLabel = 'Select Start Date';
    appliedEndDateLabel = 'Select End Date';
    _activeSearchQuery = null;
    _currentPage = 0;
    notifyListeners();
  }

  void setStartDate(DateTime selectedDate) {
    tempStartDate = selectedDate;
    tempStartDateLabel = DateFormat('MMM dd, yyyy').format(selectedDate);
    notifyListeners();
  }

  /// Sets the end date for filtering and notifies listeners.
  void setEndDate(DateTime selectedDate) {
    tempEndDate = selectedDate;
    tempEndDateLabel = DateFormat('MMM dd, yyyy').format(selectedDate);
    notifyListeners();
  }

  final Map<String, List<dynamic>> statusDomains = {
    'Quotation': [
      [
        'state',
        'in',
        ['draft', 'sent'],
      ],
    ],
    'Pickup': [
      ['rental_status', '=', 'pickup'],
    ],
    'Return': [
      ['rental_status', '=', 'return'],
    ],
    'Cancelled': [
      ['state', '=', 'cancel'],
    ],
  };

  /// Builds the Odoo domain for fetching rental orders based on filters and search.
  List<dynamic> buildDomain({required int userId, String? searchQuery}) {
    List<dynamic> domain = [
      ['is_rental_order', '=', true],
    ];

    List<String> statusFilters = appliedFilters
        .where((f) => statusDomains.containsKey(f))
        .toList();

    if (statusFilters.isNotEmpty) {
      if (statusFilters.length == 1) {
        domain.addAll(statusDomains[statusFilters.first]!);
      } else {
        for (int i = 0; i < statusFilters.length - 1; i++) {
          domain.add('|');
        }
        for (final filter in statusFilters) {
          domain.addAll(statusDomains[filter]!);
        }
      }
    }

    if (appliedFilters.contains('Late')) {
      domain.add(['is_late', '=', true]);
    }

    if (appliedFilters.contains('My Orders')) {
      domain.add(['user_id', '=', userId]);
    }

    if (appliedFilters.contains('To Do Today')) {
      final now = DateTime.now();
      final today = DateFormat('yyyy-MM-dd').format(now);
      final tomorrow = DateFormat(
        'yyyy-MM-dd',
      ).format(now.add(const Duration(days: 1)));

      domain.add('|');
      domain.addAll([
        '&',
        ['rental_start_date', '>=', '$today 00:00:00'],
        ['rental_start_date', '<', '$tomorrow 00:00:00'],
      ]);
      domain.addAll([
        '&',
        ['rental_return_date', '>=', '$today 00:00:00'],
        ['rental_return_date', '<', '$tomorrow 00:00:00'],
      ]);
    }

    if (appliedStartDate != null && appliedEndDate != null) {
      domain.add([
        'date_order',
        '>=',
        DateFormat('yyyy-MM-dd').format(appliedStartDate!),
      ]);
      domain.add([
        'date_order',
        '<=',
        DateFormat('yyyy-MM-dd').format(appliedEndDate!),
      ]);
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      domain = [
        '&',
        ...domain,
        '|',
        ['name', 'ilike', searchQuery],
        ['partner_id.name', 'ilike', searchQuery],
      ];
    }

    return domain;
  }

  int get totalCount => _totalCount;
  int _totalCount = 0;
  static const int _pageSize = 40;
  int _currentPage = 0;

  bool get canGoPrevious => _currentPage > 0;
  bool get canGoNext => (_currentPage + 1) * _pageSize < _totalCount;
  int get startIndex => _totalCount == 0 ? 0 : (_currentPage * _pageSize) + 1;

  int get endIndex {
    if (_totalCount == 0) return 0;
    final end = (_currentPage + 1) * _pageSize;
    return end > _totalCount ? _totalCount : end;
  }

  Future<void> nextPage(BuildContext context) async {
    if (!canGoNext) return;

    isRentalOrderScreenLoading = true;
    notifyListeners();

    _currentPage++;

    await searchCountForRentalOrders(context, searchQuery: _activeSearchQuery);

    await fetchRentalOrdersScreen(context, searchQuery: _activeSearchQuery);

    isRentalOrderScreenLoading = false;
    notifyListeners();
  }

  Future<void> previousPage(BuildContext context) async {
    if (!canGoPrevious) return;

    isRentalOrderScreenLoading = true;
    notifyListeners();

    _currentPage--;

    await searchCountForRentalOrders(context, searchQuery: _activeSearchQuery);

    await fetchRentalOrdersScreen(context, searchQuery: _activeSearchQuery);

    isRentalOrderScreenLoading = false;
    notifyListeners();
  }

  Future<void> searchRentalOrders(
    BuildContext context, {
    String? searchQuery,
  }) async {
    isRentalOrderScreenLoading = true;
    notifyListeners();

    _activeSearchQuery = searchQuery;
    _currentPage = 0;

    await searchCountForRentalOrders(context, searchQuery: searchQuery);
    await fetchRentalOrdersScreen(context, searchQuery: searchQuery);

    isRentalOrderScreenLoading = false;
    notifyListeners();
  }

  Future<void> searchCountForRentalOrders(
    BuildContext context, {
    String? searchQuery,
  }) async {
    final userId = context.read<UserProvider>().userId;
    if (userId == null) {
      _totalCount = 0;
      notifyListeners();
      return;
    }

    final domain = buildDomain(userId: userId, searchQuery: searchQuery);

    try {
      final response = await OdooSessionManager.callKwWithCompany({
        'model': 'sale.order',
        'method': 'search_count',
        'args': [domain],
        'kwargs': {},
      });

      _totalCount = response as int;
      notifyListeners();
    } catch (e) {
      _totalCount = 0;
      notifyListeners();
    }
  }

  Future<void> fetchRentalOrdersScreen(
    BuildContext context, {
    String? searchQuery,
  }) async {
    notifyListeners();

    try {
      final userId = context.read<UserProvider>().userId;

      final queryToUse = searchQuery ?? _activeSearchQuery;

      final domain = buildDomain(userId: userId!, searchQuery: queryToUse);

      final offset = _currentPage * _pageSize;

      final response = await OdooSessionManager.callKwWithCompany({
        'model': 'sale.order',
        'method': 'search_read',
        'args': [domain],
        'kwargs': {
          'fields': [],
          'limit': _pageSize,
          'offset': offset,
          'order': 'date_order desc',
        },
      });

      rentalOrderScreenList = response
          .map<RentalOrderItem>((e) => RentalOrderItem.fromJson(e))
          .toList();
      notifyListeners();
    } catch (e) {
      error = _getUserFriendlyErrorMessage(e);

      rentalOrderScreenList = [];
    }
  }

  RentalOrderItem? selectedOrder;
  double totalTaxamount = 0.0;
  bool isViewOrderLoading = false;

  /// Fetches a specific rental order by its [orderId].
  Future<void> fetchOrderById(BuildContext context, int orderId) async {
    isViewOrderLoading = true;
    notifyListeners();

    try {
      fetchOrderline = [];
      final response = await OdooSessionManager.callKwWithCompany({
        'model': 'sale.order',
        'method': 'search_read',
        'args': [[['id', '=', orderId]]],
        'kwargs': {'fields': [], 'limit': 1},
      });

      if (response is List && response.isNotEmpty) {
        final orderData = response.first;
        selectedOrder = RentalOrderItem.fromJson(orderData);

        if (orderData['partner_id'] is List &&
            orderData['partner_id'].isNotEmpty) {
          final partnerId = orderData['partner_id'][0];

          final addressResponse = await OdooSessionManager.callKwWithCompany({
            'model': 'res.partner',
            'method': 'read',
            'args': [
              [partnerId],
              [
                'street',
                'street2',
                'city',
                'state_id',
                'zip',
                'country_id',
                'phone',
                'email',
              ],
            ],
            'kwargs': {},
          });

          if (addressResponse is List &&
              addressResponse.isNotEmpty &&
              selectedOrder != null) {
            final address = addressResponse.first;

            String str(dynamic v) => (v is String && v.isNotEmpty) ? v : '';
            String name(dynamic v) =>
                (v is List && v.length > 1) ? v[1].toString() : '';

            selectedOrder = selectedOrder!.copyWith(
              street: str(address['street']),
              street2: str(address['street2']),
              city: str(address['city']),
              state: name(address['state_id']),
              zip: str(address['zip']),
              country: name(address['country_id']),
              customerPhone: str(address['phone']),
              customerEmail: str(address['email']),
            );
          }
          notifyListeners();
        }

        final orderLineIds = (orderData['order_line'] as List?)?.cast<int>();
        if (orderLineIds != null && orderLineIds.isNotEmpty) {
          await fetchOrderLine(context, orderLineIds);
        }
        if (selectedOrder?.isQuoteAvailable == true) {
          await fetchQuoteBuilderParams(context, orderId);
        }
      } else {
        selectedOrder = null;
      }
    } catch (e) {
      fetchOrderline = [];
      selectedOrder = null;
    }

    isViewOrderLoading = false;
    notifyListeners();
  }

  /// Cancels a rental order.
  Future<void> cancelOrder(BuildContext context, int orderId) async {
    await OdooSessionManager.callKwWithCompany({
      'model': 'sale.order',
      'method': 'action_cancel',
      'args': [
        [orderId],
      ],
      'kwargs': {},
    });

    await fetchOrderById(context, orderId);
    if (context.mounted) context.refreshDashboard();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen(initialIndex: 1)),
    );

    CustomSnackbar.showSuccess(context, 'Order cancelled successfully');
  }

  /// Advances the rental order to the next status (e.g., pickup to return).
  Future<void> nextStageOnOrder(
    BuildContext context,
    int orderId,
    String currentStatus,
  ) async {
    String nextStatus = (currentStatus == 'pickup' || currentStatus == 'sale')
        ? 'return'
        : 'returned';

    await OdooSessionManager.callKwWithCompany({
      'model': 'sale.order',
      'method': 'write',
      'args': [
        [orderId],
        {'rental_status': nextStatus},
      ],
      'kwargs': {},
    });

    await fetchOrderById(context, orderId);
    if (context.mounted) context.refreshDashboard();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen(initialIndex: 1)),
    );

    String message = nextStatus == 'return'
        ? 'Order picked up successfully'
        : 'Items returned successfully';

    CustomSnackbar.showSuccess(context, message);
  }

  /// Converts a standard sale order to a rental order.
  Future<void> convertToRental(BuildContext context, int orderId) async {
    await OdooSessionManager.callKwWithCompany({
      'model': 'sale.order',
      'method': 'write',
      'args': [
        [orderId],
        {'is_rental_order': true},
      ],
      'kwargs': {},
    });

    await fetchOrderById(context, orderId);
    if (context.mounted) context.refreshDashboard();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen(initialIndex: 1)),
    );

    CustomSnackbar.showSuccess(
      context,
      'Converted to rental order successfully',
    );
  }

  /// Confirms a rental quotation as a sale order.
  Future<void> confirmOrder(BuildContext context, int orderId) async {
    await OdooSessionManager.callKwWithCompany({
      'model': 'sale.order',
      'method': 'action_confirm',
      'args': [
        [orderId],
      ],
      'kwargs': {},
    });

    await fetchOrderById(context, orderId);
    if (context.mounted) context.refreshDashboard();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen(initialIndex: 1)),
    );

    CustomSnackbar.showSuccess(
      context,
      'Converted to rental order successfully',
    );
  }

  bool convertingPdf = false;

  /// Downloads the PDF report for a rental order.
  Future<File> downloadRentalOrderPdf(
    int orderId, {
    required SalePdfType pdfType,
    bool openAfterDownload = false,
  }) async {
    convertingPdf = true;
    notifyListeners();

    try {
      final service = SalePdfService();
      return await service.downloadRentalOrderPdf(
        orderId,
        pdfType: pdfType,
        openAfterDownload: openAfterDownload,
      );
    } finally {
      convertingPdf = false;
      notifyListeners();
    }
  }

  Future<void> downloadQuotationWithDialog(
    BuildContext context,
    int orderId,
  ) async {
    final pdfType = await showSalePdfTypeSheet(context);
    if (pdfType == null) return;

    loadingDialog(
      context,
      'Downloading pdf...',
      'Please hold for a moment!',
      LoadingAnimationWidget.fourRotatingDots(
        color: Theme.of(context).colorScheme.primary,
        size: 30,
      ),
    );

    try {
      await downloadRentalOrderPdf(
        orderId,
        pdfType: pdfType,
        openAfterDownload: true,
      );
    } catch (e) {
      if (context.mounted) {
        CustomSnackbar.showError(context, 'Failed to download PDF');
      }
    } finally {
      if (context.mounted) {
        hideLoadingDialog(context);
      }
    }
  }

  bool sendingEmail = false;

  /// Initiates an email send for the rental order (quotation).
  Future<void> sendRentalOrderByEmail(BuildContext context, int orderId) async {
    sendingEmail = true;
    notifyListeners();

    loadingDialog(
      context,
      'Sending Email...',
      'Please hold for a moment!',
      LoadingAnimationWidget.fourRotatingDots(
        color: Theme.of(context).colorScheme.primary,
        size: 30,
      ),
    );
    bool isOperationSuccessful = false;

    try {
      final client = await OdooSessionManager.getClient();

      // 1. Version Parsing
      final String versionString = client?.sessionId?.serverVersion ?? '0';
      final int majorVersion =
          int.tryParse(versionString.split('.').first) ?? 0;

      // Define specific version flags
      bool isOdoo19 = majorVersion >= 19;
      bool isOdoo18 = majorVersion == 18;

      // 2. Get the Email Template Context
      final responseContext = await OdooSessionManager.callKwWithCompany({
        'model': 'sale.order',
        'method': 'action_quotation_send',
        'args': [
          [orderId],
        ],
        'kwargs': {},
      });

      final contextData = responseContext['context'];
      int? templateId = contextData?['default_template_id'];

      if (templateId == null) {
        if (context.mounted) Navigator.pop(context);
        return;
      }

      // 3. Define Fields to Read (THE FIX)
      // Odoo 19 crashed on 'available_product_document_ids', so we exclude it.
      // Only Odoo 18 definitely has these fields confirmed in your setup.
      // Odoo 17 and 19 will use the safe fallback ['partner_id'].
      List<String> fieldsToRead = isOdoo18
          ? [
              'partner_id',
              'available_product_document_ids',
              'quotation_document_ids',
            ]
          : ['partner_id'];

      final saleOrderResponse = await OdooSessionManager.callKwWithCompany({
        'model': 'sale.order',
        'method': 'read',
        'args': [
          [orderId],
        ],
        'kwargs': {'fields': fieldsToRead},
      });

      if (saleOrderResponse.isEmpty ||
          saleOrderResponse[0]['partner_id'] == null) {
        if (context.mounted) Navigator.pop(context);
        return;
      }

      int partnerId = saleOrderResponse[0]['partner_id'][0] as int;

      // 4. Handle 'res_ids' format (String for 19, List for others)
      dynamic resIdsValue = isOdoo19
          ? jsonEncode([orderId]) // Odoo 19 requires String: "[100]"
          : [orderId]; // Odoo 17/18 requires List: [100]

      final mailComposeId = await OdooSessionManager.callKwWithCompany({
        'model': 'mail.compose.message',
        'method': 'create',
        'args': [
          {
            'model': 'sale.order',
            'res_ids': resIdsValue,
            'template_id': templateId,
            'composition_mode': 'comment',
            'force_send': true,
            'email_layout_xmlid':
                'mail.mail_notification_layout_with_responsible_signature',
            'partner_ids': [partnerId],
          },
        ],
        'kwargs': {},
      });

      await client!.callKw({
        'model': 'mail.compose.message',
        'method': 'action_send_mail',
        'args': [
          [mailComposeId],
        ],
        'kwargs': {},
      });

      isOperationSuccessful = true;
    } catch (error) {
    } finally {
      sendingEmail = false;
      notifyListeners();

      hideLoadingDialog(context);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;

        if (isOperationSuccessful) {
          CustomSnackbar.showSuccess(context, 'Email sent successfully');
        } else {
          CustomSnackbar.showError(context, 'Failed to send email');
        }
      });
    }
  }

  bool deletingOrder = false;

  Future<void> deleteOrder(BuildContext context, int orderId) async {
    deletingOrder = true;
    notifyListeners();

    loadingDialog(
      context,
      'Deleting order...',
      'Please hold for a moment!',
      LoadingAnimationWidget.fourRotatingDots(
        color: Theme.of(context).colorScheme.primary,
        size: 30,
      ),
    );
    bool success = false;

    try {
      await OdooSessionManager.callKwWithCompany({
        'model': 'sale.order',
        'method': 'unlink',
        'args': [
          [orderId],
        ],
        'kwargs': {},
      });

      success = true;
    } catch (e) {
    } finally {
      deletingOrder = false;
      notifyListeners();

      hideLoadingDialog(context);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;

        if (success) {
          context.refreshDashboard();
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => const HomeScreen(initialIndex: 1),
            ),
            (_) => false,
          );

          CustomSnackbar.showSuccess(context, 'Order deleted successfully');
        } else {
          CustomSnackbar.showError(context, 'Failed to delete order');
        }
      });
    }
  }

  Future<void> confirmDeleteOrder(
    BuildContext context,
    int orderId,
    RentalOrderProvider provider,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          title: const Text('Delete Order'),
          content: const Text(
            'This action cannot be undone.\nAre you sure you want to delete this order?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await provider.deleteOrder(context, orderId);
    }
  }

  Future<void> shareRentalOrderViaWhatsapp(
    BuildContext context,
    int orderId,
  ) async {
    loadingDialog(
      context,
      'Preparing PDF...',
      'Please hold for a sec!',
      LoadingAnimationWidget.fourRotatingDots(
        color: Theme.of(context).colorScheme.primary,
        size: 30,
      ),
    );

    try {
      final file = await downloadRentalOrderPdf(
        orderId,
        pdfType: SalePdfType.quotation,
        openAfterDownload: false,
      );

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'Please find the rental quotation attached.',
        ),
      );
    } catch (e) {

      if (context.mounted) {
        CustomSnackbar.showError(context, 'Failed to share rental quotation');
      }
    } finally {
      if (context.mounted) {
        hideLoadingDialog(context);
      }
    }
  }

  QuoteBuilderData? quoteBuilderData;

  Future<void> fetchQuoteBuilderParams(
    BuildContext context,
    int orderId,
  ) async {
    try {
      final response = await OdooSessionManager.callKwWithCompany({
        'model': 'sale.order',
        'method': 'get_update_included_pdf_params',
        'args': [orderId],
        'kwargs': {'context': {}},
      });

      if (response != null) {
        QuoteBuilderData data = QuoteBuilderData();

        if (response['headers'] != null &&
            response['headers']['files'] != null) {
          data.headers = (response['headers']['files'] as List)
              .map((f) => QuoteDocument.fromJson(f))
              .toList();
        }
        if (response['footers'] != null &&
            response['footers']['files'] != null) {
          data.footers = (response['footers']['files'] as List)
              .map((f) => QuoteDocument.fromJson(f))
              .toList();
        }
        if (response['lines'] != null) {
          data.lines = (response['lines'] as List)
              .map((l) => QuoteLine.fromJson(l))
              .toList();
        }
        quoteBuilderData = data;
        notifyListeners();
      }
    } catch (e) {
    }
  }

  void toggleDocumentSelection(int id, bool isHeader) {
    if (quoteBuilderData == null) return;

    void toggleInList(List<QuoteDocument> list) {
      for (var doc in list) {
        if (doc.id == id) {
          doc.isSelected = !doc.isSelected;
        }
      }
    }

    if (isHeader) {
      toggleInList(quoteBuilderData!.headers);
    } else {
      toggleInList(quoteBuilderData!.footers);
    }
    notifyListeners();
  }

  void toggleLineDocumentSelection(int lineId, int fileId) {
    if (quoteBuilderData == null) return;

    for (var line in quoteBuilderData!.lines) {
      if (line.lineId == lineId) {
        for (var file in line.files) {
          if (file.id == fileId) {
            file.isSelected = !file.isSelected;
          }
        }
      }
    }
    notifyListeners();
  }

  bool savingQuote = false;
  Future<void> saveAllQuoteBuilderChanges(
    BuildContext context,
    int orderId,
  ) async {
    if (quoteBuilderData == null) return;

    try {
      savingQuote = true;
      notifyListeners();

      List<int> globalSelectedIds = [];
      List<dynamic> orderLineUpdates = [];

      Map<String, dynamic> formFieldsJson = {
        "header": {},
        "line": {},
        "footer": {},
      };

      for (var doc in quoteBuilderData!.headers) {
        if (doc.isSelected) {
          globalSelectedIds.add(doc.id);
          formFieldsJson["header"]["${doc.id}"] = {
            "document_name": doc.name,
            "custom_form_fields": {},
          };
        }
      }
      for (var doc in quoteBuilderData!.footers) {
        if (doc.isSelected) {
          globalSelectedIds.add(doc.id);
          formFieldsJson["footer"]["${doc.id}"] = {
            "document_name": doc.name,
            "custom_form_fields": {},
          };
        }
      }

      for (var line in quoteBuilderData!.lines) {
        List<int> lineFileIds = [];

        for (var file in line.files) {
          if (file.isSelected) {
            lineFileIds.add(file.id);

            formFieldsJson["line"] ??= {};
            if (formFieldsJson["line"]["${line.lineId}"] == null) {
              formFieldsJson["line"]["${line.lineId}"] = {};
            }
            formFieldsJson["line"]["${line.lineId}"]["${file.id}"] = {
              "document_name": file.name,
              "custom_form_fields": {},
            };
          }
        }
        orderLineUpdates.add([
          1,
          line.lineId,
          {
            'product_document_ids': [
              [6, 0, lineFileIds],
            ],
          },
        ]);
      }

      final companyProvider = Provider.of<CompanyProvider>(
        context,
        listen: false,
      );
      final mainId = companyProvider.selectedCompanyId;
      final response = await OdooSessionManager.callKwWithCompany({
        'model': 'sale.order',
        'method': 'web_save',
        'args': [
          [orderId],
          {
            'quotation_document_ids': [
              [6, 0, globalSelectedIds],
            ],
            'order_line': orderLineUpdates,
            'customizable_pdf_form_fields': jsonEncode(formFieldsJson),
          },
        ],
        'kwargs': {
          'specification': {'display_name': {}},
          'context': {
            // 'lang': 'en_US',
            // 'tz': 'Asia/Calcutta',
            // 'allowed_company_ids': [activeCompanyId],
            'in_rental_app': 1,
            'active_id': orderId,
            'active_model': 'sale.order',
          },
        },
      });

      await fetchQuoteBuilderParams(context, orderId);
      savingQuote = false;
      CustomSnackbar.showSuccess(context, 'Succefully Applied Quote');

      notifyListeners();
    } catch (e) {

      CustomSnackbar.showError(context, 'Failed to save changes');
    }
  }

  List<FetchedOrderLineModel> fetchOrderline = [];
  Future<void> fetchOrderLine(
    BuildContext context,
    List<int> orderLineIds,
  ) async {
    if (orderLineIds.isEmpty) return;

    try {
      final client = await OdooSessionManager.getClient();
      final String serverVersionString = client!.sessionId!.serverVersion;

      final int majorVersion = int.parse(serverVersionString.split('.').first);

      final String taxFieldName = majorVersion >= 19 ? 'tax_ids' : 'tax_id';

      List<String> fieldsToFetch = [
        'id',
        'name',
        'product_id',
        'price_unit',
        'price_total',
        'qty_delivered',
        'product_uom_qty',
        'price_tax',
        taxFieldName,
      ];

      if (majorVersion == 18) {
        fieldsToFetch.add('product_document_ids');
      }

      final response = await OdooSessionManager.callKwWithCompany({
        'model': 'sale.order.line',
        'method': 'search_read',
        'args': [
          [
            ['id', 'in', orderLineIds],
          ],
        ],
        'kwargs': {'fields': fieldsToFetch},
      });

      if (response is List && selectedOrder != null) {
        if (majorVersion < 19) {
          for (var item in response) {
            if (item is Map<String, dynamic>) {
              item['tax_ids'] = item['tax_id'];
            }
          }
        }

        fetchOrderline = response
            .map<FetchedOrderLineModel>(
              (json) => FetchedOrderLineModel.fromJson(json),
            )
            .toList();

        Set<int> allTaxIds = {};
        for (var lineJson in response) {
          final taxIds = lineJson['tax_ids'];
          if (taxIds != null && taxIds is List) {
            allTaxIds.addAll(taxIds.cast<int>());
          }
        }

        if (allTaxIds.isNotEmpty) {
          final List<TaxModel> allFetchedTaxes = await fetchTaxesByIds(
            context,
            allTaxIds.toList(),
          );
          final Map<int, TaxModel> taxMap = {
            for (var tax in allFetchedTaxes) tax.id: tax,
          };
          for (int i = 0; i < fetchOrderline.length; i++) {
            final rawTaxIds = response[i]['tax_ids'] as List?;
            if (rawTaxIds != null) {
              fetchOrderline[i].taxes = rawTaxIds
                  .map((id) => taxMap[id])
                  .whereType<TaxModel>()
                  .toList();
            }
          }
        }
      }
    } catch (e) {
    }
    notifyListeners();
  }

  Future<List<TaxModel>> fetchTaxesByIds(
    BuildContext context,
    List<int> taxIds,
  ) async {
    try {
      final result = await OdooSessionManager.callKwWithCompany({
        'model': 'account.tax',
        'method': 'search_read',
        'args': [
          [
            ['id', 'in', taxIds],
          ],
        ],
        'kwargs': {
          'fields': ['id', 'display_name', 'amount'],
        },
      });

      if (result is List) {
        return result.map<TaxModel>((json) => TaxModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  bool savingSignature = false;
  Future<void> saveSignature(
    BuildContext context,
    int orderId,
    Uint8List signatureBytes,
    String signedBy,
    DateTime signedOn,
  ) async {
    try {
      savingSignature = true;
      notifyListeners();

      String base64Signature = base64Encode(signatureBytes);
      String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(signedOn);

      await OdooSessionManager.callKwWithCompany({
        'model': 'sale.order',
        'method': 'write',
        'args': [
          [orderId],
          {
            'signed_by': signedBy,
            'signed_on': formattedDate,
            'signature': base64Signature,
          },
        ],
        'kwargs': {
          'context': {'in_rental_app': 1},
        },
      });

      savingSignature = false;
      notifyListeners();
      CustomSnackbar.showSuccess(context, "Signature saved successfully!");
    } catch (e) {
      CustomSnackbar.showError(context, "Failed to save signature: $e");
    }
  }

  void clearRentalOrderProviderState() {
    tempFilters.clear();
    appliedFilters.clear();
    error = null;
    tempStartDate = null;
    tempEndDate = null;
    appliedStartDate = null;
    appliedEndDate = null;
    startDate = null;
    endDate = null;

    tempStartDateLabel = 'Select Start Date';
    tempEndDateLabel = 'Select End Date';
    appliedStartDateLabel = 'Select Start Date';
    appliedEndDateLabel = 'Select End Date';

    isRentalOrderScreenLoading = false;
    rentalOrderScreenList.clear();

    _totalCount = 0;
    _currentPage = 0;

    selectedOrder = null;
    totalTaxamount = 0.0;
    isViewOrderLoading = false;

    convertingPdf = false;
    sendingEmail = false;
    deletingOrder = false;
    savingQuote = false;
    savingSignature = false;

    quoteBuilderData = null;
    fetchOrderline.clear();

    notifyListeners();
  }
}
