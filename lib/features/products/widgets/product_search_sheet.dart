import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobo_rental/features/products/model/product.dart';
import 'package:mobo_rental/features/products/provider/currency_provider.dart';
import 'package:mobo_rental/Core/utils/constants/theme/app_theme.dart';
import 'package:provider/provider.dart';

import 'quantity_dialog.dart';

/// A bottom sheet widget for searching and selecting products.
class ProductSearchSheet extends StatefulWidget {
  final List<Product> products;
  final Function(Product product, double quantity, double unitPrice)
  onProductSelected;

  const ProductSearchSheet({
    Key? key,
    required this.products,
    required this.onProductSelected,
  }) : super(key: key);

  @override
  State<ProductSearchSheet> createState() => _ProductSearchSheetState();
}

class _ProductSearchSheetState extends State<ProductSearchSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<Product> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    _filteredProducts = widget.products;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterProducts(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredProducts = widget.products;
      } else {
        _filteredProducts = widget.products.where((product) {
          final nameMatch = product.name.toLowerCase().contains(
            query.toLowerCase(),
          );
          final barcodeMatch =
              product.barcode?.toLowerCase().contains(query.toLowerCase()) ??
              false;
          return nameMatch || barcodeMatch;
        }).toList();
      }
    });
  }

  void _onProductTap(Product product) {
    showDialog(
      context: context,
      builder: (context) => QuantityDialog(
        product: product,
        onConfirm: (quantity, unitPrice) {
          widget.onProductSelected(product, quantity, unitPrice);
          Navigator.pop(context); // Close the sheet
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyProvider = Provider.of<CurrencyProvider>(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF121212) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Select Product',
                      style: GoogleFonts.manrope(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    IconButton(
                      icon: HugeIcon(
                        icon: HugeIcons.strokeRoundedCancel01,
                        size: 24,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Search field
                TextField(
                  controller: _searchController,
                  style: GoogleFonts.manrope(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 15,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search by name or barcode...',
                    hintStyle: GoogleFonts.manrope(
                      color: isDark ? Colors.grey[500] : Colors.grey[400],
                      fontSize: 15,
                    ),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedSearch01,
                        size: 20,
                        color: isDark ? Colors.grey[400] : Colors.grey[500],
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: AppTheme.primaryColor,
                        width: 1.5,
                      ),
                    ),
                    filled: true,
                    fillColor: isDark
                        ? const Color(0xFF1E1E1E)
                        : Colors.grey[50],
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onChanged: _filterProducts,
                ),
              ],
            ),
          ),
          // Products list
          Expanded(
            child: _filteredProducts.isEmpty
                ? _buildEmptyState(isDark)
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = _filteredProducts[index];
                      return _buildProductItem(
                        product,
                        isDark,
                        currencyProvider,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductItem(
    Product product,
    bool isDark,
    CurrencyProvider currencyProvider,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey[850]! : Colors.grey[100]!,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => _onProductTap(product),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _buildProductImage(product, isDark),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: GoogleFonts.manrope(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (product.barcode != null)
                      Text(
                        'Barcode: ${product.barcode}',
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          color: isDark ? Colors.grey[500] : Colors.grey[500],
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      currencyProvider.formatAmount(product.listPrice ?? 0.0),
                      style: GoogleFonts.manrope(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              const HugeIcon(
                icon: HugeIcons.strokeRoundedArrowRight01,
                size: 20,
                color: AppTheme.primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage(Product product, bool isDark) {
    Widget imageWidget;
    if (product.imageUrl != null && product.imageUrl!.isNotEmpty) {
      try {
        final base64String = product.imageUrl!.contains(',')
            ? product.imageUrl!.split(',')[1]
            : product.imageUrl!;
        final bytes = base64Decode(base64String);
        imageWidget = Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              _buildPlaceholder(isDark),
        );
      } catch (e) {
        imageWidget = _buildPlaceholder(isDark);
      }
    } else {
      imageWidget = _buildPlaceholder(isDark);
    }

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: imageWidget,
      ),
    );
  }

  Widget _buildPlaceholder(bool isDark) {
    return Center(
      child: HugeIcon(
        icon: HugeIcons.strokeRoundedPackage,
        color: isDark ? Colors.grey[700] : Colors.grey[400],
        size: 24,
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          HugeIcon(
            icon: HugeIcons.strokeRoundedPackageOutOfStock,
            size: 64,
            color: isDark ? Colors.grey[800] : Colors.grey[200],
          ),
          const SizedBox(height: 16),
          Text(
            'No products found',
            style: GoogleFonts.manrope(
              fontSize: 16,
              color: isDark ? Colors.grey[500] : Colors.grey[400],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
