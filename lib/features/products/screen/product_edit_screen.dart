import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:mobo_rental/Core/services/odoo_session_manager.dart';
import 'package:mobo_rental/shared/widgets/snackbars/custom_snackbar.dart';
import 'package:mobo_rental/features/dashboard/providers/dashboard_provider.dart';
import 'package:mobo_rental/features/products/widgets/custom_drop_down.dart' as simple;
import 'package:mobo_rental/Core/services/review_service.dart';
import 'package:mobo_rental/features/products/widgets/custom_text_feild.dart' as simple;
import 'package:mobo_rental/Core/utils/constants/theme/app_theme.dart';
import 'package:mobo_rental/Core/utils/dashbord_clear_helper.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:hugeicons/hugeicons.dart';

class ProductEditScreen extends StatefulWidget {
  final Map<String, dynamic>? product;
  final bool isEditing;
  final bool isTest;

  const ProductEditScreen({
    Key? key,
    this.product,
    this.isEditing = false,
    this.isTest = false,
  }) : super(key: key);

  @override
  State<ProductEditScreen> createState() => _ProductEditScreenState();
}

// Updated class to store specific recurrence ID
class _RentalPricingRule {
  TextEditingController priceController;
  String? recurrenceId; // Changed from String unit to String? recurrenceId
  int? id; // Pricing Rule ID (if editing)

  _RentalPricingRule({required double price, this.recurrenceId, this.id})
    : priceController = TextEditingController(text: price.toString());

  void dispose() {
    priceController.dispose();
  }
}

class _ProductEditScreenState extends State<ProductEditScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _defaultCodeController;
  late TextEditingController _barcodeController;
  late TextEditingController _listPriceController;
  late TextEditingController _standardPriceController;
  late TextEditingController _weightController;
  late TextEditingController _volumeController;
  late TextEditingController _descriptionController;

  // New: List to hold multiple rental rules
  List<_RentalPricingRule> _rentalRules = [];

  List<Map<String, String>> _categoryOptions = [];
  List<Map<String, String>> _taxOptions = [];
  List<Map<String, String>> _uomOptions = [];
  List<Map<String, String>> _currencyOptions = [];

  // New: Dynamic Recurrence Options
  List<Map<String, String>> _rentalRecurrenceOptions = [];
  bool _dropdownsLoading = true;
  bool _recurrencesLoading = true; // New loading state

  String? _selectedCategory;
  String? _selectedTax;
  String? _selectedUOM;
  String? _selectedCurrency;
  bool _isActive = true;
  bool _canBeSold = true;
  bool _canBePurchased = true;
  bool _canBeRented = true;

  bool _isLoading = false;
  bool _isEditMode = false;
  String? _imageBase64;
  File? _pickedImageFile;
  String? _pickedImageBase64;
  final ImagePickerPlatform _picker = ImagePickerPlatform.instance;

  bool get _isNameFilled => _nameController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    if (widget.isTest) {
    } else {
      _isEditMode = widget.product != null;
      final p = widget.product;
      String clean(String? v) => (v == null || v == 'false') ? '' : v;

      _nameController = TextEditingController(
        text: clean(p?['name']?.toString()),
      );
      _defaultCodeController = TextEditingController(
        text: clean(p?['default_code']?.toString()),
      );
      _barcodeController = TextEditingController(
        text: clean(p?['barcode']?.toString()),
      );
      _descriptionController = TextEditingController(
        text: clean(p?['description_sale']?.toString()),
      );
      _listPriceController = TextEditingController(
        text: p?['list_price']?.toString() ?? '',
      );
      _standardPriceController = TextEditingController(
        text: p?['standard_price']?.toString() ?? '',
      );
      _weightController = TextEditingController(
        text: p?['weight']?.toString() ?? '',
      );
      _volumeController = TextEditingController(
        text: p?['volume']?.toString() ?? '',
      );

      _isActive = p?['active'] ?? true;
      _canBeSold = p?['sale_ok'] ?? true;
      _canBePurchased = p?['purchase_ok'] ?? true;
      _canBeRented = p?['rent_ok'] ?? true;

      // Load Recurrences first, then pricing if editing
      _fetchRentalRecurrences().then((_) {
        if (widget.product != null) {
          _imageBase64 =
              p?['image_128']?.toString() ??
              p?['image_256']?.toString() ??
              p?['image_512']?.toString() ??
              p?['image_1024']?.toString() ??
              p?['image']?.toString();

          _fetchTemplateAndPricing(p!['id']);
        } else {
          if (_canBeRented) {
            _addRentalRule();
          }
        }
      });

      _fetchDropdowns();
      _nameController.addListener(() {
        setState(() {});
      });
    }
  }

  Future<void> _fetchTemplateAndPricing(int productVariantId) async {
    try {
      final result = await OdooSessionManager.callKwWithCompany({
        'model': 'product.product',
        'method': 'read',
        'args': [
          [productVariantId],
          ['product_tmpl_id'],
        ],
      });

      if (result == null || result.isEmpty) return;

      final templateId = result[0]['product_tmpl_id'][0];

      await _fetchRentalPricingByTemplate(templateId);
    } catch (e) {
    }
  }

  Future<void> _fetchRentalPricingByTemplate(int templateId) async {
    try {
      _rentalRules.clear();

      final pricing = await OdooSessionManager.callKwWithCompany({
        'model': 'product.pricing',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'domain': [
            ['product_template_id', '=', templateId],
          ],
          'fields': ['price', 'recurrence_id', 'id'],
        },
      });

      if (pricing != null && pricing is List) {
        for (final rule in pricing) {
          final recurrence = rule['recurrence_id'];
          String? recurrenceId;

          if (recurrence is List && recurrence.isNotEmpty) {
            recurrenceId = recurrence[0].toString();
          }

          if (recurrenceId != null) {
            _rentalRules.add(
              _RentalPricingRule(
                price: (rule['price'] as num).toDouble(),
                recurrenceId: recurrenceId,
                id: rule['id'],
              ),
            );
          }
        }
      }

      if (_rentalRules.isEmpty && _canBeRented) {
        _addRentalRule();
      }

      if (mounted) setState(() {});
    } catch (e) {
    }
  }

  // Fetch dynamic rental durations from sale.temporal.recurrence
  Future<void> _fetchRentalRecurrences() async {
    setState(() {
      _recurrencesLoading = true;
    });

    try {
      final recurrences = await OdooSessionManager.callKwWithCompany({
        'model': 'sale.temporal.recurrence',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'fields': ['id', 'display_name', 'duration', 'unit'],
          'order': 'duration asc, unit asc', // Sort nicely
        },
      });

      if (recurrences != null && recurrences is List) {
        _rentalRecurrenceOptions = recurrences.map<Map<String, String>>((r) {
          return {
            'value': r['id'].toString(),
            'label': r['display_name'].toString(),
          };
        }).toList();
      }
    } catch (e) {
    } finally {
      if (mounted) {
        setState(() {
          _recurrencesLoading = false;
        });
      }
    }
  }

  void _addRentalRule() {
    setState(() {
      // Default to the first available option if exists
      String? defaultRecurrenceId;
      if (_rentalRecurrenceOptions.isNotEmpty) {
        defaultRecurrenceId = _rentalRecurrenceOptions.first['value'];
      }
      _rentalRules.add(
        _RentalPricingRule(price: 0.0, recurrenceId: defaultRecurrenceId),
      );
    });
  }

  void _removeRentalRule(int index) {
    setState(() {
      _rentalRules[index].dispose();
      _rentalRules.removeAt(index);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _defaultCodeController.dispose();
    _barcodeController.dispose();
    _listPriceController.dispose();
    _standardPriceController.dispose();
    _weightController.dispose();
    _volumeController.dispose();
    _descriptionController.dispose();
    for (var rule in _rentalRules) {
      rule.dispose();
    }
    super.dispose();
  }

  Future<void> _fetchDropdowns() async {
    setState(() {
      _dropdownsLoading = true;
    });

    try {
      final categories = await OdooSessionManager.callKwWithCompany({
        'model': 'product.category',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'fields': ['name'],
          'order': 'name asc',
        },
      });
      _categoryOptions = categories
          .map<Map<String, String>>(
            (c) => {'value': c['id'].toString(), 'label': c['name'].toString()},
          )
          .toList();

      final taxes = await OdooSessionManager.callKwWithCompany({
        'model': 'account.tax',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'fields': ['name'],
          'order': 'name asc',
        },
      });
      _taxOptions = taxes
          .map<Map<String, String>>(
            (t) => {'value': t['id'].toString(), 'label': t['name'].toString()},
          )
          .toList();

      final uoms = await OdooSessionManager.callKwWithCompany({
        'model': 'uom.uom',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'fields': ['name'],
          'order': 'name asc',
        },
      });
      _uomOptions = uoms
          .map<Map<String, String>>(
            (u) => {'value': u['id'].toString(), 'label': u['name'].toString()},
          )
          .toList();

      final currencies = await OdooSessionManager.callKwWithCompany({
        'model': 'res.currency',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'fields': ['name'],
          'order': 'name asc',
        },
      });
      _currencyOptions = currencies
          .map<Map<String, String>>(
            (c) => {'value': c['id'].toString(), 'label': c['name'].toString()},
          )
          .toList();

      final p = widget.product;
      if (p != null) {
        if (p['categ_id'] != null) {
          if (p['categ_id'] is List && p['categ_id'].length > 0) {
            _selectedCategory = p['categ_id'][0].toString();
          } else if (p['categ_id'] is int) {
            _selectedCategory = p['categ_id'].toString();
          }
        }

        if (p['taxes_id'] != null &&
            p['taxes_id'] is List &&
            (p['taxes_id'] as List).isNotEmpty) {
          _selectedTax = p['taxes_id'][0].toString();
        }

        if (p['uom_id'] != null) {
          if (p['uom_id'] is List && p['uom_id'].length > 0) {
            _selectedUOM = p['uom_id'][0].toString();
          } else if (p['uom_id'] is int) {
            _selectedUOM = p['uom_id'].toString();
          }
        }

        if (p['currency_id'] != null) {
          if (p['currency_id'] is List && p['currency_id'].length > 0) {
            _selectedCurrency = p['currency_id'][0].toString();
          } else if (p['currency_id'] is int) {
            _selectedCurrency = p['currency_id'].toString();
          }
        }
      }

      setState(() {
        _dropdownsLoading = false;
      });
    } catch (e) {
      setState(() {
        _dropdownsLoading = false;
      });
      if (mounted) {
        CustomSnackbar.showError(
          context,
          'Failed to load options: ${e.toString()}',
        );
      }
    }
  }

  Future<void> _pickImageFromSource(ImageSource source) async {
    final picked = await _picker.getImageFromSource(
      source: source,
      options: const ImagePickerOptions(imageQuality: 80, maxWidth: 600),
    );
    if (picked != null) {
      setState(() {
        _pickedImageFile = File(picked.path);
      });
      final bytes = await picked.readAsBytes();
      setState(() {
        _pickedImageBase64 = base64Encode(bytes);
      });
    }
  }

  void _showImageSourceActionSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[700] : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.pop(context);
                _pickImageFromSource(ImageSource.camera);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.camera_alt,
                      size: 20,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    const SizedBox(width: 16),
                    const Text('Take Photo', style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
            Divider(
              height: 1,
              thickness: 1,
              color: isDark ? Colors.grey[800] : Colors.grey[200],
            ),
            InkWell(
              onTap: () {
                Navigator.pop(context);
                _pickImageFromSource(ImageSource.gallery);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.photo_library,
                      size: 20,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Choose from Gallery',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = AppTheme.primaryColor;

    if (_dropdownsLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            _isEditMode ? 'Edit Product' : 'Create Product',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          backgroundColor: isDark ? Colors.grey[900] : Colors.white,
          foregroundColor: isDark ? Colors.white : primaryColor,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedArrowLeft01,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ),
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        body: _buildShimmerLoading(isDark),
      );
    }

    Widget photoWidget;
    if (_pickedImageFile != null) {
      photoWidget = CircleAvatar(
        radius: 48,
        backgroundColor: isDark
            ? Colors.grey.shade200
            : primaryColor.withOpacity(.1),
        backgroundImage: FileImage(_pickedImageFile!),
      );
    } else if (_imageBase64 != null && _imageBase64!.isNotEmpty) {
      try {
        final base64String = _imageBase64!.contains(',')
            ? _imageBase64!.split(',').last
            : _imageBase64!;
        final bytes = base64Decode(base64String);
        photoWidget = CircleAvatar(
          radius: 48,
          backgroundColor: isDark
              ? Colors.grey.shade200
              : primaryColor.withOpacity(.1),
          backgroundImage: MemoryImage(bytes),
        );
      } catch (e) {
        photoWidget = CircleAvatar(
          radius: 48,
          backgroundColor: isDark
              ? Colors.grey.shade200
              : primaryColor.withOpacity(.1),
          child: Icon(
            Icons.image,
            size: 48,
            color: isDark ? Colors.grey.shade800 : primaryColor,
          ),
        );
      }
    } else {
      photoWidget = CircleAvatar(
        radius: 48,
        backgroundColor: isDark
            ? Colors.grey.shade200
            : primaryColor.withOpacity(.1),
        child: Icon(
          Icons.image,
          size: 48,
          color: isDark ? Colors.grey.shade800 : primaryColor,
        ),
      );
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _isEditMode ? 'Edit Product' : 'Create Product',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          backgroundColor: isDark ? Colors.grey[900] : Colors.white,
          foregroundColor: isDark ? Colors.white : primaryColor,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedArrowLeft01,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ),
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    photoWidget,
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: _isLoading ? null : _showImageSourceActionSheet,
                        borderRadius: BorderRadius.circular(24),
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: isDark ? Colors.grey : primaryColor,
                          child: Icon(
                            Icons.add_a_photo,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              simple.CustomTextField(
                controller: _nameController,
                labelText: 'Product Name *',
                hintText: 'Enter product name',
                isDark: isDark,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Product name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              simple.CustomTextField(
                controller: _defaultCodeController,
                labelText: 'SKU/Default Code',
                hintText: 'Enter SKU',
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              simple.CustomTextField(
                controller: _barcodeController,
                labelText: 'Barcode',
                hintText: 'Enter barcode',
                isDark: isDark,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.qr_code_scanner),
                  onPressed: () {},
                  tooltip: 'Scan Barcode',
                ),
              ),
              const SizedBox(height: 12),
              simple.CustomDropdownField(
                value:
                    _categoryOptions.any((m) => m['value'] == _selectedCategory)
                    ? _selectedCategory
                    : null,
                labelText: 'Category',
                hintText: 'Select a product category',
                isDark: isDark,
                items: _categoryOptions
                    .map(
                      (m) => DropdownMenuItem(
                        value: m['value'],
                        child: Text(m['label']!),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _selectedCategory = v),
              ),
              const SizedBox(height: 12),
              simple.CustomTextField(
                controller: _listPriceController,
                labelText: 'List Price',
                hintText: 'Enter selling price',
                isDark: isDark,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v != null && v.trim().isNotEmpty) {
                    if (double.tryParse(v.trim()) == null) {
                      return 'Enter a valid number';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              simple.CustomTextField(
                controller: _standardPriceController,
                labelText: 'Cost Price',
                hintText: 'Enter cost price',
                isDark: isDark,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v != null && v.trim().isNotEmpty) {
                    if (double.tryParse(v.trim()) == null) {
                      return 'Enter a valid number';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              simple.CustomDropdownField(
                value: _taxOptions.any((m) => m['value'] == _selectedTax)
                    ? _selectedTax
                    : null,
                labelText: 'Tax',
                hintText: 'Select applicable tax',
                isDark: isDark,
                items: _taxOptions
                    .map(
                      (m) => DropdownMenuItem(
                        value: m['value'],
                        child: Text(m['label']!),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _selectedTax = v),
              ),
              const SizedBox(height: 12),
              simple.CustomDropdownField(
                value: _uomOptions.any((m) => m['value'] == _selectedUOM)
                    ? _selectedUOM
                    : null,
                labelText: 'Unit of Measure',
                hintText: 'Select unit',
                isDark: isDark,
                items: _uomOptions
                    .map(
                      (m) => DropdownMenuItem(
                        value: m['value'],
                        child: Text(m['label']!),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _selectedUOM = v),
              ),
              const SizedBox(height: 12),
              simple.CustomDropdownField(
                value:
                    _currencyOptions.any((m) => m['value'] == _selectedCurrency)
                    ? _selectedCurrency
                    : null,
                labelText: 'Currency',
                hintText: 'Select currency',
                isDark: isDark,
                items: _currencyOptions
                    .map(
                      (m) => DropdownMenuItem(
                        value: m['value'],
                        child: Text(m['label']!),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _selectedCurrency = v),
              ),
              const SizedBox(height: 12),
              simple.CustomTextField(
                controller: _weightController,
                labelText: 'Weight',
                hintText: 'Enter weight in kg',
                isDark: isDark,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              simple.CustomTextField(
                controller: _volumeController,
                labelText: 'Volume',
                hintText: 'Enter volume in cubic meters',
                isDark: isDark,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              simple.CustomTextField(
                controller: _descriptionController,
                labelText: 'Description',
                hintText: 'Enter a product description',
                isDark: isDark,
                maxLines: 3,
              ),
              const SizedBox(height: 12),

              // --- TOGGLES SECTION ---
              Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  children: [
                    _buildToggleRow(
                      "Active",
                      _isActive,
                      (v) => setState(() => _isActive = v ?? true),
                      isDark,
                      primaryColor,
                    ),
                    _buildToggleRow(
                      "Can be Sold",
                      _canBeSold,
                      (v) => setState(() => _canBeSold = v ?? true),
                      isDark,
                      primaryColor,
                    ),
                    _buildToggleRow(
                      "Can be Purchased",
                      _canBePurchased,
                      (v) => setState(() => _canBePurchased = v ?? true),
                      isDark,
                      primaryColor,
                    ),
                    _buildToggleRow(
                      "Can be Rented",
                      _canBeRented,
                      (v) => setState(() {
                        _canBeRented = v ?? false;
                        // Ensure at least one rule exists if rented is checked
                        if (_canBeRented && _rentalRules.isEmpty) {
                          _addRentalRule();
                        }
                      }),
                      isDark,
                      primaryColor,
                    ),
                  ],
                ),
              ),

              // --- RENTAL PRICING SECTION (Multi-Rule) ---
              if (_canBeRented) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800] : Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              HugeIcon(
                                icon: HugeIcons.strokeRoundedClock01,
                                color: isDark ? Colors.white70 : Colors.black54,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Rental Pricing Rules",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          InkWell(
                            onTap: _addRentalRule,
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Text(
                                "+ Add Rule",
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      if (_recurrencesLoading)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        )
                      else if (_rentalRules.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            "No pricing rules. Add one to set rental prices.",
                            style: TextStyle(
                              color: Colors.orange,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),

                      ..._rentalRules.asMap().entries.map((entry) {
                        int index = entry.key;
                        _RentalPricingRule rule = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: simple.CustomTextField(
                                  controller: rule.priceController,
                                  labelText: 'Price',
                                  hintText: '0.00',
                                  isDark: isDark,
                                  keyboardType: TextInputType.number,
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) {
                                      return 'Req';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 3,
                                child: simple.CustomDropdownField(
                                  value: rule.recurrenceId,
                                  labelText: 'Duration',
                                  hintText: 'Select Duration',
                                  isDark: isDark,
                                  items: _rentalRecurrenceOptions
                                      .map(
                                        (u) => DropdownMenuItem(
                                          value: u['value'],
                                          child: Text(u['label']!),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (v) =>
                                      setState(() => rule.recurrenceId = v),
                                ),
                              ),
                              const SizedBox(width: 4),
                              IconButton(
                                icon: HugeIcon(
                                  icon: HugeIcons.strokeRoundedDelete02,
                                  color: Colors.red[400],
                                ),
                                onPressed: () => _removeRentalRule(index),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_isLoading || !_isNameFilled)
                      ? null
                      : _saveProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: isDark
                        ? Colors.grey[700]!
                        : Colors.grey[400]!,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          _isEditMode ? 'Save Changes' : 'Create Product',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleRow(
    String title,
    bool value,
    ValueChanged<bool?> onChanged,
    bool isDark,
    Color primaryColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            height: 24,
            width: 24,
            child: Checkbox(
              checkColor: Colors.white,
              activeColor: isDark ? Colors.grey : primaryColor,
              value: value,
              onChanged: onChanged,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading(bool isDark) {
    final shimmerBase = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final shimmerHighlight = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: shimmerBase,
      highlightColor: shimmerHighlight,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: List.generate(
          10,
          (index) => Container(
            height: 44,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[850] : Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final Map<String, dynamic> productData = {
        'name': _nameController.text,
        'default_code': _defaultCodeController.text.isEmpty
            ? false
            : _defaultCodeController.text,
        'barcode': _barcodeController.text.isEmpty
            ? false
            : _barcodeController.text,
        'list_price': double.tryParse(_listPriceController.text) ?? 0.0,
        'standard_price': double.tryParse(_standardPriceController.text) ?? 0.0,
        'weight': double.tryParse(_weightController.text) ?? 0.0,
        'volume': double.tryParse(_volumeController.text) ?? 0.0,
        'description_sale': _descriptionController.text.isEmpty
            ? false
            : _descriptionController.text,
        'active': _isActive,
        'sale_ok': _canBeSold,
        'purchase_ok': _canBePurchased,
        'rent_ok': _canBeRented,
      };
      if (_pickedImageBase64 != null) {
        productData['image_1920'] = _pickedImageBase64;
      }

      if (_selectedCategory != null) {
        final categoryId = int.tryParse(_selectedCategory!);
        if (categoryId != null) {
          productData['categ_id'] = categoryId;
        }
      }
      if (_selectedTax != null) {
        final taxId = int.tryParse(_selectedTax!);
        if (taxId != null) {
          productData['taxes_id'] = [
            [
              6,
              0,
              [taxId],
            ],
          ];
        }
      }
      if (_selectedUOM != null) {
        final uomId = int.tryParse(_selectedUOM!);
        if (uomId != null) {
          productData['uom_id'] = uomId;
        }
      }
      if (_selectedCurrency != null) {
        final currencyId = int.tryParse(_selectedCurrency!);
        if (currencyId != null) {
          productData['currency_id'] = currencyId;
        }
      }

      if (_canBeRented) {
        List<List<dynamic>> pricingCommands = [];

        for (var rule in _rentalRules) {
          final price = double.tryParse(rule.priceController.text) ?? 0.0;

          if (rule.recurrenceId == null) continue;

          final recurrenceId = int.tryParse(rule.recurrenceId!);

          if (recurrenceId != null) {
            if (rule.id != null) {
              // Write existing rule
              pricingCommands.add([
                1,
                rule.id,
                {
                  'price': price,
                  'recurrence_id': recurrenceId, // Ensure recurrence is updated
                },
              ]);
            } else {
              pricingCommands.add([
                0,
                0,
                {
                  'recurrence_id': recurrenceId,
                  'price': price,
                  'currency_id': productData['currency_id'] ?? 1,
                },
              ]);
            }
          }
        }

        if (pricingCommands.isNotEmpty) {
          productData['product_pricing_ids'] = pricingCommands;
        }
      }

      if (widget.product != null) {
        final result = await OdooSessionManager.callKwWithCompany({
          'model': 'product.product',
          'method': 'write',
          'args': [
            [widget.product!['id']],
            productData,
          ],
          'kwargs': {},
        });


        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          context.refreshDashboard();
          Navigator.pop(context, true);

          Future.delayed(const Duration(milliseconds: 100), () {
            if (context.mounted) {
              CustomSnackbar.showSuccess(
                context,
                'Product updated successfully',
              );
            }
          });
        }
      } else {
        final newId = await OdooSessionManager.callKwWithCompany({
          'model': 'product.product',
          'method': 'create',
          'args': [productData],
          'kwargs': {},
        });

        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          context.refreshDashboard();
          Navigator.pop(context, true);

          Future.delayed(const Duration(milliseconds: 100), () {
            if (context.mounted) {
              CustomSnackbar.showSuccess(
                context,
                'Product created successfully',
              );
            }
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        String errorMsg = e.toString();
        if (errorMsg.contains("multiple pricing") ||
            errorMsg.contains("Duplicate")) {
          errorMsg =
              "Duplicate rule detected. You cannot have two pricing rules for the same duration.";
        }

        CustomSnackbar.showError(context, 'Failed to save product: $errorMsg');
      }
    }
  }
}
