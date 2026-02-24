import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobo_rental/shared/widgets/snackbars/custom_snackbar.dart';
import 'package:mobo_rental/features/customer/providers/customer_provider.dart';
import 'package:mobo_rental/features/customer/screens/customer_detail_screen.dart';
import 'package:mobo_rental/features/customer/widgets/customer_list_tile.dart';
import 'package:mobo_rental/features/dashboard/providers/dashboard_provider.dart';
import 'package:mobo_rental/features/dashboard/providers/user_provider.dart';
import 'package:mobo_rental/features/products/provider/product_provider.dart';
import 'package:mobo_rental/features/products/widgets/date_picker_utils.dart';
import 'package:mobo_rental/Core/utils/constants/colors.dart';
import 'package:mobo_rental/Core/Widgets/common/textfrom.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../shared/widgets/empty_state.dart';
import 'customer_form_screen.dart';
import 'package:intl/intl.dart';

class CustomersScreen extends StatefulWidget {
  final bool autoFocusSearch;

  const CustomersScreen({super.key, this.autoFocusSearch = false});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _searchDebounce;
  final Map<String, Uint8List> _imageCache = {};
  final Map<String, bool> _expandedGroups = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = Provider.of<CustomerProvider>(context, listen: false);

      if (provider.customers.isEmpty) {
        _loadData();
        if (widget.autoFocusSearch) {
          _searchFocusNode.requestFocus();
        }
      }
    });
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
    final provider = Provider.of<CustomerProvider>(context, listen: false);
    provider.loadCustomers();
    provider.fetchGroupByOptions();
  }

  Future<void> _refreshData() async {
    final provider = Provider.of<CustomerProvider>(context, listen: false);
    // Trigger loads in parallel
    await Future.wait([
      provider.loadCustomers(),
      provider.fetchGroupByOptions(),
    ]);
  }

  void _onSearchChanged(String query) {
    setState(() {}); // update clear button visibility
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      final provider = Provider.of<CustomerProvider>(context, listen: false);
      if (query.isEmpty) {
        provider.loadCustomers();
      } else {
        provider.searchCustomers(query);
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

      floatingActionButton: Consumer<CustomerProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const SizedBox.shrink();
          }
          return FloatingActionButton(
            heroTag: 'fab_create_customer',
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CustomerFormScreen(),
                ),
              );
              if (result == true) {
                _loadData();
              }
            },
            backgroundColor: isDark
                ? Colors.white
                : Theme.of(context).primaryColor,
            tooltip: 'Create Customer',
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedUserAdd01,
              color: isDark ? Colors.black : Colors.white,
            ),
          );
        },
      ),
      body: Consumer<CustomerProvider>(
        builder: (context, provider, _) {
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
                        customerProvider: provider,
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
                    _buildTopPaginationBar(provider),
                  ],
                ),
              ),

              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refreshData,
                  child: Builder(
                    builder: (context) {
                      if (provider.isLoading) {
                        return _buildCustomerListShimmer();
                      } else if (provider.customers.isEmpty &&
                          !provider.isGrouped) {
                        // Make empty state scrollable for refresh
                        return RefreshIndicator(
                          onRefresh: () async {
                            await provider.loadCustomers();
                          },
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              EmptyState(
                                title: "Something Went Wrong!",
                                subtitle:
                                'Server side is not responding please check',
                                lottieAsset: 'assets/lotties/Error 404.json',
                                onAction: () async {
                                  await provider.loadCustomers();
                                },
                                actionLabel: 'Retry',
                              ),
                            ],
                          ),
                        );
                      } else {
                        return _buildCustomerList(provider.customers, provider);
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
            hintText: 'Search customers...',
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
                      Provider.of<CustomerProvider>(
                        context,
                        listen: false,
                      ).loadCustomers();
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

  Widget _buildTopPaginationBar(CustomerProvider provider) {
    if (!provider.isLoading &&
        provider.customers.isEmpty &&
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
            icon: HugeIcons.strokeRoundedUserGroup,
            size: 64,
            color: Colors.grey[300]!,
          ),
          const SizedBox(height: 16),
          Text(
            'No customers found',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or add a new customer',
            style: GoogleFonts.inter(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerList(
    List<dynamic> customers,
    CustomerProvider provider,
  ) {
    if (provider.isGrouped) {
      final groups = provider.groupSummary.entries.toList();

      if (groups.isEmpty) {
        return _buildEmptyState();
      }

      return ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: groups.length,
        itemBuilder: (context, index) {
          final group = groups[index];
          final groupKey = group.key;
          final count = group.value;
          final isExpanded = _expandedGroups[groupKey] ?? false;

          return Column(
            children: [
              _buildOdooStyleGroupTile(
                context,
                groupKey,
                count,
                isExpanded,
                () {
                  setState(() {
                    _expandedGroups[groupKey] = !isExpanded;
                  });
                  if (!isExpanded) {
                    provider.loadGroupContacts(groupKey);
                  }
                },
              ),
              if (isExpanded)
                if (provider.loadedGroups.containsKey(groupKey))
                  ...provider.loadedGroups[groupKey]!
                      .map((customer) => _buildCustomerCard(customer))
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
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: customers.length,
      itemBuilder: (context, index) {
        final customer = customers[index];
        return _buildCustomerCard(customer);
      },
    );
  }

  Widget _buildCustomerCard(dynamic customer) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.read<ProductProvider>();

    return CustomerListTile(
      customer: customer,
      isDark: isDark,
      imageCache: _imageCache,
      onTap: () async {
        // // Track as last opened (Customer)
        // try {
        //       context,
        //     ).trackCustomerAccess(
        //       customerId: id,
        //       customerName: name,
        //       customerType: type,
        //       customerData: Map<String, dynamic>.from(customer),
        // } catch (_) {}

        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CustomerDetailsScreen(
              customer: Map<String, dynamic>.from(customer),
            ),
          ),
        );
        if (result == true) {
          _loadData();
        }
      },
      onCall: () => _makePhoneCall(customer['phone']),
      onMessage: () => _sendMessage(customer['phone']),
      onEmail: () => _sendEmail(customer['email']),
      onLocation: () => _viewLocation(customer),
    );
  }

  Future<void> _makePhoneCall(String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.isEmpty || phoneNumber == 'false') {
      CustomSnackbar.showInfo(context, 'No phone number available');
      return;
    }

    final phoneUrl = 'tel:$phoneNumber';
    if (await canLaunchUrl(Uri.parse(phoneUrl))) {
      await launchUrl(Uri.parse(phoneUrl));
    }
  }

  Future<void> _sendMessage(String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.isEmpty || phoneNumber == 'false') {
      CustomSnackbar.showInfo(context, 'No phone number available');
      return;
    }

    final smsUrl = 'sms:$phoneNumber';
    if (await canLaunchUrl(Uri.parse(smsUrl))) {
      await launchUrl(Uri.parse(smsUrl));
    }
  }

  Future<void> _sendEmail(String? email) async {
    if (email == null || email.isEmpty || email == 'false') {
      CustomSnackbar.showInfo(context, 'No email address available');
      return;
    }

    final emailUrl = 'mailto:$email';
    if (await canLaunchUrl(Uri.parse(emailUrl))) {
      await launchUrl(Uri.parse(emailUrl));
    }
  }

  void _viewLocation(dynamic customer) {
    // Check if coordinates are available
    final lat = customer['partner_latitude'];
    final lng = customer['partner_longitude'];

    if (lat != null && lng != null && lat != 0.0 && lng != 0.0) {
      // Has GPS coordinates - open in maps
      _openInMaps(lat, lng);
    } else {
      // No coordinates - show message
      CustomSnackbar.showInfo(
        context,
        'No location data available for this customer',
      );
    }
  }

  Future<void> _openInMaps(double lat, double lng) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  void _showFilterBottomSheet() {
    final provider = Provider.of<CustomerProvider>(context, listen: false);

    // Temporary state for the bottom sheet
    final Map<String, dynamic> tempState = {
      'showActiveOnly': provider.showActiveOnly,
      'showCompaniesOnly': provider.showCompaniesOnly,
      'showIndividualsOnly': provider.showIndividualsOnly,
      'showCreditBreachesOnly': provider.showCreditBreachesOnly,
      'startDate': provider.startDate,
      'endDate': provider.endDate,
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
                          _buildCustomerFilterTab(
                            context,
                            setDialogState,
                            isDark,
                            theme,
                            provider,
                            tempState,
                          ),
                          _buildCustomerGroupByTab(
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

  Widget _buildCustomerFilterTab(
    BuildContext context,
    StateSetter setDialogState,
    bool isDark,
    ThemeData theme,
    CustomerProvider provider,
    Map<String, dynamic> tempState,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Active Filters Display
          if (tempState['showActiveOnly'] == true ||
              tempState['showCompaniesOnly'] == true ||
              tempState['showIndividualsOnly'] == true ||
              tempState['showCreditBreachesOnly'] == true ||
              tempState['startDate'] != null ||
              tempState['endDate'] != null) ...[
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
                if (tempState['showActiveOnly'] == true)
                  Chip(
                    label: const Text(
                      'Active Only',
                      style: TextStyle(fontSize: 13),
                    ),
                    backgroundColor: isDark
                        ? Colors.white.withOpacity(.08)
                        : theme.primaryColor.withOpacity(0.08),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () => setDialogState(
                      () => tempState['showActiveOnly'] = false,
                    ),
                  ),
                if (tempState['showCompaniesOnly'] == true)
                  Chip(
                    label: const Text(
                      'Companies',
                      style: TextStyle(fontSize: 13),
                    ),
                    backgroundColor: isDark
                        ? Colors.white.withOpacity(.08)
                        : theme.primaryColor.withOpacity(0.08),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () => setDialogState(
                      () => tempState['showCompaniesOnly'] = false,
                    ),
                  ),
                if (tempState['showIndividualsOnly'] == true)
                  Chip(
                    label: const Text(
                      'Individuals',
                      style: TextStyle(fontSize: 13),
                    ),
                    backgroundColor: isDark
                        ? Colors.white.withOpacity(.08)
                        : theme.primaryColor.withOpacity(0.08),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () => setDialogState(
                      () => tempState['showIndividualsOnly'] = false,
                    ),
                  ),

                if (tempState['startDate'] != null ||
                    tempState['endDate'] != null)
                  Chip(
                    label: Text(
                      'Date: ${tempState['startDate'] != null ? DateFormat('MMM dd').format(tempState['startDate']) : '...'} - ${tempState['endDate'] != null ? DateFormat('MMM dd, yyyy').format(tempState['endDate']) : '...'}',
                      style: const TextStyle(fontSize: 13),
                    ),
                    backgroundColor: isDark
                        ? Colors.white.withOpacity(.08)
                        : theme.primaryColor.withOpacity(0.08),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () => setDialogState(() {
                      tempState['startDate'] = null;
                      tempState['endDate'] = null;
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 16),
          ],

          // Status Filters
          Text(
            'Status',
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
                  'Active Only',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: tempState['showActiveOnly'] == true
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: tempState['showActiveOnly'] == true
                        ? Colors.white
                        : (isDark ? Colors.white : Colors.black87),
                  ),
                ),
                selected: tempState['showActiveOnly'] == true,
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
                    setDialogState(() => tempState['showActiveOnly'] = val),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Type Filters
          Text(
            'Type',
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
                  'Companies',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: tempState['showCompaniesOnly'] == true
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: tempState['showCompaniesOnly'] == true
                        ? Colors.white
                        : (isDark ? Colors.white : Colors.black87),
                  ),
                ),
                selected: tempState['showCompaniesOnly'] == true,
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
                    tempState['showCompaniesOnly'] = val;
                    if (val) tempState['showIndividualsOnly'] = false;
                  });
                },
              ),
              ChoiceChip(
                label: Text(
                  'Individuals',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: tempState['showIndividualsOnly'] == true
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: tempState['showIndividualsOnly'] == true
                        ? Colors.white
                        : (isDark ? Colors.white : Colors.black87),
                  ),
                ),
                selected: tempState['showIndividualsOnly'] == true,
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
                    tempState['showIndividualsOnly'] = val;
                    if (val) tempState['showCompaniesOnly'] = false;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Date Range
          Text(
            'Date Range',
            style: theme.textTheme.labelMedium?.copyWith(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          InkWell(
            onTap: () async {
              final date = await DatePickerUtils.showStandardDatePicker(
                context: context,
                initialDate: tempState['startDate'] ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) {
                setDialogState(() => tempState['startDate'] = date);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[850] : Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tempState['startDate'] != null
                          ? 'From: ${DateFormat('MMM dd, yyyy').format(tempState['startDate'])}'
                          : 'Select start date',
                      style: TextStyle(
                        color: tempState['startDate'] != null
                            ? (isDark ? Colors.white : Colors.grey[800])
                            : (isDark ? Colors.grey[400] : Colors.grey[600]),
                      ),
                    ),
                  ),
                  if (tempState['startDate'] != null)
                    IconButton(
                      onPressed: () =>
                          setDialogState(() => tempState['startDate'] = null),
                      icon: Icon(
                        Icons.clear,
                        size: 16,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          InkWell(
            onTap: () async {
              final date = await DatePickerUtils.showStandardDatePicker(
                context: context,
                initialDate: tempState['endDate'] ?? DateTime.now(),
                firstDate: tempState['startDate'] ?? DateTime(2020),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) {
                setDialogState(() => tempState['endDate'] = date);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[850] : Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tempState['endDate'] != null
                          ? 'To: ${DateFormat('MMM dd, yyyy').format(tempState['endDate'])}'
                          : 'Select end date',
                      style: TextStyle(
                        color: tempState['endDate'] != null
                            ? (isDark ? Colors.white : Colors.grey[800])
                            : (isDark ? Colors.grey[400] : Colors.grey[600]),
                      ),
                    ),
                  ),
                  if (tempState['endDate'] != null)
                    IconButton(
                      onPressed: () =>
                          setDialogState(() => tempState['endDate'] = null),
                      icon: Icon(
                        Icons.clear,
                        size: 16,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCustomerGroupByTab(
    BuildContext context,
    StateSetter setDialogState,
    bool isDark,
    ThemeData theme,
    CustomerProvider provider,
    Map<String, dynamic> tempState,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            'Group customers by',
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
                case 'user_id':
                  description = 'Group by assigned salesperson';
                  break;
                case 'country_id':
                  description = 'Group by country';
                  break;
                case 'state_id':
                  description = 'Group by state';
                  break;
                case 'company_id':
                  description = 'Group by company';
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
    CustomerProvider provider,
  ) {
    // 1. Update visual state (Keep Active = true)
    setDialogState(() {
      tempState['showActiveOnly'] = true; // <--- KEEP THIS TRUE
      tempState['showCompaniesOnly'] = false;
      tempState['showIndividualsOnly'] = false;
      tempState['showCreditBreachesOnly'] = false;
      tempState['startDate'] = null;
      tempState['endDate'] = null;
      tempState['selectedGroupBy'] = null;
    });

    // 2. Clear Provider state (logic handled in provider)
    provider.clearFilters();

    // 3. Trigger immediate reload
    provider.loadCustomers();

    // 4. Close the bottom sheet
    Navigator.of(context).pop();
  }

  void _applyFiltersAndGroupBy(
    Map<String, dynamic> tempState,
    CustomerProvider provider,
  ) {
    provider.setFilterState(
      showActiveOnly: tempState['showActiveOnly'],
      showCompaniesOnly: tempState['showCompaniesOnly'],
      showIndividualsOnly: tempState['showIndividualsOnly'],
      startDate: tempState['startDate'],
      endDate: tempState['endDate'],
    );

    provider.setGroupBy(tempState['selectedGroupBy']);

    // Reload data with new filters
    if (tempState['selectedGroupBy'] == null) {
      provider.loadCustomers(search: _searchController.text);
    }

    Navigator.of(context).pop();
  }

  Widget _buildActiveFiltersChips(CustomerProvider provider) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          if (provider.showActiveOnly)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                label: const Text(
                  'Active Only',
                  style: TextStyle(fontSize: 12),
                ),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () {
                  provider.setFilterState(showActiveOnly: false);
                  provider.loadCustomers(search: _searchController.text);
                },
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
              ),
            ),
          if (provider.showCompaniesOnly)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                label: const Text('Companies', style: TextStyle(fontSize: 12)),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () {
                  provider.setFilterState(showCompaniesOnly: false);
                  provider.loadCustomers(search: _searchController.text);
                },
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
              ),
            ),
          if (provider.showIndividualsOnly)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                label: const Text(
                  'Individuals',
                  style: TextStyle(fontSize: 12),
                ),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () {
                  provider.setFilterState(showIndividualsOnly: false);
                  provider.loadCustomers(search: _searchController.text);
                },
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
              ),
            ),
          if (provider.startDate != null || provider.endDate != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                label: const Text('Date Range', style: TextStyle(fontSize: 12)),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () {
                  provider.setFilterState(startDate: null, endDate: null);
                  provider.loadCustomers(search: _searchController.text);
                },
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
              ),
            ),
          if (provider.selectedGroupBy != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                label: Text(
                  'Group: ${provider.groupByOptions[provider.selectedGroupBy] ?? provider.selectedGroupBy}',
                  style: const TextStyle(fontSize: 12),
                ),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () {
                  provider.setGroupBy(null);
                },
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
              ),
            ),

          // Clear All Button
          //     onPressed: () {
          //     },
          //     style: TextButton.styleFrom(
          //       padding: const EdgeInsets.symmetric(horizontal: 8),
          //       minimumSize: Size.zero,
          //       tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          //     ),
          //     child: const Text('Clear All', style: TextStyle(fontSize: 12)),
          //   ),
        ],
      ),
    );
  }

  Widget _buildOdooStyleGroupTile(
    BuildContext context,
    String groupTitle,
    int count,
    bool isExpanded,
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
      margin: const EdgeInsets.only(bottom: 8, left: 0, right: 0),
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
                        '$count customer${count != 1 ? 's' : ''}',
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

  Widget _buildCustomerListShimmer() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 8,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Shimmer.fromColors(
            baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
            highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
            child: Container(
              height: 84,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[850] : Colors.white,
                borderRadius: BorderRadius.circular(12),
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
    required this.customerProvider,
  });

  final bool isdark;
  final CustomerProvider customerProvider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isdark ? Colors.white70 : Colors.black,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        '${customerProvider.activeFiltersCount} Active',
        style: TextStyle(
          fontSize: 12,
          color: isdark ? Colors.black : Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
