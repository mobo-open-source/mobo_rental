import 'dart:convert';
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobo_rental/shared/widgets/snackbars/custom_snackbar.dart';
import 'package:mobo_rental/features/products/provider/product_provider.dart';
import 'package:mobo_rental/features/products/screen/product_detail_screen.dart';
import 'package:mobo_rental/features/products/screen/product_edit_screen.dart';
import 'package:mobo_rental/features/products/widgets/permission_error_view.dart';
import 'package:mobo_rental/features/products/widgets/prodcut_tile.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../../shared/widgets/empty_state.dart';

class ProductsScreen extends StatefulWidget {
  final bool autoFocusSearch;
  final bool isTest;
  const ProductsScreen({
    super.key,
    this.autoFocusSearch = false,
    this.isTest = false,
  });

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _searchDebounce;
  final Map<String, Uint8List> _imageCache = {};
  final Map<String, bool> _expandedGroups = {};

  @override
  void initState() {
    super.initState();
    if (widget.isTest) {
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final provider = context.read<ProductProvider>();
        if (provider.products.isEmpty) {
          _loadData();
          if (widget.autoFocusSearch) {
            _searchFocusNode.requestFocus();
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _searchFocusNode.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  void _loadData() {
    final provider = Provider.of<ProductProvider>(context, listen: false);
    provider.checkStockModuleInstalled();
    provider.loadPermissions();

    provider.loadProducts();
    provider.fetchGroupByOptions();
  }

  // Added Refresh Logic
  Future<void> _refreshData() async {
    final provider = Provider.of<ProductProvider>(context, listen: false);
    // Trigger loads. Using Future.wait to run them in parallel.
    await Future.wait([
      provider.loadProducts(),
      provider.loadPermissions(),

      provider.fetchGroupByOptions(),
    ]);
  }

  void _onSearchChanged(String query) {
    setState(() {}); // update clear button visibility
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      final provider = Provider.of<ProductProvider>(context, listen: false);
      if (query.isEmpty) {
        provider.loadProducts();
      } else {
        provider.searchProducts(query);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mediaQuery = MediaQuery.of(context);
    final height = mediaQuery.size.height;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButton: Consumer<ProductProvider>(
        builder: (context, provider, _) {
          if (provider.error != null ||
              provider.isLoading ||
              !provider.permissionsLoaded ||
              !provider.canCreateProduct) {
            return const SizedBox.shrink();
          }

          return FloatingActionButton(
            heroTag: 'fab_create_product',
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ProductEditScreen(isTest: widget.isTest),
                ),
              );
              if (result == true) {
                _loadData();
                if (mounted) {
                  CustomSnackbar.showSuccess(
                    context,
                    'Product created successfully',
                  );
                }
              }
            },
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Theme.of(context).primaryColor,
            tooltip: 'Create Product',
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedAdd01,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black
                  : Colors.white,
            ),
          );
        },
      ),

      body: Consumer<ProductProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              _buildSearchField(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    if (provider.activeFiltersCount > 0)
                      ActivefilterBadge(
                        isdark: isDark,
                        productProvider: provider,
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          'No filters applied',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? Colors.white70
                                : Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    const Spacer(),
                    provider.error != null
                        ? SizedBox.shrink()
                        : _buildTopPaginationBar(provider),
                  ],
                ),
              ),

              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refreshData,
                  child: Builder(
                    builder: (context) {
                      if (provider.isLoading) {
                        return _buildProductListShimmer();
                      } else if (provider.error != null) {
                        final errorTitle =
                            provider.error!.toLowerCase().contains('permission')
                            ? 'Access Error'
                            : 'Something went wrong';
                        // Make error state scrollable for refresh
                        return RefreshIndicator(
                          onRefresh: () async {
                            await provider.loadProducts();
                          },
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              EmptyState(
                                title: errorTitle,
                                subtitle:
                                'Server side is not responding please check',
                                lottieAsset: 'assets/lotties/Error 404.json',
                                onAction: () async {
                                  await provider.loadProducts();
                                },
                                actionLabel: 'Retry',
                              ),
                            ],
                          ),
                        );
                      } else if (provider.products.isEmpty &&
                          !provider.isGrouped) {
                        // Make empty state scrollable for refresh
                        return ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(
                              height: height * 0.6,
                              child: _buildEmptyState(),
                            ),
                          ],
                        );
                      } else {
                        return _buildProductList(provider.products, provider);
                      }
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchField() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, left: 16.0, right: 16.0),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF000000).withOpacity(0.05),
              offset: const Offset(0, 6),
              blurRadius: 16,
              spreadRadius: 2,
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          onChanged: _onSearchChanged,
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xff1E1E1E),
            fontWeight: FontWeight.w400,
            fontStyle: FontStyle.normal,
            fontSize: 15,
            height: 1.0,
            letterSpacing: 0.0,
          ),
          decoration: InputDecoration(
            hintText: 'Search products...',
            hintStyle: TextStyle(
              color: isDark ? Colors.white : const Color(0xff1E1E1E),
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.normal,
              fontSize: 15,
              height: 1.0,
              letterSpacing: 0.0,
            ),
            prefixIcon: IconButton(
              icon: Stack(
                children: [
                  Transform.scale(
                    scale: 0.8,
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedFilterHorizontal,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
              onPressed: _showFilterBottomSheet,
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: isDark ? Colors.grey[400] : Colors.grey,
                      size: 20,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      _searchDebounce?.cancel();
                      Provider.of<ProductProvider>(
                        context,
                        listen: false,
                      ).loadProducts();
                      setState(() {});
                    },
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  )
                : null,
            filled: true,
            fillColor: isDark ? Colors.grey[850] : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? Colors.grey[850]! : Colors.white,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? Colors.grey[850]! : Colors.white,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            isDense: true,
            alignLabelWithHint: true,
          ),
        ),
      ),
    );
  }

  Widget _buildTopPaginationBar(ProductProvider provider) {
    if (!provider.isLoading &&
        provider.products.isEmpty &&
        provider.totalCount == 0) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final paginationText =
        '${provider.startRecord}-${provider.endRecord}/${provider.totalCount}';

    return Container(
      padding: const EdgeInsets.only(right: 16, top: 4, bottom: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  paginationText,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: (provider.hasPreviousPage && !provider.isLoading)
                    ? provider.goToPreviousPage
                    : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 4,
                  ),
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedArrowLeft01,
                    size: 20,
                    color: (provider.hasPreviousPage && !provider.isLoading)
                        ? (isDark ? Colors.white : Colors.black87)
                        : (isDark ? Colors.grey[600] : Colors.grey[400]),
                  ),
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: (provider.hasNextPage && !provider.isLoading)
                    ? provider.goToNextPage
                    : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 4,
                  ),
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedArrowRight01,
                    size: 20,
                    color: (provider.hasNextPage && !provider.isLoading)
                        ? (isDark ? Colors.white : Colors.black87)
                        : (isDark ? Colors.grey[600] : Colors.grey[400]),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          HugeIcon(
            icon: HugeIcons.strokeRoundedPackage,
            size: 64,
            color: Colors.grey[300]!,
          ),
          const SizedBox(height: 16),
          Text(
            'No products found',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or add a new product',
            style: GoogleFonts.inter(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList(List<dynamic> products, ProductProvider provider) {
    if (provider.isGrouped) {
      final groups = provider.groupSummary.entries.toList();

      if (groups.isEmpty) {
        // Handled in main build method now, but kept for safety
        return _buildEmptyState();
      }

      return ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        controller: _scrollController,
        padding: const EdgeInsets.only(bottom: 80, top: 8),
        itemCount: groups.length,
        itemBuilder: (context, index) {
          final group = groups[index];
          final groupKey = group.key;
          final count = group.value;
          final isExpanded = _expandedGroups[groupKey] ?? false;

          return Column(
            children: [
              _buildOdooStyleGroupTile(
                groupKey,
                count,
                isExpanded,
                provider,
                () {
                  setState(() {
                    _expandedGroups[groupKey] = !isExpanded;
                  });
                  if (!isExpanded) {
                    provider.loadGroupProducts({'key': groupKey});
                  }
                },
              ),
              if (isExpanded)
                if (provider.loadedGroups.containsKey(groupKey))
                  ...provider.loadedGroups[groupKey]!
                      .map((product) => _buildProductCard(product))
                      .toList()
                else
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
            ],
          );
        },
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      controller: _scrollController,
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildProductCard(dynamic product) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Helper to convert Odoo's false to null for string fields
    String? _getStringOrNull(dynamic value) {
      if (value == null || value == false || value.toString() == 'false') {
        return null;
      }
      return value.toString();
    }

    return ProductListTile(
      id: product['id']?.toString() ?? '',
      name: product['name'] ?? 'Unknown',
      defaultCode: _getStringOrNull(product['default_code']),
      price:
          product['display_price']?.toString() ??
          product['list_price']?.toString() ??
          '',
      currencyId: product['currency_id'],
      category: (product['categ_id'] is List && product['categ_id'].length > 1)
          ? product['categ_id'][1].toString()
          : null,
      stockQuantity: (product['qty_available'] ?? 0.0).toInt(),
      imageBase64: _getStringOrNull(product['image_128']),
      variantCount: product['variant_count'],
      isDark: isDark,
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsScreen(product: product),
          ),
        );
        if (result != null) {
          _loadData();
          if (mounted) {
            if (result == true) {
              CustomSnackbar.showSuccess(
                context,
                'Product archived successfully',
              );
            } else if (result == 'updated') {
              CustomSnackbar.showSuccess(
                context,
                'Product updated successfully',
              );
            }
          }
        }
      },
    );
  }

  void _showFilterBottomSheet() {
    final provider = Provider.of<ProductProvider>(context, listen: false);

    // Temporary state for the bottom sheet
    final Map<String, dynamic> tempState = {
      'showServicesOnly': provider.showServicesOnly,
      'showConsumablesOnly': provider.showConsumablesOnly,
      'showStorableOnly': provider.showStorableOnly,
      'showAvailableOnly': provider.showAvailableOnly,
      'selectedGroupBy': provider.selectedGroupBy,
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => DefaultTabController(
        length: 2,
        child: StatefulBuilder(
          builder: (context, setDialogState) {
            final theme = Theme.of(context);
            final isDark = theme.brightness == Brightness.dark;

            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF232323) : Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Filter & Group By',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: isDark ? Colors.white : Colors.black87,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: Icon(
                              Icons.close,
                              color: isDark ? Colors.white : Colors.black54,
                            ),
                            splashRadius: 20,
                          ),
                        ],
                      ),
                    ),

                    // Tabs
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[800] : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TabBar(
                        indicator: BoxDecoration(
                          color: theme.primaryColor,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: theme.primaryColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        indicatorPadding: const EdgeInsets.all(4),
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: Colors.transparent,
                        labelColor: Colors.white,
                        unselectedLabelColor: isDark
                            ? Colors.grey[400]
                            : Colors.grey[600],
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        unselectedLabelStyle: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                        tabs: const [
                          Tab(height: 48, text: 'Filter'),
                          Tab(height: 48, text: 'Group By'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Tab Content
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildProductFilterTab(
                            context,
                            setDialogState,
                            isDark,
                            theme,
                            provider,
                            tempState,
                          ),
                          _buildProductGroupByTab(
                            context,
                            setDialogState,
                            isDark,
                            theme,
                            provider,
                            tempState,
                          ),
                        ],
                      ),
                    ),

                    // Footer Buttons
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[850] : Colors.grey[50],
                        border: Border(
                          top: BorderSide(
                            color: isDark
                                ? Colors.grey[700]!
                                : Colors.grey[200]!,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _clearAllFilters(
                                setDialogState,
                                tempState,
                                provider,
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: isDark
                                    ? Colors.white
                                    : Colors.black87,
                                side: BorderSide(
                                  color: isDark
                                      ? Colors.grey[600]!
                                      : Colors.grey[300]!,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('Clear All'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: () =>
                                  _applyFiltersAndGroupBy(tempState, provider),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('Apply'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProductFilterTab(
    BuildContext context,
    StateSetter setDialogState,
    bool isDark,
    ThemeData theme,
    ProductProvider provider,
    Map<String, dynamic> tempState,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Active Filters Display
          if (tempState['showServicesOnly'] == true ||
              tempState['showConsumablesOnly'] == true ||
              tempState['showStorableOnly'] == true ||
              tempState['showAvailableOnly'] == true) ...[
            Text(
              'Active Filters',
              style: theme.textTheme.labelMedium?.copyWith(
                color: isDark ? Colors.white : theme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                if (tempState['showServicesOnly'] == true)
                  Chip(
                    label: const Text(
                      'Services',
                      style: TextStyle(fontSize: 13),
                    ),
                    backgroundColor: isDark
                        ? Colors.white.withOpacity(.08)
                        : theme.primaryColor.withOpacity(0.08),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () => setDialogState(
                      () => tempState['showServicesOnly'] = false,
                    ),
                  ),
                if (tempState['showConsumablesOnly'] == true)
                  Chip(
                    label: const Text(
                      'Consumables',
                      style: TextStyle(fontSize: 13),
                    ),
                    backgroundColor: isDark
                        ? Colors.white.withOpacity(.08)
                        : theme.primaryColor.withOpacity(0.08),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () => setDialogState(
                      () => tempState['showConsumablesOnly'] = false,
                    ),
                  ),
                if (tempState['showStorableOnly'] == true)
                  Chip(
                    label: const Text(
                      'Storable',
                      style: TextStyle(fontSize: 13),
                    ),
                    backgroundColor: isDark
                        ? Colors.white.withOpacity(.08)
                        : theme.primaryColor.withOpacity(0.08),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () => setDialogState(
                      () => tempState['showStorableOnly'] = false,
                    ),
                  ),
                if (tempState['showAvailableOnly'] == true)
                  Chip(
                    label: const Text(
                      'Available Only',
                      style: TextStyle(fontSize: 13),
                    ),
                    backgroundColor: isDark
                        ? Colors.white.withOpacity(.08)
                        : theme.primaryColor.withOpacity(0.08),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () => setDialogState(
                      () => tempState['showAvailableOnly'] = false,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
          ],

          // Type Filters
          Text(
            'Product Type',
            style: theme.textTheme.labelMedium?.copyWith(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              ChoiceChip(
                label: Text(
                  'Services',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: tempState['showServicesOnly'] == true
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: tempState['showServicesOnly'] == true
                        ? Colors.white
                        : (isDark ? Colors.white : Colors.black87),
                  ),
                ),
                selected: tempState['showServicesOnly'] == true,
                selectedColor: theme.primaryColor,
                backgroundColor: isDark
                    ? Colors.white.withOpacity(.08)
                    : theme.primaryColor.withOpacity(0.08),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
                  ),
                ),
                onSelected: (val) {
                  setDialogState(() {
                    tempState['showServicesOnly'] = val;
                    if (val) {
                      tempState['showConsumablesOnly'] = false;
                      tempState['showStorableOnly'] = false;
                    }
                  });
                },
              ),
              ChoiceChip(
                label: Text(
                  'Consumables',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: tempState['showConsumablesOnly'] == true
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: tempState['showConsumablesOnly'] == true
                        ? Colors.white
                        : (isDark ? Colors.white : Colors.black87),
                  ),
                ),
                selected: tempState['showConsumablesOnly'] == true,
                selectedColor: theme.primaryColor,
                backgroundColor: isDark
                    ? Colors.white.withOpacity(.08)
                    : theme.primaryColor.withOpacity(0.08),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
                  ),
                ),
                onSelected: (val) {
                  setDialogState(() {
                    tempState['showConsumablesOnly'] = val;
                    if (val) {
                      tempState['showServicesOnly'] = false;
                      tempState['showStorableOnly'] = false;
                    }
                  });
                },
              ),
              ChoiceChip(
                label: Text(
                  'Storable',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: tempState['showStorableOnly'] == true
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: tempState['showStorableOnly'] == true
                        ? Colors.white
                        : (isDark ? Colors.white : Colors.black87),
                  ),
                ),
                selected: tempState['showStorableOnly'] == true,
                selectedColor: theme.primaryColor,
                backgroundColor: isDark
                    ? Colors.white.withOpacity(.08)
                    : theme.primaryColor.withOpacity(0.08),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
                  ),
                ),
                onSelected: (val) {
                  setDialogState(() {
                    tempState['showStorableOnly'] = val;
                    if (val) {
                      tempState['showServicesOnly'] = false;
                      tempState['showConsumablesOnly'] = false;
                    }
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Availability
          Text(
            'Availability',
            style: theme.textTheme.labelMedium?.copyWith(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              ChoiceChip(
                label: Text(
                  'Available Only',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: tempState['showAvailableOnly'] == true
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: tempState['showAvailableOnly'] == true
                        ? Colors.white
                        : (isDark ? Colors.white : Colors.black87),
                  ),
                ),
                selected: tempState['showAvailableOnly'] == true,
                selectedColor: theme.primaryColor,
                backgroundColor: isDark
                    ? Colors.white.withOpacity(.08)
                    : theme.primaryColor.withOpacity(0.08),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
                  ),
                ),
                onSelected: (val) =>
                    setDialogState(() => tempState['showAvailableOnly'] = val),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildProductGroupByTab(
    BuildContext context,
    StateSetter setDialogState,
    bool isDark,
    ThemeData theme,
    ProductProvider provider,
    Map<String, dynamic> tempState,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            'Group products by',
            style: theme.textTheme.labelMedium?.copyWith(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          RadioListTile<String?>(
            title: Text(
              'None',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              'Display as a simple list',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontSize: 12,
              ),
            ),
            value: null,
            groupValue: tempState['selectedGroupBy'],
            onChanged: (value) {
              setDialogState(() {
                tempState['selectedGroupBy'] = value;
              });
            },
            activeColor: theme.primaryColor,
            contentPadding: EdgeInsets.zero,
          ),
          const Divider(),
          if (provider.groupByOptions.isEmpty) ...[
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: Text("Loading options...")),
            ),
          ] else ...[
            ...provider.groupByOptions.entries.map((entry) {
              String description = '';
              switch (entry.key) {
                case 'categ_id':
                  description = 'Group by product category';
                  break;
                case 'type':
                  description = 'Group by product type';
                  break;
                case 'uom_id':
                  description = 'Group by unit of measure';
                  break;
                default:
                  description = 'Group by ${entry.value.toLowerCase()}';
              }
              return RadioListTile<String>(
                title: Text(
                  entry.value,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  description,
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                value: entry.key,
                groupValue: tempState['selectedGroupBy'],
                onChanged: (value) {
                  setDialogState(() {
                    tempState['selectedGroupBy'] = value;
                  });
                },
                activeColor: theme.primaryColor,
                contentPadding: EdgeInsets.zero,
              );
            }).toList(),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _clearAllFilters(
    StateSetter setDialogState,
    Map<String, dynamic> tempState,
    ProductProvider provider,
  ) {
    setDialogState(() {
      tempState['showServicesOnly'] = false;
      tempState['showConsumablesOnly'] = false;
      tempState['showStorableOnly'] = false;
      tempState['showAvailableOnly'] = false;
      tempState['selectedGroupBy'] = null;
    });

    provider.clearFilters();

    // Trigger the data fetch immediately
    provider.loadProducts();

    //  Close the bottom sheet
    Navigator.of(context).pop();
  }

  void _applyFiltersAndGroupBy(
    Map<String, dynamic> tempState,
    ProductProvider provider,
  ) {
    provider.setFilterState(
      showServicesOnly: tempState['showServicesOnly'],
      showConsumablesOnly: tempState['showConsumablesOnly'],
      showStorableOnly: tempState['showStorableOnly'],
      showAvailableOnly: tempState['showAvailableOnly'],
    );
    provider.setGroupBy(tempState['selectedGroupBy']);
    Navigator.of(context).pop();
  }

  Widget _buildActiveFiltersChips(ProductProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    if (!provider.showServicesOnly &&
        !provider.showConsumablesOnly &&
        !provider.showStorableOnly &&
        !provider.showAvailableOnly &&
        !provider.isGrouped) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          if (provider.showServicesOnly)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                label: const Text('Services', style: TextStyle(fontSize: 12)),
                deleteIcon: const Icon(Icons.close, size: 14),
                onDeleted: () =>
                    provider.setFilterState(showServicesOnly: false),
                backgroundColor: theme.primaryColor.withOpacity(0.1),
                side: BorderSide.none,
              ),
            ),
          if (provider.showConsumablesOnly)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                label: const Text(
                  'Consumables',
                  style: TextStyle(fontSize: 12),
                ),
                deleteIcon: const Icon(Icons.close, size: 14),
                onDeleted: () =>
                    provider.setFilterState(showConsumablesOnly: false),
                backgroundColor: theme.primaryColor.withOpacity(0.1),
                side: BorderSide.none,
              ),
            ),
          if (provider.showStorableOnly)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                label: const Text('Storable', style: TextStyle(fontSize: 12)),
                deleteIcon: const Icon(Icons.close, size: 14),
                onDeleted: () =>
                    provider.setFilterState(showStorableOnly: false),
                backgroundColor: theme.primaryColor.withOpacity(0.1),
                side: BorderSide.none,
              ),
            ),
          if (provider.showAvailableOnly)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                label: const Text(
                  'Available Only',
                  style: TextStyle(fontSize: 12),
                ),
                deleteIcon: const Icon(Icons.close, size: 14),
                onDeleted: () =>
                    provider.setFilterState(showAvailableOnly: false),
                backgroundColor: theme.primaryColor.withOpacity(0.1),
                side: BorderSide.none,
              ),
            ),
          if (provider.isGrouped)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                label: Text(
                  'Group: ${provider.groupByOptions[provider.selectedGroupBy] ?? provider.selectedGroupBy}',
                  style: const TextStyle(fontSize: 12),
                ),
                deleteIcon: const Icon(Icons.close, size: 14),
                onDeleted: () => provider.setGroupBy(null),
                backgroundColor: theme.primaryColor.withOpacity(0.1),
                side: BorderSide.none,
              ),
            ),
          TextButton(
            onPressed: () => provider.clearFilters(),
            child: const Text('Clear All', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildOdooStyleGroupTile(
    String groupTitle,
    int count,
    bool isExpanded,
    ProductProvider provider,
    VoidCallback onTap,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.black.withOpacity(0.06),
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              blurRadius: 16,
              spreadRadius: 2,
              offset: const Offset(0, 6),
              color: Colors.black.withOpacity(0.08),
            ),
        ],
      ),
      margin: const EdgeInsets.only(bottom: 8, left: 10, right: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        groupTitle,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$count product${count != 1 ? 's' : ''}',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductListShimmer() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final baseColor = isDark ? Colors.grey[850]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 80, top: 8),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: Container(
              height: 84,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 14,
                          width: double.infinity,
                          color: baseColor,
                        ),
                        const SizedBox(height: 8),
                        Container(height: 12, width: 120, color: baseColor),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class ActivefilterBadge extends StatelessWidget {
  const ActivefilterBadge({
    super.key,
    required this.isdark,
    required this.productProvider,
  });

  final bool isdark;
  final ProductProvider productProvider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isdark ? Colors.white70 : Colors.black,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        '${productProvider.activeFiltersCount} Active',
        style: TextStyle(
          fontSize: 12,
          color: isdark ? Colors.black : Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
