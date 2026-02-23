import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mobo_rental/Core/Widgets/common/alert_dialog.dart';
import 'package:mobo_rental/features/rental_orders/models/order_line_model.dart';
import 'package:mobo_rental/features/rental_orders/models/product_model.dart';
import 'package:mobo_rental/features/rental_orders/models/tax_model.dart';
import 'package:mobo_rental/features/rental_orders/providers/create_rental_provider.dart';
import 'package:mobo_rental/Core/Widgets/common/paddings.dart';
import 'package:mobo_rental/Core/Widgets/common/textfrom.dart';
import 'package:mobo_rental/features/rental_orders/widgets/product_conteiner.dart';
import 'package:mobo_rental/features/rental_orders/widgets/rental_order_widget.dart';
import 'package:provider/provider.dart';

// --- REUSABLE WIDGETS ---

/// A standard card widget with a title and child content.
Widget mainCard({
  required String title,
  required Widget child,
  required bool isDark,
}) {
  return Container(
    width: double.infinity,
    decoration: BoxDecoration(
      boxShadow: isDark
          ? []
          : [
              BoxShadow(
                offset: const Offset(-1, 0),
                spreadRadius: 1,
                blurRadius: 2,
                color: Colors.grey.shade300,
              ),
            ],
      color: isDark ? Colors.grey[850] : Colors.white,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: CustomText(
            text: title,
            size: 18,
            fontweight: FontWeight.w800,
            textcolor: isDark ? Colors.white : Colors.black,
          ),
        ),
        Divider(color: isDark ? Colors.grey[700] : Colors.grey.shade200),
        Padding(padding: const EdgeInsets.all(16), child: child),
      ],
    ),
  );
}

/// A standard text field widget used in the rental creation flow.
Widget commonTextField({
  TextEditingController? controller,
  required String hint,
  IconData? icon,
  VoidCallback? ontap,
  ValueChanged<String>? onchange,
  required bool readonly,
  bool? showCursor,
  VoidCallback? onTapSuffix,
  bool? isDropShown,
  VoidCallback? unfocus,
  FocusNode? focusNode,
  required BuildContext ctx,
}) {
  return TextFormField(
    focusNode: focusNode,
    onTapOutside: (PointerDownEvent event) {
      FocusManager.instance.primaryFocus?.unfocus();
      if (unfocus != null) unfocus();
    },
    showCursor: showCursor,
    onTap: ontap,
    readOnly: readonly,
    controller: controller,
    onChanged: onchange,
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black38),
      prefixIcon: Icon(icon, color: Colors.black38),
      suffixIcon: IconButton(
        icon: Icon(
          isDropShown == false ? Icons.arrow_drop_down : Icons.arrow_drop_up,
          color: Colors.black45,
        ),
        onPressed: onTapSuffix,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Theme.of(ctx).primaryColor),
      ),
      filled: true,
      fillColor: const Color(0xfff5f5f5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
    ),
  );
}

/// A dropdown field widget used in the rental creation flow.
Widget dropdownField({
  required String hint,
  IconData? icon,
  required VoidCallback onTap,
  VoidCallback? showList,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xfff5f5f5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          if (icon != null) Icon(icon, color: Colors.black38),
          if (icon != null) const SizedBox(width: 12),
          Expanded(
            child: Text(hint, style: const TextStyle(color: Colors.black38)),
          ),
          GestureDetector(
            onTap: showList,
            child: const Icon(Icons.arrow_drop_down, color: Colors.black45),
          ),
        ],
      ),
    ),
  );
}

Widget notesField(String text, TextEditingController controller) {
  return Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xfff5f5f5),
      borderRadius: BorderRadius.circular(16),
    ),
    child: TextField(
      controller: controller,
      minLines: 3,
      maxLines: 6,
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: text,
        hintStyle: const TextStyle(color: Colors.black38),
      ),
    ),
  );
}

final SuggestionsController<TaxModel> taxSuggestionsController =
    SuggestionsController<TaxModel>();

/// A date picker field widget.
Widget dateField(String dateText, VoidCallback onTap, bool isdark) {
  return InkWell(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
      decoration: BoxDecoration(
        color: isdark ? Colors.grey[900] : const Color(0xfff5f5f5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          HugeIcon(
            icon: HugeIcons.strokeRoundedCalendar03,
            size: 18,
            color: isdark ? const Color(0xfff5f5f5) : Colors.black45,
          ),
          const SizedBox(width: 12),
          Text(dateText, style: const TextStyle(fontSize: 16)),
        ],
      ),
    ),
  );
}

/// A card widget that displays information about the selected customer.
Widget CustomerCardWidget({
  required bool isTrailing,
  Widget? trailingIcon,
  VoidCallback? trailingFunction,
  required BuildContext context,
}) {
  final provider = Provider.of<CreateRentalProvider>(context, listen: false);
  final customer = provider.selectedCustomer;
  final imageBytes = customer?.imageBytes;

  // 1. Check current theme brightness
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      boxShadow: [
        BoxShadow(
          offset: const Offset(2, 1),
          // Dark mode usually requires subtler, darker shadows (or none)
          color: isDark
              ? Colors.black.withAlpha(50)
              : Colors.grey.withAlpha(100),
          blurRadius: 3,
        ),
      ],
      // Dark card background vs White
      color: isDark ? Colors.grey[850] : Colors.white,
      borderRadius: BorderRadius.circular(12),
      // Darker border for dark mode
      border: Border.all(
        color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        width: 1,
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              height: 55,
              width: 55,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // Adaptive placeholder background
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
                // Adaptive border
                border: Border.all(
                  color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                  width: 2,
                ),
                image: (imageBytes != null && imageBytes.isNotEmpty)
                    ? DecorationImage(
                        image: MemoryImage(imageBytes),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: (imageBytes == null || imageBytes.isEmpty)
                  ? Icon(
                      Icons.person_outline,
                      size: 32,
                      // Lighter icon on dark background
                      color: isDark
                          ? Colors.grey.shade300
                          : Colors.grey.shade600,
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                customer?.name ?? 'ABC',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  // White text for dark mode
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
            const Spacer(),
            if (isTrailing)
              GestureDetector(
                onTap: trailingFunction,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedCancelCircleHalfDot,
                    size: 25,
                    color: isDark ? Colors.grey.shade400 : Colors.grey,
                  ),
                ),
              ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            CustomerDataFeild(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.email_outlined,
                    size: 18,
                    // Adaptive icon color
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    (customer?.email != null &&
                            customer!.email!.trim().isNotEmpty)
                        ? customer.email!
                        : 'No email available',
                    style: TextStyle(
                      fontSize: 14,
                      // Adaptive text color
                      color: isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            CustomerDataFeild(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.phone,
                    size: 18,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    (customer?.phone != null &&
                            customer!.phone!.trim().isNotEmpty)
                        ? customer.phone!
                        : 'No phone number available',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

// --- MAIN FUNCTION TO OPEN DIALOG ---

void openProductDialog(
  BuildContext context,
  ProductModel product, {
  int? specificVariantId,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return ProductEditContent(
        product: product,
        parentContext: context,
        specificVariantId: specificVariantId,
      );
    },
  );
}

// --- BOTTOM SHEET LIST ---

openProduct(BuildContext context) {
  final TextEditingController searchController = TextEditingController();
  final mediaQuery = MediaQuery.of(context);
  final height = mediaQuery.size.height;
  final width = mediaQuery.size.width;
  final isDark = Theme.of(context).brightness == Brightness.dark;

  showModalBottomSheet(
    isDismissible: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
    ),
    backgroundColor: isDark ? Colors.grey[900] : Colors.white,
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    barrierColor: Colors.black38,
    constraints: BoxConstraints.expand(height: height * 0.85),
    builder: (sheetContext) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: pagePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedPackage,
                      color: isDark
                          ? Colors.white
                          : Theme.of(context).primaryColor,
                    ),
                    SizedBox(width: width * 0.02),
                    CustomText(
                      text: 'Select Products',
                      size: 26,
                      textcolor: isDark ? Colors.white : Colors.black87,
                      fontweight: FontWeight.w700,
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedCancelCircleHalfDot,
                        color: isDark ? Colors.white54 : Colors.black45,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: height * 0.02),
                TextFormField(
                  controller: searchController,
                  onChanged: (val) => Provider.of<CreateRentalProvider>(
                    context,
                    listen: false,
                  ).fetchProducts(context, val),
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                        width: 2,
                      ),
                    ),
                    hintText: "Search rented products...",
                    hintStyle: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.black38,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: isDark ? Colors.grey[300] : Colors.black45,
                    ),
                    filled: true,
                    fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: height * 0.02),
                Consumer<CreateRentalProvider>(
                  builder: (context, provider, child) {
                    return Text(
                      'Fetched ${provider.prductsList.length} products',
                      style: TextStyle(
                        color: isDark ? Colors.grey[300] : Colors.black87,
                      ),
                    );
                  },
                ),
                SizedBox(height: height * 0.02),
              ],
            ),
          ),
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is ScrollUpdateNotification) {
                  final metrics = notification.metrics;
                  if (metrics.pixels >= metrics.maxScrollExtent - 50) {
                    final provider = context.read<CreateRentalProvider>();
                    if (!provider.isFetchingMoreProduct &&
                        provider.hasMoreProduct) {
                      provider.fetchProducts(
                        context,
                        searchController.text,
                        isLoadMore: true,
                      );
                    }
                  }
                }
                return true;
              },
              child: Consumer<CreateRentalProvider>(
                builder: (context, provider, child) {
                  if (provider.productLoading) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          LoadingAnimationWidget.fourRotatingDots(
                            color: Theme.of(context).primaryColor,
                            size: 40,
                          ),
                          const SizedBox(height: 10),
                          CustomText(
                            text: 'Loading Products',
                            textcolor: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ],
                      ),
                    );
                  } else if (provider.prductsList.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomText(
                            text: 'No products available',
                            textcolor: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: pagePadding),
                    itemCount:
                        provider.prductsList.length +
                        (provider.isFetchingMoreProduct ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == provider.prductsList.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: SizedBox(
                              height: 25,
                              width: 25,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                              ),
                            ),
                          ),
                        );
                      }

                      final item = provider.prductsList[index];
                      return ProductConteiner(
                        title: item.name,
                        price: item.displayPrice,
                        qty: item.qty,
                        variants: item.variantCount,
                        ontap: () {
                          if (item.variantCount > 1) {
                            provider.fetchVariantsAndOpenDialog(
                              context,
                              templateId: item.id,
                              templateName: item.name,
                            );
                          } else {
                            // 1. Close keyboard if open
                            FocusScope.of(context).unfocus();

                            // 2. Open Standard Dialog
                            openProductDialog(context, item);
                          }
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// --- THE EDIT CONTENT WIDGET (HANDLES LOGIC) ---

/// A widget that manages the content for editing a product in a rental order.
class ProductEditContent extends StatefulWidget {
  final ProductModel product;
  final BuildContext parentContext;
  final int? specificVariantId;

  const ProductEditContent({
    super.key,
    required this.product,
    required this.parentContext,
    this.specificVariantId,
  });

  @override
  State<ProductEditContent> createState() => _ProductEditContentState();
}

class _ProductEditContentState extends State<ProductEditContent> {
  bool isLoading = true;
  bool isPriceCalculating = false;
  String? errorMessage;
  int? lineId;
  Timer? _debounce;

  List<int> _localSelectedTaxIds = [];

  late TextEditingController qtyController;
  late TextEditingController priceController;
  late TextEditingController taxTextController;

  final SuggestionsController<TaxModel> taxSuggestionsController =
      SuggestionsController<TaxModel>();

  @override
  void initState() {
    super.initState();
    qtyController = TextEditingController(text: widget.product.qty.toString());
    priceController = TextEditingController(
      text: widget.product.displayPrice.toString(),
    );
    taxTextController = TextEditingController();

    qtyController.addListener(_onQtyChanged);
    priceController.addListener(_onPriceChanged);

    _initData();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    qtyController.dispose();
    priceController.dispose();
    taxTextController.dispose();
    taxSuggestionsController.close();
    super.dispose();
  }

  void _onQtyChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 100), () {
      _handleQtyUpdate();
    });
  }

  void _onPriceChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 100), () {
      _handlePriceUpdate();
    });
  }

  Future<void> _handleQtyUpdate() async {
    if (lineId == null) return;
    final newQty = int.tryParse(qtyController.text);
    if (newQty == null) return;

    final provider = Provider.of<CreateRentalProvider>(context, listen: false);

    final line = provider.selectedProducts
        .where((p) => p.id == lineId)
        .cast<ProductLine?>()
        .firstOrNull;

    if (line != null && line.quantity == newQty) return;

    setState(() {
      isPriceCalculating = true;
    });

    try {
      provider.editingOrderLineId = lineId;
      await provider.updateLineQty(newQty);
    } finally {
      if (mounted) {
        setState(() {
          isPriceCalculating = false;
        });
      }
    }
  }

  Future<void> _handlePriceUpdate() async {
    if (lineId == null) return;
    final newPrice = double.tryParse(priceController.text);
    if (newPrice == null) return;

    final provider = Provider.of<CreateRentalProvider>(context, listen: false);

    final line = provider.selectedProducts
        .where((p) => p.id == lineId)
        .cast<ProductLine?>()
        .firstOrNull;

    if (line != null && line.price == newPrice) return;

    setState(() {
      isPriceCalculating = true;
    });

    try {
      provider.editingOrderLineId = lineId;
      await provider.updateLinePrice(newPrice, _localSelectedTaxIds);
    } finally {
      if (mounted) {
        setState(() {
          isPriceCalculating = false;
        });
      }
    }
  }

  Future<void> _initData() async {
    try {
      final provider = Provider.of<CreateRentalProvider>(
        context,
        listen: false,
      );

      int variantId;
      if (widget.specificVariantId != null) {
        variantId = widget.specificVariantId!;
      } else {
        variantId = await provider.fetchSingleVariantId(
          templateId: widget.product.id,
        );
      }

      final createdLineId = await provider.createOrderLine(
        context: context,
        productId: variantId,
        showGlobalLoader: false,
      );

      if (createdLineId == null) {
        if (mounted) {
          setState(() {
            isLoading = false;
            errorMessage = "Failed to add product";
          });
        }
        return;
      }

      provider.editingOrderLineId = createdLineId;

      final createdLine = provider.selectedProducts
          .where((e) => e.id == createdLineId)
          .cast<ProductLine?>()
          .firstOrNull;

      if (mounted) {
        setState(() {
          lineId = createdLineId;
          if (createdLine != null) {
            qtyController.text = createdLine.quantity.toString();
            priceController.text = createdLine.price.toString();

            _localSelectedTaxIds = createdLine.taxes.map((t) => t.id).toList();
            _updateTaxText(provider.taxesList);
          }
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = e.toString();
        });
      }
    }
  }

  void _updateTaxText(List<TaxModel> allTaxes) {
    final selectedNames = allTaxes
        .where((tax) => _localSelectedTaxIds.contains(tax.id))
        .map((tax) => tax.name)
        .join(", ");
    taxTextController.text = selectedNames;
  }

  Future<void> _toggleTax(TaxModel tax) async {
    final provider = Provider.of<CreateRentalProvider>(context, listen: false);

    setState(() {
      if (_localSelectedTaxIds.contains(tax.id)) {
        _localSelectedTaxIds.remove(tax.id);
      } else {
        _localSelectedTaxIds.add(tax.id);
      }
      _updateTaxText(provider.taxesList);
      isPriceCalculating = true;
    });

    try {
      if (lineId != null) {
        provider.editingOrderLineId = lineId;
        await provider.updateLineTaxes(_localSelectedTaxIds);
      }
    } finally {
      if (mounted) {
        setState(() {
          isPriceCalculating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        FocusScope.of(context).unfocus();
        taxSuggestionsController.close();
      },
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: width * 0.85,
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black54 : Colors.black12,
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: isLoading
                ? _buildLoading(context, isDark)
                : errorMessage != null
                ? _buildError(context, isDark)
                : _buildForm(context, isDark, height),
          ),
        ),
      ),
    );
  }

  Widget _buildLoading(BuildContext context, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LoadingAnimationWidget.fourRotatingDots(
          color: Theme.of(context).primaryColor,
          size: 40,
        ),
        const SizedBox(height: 20),
        Text(
          "Calculating Prices...",
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildError(BuildContext context, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.error_outline, color: Colors.red, size: 40),
        const SizedBox(height: 10),
        Text(
          errorMessage ?? "Error",
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Close"),
        ),
      ],
    );
  }

  Widget _buildForm(BuildContext context, bool isDark, double height) {
    return Consumer<CreateRentalProvider>(
      builder: (context, provider, _) {
        final line =
            provider.selectedProducts
                .where((p) => p.id == lineId)
                .cast<ProductLine?>()
                .firstOrNull ??
            ProductLine(
              id: 0,
              productId: 0,
              name: widget.product.name,
              price: 0,
              quantity: 0,
              taxes: [],
              subtotal: 0,
              tax: 0,
              lineTotal: 0,
            );

        final productName = line.id != 0 ? line.name : widget.product.name;
        final noBorderDecoration = const InputDecoration(
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12),
          isDense: true,
        );
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Theme.of(context).primaryColor.withAlpha(100),
                  ),
                  child: const HugeIcon(
                    icon: HugeIcons.strokeRoundedPackageAdd,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    productName,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 13,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: height * 0.02),

            // --- LABELS ---
            Row(
              children: [
                Expanded(
                  child: CustomText(
                    text: "Quantity",
                    size: 14,
                    textcolor: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
                Expanded(
                  child: CustomText(
                    text: "Unit Price",
                    size: 14,
                    textcolor: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
            SizedBox(height: height * 0.03),

            // --- INPUTS ---
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.grey[800]
                          : const Color(0xfff5f5f5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: TextField(
                      controller: qtyController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      decoration: noBorderDecoration,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.grey[800]
                          : const Color(0xfff5f5f5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      decoration: noBorderDecoration,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: height * 0.03),

            TypeAheadField<TaxModel>(
              suggestionsController: taxSuggestionsController,
              suggestionsCallback: (_) => provider.taxesList,
              hideOnSelect: false,
              onSelected: (TaxModel tax) => _toggleTax(tax),
              builder: (context, controller, node) {
                if (controller.text != taxTextController.text) {
                  controller.text = taxTextController.text;
                }
                return TextField(
                  controller: taxTextController,
                  focusNode: node,
                  readOnly: true,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    hintText: "Select Taxes",
                    filled: true,
                    fillColor: isDark ? Colors.grey[800] : Colors.white,
                    border: const OutlineInputBorder(),
                    suffixIcon: const Icon(Icons.arrow_drop_down),
                  ),
                  onTap: () => taxSuggestionsController.open(),
                );
              },
              itemBuilder: (context, tax) {
                final isSelected = _localSelectedTaxIds.contains(tax.id);
                return CheckboxListTile(
                  value: isSelected,
                  title: Text(tax.name),
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (_) => _toggleTax(tax),
                );
              },
            ),
            SizedBox(height: height * 0.03),

            // --- TOTAL (SHOWS CALCULATING...) ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).primaryColor.withAlpha(isDark ? 50 : 30),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText(
                    text: "Total:",
                    size: 16,
                    textcolor: isDark ? Colors.white : Colors.black87,
                  ),
                  isPriceCalculating
                      ? Row(
                          children: [
                            Text(
                              "Calculating...",
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).primaryColor,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              height: 15,
                              width: 15,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        )
                      : CustomText(
                          text: "\$${line.lineTotal.toStringAsFixed(2)}",
                          size: 18,
                          textcolor: Theme.of(context).primaryColor,
                          fontweight: FontWeight.w600,
                        ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- ACTION BUTTONS ---
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () async {
                    if (lineId != null) {
                      loadingDialog(
                        context,
                        'Removing Product',
                        'Please wait...',
                        LoadingAnimationWidget.fourRotatingDots(
                          color: Theme.of(context).primaryColor,
                          size: 30,
                        ),
                      );

                      try {
                        provider.editingOrderLineId = lineId;
                        await provider.cancelEditingLine();
                      } finally {
                        if (context.mounted) {
                          hideLoadingDialog(context);
                          Navigator.pop(context);
                        }
                      }
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  // Disable if currently calculating
                  onTap: isPriceCalculating
                      ? null
                      : () async {
                          loadingDialog(
                            context,
                            'Adding to Quote',
                            'Updating line details...',
                            LoadingAnimationWidget.fourRotatingDots(
                              color: Theme.of(context).primaryColor,
                              size: 30,
                            ),
                          );

                          try {
                            // Ensure the final values in the box are sent if user typed quickly
                            final newQty =
                                int.tryParse(qtyController.text) ??
                                line.quantity;
                            final newPrice =
                                double.tryParse(priceController.text) ??
                                line.price;

                            provider.editingOrderLineId = line.id;

                            if (newQty != line.quantity) {
                              await provider.updateLineQty(newQty);
                            }

                            await provider.updateLinePrice(
                              newPrice,
                              _localSelectedTaxIds,
                            );
                          } finally {
                            if (context.mounted) {
                              hideLoadingDialog(context);
                              Navigator.pop(context);
                              Navigator.pop(widget.parentContext);
                            }
                          }
                        },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 26,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isPriceCalculating
                          ? Colors.grey
                          : Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      "Add to Quote",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
