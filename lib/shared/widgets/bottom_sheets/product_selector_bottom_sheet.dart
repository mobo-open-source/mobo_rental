// import 'dart:async';
// import 'dart:convert';
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:hugeicons/hugeicons.dart';
// import 'package:loading_animation_widget/loading_animation_widget.dart';
// import 'package:mobo_inv_app/core/const/app_colors.dart';
// import '../../services/product_search_service.dart';
//
// /// Bottom sheet for selecting a product with API-based fetching, pagination, and search.
// /// Returns a Map: { 'product': <Map>, 'quantity': double, 'unit_price': double? }
//
//
//     BuildContext context, {
//     String title = 'Select Product',
//   }) {
//       context: context,
//       isScrollControlled: true,
//       useSafeArea: true,
//       backgroundColor: Colors.transparent,
//       builder: (ctx) => ProductSelectorBottomSheet(title: title),
//
//   State<ProductSelectorBottomSheet> createState() =>
//
//     extends State<ProductSelectorBottomSheet> {
//
//   Timer? _debounce;
//   String _query = '';
//   bool _isSearching = false;
//   bool _isLoading = false;
//   bool _isLoadingMore = false;
//   bool _hasMore = true;
//   String? _error;
//
//   int _offset = 0;
//
//
//     _debounce?.cancel();
//
//
//     });
//
//     try {
//         searchQuery: _query.isEmpty ? null : _query,
//         limit: _limit,
//         offset: 0,
//
//         });
//     } catch (e) {
//         });
//
//
//
//     try {
//         searchQuery: _query.isEmpty ? null : _query,
//         limit: _limit,
//         offset: _offset,
//
//           _offset += moreProducts.length;
//         });
//     } catch (e) {
//         });
//
//
//       });
//     });
//
//   Widget build(BuildContext context) {
//
//       initialChildSize: 0.9,
//       minChildSize: 0.6,
//       maxChildSize: 0.95,
//       expand: false,
//       builder: (context, controller) {
//           decoration: BoxDecoration(
//             color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
//             borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
//           ),
//           child: Column(
//             children: [
//               // Drag handle
//                 margin: const EdgeInsets.only(top: 8),
//                 width: 40,
//                 height: 4,
//                 decoration: BoxDecoration(
//                   color: isDark ? Colors.grey[600] : Colors.grey[300],
//                   borderRadius: BorderRadius.circular(2),
//                 ),
//               ),
//
//               // Header
//                 padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
//                 child: Row(
//                   children: [
//
//                       color: theme.primaryColor,
//                       size: 24,
//                     ),
//                       child: Text(
//                         style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                           fontWeight: FontWeight.bold,
//                           color: isDark
//                               ? Colors.white
//                               : Theme.of(context).primaryColor,
//                         ),
//                       ),
//                     ),
//                       onPressed: () => Navigator.pop(context),
//                       icon: Icon(
//                         color: isDark ? Colors.white70 : Colors.black87,
//                       ),
//                       style: IconButton.styleFrom(
//                         backgroundColor: isDark
//                             ? Colors.grey[50]
//                             : Colors.grey[50],
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               // Search
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: isDark ? Colors.grey[850] : const Color(0xFFF6F7F9),
//                     borderRadius: BorderRadius.circular(14),
//                     border: Border.all(
//                       color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
//                     ),
//                   ),
//                   child: TextField(
//                     controller: _searchController,
//                     onChanged: _onSearchChanged,
//                     autofocus: false,
//                     style: TextStyle(
//                       color: isDark ? Colors.white : Colors.black87,
//                       fontSize: 14,
//                     ),
//                     decoration: InputDecoration(
//                       hintText: 'Search products by name, code or barcode...',
//                       hintStyle: TextStyle(
//                         color: isDark ? Colors.grey[400] : Colors.grey[500],
//                         fontSize: 14,
//                       ),
//                       prefixIcon: Icon(
//                         size: 20,
//                         color: isDark ? Colors.grey[400] : Colors.grey[600],
//                       ),
//                       suffixIcon: _isSearching
//                           ? Padding(
//                               padding: const EdgeInsets.all(12.0),
//                               child: SizedBox(
//                                 width: 18,
//                                 height: 18,
//                                 child: CircularProgressIndicator(
//                                   strokeWidth: 2,
//                                   valueColor: AlwaysStoppedAnimation<Color>(
//                                   ),
//                                 ),
//                               ),
//                             )
//                           : _searchController.text.isNotEmpty
//                           ? IconButton(
//                               icon: Icon(
//                                 color: isDark
//                                     ? Colors.grey[400]
//                                     : Colors.grey[600],
//                                 size: 20,
//                               ),
//                               onPressed: () {
//                               },
//                             )
//                           : null,
//                       filled: true,
//                       fillColor: Colors.transparent,
//                       contentPadding: const EdgeInsets.symmetric(
//                         horizontal: 14,
//                         vertical: 12,
//                       ),
//                       border: InputBorder.none,
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(14),
//                         borderSide: BorderSide(
//                           color: theme.primaryColor,
//                           width: 2,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//
//               // Result count
//                 padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
//                 child: Align(
//                   alignment: Alignment.centerLeft,
//                   child: Text(
//                     _isLoading
//                         ? 'Loading...'
//                         : '${_products.length} ${_products.length == 1 ? 'product' : 'products'} found',
//                     style: TextStyle(
//                       color: isDark ? Colors.grey[400] : Colors.grey[600],
//                       fontSize: 13,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//               ),
//
//               // List
//             ],
//           ),
//       },
//
//   Widget _buildContent(bool isDark, ScrollController controller) {
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//               color: isDark
//                   ? Colors.white
//                   : Theme.of(context).primaryColor,
//               size: 40,
//             ),
//                   ? 'Searching for "${_searchController.text.trim()}"...'
//                   : 'Loading products...',
//               style: Theme.of(context).textTheme.bodyMedium
//                   ?.copyWith(color: Colors.grey.shade600),
//             ),
//           ],
//         ),
//
//
//
//       controller: _scrollController,
//       padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
//       itemCount: _products.length + (_isLoadingMore ? 1 : 0),
//       itemBuilder: (ctx, index) {
//             padding: const EdgeInsets.all(16.0),
//             child: Center(
//               child:SizedBox(
//                 width: 16,
//                 height: 16,
//                 child: CircularProgressIndicator(strokeWidth: 2),)
//             ),
//
//           product: p,
//           isDark: isDark,
//           onTap: () async {
//           },
//       },
//
//   Widget _buildErrorState(bool isDark) {
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//             size: 64,
//             color: isDark ? Colors.grey[700] : Colors.grey[300],
//           ),
//             'Error loading products',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//               color: isDark ? Colors.grey[400] : Colors.grey[600],
//             ),
//           ),
//             padding: const EdgeInsets.symmetric(horizontal: 32),
//             child: Text(
//               _error ?? 'Unknown error',
//               style: TextStyle(
//                 fontSize: 14,
//                 color: isDark ? Colors.grey[500] : Colors.grey[500],
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ),
//             onPressed: _loadInitialProducts,
//             icon: const Icon(Icons.refresh),
//             label: const Text('Retry'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Theme.of(context).primaryColor,
//             ),
//           ),
//         ],
//       ),
//
//   Widget _buildEmptyState(bool isDark) {
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//             size: 64,
//             color: isDark ? Colors.grey[700] : Colors.grey[300],
//           ),
//             'No products found',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//               color: isDark ? Colors.grey[400] : Colors.grey[600],
//             ),
//           ),
//                 ? 'Try adjusting your search'
//                 : 'No products available',
//             style: TextStyle(
//               fontSize: 14,
//               color: isDark ? Colors.grey[500] : Colors.grey[500],
//             ),
//           ),
//         ],
//       ),
//
//     BuildContext context,
//   ) async {
//       text: (product['list_price']?.toString() ?? '0'),
//
//     double _parse(String v) => double.tryParse(v) ?? 0;
//
//       context: context,
//       builder: (ctx) {
//           elevation: 8,
//           backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: Container(
//             width: MediaQuery.of(ctx).size.width * 0.9,
//             padding: const EdgeInsets.all(24),
//             child: Form(
//               key: formKey,
//               child: StatefulBuilder(
//                 builder: (context, setDialogState) {
//
//                     mainAxisSize: MainAxisSize.min,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Header
//                         children: [
//                             padding: const EdgeInsets.all(10),
//                             decoration: BoxDecoration(
//                               color: theme.primaryColor.withOpacity(0.12),
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: Icon(
//                               color: theme.primaryColor,
//                               size: 20,
//                             ),
//                           ),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                   'Add Product',
//                                   style: TextStyle(
//                                     fontWeight: FontWeight.w600,
//                                     fontSize: 18,
//                                     color: isDark
//                                         ? Colors.white
//                                         : Colors.black87,
//                                   ),
//                                 ),
//                                   style: TextStyle(
//                                     fontSize: 14,
//                                     color: isDark
//                                         ? Colors.grey[400]
//                                         : Colors.grey[600],
//                                   ),
//                                   maxLines: 2,
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//
//                       // Input fields
//                         children: [
//                             flex: 2,
//                             child: _InputField(
//                               label: 'Quantity',
//                               controller: qtyCtrl,
//                               isDark: isDark,
//                               onChanged: (_) => setDialogState(() {}),
//                               validator: (value) {
//                               },
//                             ),
//                           ),
//                             flex: 3,
//                             child: _InputField(
//                               label: 'Unit Price',
//                               controller: priceCtrl,
//                               isDark: isDark,
//                               onChanged: (_) => setDialogState(() {}),
//                               validator: (value) {
//                               },
//                             ),
//                           ),
//                         ],
//                       ),
//
//                       // Total display
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 16,
//                           vertical: 14,
//                         ),
//                         decoration: BoxDecoration(
//                           color: theme.primaryColor.withOpacity(0.08),
//                           borderRadius: BorderRadius.circular(12),
//                           border: Border.all(
//                             color: theme.primaryColor.withOpacity(0.2),
//                           ),
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                               'Total:',
//                               style: TextStyle(
//                                 fontWeight: FontWeight.w600,
//                                 fontSize: 16,
//                                 color: isDark ? Colors.white : Colors.black87,
//                               ),
//                             ),
//                               '\$ ${total.toStringAsFixed(2)}',
//                               style: TextStyle(
//                                 color: theme.primaryColor,
//                                 fontWeight: FontWeight.w700,
//                                 fontSize: 18,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//
//                       // Action buttons
//                         children: [
//                             child: TextButton(
//                               onPressed: () => Navigator.pop(ctx),
//                               style: TextButton.styleFrom(
//                                 padding: const EdgeInsets.symmetric(
//                                   vertical: 14,
//                                 ),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                               ),
//                               child: Text(
//                                 'Cancel',
//                                 style: TextStyle(
//                                   color: isDark
//                                       ? Colors.white70
//                                       : theme.primaryColor,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                             ),
//                           ),
//                             child: ElevatedButton(
//                               onPressed: qty > 0
//                                   ? () {
//                                           'product': product,
//                                           'quantity': qty,
//                                           'unit_price': price,
//                                         });
//                                   : null,
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: theme.primaryColor,
//                                 padding: const EdgeInsets.symmetric(
//                                   vertical: 14,
//                                 ),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                                 elevation: 0,
//                               ),
//                               child: const Text(
//                                 'Add',
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.w600,
//                                   fontSize: 16,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                 },
//               ),
//             ),
//           ),
//       },
//
//
//     required this.product,
//     required this.isDark,
//     required this.onTap,
//   });
//
//   Uint8List? _decodeBase64Image(String? imageData) {
//     try {
//           ? imageData.split(',').last
//           : imageData;
//     } catch (e) {
//
//   Widget build(BuildContext context) {
//
//     }();
//
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(16),
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 12),
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: isDark ? Colors.grey[850] : Colors.white,
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(
//             color: isDark ? Colors.grey[800]! : Colors.black.withOpacity(0.08),
//           ),
//           boxShadow: [
//                 blurRadius: 16,
//                 spreadRadius: 2,
//                 offset: const Offset(0, 6),
//                 color: Colors.black.withOpacity(0.06),
//               ),
//           ],
//         ),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Product image
//               width: 60,
//               height: 60,
//               decoration: BoxDecoration(
//                 color: isDark ? Colors.grey[800] : Colors.grey[100],
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(12),
//                 child: imageBytes != null
//                     ? Image.memory(
//                         imageBytes,
//                         fit: BoxFit.cover,
//                         errorBuilder: (context, error, stackTrace) {
//                             color: isDark ? Colors.grey[600] : Colors.grey[400],
//                             size: 28,
//                         },
//                       )
//                     : Icon(
//                         color: isDark ? Colors.grey[600] : Colors.grey[400],
//                         size: 28,
//                       ),
//               ),
//             ),
//
//             // Product details
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                         child: Text(
//                           name,
//                           style: TextStyle(
//                             fontSize: 15,
//                             fontWeight: FontWeight.w600,
//                             color: isDark ? Colors.white : Colors.black87,
//                           ),
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                           '\$ ${price.toString()}',
//                           style: TextStyle(
//                             fontSize: 15,
//                             fontWeight: FontWeight.w700,
//                             color: theme.primaryColor,
//                           ),
//                         ),
//                       ],
//                     ],
//                   ),
//                     spacing: 8,
//                     runSpacing: 6,
//                     children: [
//                         context,
//                         qtyAvailable > 0
//                             ? 'In Stock ($qtyAvailable)'
//                             : 'Out of Stock',
//                         isDark,
//                         tint: qtyAvailable > 0 ? Colors.green : Colors.red,
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//
//   Widget _badge(BuildContext context, String text, bool isDark, {Color? tint ,double fontsize=10}) {
//     tint ??= Colors.grey;
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: tint.withOpacity(0.12),
//         borderRadius: BorderRadius.circular(8),
//         // border: Border.all(color: tint.withOpacity(0.2)),
//       ),
//       child: Text(
//         text,
//         style: TextStyle(
//           fontSize: fontsize,
//           color: isDark ? Colors.grey[300] : tint,
//           fontWeight: FontWeight.w500,
//         ),
//       ),
//
//
//     required this.label,
//     required this.controller,
//     required this.isDark,
//   });
//
//   Widget build(BuildContext context) {
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//           label,
//           style: TextStyle(
//             fontSize: 13,
//             fontWeight: FontWeight.w600,
//             color: isDark ? Colors.grey[300] : Colors.grey[700],
//           ),
//         ),
//           controller: controller,
//           onChanged: onChanged,
//           validator: validator,
//           keyboardType: const TextInputType.numberWithOptions(decimal: true),
//           style: TextStyle(
//             fontSize: 15,
//             fontWeight: FontWeight.w600,
//             color: isDark ? Colors.white : Colors.black87,
//           ),
//           decoration: InputDecoration(
//             filled: true,
//             fillColor: isDark ? Colors.grey[850] : const Color(0xFFF6F7F9),
//             contentPadding: const EdgeInsets.symmetric(
//               horizontal: 14,
//               vertical: 14,
//             ),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide.none,
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide(color: theme.primaryColor, width: 2),
//             ),
//             errorBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: const BorderSide(color: Colors.red, width: 1),
//             ),
//             focusedErrorBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: const BorderSide(color: Colors.red, width: 2),
//             ),
//             errorStyle: const TextStyle(fontSize: 11),
//           ),
//         ),
//       ],
