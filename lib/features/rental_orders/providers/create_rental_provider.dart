import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mobo_rental/Core/services/odoo_session_manager.dart';
import 'package:mobo_rental/features/company/providers/company_provider.dart';
import 'package:mobo_rental/shared/widgets/dialogs/common_dialog.dart';
import 'package:mobo_rental/Core/Widgets/common/alert_dialog.dart';
import 'package:mobo_rental/Core/services/review_service.dart';
import 'package:mobo_rental/features/rental_orders/models/customer_model.dart';
import 'package:mobo_rental/features/rental_orders/models/fetched_order_line_model.dart';
import 'package:mobo_rental/features/rental_orders/models/order_line_model.dart';
import 'package:mobo_rental/features/rental_orders/models/product_model.dart';
import 'package:mobo_rental/features/rental_orders/models/payment_term_model.dart';
import 'package:mobo_rental/features/rental_orders/models/product_varient_model.dart';
import 'package:mobo_rental/features/rental_orders/models/rental_order_item.dart';
import 'package:mobo_rental/features/rental_orders/models/tax_model.dart';
import 'package:mobo_rental/features/rental_orders/providers/rental_order_provider.dart';
import 'package:mobo_rental/features/rental_orders/widgets/varient_dialog.dart';
import 'package:odoo_rpc/odoo_rpc.dart';
import 'package:provider/provider.dart';

/// A provider that manages the state and logic for creating a new rental order.
/// 
/// Handles customer selection, product selection, date management, 
/// and synchronization with the Odoo backend for draft orders.
class CreateRentalProvider extends ChangeNotifier {
  bool showCustomerDropdown = false;
  bool customerIsSelected = false;
  bool showPricelistDropdown = false;
  bool showPaymentDropdown = false;
  bool isCustomerloading = false;
  bool paymentTermLoading = false;
  bool isUpdatingRental = false;
  TextEditingController customerController = TextEditingController();
  TextEditingController pricelistController = TextEditingController();
  TextEditingController paymentTermController = TextEditingController();

  List<Customer> customerList = [];
  List<Pricelist> pricelistsList = [];
  List<PaymentTerm> paymentTermsList = [];
  List<ProductModel> prductsList = [];
  List<ProductLine> selectedProducts = [];
  List<TaxModel> taxesList = [];

  Customer? selectedCustomer;
  PaymentTerm? selectedPaymentTerm;
  Pricelist? selectedPricelist;

  DateTime quotationDate = DateTime.now();
  DateTime expirationDate = DateTime.now().add(const Duration(days: 365));
  DateTime fromDate = DateTime.now();
  DateTime toDate = DateTime.now().add(const Duration(days: 1));

  double orderSubtotal = 0.0;
  double orderTaxTotal = 0.0;
  double orderGrandTotal = 0.0;

  int? editingOrderId;
  int? editingOrderLineId;
  String? editingOrderName;

  bool isCreatingRental = false;
  bool editRentalLoading = false;

  List<ProductVariantModel> variants = [];
  bool variantsLoading = false;

  /// Returns a human-readable duration string for the rental period.
  String get duration {
    final days = toDate.difference(fromDate).inDays;
    if (days <= 1) return '$days day';
    return '$days days';
  }

  bool rentalDatesChanged = false;
  bool updatingRentalPrices = false;

  bool get isEditMode => editingOrderId != null;
  // ... existing variables ...

  bool _hasStockModule = false;
  bool get hasStockModule => _hasStockModule;

  /// Checks if the 'stock' module is installed on the Odoo server.
  Future<void> checkStockModuleInstalled() async {
    try {
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
      notifyListeners();
    } catch (e) {
      _hasStockModule = false;
    }
  }

  /// Ensures a draft sale order exists in Odoo before adding lines.
  /// 
  /// Creates a new draft order if [editingOrderId] is null.
  Future<bool> ensureDraftOrder(BuildContext context) async {
    if (editingOrderId != null) return true;

    if (selectedCustomer == null) {
      showDialog(
        context: context,
        builder: (ctx) => CommonDialog(
          title: 'Customer Required',
          message: 'Please select a customer before adding products.',
          icon: HugeIcons.strokeRoundedUser,
          primaryLabel: 'Select Customer',
          onPrimary: () => Navigator.of(ctx).pop(),
          topIconCentered: true,
        ),
      );
      return false;
    }

    final companyId = Provider.of<CompanyProvider>(
      context,
      listen: false,
    ).selectedCompanyId;

    final orderId = await OdooSessionManager.callKwWithCompany({
      'model': 'sale.order',
      'method': 'create',
      'args': [
        {
          'partner_id': selectedCustomer!.id,
          'company_id': companyId,
          'state': 'draft',
          'is_rental_order': true,
         'rental_start_date': DateFormat(
            'yyyy-MM-dd HH:mm:ss',
          ).format(fromDate.toUtc()),
          'rental_return_date': DateFormat(
            'yyyy-MM-dd HH:mm:ss',
          ).format(toDate.toUtc()),
        },
      ],
      'kwargs': {
        'context': {'in_rental_app': true},
      },
    });

    editingOrderId = orderId;
    final order = await OdooSessionManager.callKwWithCompany({
      'model': 'sale.order',
      'method': 'read',
      'args': [
        [editingOrderId],
        ['name'],
      ],
      'kwargs': {},
    });

    editingOrderName = order[0]['name'];
    notifyListeners();
    return true;
  }

  /// Reloads all order lines and totals from the current Odoo order.
  Future<void> reloadOrderLines() async {
    if (editingOrderId == null) return;

    final order = await OdooSessionManager.callKwWithCompany({
      'model': 'sale.order',
      'method': 'read',
      'args': [
        [editingOrderId],
        ['order_line', 'amount_untaxed', 'amount_tax', 'amount_total'],
      ],
      'kwargs': {},
    });

    orderSubtotal = (order[0]['amount_untaxed'] as num).toDouble();
    orderTaxTotal = (order[0]['amount_tax'] as num).toDouble();
    orderGrandTotal = (order[0]['amount_total'] as num).toDouble();

    final lineIds = order[0]['order_line'] as List;
    if (lineIds.isEmpty) {
      selectedProducts.clear();
      notifyListeners();
      return;
    }

    final client = await OdooSessionManager.getClient();
    final int majorVersion = int.parse(
      client!.sessionId!.serverVersion.split('.').first,
    );

    final String taxField = majorVersion >= 19 ? 'tax_ids' : 'tax_id';

    final lines = await OdooSessionManager.callKwWithCompany({
      'model': 'sale.order.line',
      'method': 'read',
      'args': [
        lineIds,
        [
          'product_id',
          'name',
          'price_unit',
          'product_uom_qty',
          taxField,
          'price_subtotal',
          'price_tax',
          'price_total',
        ],
      ],
      'kwargs': {},
    });

    selectedProducts = (lines as List).map<ProductLine>((line) {
      final product = line['product_id'] as List?;
      final int productId = product != null && product.isNotEmpty
          ? product[0]
          : 0;

      final rawTaxes = line[taxField];

      List<int> taxIds = [];
      if (rawTaxes is List) {
        taxIds = List<int>.from(rawTaxes);
      } else if (rawTaxes is int) {
        taxIds = [rawTaxes];
      }
      return ProductLine(
        id: line['id'],
        productId: productId,
        name: line['name'] ?? '',
        price: (line['price_unit'] as num?)?.toDouble() ?? 0.0,
        quantity: (line['product_uom_qty'] as num?)?.toInt() ?? 0,
        taxes: taxesList.where((t) => taxIds.contains(t.id)).toList(),
        subtotal: (line['price_subtotal'] as num?)?.toDouble() ?? 0.0,
        tax: (line['price_tax'] as num?)?.toDouble() ?? 0.0,
        lineTotal: (line['price_total'] as num?)?.toDouble() ?? 0.0,
      );
    }).toList();

    notifyListeners();
  }

  bool creatingDraftOrder = false;

 // Update this method signature
  /// Creates a new sale order line for a given product.
  /// 
  /// Returns the ID of the newly created line.
  Future<int?> createOrderLine({
    required BuildContext context,
    required int productId,
    double qty = 1.0,
    bool showGlobalLoader = true, // <--- ADD THIS PARAMETER (Default to true)
  }) async {
    // Check customer existence logic...
    if (editingOrderId == null && selectedCustomer == null) {
      // ... (Keep existing customer dialog logic)
      return null;
    }

    final bool isFirstProduct = editingOrderId == null;

    // Only show Global Loader if isFirstProduct is true AND showGlobalLoader is true
    if (isFirstProduct && showGlobalLoader) {
      creatingDraftOrder = true;
      notifyListeners();

      loadingDialog(
        context,
        'Creating Order',
        'Setting up rental draft...',
        LoadingAnimationWidget.fourRotatingDots(
          color: Theme.of(context).colorScheme.primary,
          size: 30,
        ),
      );
    }

    try {
      // Logic remains the same
      final canProceed = await ensureDraftOrder(context);
      if (!canProceed) return null;

      final lineId = await OdooSessionManager.callKwWithCompany({
        'model': 'sale.order.line',
        'method': 'create',
        'args': [
          {
            'order_id': editingOrderId,
            'product_id': productId,
            'product_uom_qty': qty,
          },
        ],
        'kwargs': {
          'context': {'in_rental_app': true},
        },
      });

      await reloadOrderLines();
      ReviewService().trackSignificantEvent();
      return lineId as int;
    } catch (e) {
      return null;
    } finally {
      // Only hide Global Loader if we actually showed it
      if (isFirstProduct && showGlobalLoader) {
        creatingDraftOrder = false;
        if (context.mounted) {
          hideLoadingDialog(context);
        }
        notifyListeners();
      }
    }
  }

  /// Updates the quantity of a specific order line.
  Future<void> updateLineQty(int qty) async {
    if (editingOrderLineId == null) return;

    await OdooSessionManager.callKwWithCompany({
      'model': 'sale.order.line',
      'method': 'write',
      'args': [
        [editingOrderLineId],
        {'product_uom_qty': qty},
      ],

      'kwargs': {},
    });

    await reloadOrderLines();
  }

  /// Updates the unit price and taxes for the currently editing line.
  Future<void> updateLinePrice(double price, List<int> taxIds) async {
    if (editingOrderLineId == null) return;

    final client = await OdooSessionManager.getClient();
    final int majorVersion = int.parse(
      client!.sessionId!.serverVersion.split('.').first,
    );
    final String taxField = majorVersion >= 19 ? 'tax_ids' : 'tax_id';

    final List<List<dynamic>> taxCommand = taxIds.isEmpty
        ? [
            [5, 0, 0],
          ]
        : [
            [6, 0, taxIds],
          ];

    try {
      await OdooSessionManager.callKwWithCompany({
        'model': 'sale.order.line',
        'method': 'write',
        'args': [
          [editingOrderLineId],
          {'price_unit': price, taxField: taxCommand},
        ],
        'kwargs': {
          'context': {'in_rental_app': true},
        },
      });

      await reloadOrderLines();
    } catch (e) {
    }
  }

  Future<void> updateLineTaxes(List<int> taxIds) async {
    if (editingOrderLineId == null) return;

    final client = await OdooSessionManager.getClient();
    final int majorVersion = int.parse(
      client!.sessionId!.serverVersion.split('.').first,
    );

    final String taxField = majorVersion >= 19 ? 'tax_ids' : 'tax_id';

    final List<List<dynamic>> taxCommand = taxIds.isEmpty
        ? [
            [5, 0, 0],
          ]
        : [
            [6, 0, taxIds],
          ];

    await OdooSessionManager.callKwWithCompany({
      'model': 'sale.order.line',
      'method': 'write',
      'args': [
        [editingOrderLineId],
        {taxField: taxCommand},
      ],
      'kwargs': {
        'context': {'in_rental_app': true},
      },
    });

    await reloadOrderLines();
  }

  /// Deletes the currently editing order line from the server.
  Future<void> cancelEditingLine() async {
    if (editingOrderLineId == null) return;

    await OdooSessionManager.callKwWithCompany({
      'model': 'sale.order.line',
      'method': 'unlink',
      'args': [
        [editingOrderLineId],
      ],
      'kwargs': {},
    });

    editingOrderLineId = null;
    await reloadOrderLines();
  }

  /// Loads data from an existing Odoo order into the provider for editing.
  Future<void> loadFromExistingOrder({
    required BuildContext context,
    required RentalOrderItem order,
    required List<FetchedOrderLineModel> orderLines,
  }) async {
    editRentalLoading = true;
    notifyListeners();

    selectedProducts.clear();
    editingOrderId = order.id;
    editingOrderName = order.code;

    final companyProvider = Provider.of<CompanyProvider>(
      context,
      listen: false,
    );

    final partnerResponse = await OdooSessionManager.callKwWithCompany({
      'model': 'res.partner',
      'method': 'read',
      'args': [
        [order.customerId],
        ['id', 'name', 'email', 'phone', 'image_1920'],
      ],
      'kwargs': {},
    });

    if (partnerResponse is List && partnerResponse.isNotEmpty) {
      selectedCustomer = Customer.fromJson(partnerResponse.first);
      customerController.text = selectedCustomer!.name;
      customerIsSelected = true;
    }

    quotationDate = order.orderDate ?? DateTime.now();
    expirationDate = quotationDate;

    fromDate = DateTime.tryParse(order.startDate) ?? DateTime.now();
    toDate = DateTime.tryParse(order.endDate) ?? DateTime.now();

    paymentTermController.text = order.paymentTerm ?? '';

    await reloadOrderLines();

    editRentalLoading = false;
    notifyListeners();
  }

  /// Selects a specific product variant and adds it to the order.
  Future<void> selectVariant(
    BuildContext context,
    ProductVariantModel variant,
  ) async {
    final lineId = await createOrderLine(
      context: context,
      productId: variant.id,
    );

    if (lineId == null) return;

    editingOrderLineId = lineId;
    notifyListeners();
  }

  /// Subtotal of the current rental order.
  double get subtotal => orderSubtotal;

  /// Total tax amount for the current rental order.
  double get totalTax => orderTaxTotal;

  /// Grand total for the current rental order.
  double get grandTotal => orderGrandTotal;
  bool productLoading = false;
  bool isFetchingMoreProduct = false;
  bool hasMoreProduct = true;

  int productOffset = 0;
  static const int pageSize = 10;
  /// Fetches a list of rentable products based on the search [query].
  Future<void> fetchProducts(
    BuildContext context,
    String query, {
    bool isLoadMore = false,
  }) async {
    final companyProvider = Provider.of<CompanyProvider>(
      context,
      listen: false,
    );

    if (isLoadMore) {
      if (isFetchingMoreProduct || !hasMoreProduct) return;
      isFetchingMoreProduct = true;
    } else {
      productLoading = true;
      productOffset = 0;
      hasMoreProduct = true;
      prductsList.clear();
      // Ensure we check for the module before the first fetch
      if (prductsList.isEmpty) {
        await checkStockModuleInstalled();
      }
    }

    notifyListeners();

    // Dynamically build fields list
    final List<String> fields = [
      'name',
      'display_price',
      'product_variant_count',
    ];

    if (_hasStockModule) {
      fields.add('qty_available');
    }

    try {
      final response = await OdooSessionManager.callKwWithCompany({
        'model': 'product.template',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'domain': [
            ['name', 'ilike', query],
            ['rent_ok', '=', true],
            [
              'company_id',
              'in',
              [companyProvider.selectedCompanyId, false],
            ],
          ],
          'fields': fields,
          'limit': pageSize,
          'offset': productOffset,
        },
      });

      final fetched = (response as List)
          .map((e) => ProductModel.fromJson(e))
          .toList();

      prductsList.addAll(fetched);
      productOffset += pageSize;
      hasMoreProduct = fetched.length == pageSize;
    } catch (e) {
    } finally {
      productLoading = false;
      isFetchingMoreProduct = false;
      notifyListeners();
    }
  }

  /// Fetches variants for a product template and opens the variant selection dialog.
  Future<void> fetchVariantsAndOpenDialog(
    BuildContext context, {
    required int templateId,
    required String templateName,
  }) async {
    variantsLoading = true;
    variants.clear();
    notifyListeners();

    // Dynamically build fields list
    final List<String> fields = [
      'id',
      'display_name',
      'list_price',
      'taxes_id',
    ];

    if (_hasStockModule) {
      fields.add('qty_available');
    }

    try {
      final response = await OdooSessionManager.callKwWithCompany({
        'model': 'product.product',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'domain': [
            ['product_tmpl_id', '=', templateId],
            ['active', '=', true],
          ],
          'fields': fields,
        },
      });

      variants = (response as List)
          .map((e) => ProductVariantModel.fromJson(e))
          .toList();

      openVariantDialog(context, templateName);
    } catch (e) {
    } finally {
      variantsLoading = false;
      notifyListeners();
    }
  }

  /// Fetches a single variant ID for a product template.
  Future<int> fetchSingleVariantId({required int templateId}) async {
    final result = await OdooSessionManager.callKwWithCompany({
      'model': 'product.product',
      'method': 'search_read',
      'args': [],
      'kwargs': {
        'domain': [
          ['product_tmpl_id', '=', templateId],
          ['active', '=', true],
        ],
        'fields': ['id'],
        'limit': 1,
      },
    });

    if (result.isEmpty) {
      throw Exception('No variant found for template $templateId');
    }

    return result.first['id'] as int;
  }

  /// Opens the variant selection dialog.
  void openVariantDialog(BuildContext context, String templateName) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) =>
          VariantDialog(templateName: templateName, parentContext: context),
    );
  }

  /// Confirms the current draft order as a sale/rental order in Odoo.
  Future<bool> createRentalOrder(BuildContext context) async {
    if (editingOrderId == null) {
      await ensureDraftOrder(context);
    }

    isCreatingRental = true;
    notifyListeners();

    try {
      await OdooSessionManager.callKwWithCompany({
        'model': 'sale.order',
        'method': 'write',
        'args': [
          [editingOrderId],
          {'state': 'sale'},
        ],
        'kwargs': {},
      });
      ReviewService().trackSignificantEvent();
      return true;
    } catch (e) {
      return false;
    } finally {
      // Stop Loading
      isCreatingRental = false;
      notifyListeners();
    }
  }

  /// Opens the customer selection dropdown.
  void openCustomerDropdown() {
    showCustomerDropdown = true;
    notifyListeners();
  }

  /// Closes the customer selection dropdown.
  void closeCustomerDropdown() {
    showCustomerDropdown = false;
    notifyListeners();
  }

  /// Sets the selected [customer] and updates the UI.
  void setCustomer(Customer customer) {
    selectedCustomer = customer;
    customerController.text = customer.name;
    customerIsSelected = true;
    customerList.clear();
    showCustomerDropdown = false;
    notifyListeners();
  }

  /// Removes the currently selected customer.
  void removeCustomer() {
    selectedCustomer = null;
    customerIsSelected = false;
    customerController.clear();
    notifyListeners();
  }

  /// Searches for customers matching the [query].
  Future<void> searchCustomers(BuildContext context, String query) async {
    try {
      isCustomerloading = true;
      notifyListeners();

      final companyProvider = Provider.of<CompanyProvider>(
        context,
        listen: false,
      );
      final mainId = companyProvider.selectedCompanyId;

      final result = await OdooSessionManager.callKwWithCompany({
        'model': 'res.partner',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'domain': [
            ['name', 'ilike', query],
            [
              'company_id',
              'in',
              [mainId, false],
            ],
          ],
          'fields': ['id', 'name', 'email', 'phone', 'image_1920'],
          'limit': 5,
        },
      });

      customerList = (result as List).map((e) => Customer.fromJson(e)).toList();
    } finally {
      isCustomerloading = false;
      notifyListeners();
    }
  }

  /// Sets the expiration date for the quotation.
  void setExpirationDate(DateTime date) {
    expirationDate = date;
    notifyListeners();
  }

  /// Sets the quotation date.
  void setQuotationDate(DateTime date) {
    quotationDate = date;
    notifyListeners();
  }

  /// Updates the starting date for the rental period.
  Future<void> setFromDate(DateTime date, BuildContext context) async {
    fromDate = date;

    if (toDate.isBefore(fromDate)) {
      toDate = fromDate.add(const Duration(hours: 1));
    }
    rentalDatesChanged = true;

    notifyListeners();

    await ensureDraftOrder(context);
    await updateRentalDates(context);
  }

  /// Updates the return date for the rental period.
  Future<void> setToDate(DateTime date, BuildContext context) async {
    toDate = date;

    if (toDate.isBefore(fromDate)) {
      toDate = fromDate.add(const Duration(hours: 1));
    }
    rentalDatesChanged = true;

    notifyListeners();

    await ensureDraftOrder(context);
    await updateRentalDates(context);
  }

  Future<bool> updateRentalOrder(BuildContext context) async {
    // Start Loading
    isUpdatingRental = true;
    notifyListeners();

    try {

      // ... [Keep all your existing logic inside this try block] ...
      // 1. Snapshot Tax Preferences
      final Map<int, List<int>> userTaxPreferences = {
        for (var line in selectedProducts)
          line.id: line.taxes.map((t) => t.id).toList(),
      };

      final companyProvider = Provider.of<CompanyProvider>(
        context,
        listen: false,
      );
      final mainId = companyProvider.selectedCompanyId;

      // 2. Write Header
      await OdooSessionManager.callKwWithCompany({
        'model': 'sale.order',
        'method': 'write',
        'args': [
          [editingOrderId],
          {
            'partner_id': selectedCustomer?.id,
            'company_id': mainId,
            'state': 'draft',
            'is_rental_order': true,
           'rental_start_date': DateFormat(
              'yyyy-MM-dd HH:mm:ss',
            ).format(fromDate.toUtc()),
            'rental_return_date': DateFormat(
              'yyyy-MM-dd HH:mm:ss',
            ).format(toDate.toUtc()),
          },
        ],
        'kwargs': {},
      });

      // 3. Re-apply Tax Preferences (Logic from your code)
      final client = await OdooSessionManager.getClient();
      final int majorVersion = int.parse(
        client!.sessionId!.serverVersion.split('.').first,
      );
      final String taxField = majorVersion >= 19 ? 'tax_ids' : 'tax_id';

      final List<int> lineIds = selectedProducts.map((e) => e.id).toList();
      final dynamic freshLinesResult =
          await OdooSessionManager.callKwWithCompany({
            'model': 'sale.order.line',
            'method': 'read',
            'args': [
              lineIds,
              ['id', 'price_unit', 'price_subtotal', taxField],
            ],
            'kwargs': {},
          });

      final List<dynamic> freshLines = freshLinesResult as List<dynamic>;

      for (final freshLine in freshLines) {
        final int lineId = freshLine['id'];
        final List<int> preferredTaxIds = userTaxPreferences[lineId] ?? [];
        double? newUnitPrice;

        if (preferredTaxIds.isEmpty) {
          final double subtotal = (freshLine['price_subtotal'] as num)
              .toDouble();
          final double currentUnit = (freshLine['price_unit'] as num)
              .toDouble();

          if (subtotal != currentUnit) {
            newUnitPrice = subtotal;
          }
        }

        final List<List<dynamic>> taxCommand = [
          [6, 0, preferredTaxIds],
        ];
        final Map<String, dynamic> writeValues = {taxField: taxCommand};

        if (newUnitPrice != null) {
          writeValues['price_unit'] = newUnitPrice;
        }

        await OdooSessionManager.callKwWithCompany({
          'model': 'sale.order.line',
          'method': 'write',
          'args': [
            [lineId],
            writeValues,
          ],
          'kwargs': {
            'context': {'in_rental_app': true},
          },
        });
      }

      await reloadOrderLines();
      if (context.mounted) {
        await Provider.of<RentalOrderProvider>(
          context,
          listen: false,
        ).searchRentalOrders(context, searchQuery: null);
      }
      return true;
    } catch (e) {
      return false;
    } finally {
      // Stop Loading regardless of success or failure
      isUpdatingRental = false;
      notifyListeners();
    }
  }

  bool get hasUnsavedChanges {
    return selectedCustomer != null ||
        selectedProducts.isNotEmpty ||
        editingOrderId != null;
  }

  Future<void> updateRentalDates(BuildContext context) async {
    if (editingOrderId == null) return;

    try {
      await OdooSessionManager.callKwWithCompany({
        'model': 'sale.order',
        'method': 'write',
        'args': [
          [editingOrderId],
          {
        'rental_start_date': DateFormat(
              'yyyy-MM-dd HH:mm:ss',
            ).format(fromDate.toUtc()),
            'rental_return_date': DateFormat(
              'yyyy-MM-dd HH:mm:ss',
            ).format(toDate.toUtc()),
          },
        ],
        'kwargs': {},
      });
    } catch (_) {}
  }

  void closePaymentDropdown() {
    showPaymentDropdown = false;
    notifyListeners();
  }

  Future<List<PaymentTerm>> fetchPaymentTerms(
    BuildContext context,
    String query, {
    int? currentCompanyId,
  }) async {
    try {
      paymentTermLoading = true;

      final companyProvider = Provider.of<CompanyProvider>(
        context,
        listen: false,
      );
      final mainId = companyProvider.selectedCompanyId;

      final result = await OdooSessionManager.callKwWithCompany({
        'model': 'account.payment.term',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'domain': [
            ['name', 'ilike', query],
            [
              'company_id',
              'in',
              [mainId, false],
            ],
          ],
          'fields': ['id', 'name'],
          'limit': 3,
        },
      });

      paymentTermLoading = false;

      if (result != null && result is List) {
        paymentTermsList = result
            .map((item) => PaymentTerm.fromJson(item as Map<String, dynamic>))
            .toList();
        notifyListeners();
        return paymentTermsList;
      }

      paymentTermsList = [];
      notifyListeners();
      return [];
    } catch (e) {
      paymentTermLoading = false;
      paymentTermsList = [];
      notifyListeners();
      return [];
    }
  }

  void setPaymentTerm(PaymentTerm term) {
    selectedPaymentTerm = term;
    paymentTermController.text = term.name;
    closePaymentDropdown();
    notifyListeners();
  }

  void openPaymentDropdown() {
    showPaymentDropdown = true;
    notifyListeners();
  }

  Future<void> fetchTaxes(BuildContext context, {int? currentCompanyId}) async {
    final companyProvider = Provider.of<CompanyProvider>(
      context,
      listen: false,
    );

    final mainId = companyProvider.selectedCompanyId;

    final result = await OdooSessionManager.callKwWithCompany({
      'model': 'account.tax',
      'method': 'search_read',
      'args': [],
      'kwargs': {
        'domain': [
          ['type_tax_use', '=', 'sale'],
          ['company_id', '=', mainId],
        ],
        'fields': ['id', 'display_name', 'amount'],
      },
    });

    taxesList = (result as List).map((tax) => TaxModel.fromJson(tax)).toList();

    notifyListeners();
  }

  void clearRentalQutationStates() {
    showCustomerDropdown = false;
    customerIsSelected = false;
    showPricelistDropdown = false;
    showPaymentDropdown = false;
    isCustomerloading = false;
    paymentTermLoading = false;

    selectedCustomer = null;
    selectedPaymentTerm = null;
    selectedPricelist = null;

    customerList.clear();
    pricelistsList.clear();
    paymentTermsList.clear();
    prductsList.clear();
    selectedProducts.clear();
    taxesList.clear();
    variants.clear();

    customerController.clear();
    pricelistController.clear();
    paymentTermController.clear();

    quotationDate = DateTime.now();
    expirationDate = DateTime.now().add(const Duration(days: 365));
    fromDate = DateTime.now();
    toDate = DateTime.now().add(const Duration(days: 1));

    orderSubtotal = 0.0;
    orderTaxTotal = 0.0;
    orderGrandTotal = 0.0;

    editingOrderId = null;
    editingOrderLineId = null;
    editingOrderName = null;

    isCreatingRental = false;
    editRentalLoading = false;

    productOffset = 0;
    productLoading = false;
    isFetchingMoreProduct = false;
    hasMoreProduct = true;

    variantsLoading = false;

    notifyListeners();
  }

  void restEdittoCreate() {
    editingOrderId = null;
    editingOrderName = null;
    notifyListeners();
  }

  Future<void> actionUpdateRentalPrices(BuildContext context) async {

    if (editingOrderId == null) {
      return;
    }
    if (selectedProducts.isEmpty) {
      return;
    }
    if (!rentalDatesChanged) {
      return;
    }

    updatingRentalPrices = true;
    notifyListeners();

    try {
      // 1. Capture User's current Tax selection from the UI
      final Map<int, List<int>> userTaxPreferences = {
        for (var line in selectedProducts)
          line.id: line.taxes.map((t) => t.id).toList(),
      };


      // 2. Call Odoo to update prices (This resets everything to defaults)
      await OdooSessionManager.callKwWithCompany({
        'model': 'sale.order',
        'method': 'action_update_rental_prices',
        'args': [
          [editingOrderId],
        ],
        'kwargs': {
          'context': {'in_rental_app': true},
        },
      });

      // 3. Prepare to read fresh data
      final client = await OdooSessionManager.getClient();
      final int majorVersion = int.parse(
        client!.sessionId!.serverVersion.split('.').first,
      );
      final String taxField = majorVersion >= 19 ? 'tax_ids' : 'tax_id';
      final List<int> lineIds = selectedProducts.map((e) => e.id).toList();

      // 4. Read fresh lines to get the "Net Price" (price_subtotal) calculated by Odoo
      final dynamic freshLinesResult =
          await OdooSessionManager.callKwWithCompany({
            'model': 'sale.order.line',
            'method': 'read',
            'args': [
              lineIds,
              ['id', 'name', 'price_unit', 'price_subtotal', taxField],
            ],
            'kwargs': {},
          });
      final List<dynamic> freshLines = freshLinesResult as List<dynamic>;

      for (final freshLine in freshLines) {
        final int lineId = freshLine['id'];
        final List<int> preferredTaxIds = userTaxPreferences[lineId] ?? [];

        final List<List<dynamic>> taxCommand = [
          [6, 0, preferredTaxIds],
        ];


        double? newUnitPrice;

        if (preferredTaxIds.isEmpty) {
          final double subtotal = (freshLine['price_subtotal'] as num)
              .toDouble();
          final double currentUnit = (freshLine['price_unit'] as num)
              .toDouble();

          if (subtotal != currentUnit) {
            newUnitPrice = subtotal;
          } else {
          }
        }

        final Map<String, dynamic> writeValues = {taxField: taxCommand};

        if (newUnitPrice != null) {
          writeValues['price_unit'] = newUnitPrice;
        }


        await OdooSessionManager.callKwWithCompany({
          'model': 'sale.order.line',
          'method': 'write',
          'args': [
            [lineId],
            writeValues,
          ],
          'kwargs': {
            'context': {'in_rental_app': true},
          },
        });
      }

      await reloadOrderLines();
      rentalDatesChanged = false;
    } catch (e) {
    } finally {
      updatingRentalPrices = false;
      notifyListeners();
    }
  }
}
