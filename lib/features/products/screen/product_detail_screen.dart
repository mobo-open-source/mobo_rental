import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobo_rental/Core/services/odoo_session_manager.dart';

import 'package:mobo_rental/shared/widgets/full_image_screen.dart';
import 'package:mobo_rental/shared/widgets/snackbars/custom_snackbar.dart';
import 'package:mobo_rental/features/products/provider/currency_provider.dart';
import 'package:mobo_rental/features/products/provider/product_provider.dart';
import 'package:mobo_rental/Core/utils/constants/theme/app_theme.dart';
import 'package:mobo_rental/Core/utils/dashbord_clear_helper.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'product_edit_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> product;
  final bool isTest;
  const ProductDetailsScreen({Key? key, required this.product,  this.isTest =false})
    : super(key: key);

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen>
    with TickerProviderStateMixin {
  bool _isLoading = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  Map<String, dynamic>? _loadedProduct;
  List<String> _taxNames = [];

  // --- UPDATED: Rental Specific Variables ---
  double? _totalRentalUnitsCumulative; // Total units rented over time
  double? _averageRentalValue; // Average price of a rental order
  double? _totalRentalRevenue; // Total revenue generated from rentals
  Map<String, dynamic>? _reservedLines; // Items reserved for future
  String? _lastRentalDate;
  // ------------------------------------------

  int _rentalCount = 0; // Currently in rent (from template)
  List<Map<String, dynamic>> _rentalPricing = [];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();

    _loadProductDetails();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  // ... [Keep _loadRentalPricing existing method] ...
  Future<void> _loadRentalPricing(int productId) async {
    final productResult = await OdooSessionManager.callKwWithCompany({
      'model': 'product.product',
      'method': 'read',
      'args': [
        [productId],
      ],
      'kwargs': {
        'fields': ['product_tmpl_id'],
      },
    });

    if (productResult is! List || productResult.isEmpty) return;

    final templateId = (productResult[0]['product_tmpl_id'] as List?)?.first;
    if (templateId == null) return;

    final templateResult = await OdooSessionManager.callKwWithCompany({
      'model': 'product.template',
      'method': 'web_read',
      'args': [
        [templateId],
      ],
      'kwargs': {
        'specification': {
          'product_pricing_ids': {
            'fields': {
              'recurrence_id': {
                'fields': {'display_name': {}},
              },
              'price': {},
              'currency_id': {'fields': {}},
            },
          },
        },
      },
    });

    if (!mounted) return;

    final rawPricing =
        templateResult is List &&
            templateResult.isNotEmpty &&
            templateResult[0]['product_pricing_ids'] is List
        ? templateResult[0]['product_pricing_ids'] as List
        : [];

    final pricing = rawPricing
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();

    setState(() {
      _rentalPricing = pricing;
    });
  }

  // ... [Keep _loadTemplateRentalCount existing method] ...
  Future<void> _loadTemplateRentalCount(int productId) async {
    try {
      final productResult = await OdooSessionManager.callKwWithCompany({
        'model': 'product.product',
        'method': 'read',
        'args': [
          [productId],
        ],
        'kwargs': {
          'fields': ['product_tmpl_id'],
        },
      });

      if (productResult is! List || productResult.isEmpty) return;

      final templateId = (productResult[0]['product_tmpl_id'] as List?)?.first;

      if (templateId == null) return;

      final templateResult = await OdooSessionManager.callKwWithCompany({
        'model': 'product.template',
        'method': 'read',
        'args': [
          [templateId],
        ],
        'kwargs': {
          'fields': ['qty_in_rent'],
        },
      });

      if (!mounted) return;

      setState(() {
        _rentalCount =
            templateResult is List &&
                templateResult.isNotEmpty &&
                templateResult[0]['qty_in_rent'] != null
            ? (templateResult[0]['qty_in_rent'] as num).toInt()
            : 0;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _rentalCount = 0;
      });
    }
  }

  Future<void> _loadProductDetails() async {
    setState(() => _isLoading = true);

    try {
      final productId = widget.product['id'];

      final result = await OdooSessionManager.callKwWithCompany({
        'model': 'product.product',
        'method': 'read',
        'args': [
          [productId],
        ],
        'kwargs': {
          // Keep fields empty to fetch default readable fields or specify if needed
          'fields': [],
        },
      });

      if (result is List && result.isNotEmpty && mounted) {
        final productData = result[0] as Map<String, dynamic>;
        setState(() {
          _loadedProduct = productData;
        });

        await Future.wait([
          _loadTaxNames(productData),
          _loadRentalAnalytics(productId), // Changed from _loadSalesAnalytics
          _loadTemplateRentalCount(productId),
          _loadRentalPricing(productId),
        ]);
      }
    } catch (e) {
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ... [Keep _loadTaxNames existing method] ...
  Future<void> _loadTaxNames(Map<String, dynamic> productData) async {
    try {
      if (productData['taxes_id'] is List &&
          (productData['taxes_id'] as List).isNotEmpty) {
        final taxesResult = await OdooSessionManager.callKwWithCompany({
          'model': 'account.tax',
          'method': 'search_read',
          'args': [
            [
              ['id', 'in', productData['taxes_id']],
            ],
          ],
          'kwargs': {
            'fields': ['name'],
          },
        });

        if (taxesResult is List && mounted) {
          setState(() {
            _taxNames = taxesResult.map((t) => t['name'].toString()).toList();
          });
        }
      }
    } catch (e) {
    }
  }

  // --- UPDATED: New Rental Analytics Loading Logic ---
  Future<void> _loadRentalAnalytics(dynamic productId) async {
    try {
      // 1. Fetch Confirmed/Done Rental Orders
      final rentalOrderResult = await OdooSessionManager.callKwWithCompany({
        'model': 'sale.order.line',
        'method': 'search_read',
        'args': [
          [
            ['product_id', '=', productId],
            [
              'state',
              'in',
              ['sale', 'done'],
            ],
            ['is_rental', '=', true], // Specific to Rental
          ],
        ],
        'kwargs': {
          'fields': [
            'product_uom_qty',
            'price_subtotal',
            'create_date',
            'pickup_date', // Helpful for rental specifics
          ],
          'limit': 100,
        },
      });

      if (rentalOrderResult is List && mounted) {
        double totalQuantity = 0;
        double totalRevenue = 0;
        String? lastDate;

        // Assuming sorted by default desc, first item is latest
        if (rentalOrderResult.isNotEmpty) {
          lastDate =
              rentalOrderResult[0]['pickup_date'] ??
              rentalOrderResult[0]['create_date'];
        }

        for (var line in rentalOrderResult) {
          totalQuantity += (line['product_uom_qty'] ?? 0.0);
          totalRevenue += (line['price_subtotal'] ?? 0.0);
        }

        setState(() {
          _totalRentalUnitsCumulative = totalQuantity;
          _totalRentalRevenue = totalRevenue;
          _averageRentalValue = rentalOrderResult.isNotEmpty
              ? totalRevenue / rentalOrderResult.length
              : 0;
          _lastRentalDate = lastDate;
        });
      }

      // 2. Fetch Reserved/Draft Rentals
      final reservedResult = await OdooSessionManager.callKwWithCompany({
        'model': 'sale.order.line',
        'method': 'search_read',
        'args': [
          [
            ['product_id', '=', productId],
            [
              'state',
              '=',
              'sale',
            ], // 'sale' usually means confirmed but not yet picked up/done in some flows, or check 'reserved' status if custom
            ['is_rental', '=', true],
            // logic might vary based on workflow, checking Draft/Sent quotes here
            ['qty_delivered', '=', 0],
          ],
        ],
        'kwargs': {
          'fields': ['product_uom_qty'],
          'limit': 50,
        },
      });

      if (reservedResult is List && mounted) {
        double reservedQty = 0;
        for (var line in reservedResult) {
          reservedQty += (line['product_uom_qty'] ?? 0.0);
        }
        setState(() {
          _reservedLines = {
            'total_qty': reservedQty,
            'count': reservedResult.length,
          };
        });
      }
    } catch (e) {
    }
  }

  Map<String, dynamic> get _product => _loadedProduct ?? widget.product;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final provider = Provider.of<ProductProvider>(context);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
        appBar: AppBar(
          title: Text('Product Details'),
          backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
          elevation: 0,
          leading: IconButton(
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedArrowLeft01,
              color: isDark ? Colors.white : Colors.black,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LoadingAnimationWidget.staggeredDotsWave(
                color: theme.primaryColor,
                size: 50,
              ),
              const SizedBox(height: 16),
              Text(
                'Loading product details...',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // --- DATA PREPARATION (Only happens after loading is done) ---
    final product = _product;

    final salePrice = (product['list_price'] as num?)?.toDouble() ?? 0.0;
    final available = (product['qty_available'] as num?)?.toInt() ?? 0;
    final cost = (product['standard_price'] as num?)?.toDouble() ?? 0.0;

    String? productCurrency;
    if (product['currency_id'] is List &&
        (product['currency_id'] as List).length > 1) {
      productCurrency = product['currency_id'][1].toString();
    }

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        title: const Text('Product Details'),
        backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
        elevation: 0,
        leading: IconButton(
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedArrowLeft01,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          _rentalCount == 0
              ? SizedBox.shrink()
              : Badge(
                  offset: const Offset(4, -5),
                  label: Text(_rentalCount.toString()),
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedCalendar03,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
          SizedBox(width: 10),

          provider.canCreateProduct == false
              ? const SizedBox.shrink()
              : IconButton(
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedPencilEdit02,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  tooltip: 'Edit Product',
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductEditScreen(
                          product: product,
                          isEditing: true,
                        ),
                      ),
                    );
                    if (result == true && context.mounted) {
                      Navigator.pop(context, 'updated');
                    }
                  },
                ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                color: (isDark ? Colors.grey[400] : Colors.grey[600]),
                size: 20,
              ),
              color: isDark ? Colors.grey[900] : Colors.white,
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              itemBuilder: (context) => [
                PopupMenuItem<String>(
                  value: 'share_product',
                  child: Row(
                    children: [
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedShare08,
                        color: isDark ? Colors.grey[300] : Colors.grey[800],
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Share Product',
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                if (provider.canCreateProduct)
                  PopupMenuItem<String>(
                    value: 'archive_product',
                    child: Row(
                      children: [
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedDownload05,
                          color: isDark ? Colors.grey[300] : Colors.grey[800],
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Archive Product',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
              onSelected: (value) async {
                switch (value) {
                  case 'share_product':
                    _showShareProductDialog(context);
                    break;
                  case 'archive_product':
                    _showArchiveProductDialog(context);
                    break;
                }
              },
            ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: RefreshIndicator(
          color: isDark ? Colors.blue[200] : AppTheme.primaryColor,
          onRefresh: () async {
            await _loadProductDetails();
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderCard(context),
                const SizedBox(height: 16),
                _buildSectionCard(
                  title: 'Pricing Information',
                  children: [
                    Consumer<CurrencyProvider>(
                      builder: (context, currencyProvider, child) {
                        return _buildInfoRow(
                          'Sale Price',
                          currencyProvider.formatAmount(
                            salePrice,
                            currency: productCurrency,
                          ),
                          highlight: true,
                          valueColor: isDark
                              ? Colors.white70
                              : AppTheme.primaryColor,
                        );
                      },
                    ),
                    _buildInfoRow(
                      'Currency',
                      productCurrency ??
                          Provider.of<CurrencyProvider>(
                            context,
                            listen: false,
                          ).currency,
                    ),
                    if (product['standard_price'] != null)
                      Consumer<CurrencyProvider>(
                        builder: (context, currencyProvider, child) {
                          return _buildInfoRow(
                            'Cost',
                            currencyProvider.formatAmount(
                              cost,
                              currency: productCurrency,
                            ),
                          );
                        },
                      ),
                    _buildInfoRow(
                      'Taxes',
                      _taxNames.isNotEmpty ? _taxNames.join(', ') : 'None',
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                if (_rentalPricing.isNotEmpty)
                  _buildSectionCard(
                    title: 'Rental Pricing',
                    children: _rentalPricing.map((pricing) {
                      final recurrence = pricing['recurrence_id'] is Map
                          ? pricing['recurrence_id']['display_name']
                          : 'N/A';

                      final price =
                          (pricing['price'] as num?)?.toDouble() ?? 0.0;

                      String? lineCurrency;
                      if (pricing['currency_id'] is List &&
                          (pricing['currency_id'] as List).length > 1) {
                        lineCurrency = pricing['currency_id'][1].toString();
                      }

                      return Consumer<CurrencyProvider>(
                        builder: (context, currencyProvider, child) {
                          return _buildInfoRow(
                            recurrence,
                            currencyProvider.formatAmount(
                              price,
                              currency: lineCurrency ?? productCurrency,
                            ),
                            highlight: true,
                            valueColor:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.white70
                                : AppTheme.primaryColor,
                          );
                        },
                      );
                    }).toList(),
                  ),

                const SizedBox(height: 12),

                _buildSectionCard(
                  title: 'Rental Performance',
                  children: [
                    Consumer<CurrencyProvider>(
                      builder: (context, currencyProvider, child) {
                        return _buildInfoRow(
                          'Total Revenue',
                          currencyProvider.formatAmount(
                            _totalRentalRevenue ?? 0.0,
                            currency: productCurrency,
                          ),
                          highlight: true,
                          valueColor: isDark ? Colors.white : Colors.green[700],
                        );
                      },
                    ),
                    Consumer<CurrencyProvider>(
                      builder: (context, currencyProvider, child) {
                        return _buildInfoRow(
                          'Avg. Rental Value',
                          currencyProvider.formatAmount(
                            _averageRentalValue ?? 0.0,
                            currency: productCurrency,
                          ),
                          valueColor: isDark ? Colors.white70 : Colors.black,
                        );
                      },
                    ),
                    _buildInfoRow(
                      'Times Rented',
                      '${_totalRentalUnitsCumulative?.toStringAsFixed(0) ?? '0'} times',
                      valueColor: isDark ? Colors.white70 : Colors.black,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                _buildSectionCard(
                  title: 'Rental Status',
                  children: [
                    _buildInfoRow(
                      'Currently Out',
                      '$_rentalCount units',
                      highlight: _rentalCount > 0,
                      valueColor: _rentalCount > 0
                          ? (isDark ? Colors.orangeAccent : Colors.orange[800])
                          : null,
                    ),
                    if (_lastRentalDate != null)
                      _buildInfoRow(
                        'Last Rented',
                        _lastRentalDate?.split(' ')[0] ?? 'N/A',
                      ),
                    if (_reservedLines != null &&
                        (_reservedLines?['total_qty'] ?? 0) > 0)
                      _buildInfoRow(
                        'Reserved Future',
                        '${_reservedLines?['total_qty']?.toStringAsFixed(0) ?? '0'} units',
                      ),
                  ],
                ),

                const SizedBox(height: 12),
                _buildSectionCard(
                  title: 'Inventory Information',
                  children: [
                    _buildInfoRow(
                      'Available Quantity',
                      available.toString(),
                      highlight: true,
                      valueColor: isDark
                          ? Colors.white70
                          : available > 0
                          ? Colors.green[700]
                          : Colors.red[700],
                    ),
                    _buildInfoRow(
                      'Stock Status',
                      available > 0 ? 'In Stock' : 'Out of Stock',
                    ),
                    if (product['property_stock_inventory'] != null)
                      _buildInfoRow(
                        'Inventory Location',
                        _extractLocationName(
                          product['property_stock_inventory'],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                if (product['weight'] != null || product['volume'] != null)
                  _buildSectionCard(
                    title: 'Shipping Information',
                    children: [
                      if (product['weight'] != null &&
                          product['weight'] != false)
                        _buildInfoRow('Weight', '${product['weight']} kg'),
                      if (product['volume'] != null &&
                          product['volume'] != false)
                        _buildInfoRow('Volume', '${product['volume']} m³'),
                    ],
                  ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final product = _product;
    final titleColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subtle = isDark ? Colors.white60 : Colors.black54;
    final dividerColor = isDark ? Colors.white12 : Colors.black12;

    final salePrice = (product['list_price'] as num?)?.toDouble() ?? 0.0;
    final available = (product['qty_available'] as num?)?.toInt() ?? 0;

    // --- 1. EXTRACT CURRENCY HERE ---
    String? productCurrency;
    if (product['currency_id'] is List &&
        (product['currency_id'] as List).length > 1) {
      productCurrency = product['currency_id'][1].toString();
    }
    // --------------------------------

    final category =
        product['categ_id'] is List && product['categ_id'].length > 1
        ? product['categ_id'][1].toString()
        : '';
    final defaultCodeVal = product['default_code'];
    final defaultCode =
        (defaultCodeVal != null &&
            defaultCodeVal != false &&
            defaultCodeVal.toString().trim().isNotEmpty)
        ? defaultCodeVal.toString()
        : '';
    final barcodeVal = product['barcode'];
    final barcode =
        (barcodeVal != null &&
            barcodeVal != false &&
            barcodeVal.toString().trim().isNotEmpty)
        ? barcodeVal.toString()
        : '';

    Widget buildMetric(String label, String value, {Color? valueColor}) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? (isDark ? Colors.white : Colors.black87),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.black.withOpacity(0.05),
            blurRadius: 16,
            spreadRadius: 2,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Product Image - Tappable
              InkWell(
                onTap: () {
                  final imageBase64 =
                      product['image_128']?.toString() ??
                      product['image_256']?.toString() ??
                      product['image_512']?.toString();

                  if (imageBase64 != null && imageBase64.isNotEmpty) {
                    try {
                      final base64Str = imageBase64.contains(',')
                          ? imageBase64.split(',').last
                          : imageBase64;
                      final bytes = base64Decode(base64Str);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullImageScreen(
                            imageBytes: bytes,
                            title: 'Product Image',
                          ),
                        ),
                      );
                    } catch (e) {
                      // Handle error silently
                    }
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 74,
                  height: 74,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black26
                            : Colors.black.withOpacity(0.05),
                        blurRadius: 16,
                        spreadRadius: 2,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _buildProductImageContent(isDark),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['name']?.toString() ?? 'Unknown Product',
                      style: TextStyle(
                        fontSize:
                            (product['name']?.toString() ?? '').length > 20
                            ? 20
                            : ((product['name']?.toString() ?? '').length > 15
                                  ? 22
                                  : 24),
                        fontWeight: FontWeight.bold,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (category.isNotEmpty)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              HugeIcon(
                                icon: HugeIcons.strokeRoundedFilterMailCircle,
                                size: 14,
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[700],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                category,
                                style: TextStyle(color: subtle, fontSize: 12),
                              ),
                            ],
                          ),
                        if (defaultCode.isNotEmpty)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              HugeIcon(
                                icon: HugeIcons.strokeRoundedQrCode,
                                size: 14,
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[700],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                defaultCode,
                                style: TextStyle(color: subtle, fontSize: 12),
                              ),
                            ],
                          ),
                        if (barcode.isNotEmpty)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              HugeIcon(
                                icon: HugeIcons.strokeRoundedBarCode02,
                                size: 14,
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[700],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                barcode,
                                style: TextStyle(color: subtle, fontSize: 12),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: dividerColor, height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: buildMetric(
                  'Sale Price',
                  // --- 2. APPLY CURRENCY HERE ---
                  Provider.of<CurrencyProvider>(
                    context,
                    listen: false,
                  ).formatAmount(salePrice, currency: productCurrency),
                  // ------------------------------
                  valueColor: isDark ? Colors.white : Colors.black,
                ),
              ),
              Expanded(
                child: buildMetric(
                  'Available',
                  available.toString(),
                  valueColor: isDark ? Colors.white : Colors.black,
                ),
              ),
              Expanded(
                child: buildMetric(
                  'Status',
                  available > 0 ? 'In Stock' : 'Out of Stock',
                  valueColor: available > 0
                      ? (isDark ? Colors.green[300] : Colors.green[700])
                      : (isDark ? Colors.red[300] : Colors.red[700]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductImageContent(bool isDark) {
    final product = _product;
    final imageBase64 =
        product['image_128']?.toString() ??
        product['image_256']?.toString() ??
        product['image_512']?.toString();

    Uint8List? safeBase64Image(String? raw) {
      if (raw == null) return null;

      final value = raw.trim().toLowerCase();
      if (value.isEmpty || value == 'false' || value == 'null') {
        return null;
      }

      try {
        String data = raw.contains(',') ? raw.split(',').last : raw;
        data = data.replaceAll(RegExp(r'\s+'), '');

        final remainder = data.length % 4;
        if (remainder != 0) {
          data = data.padRight(data.length + (4 - remainder), '=');
        }

        final bytes = base64Decode(data);

        if (bytes.length < 20) {
          return null;
        }

        return bytes;
      } catch (_) {
        return null;
      }
    }

    final Uint8List? imageBytes = safeBase64Image(imageBase64);

    Widget fallback() {
      final name = product['name']?.toString() ?? '?';
      final letter = name.isNotEmpty ? name[0].toUpperCase() : '?';

      return Center(
        child: Text(
          letter,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white70 : Colors.black45,
          ),
        ),
      );
    }

    return Container(
      color: isDark ? Colors.white10 : Colors.grey[100],
      child: imageBytes == null
          ? fallback()
          : Image.memory(
              imageBytes,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return fallback();
              },
            ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    // ... [Paste original _buildSectionCard code here] ...
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.black.withOpacity(0.05),

            blurRadius: 16,
            spreadRadius: 2,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    bool highlight = false,
    Color? valueColor,
  }) {
    // ... [Paste original _buildInfoRow code here] ...
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: valueColor ?? (isDark ? Colors.white : Colors.black),
                fontSize: 14,
                fontWeight: highlight ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _extractLocationName(dynamic location) {
    if (location == null || location == false) return 'N/A';
    if (location is List && location.length >= 2) {
      return location[1]?.toString() ?? 'N/A';
    }
    return location.toString();
  }

  // Note: All share/archive dialog methods (_showShareProductDialog, _archiveProduct, etc.)
  // should remain exactly as they were in the original code. I haven't repeated them to save space
  // but they are required for the file to compile.

  // ... [Keep existing Dialog methods: _showShareProductDialog, _showArchiveProductDialog, _archiveProduct, etc.] ...

  void _showShareProductDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final product = _product;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: isDark ? 0 : 8,
        title: Text(
          'Share Product',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: isDark
                ? Colors.white
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Choose how you want to share "${product['name']}"',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildShareOption(
                    context,
                    icon: HugeIcons.strokeRoundedMail01,
                    label: 'Email',
                    color: Colors.blue,
                    onTap: () => _shareViaEmail(product),
                  ),
                  _buildShareOption(
                    context,
                    icon: HugeIcons.strokeRoundedWhatsapp,
                    label: 'WhatsApp',
                    color: Colors.green,
                    onTap: () => _shareViaWhatsApp(product),
                  ),
                  _buildShareOption(
                    context,
                    icon: HugeIcons.strokeRoundedShare08,
                    label: 'More',
                    color: Colors.orange,
                    onTap: () => _shareViaSystem(product),
                  ),
                ],
              ),
            ],
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    elevation: isDark ? 0 : 3,
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShareOption(
    BuildContext context, {
    required dynamic icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        onTap();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            HugeIcon(icon: icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _shareViaEmail(Map<String, dynamic> product) async {
    final productName =
        product['name'] is String && product['name'].toString().isNotEmpty
        ? product['name']
        : 'Product';

    final price = (product['list_price'] as num?)?.toDouble() ?? 0.0;

    final currencyProvider = Provider.of<CurrencyProvider>(
      context,
      listen: false,
    );

    final subject = Uri.encodeComponent('Product: $productName');
    final body = Uri.encodeComponent(
      'Check out this product:\n\n'
      'Name: $productName\n'
      'Price: ${currencyProvider.formatAmount(price)}\n',
    );

    final uri = Uri.parse('mailto:?subject=$subject&body=$body');

    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (!mounted) return;

      CustomSnackbar.showError(context, 'No email app found on this device');
    }
  }

  void _shareViaWhatsApp(Map<String, dynamic> product) async {
    final productName =
        product['name'] is String && product['name'].toString().isNotEmpty
        ? product['name']
        : 'Product';

    final price = (product['list_price'] as num?)?.toDouble() ?? 0.0;

    final currencyProvider = Provider.of<CurrencyProvider>(
      context,
      listen: false,
    );

    final message = Uri.encodeComponent(
      'Check out this product:\n\n'
      'Name: $productName\n'
      'Price: ${currencyProvider.formatAmount(price)}',
    );

    final uri = Uri.parse('whatsapp://send?text=$message');

    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (!mounted) return;
      CustomSnackbar.showError(context, 'WhatsApp is not installed');
    }
  }

  void _shareViaSystem(Map<String, dynamic> product) {
    final productName = product['name']?.toString() ?? 'Product';
    final price = (product['list_price'] as num?)?.toDouble() ?? 0.0;
    final currencyProvider = Provider.of<CurrencyProvider>(
      context,
      listen: false,
    );

    final message =
        'Check out this product:\n\n'
        'Name: $productName\n'
        'Price: ${currencyProvider.formatAmount(price)}';

    Share.share(message, subject: 'Product: $productName');
  }

  void _showArchiveProductDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Archive Product',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        content: SizedBox(
          width: 300,
          child: Text(
            'Are you sure you want to archive this product? This action will hide the product from active listings.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isDark ? Colors.grey[300] : Colors.grey[700],
            ),
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: isDark
                        ? Colors.grey[400]
                        : Colors.grey[600],
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _archiveProduct();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: isDark ? 0 : 3,
                  ),
                  child: const Text(
                    'Archive',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _archiveProduct() async {
    bool isLoaderShowing = false;
    // Use a local reference to the navigator to avoid context issues after pop
    final navigator = Navigator.of(context);

    try {
      final productId = widget.product['id'];

      // Show loading dialog
      if (mounted) {
        _showLoadingDialog(
          context,
          'Archiving Product',
          'Please wait while we archive this product...',
        );
        isLoaderShowing = true;
      }

      // 1. Get template ID
      final productResult = await OdooSessionManager.callKwWithCompany({
        'model': 'product.product',
        'method': 'read',
        'args': [
          [productId],
        ],
        'kwargs': {
          'fields': ['product_tmpl_id'],
        },
      });

      if (productResult is! List || productResult.isEmpty) {
        if (mounted && isLoaderShowing) {
          navigator.pop();
          isLoaderShowing = false;
        }
        throw Exception('Product not found');
      }

      final templateId = (productResult[0]['product_tmpl_id'] as List?)?.first;

      // 2. Archive product
      final result1 = await OdooSessionManager.callKwWithCompany({
        'model': 'product.product',
        'method': 'write',
        'args': [
          [productId],
          {'active': false},
        ],
        'kwargs': {},
      });

      // 3. Archive template if exists
      var result2 = true;
      if (templateId != null) {
        result2 = await OdooSessionManager.callKwWithCompany({
          'model': 'product.template',
          'method': 'write',
          'args': [
            [templateId],
            {'active': false},
          ],
          'kwargs': {},
        });

      }

      // Hide loading
      if (mounted && isLoaderShowing) {
        navigator.pop();
        isLoaderShowing = false;
      }

      if (result1 == true && result2 == true) {
        if (mounted) {
          context.refreshDashboard();
          Navigator.of(context).pop(true); // Return true to indicate success
        }
      } else {
        throw Exception(
          'Failed to archive product or template. Odoo returned: product:$result1, template:$result2',
        );
      }
    } catch (e) {
      if (mounted) {
        if (isLoaderShowing) {
          navigator.pop();
          isLoaderShowing = false;
        }
        CustomSnackbar.showError(context, 'Failed to archive product: $e');
      }
    }
  }

  void _showLoadingDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return WillPopScope(
          onWillPop: () async => false,
          child: Dialog(
            backgroundColor: isDark ? Colors.grey[900] : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(16),
                    child: LoadingAnimationWidget.fourRotatingDots(
                      color: isDark
                          ? Colors.white
                          : Theme.of(context).primaryColor,
                      size: 50,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
