import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mobo_rental/Core/Widgets/common/alert_dialog.dart';
import 'package:mobo_rental/Core/Widgets/common/textfrom.dart';
import 'package:mobo_rental/features/rental_orders/models/order_line_model.dart';
import 'package:mobo_rental/features/rental_orders/models/product_model.dart';
import 'package:mobo_rental/features/rental_orders/models/tax_model.dart';
import 'package:mobo_rental/features/rental_orders/providers/create_rental_provider.dart';
import 'package:provider/provider.dart';

class ProductEditContent extends StatefulWidget {
  final ProductModel product;
  final BuildContext parentContext;

  const ProductEditContent({
    super.key,
    required this.product,
    required this.parentContext,
  });

  @override
  State<ProductEditContent> createState() => _ProductEditContentState();
}

class _ProductEditContentState extends State<ProductEditContent> {
  bool isLoading = true;
  String? errorMessage;
  int? lineId;

  late TextEditingController qtyController;
  late TextEditingController priceController;
  final SuggestionsController<TaxModel> taxSuggestionsController =
      SuggestionsController<TaxModel>();

  @override
  void initState() {
    super.initState();
    // Initialize with display values immediately
    qtyController = TextEditingController(text: widget.product.qty.toString());
    priceController = TextEditingController(
      text: widget.product.displayPrice.toString(),
    );

    // Fetch real data
    _initData();
  }

  Future<void> _initData() async {
    try {
      final provider = Provider.of<CreateRentalProvider>(
        context,
        listen: false,
      );

      // 1. Get Variant ID
      final variantId = await provider.fetchSingleVariantId(
        templateId: widget.product.id,
      );

      // 2. Create Line
      final createdLineId = await provider.createOrderLine(
        context: context, // Use dialog context
        productId: variantId,
      );

      if (createdLineId == null) {
        if (mounted)
          setState(() {
            isLoading = false;
            errorMessage = "Failed to add product";
          });
        return;
      }

      // 3. Update Provider
      provider.editingOrderLineId = createdLineId;

      // 4. Get the calculated values from Odoo
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
          }
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted)
        setState(() {
          isLoading = false;
          errorMessage = e.toString();
        });
    }
  }

  @override
  void dispose() {
    qtyController.dispose();
    priceController.dispose();
    taxSuggestionsController.close();
    super.dispose();
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
        // Use the lineId we fetched, fallback to defaults if somehow missing
        final line = provider.selectedProducts.firstWhere(
          (p) => p.id == lineId,
          orElse: () => ProductLine(
            id: 0,
            productId: 0,
            name: widget.product.name,
            price: 0,
            quantity: 0,
            taxes: [],
            subtotal: 0,
            tax: 0,
            lineTotal: 0,
          ),
        );

        // Use widget name if line name is not ready
        final productName = line.id != 0 ? line.name : widget.product.name;

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
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
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
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: height * 0.03),

            // --- TAX FIELD ---
            TypeAheadField<TaxModel>(
              suggestionsController: taxSuggestionsController,
              suggestionsCallback: (_) => provider.taxesList,
              hideOnSelect: false,
              onSelected: (TaxModel tax) async {
                final currentTaxIds = line.taxes.map((e) => e.id).toList();
                final updatedList = List<int>.from(currentTaxIds);
                if (updatedList.contains(tax.id)) {
                  updatedList.remove(tax.id);
                } else {
                  updatedList.add(tax.id);
                }
                provider.editingOrderLineId = line.id;
                await provider.updateLineTaxes(updatedList);
              },
              builder: (context, controller, node) {
                final selectedTaxNames = line.taxes
                    .map((e) => e.name)
                    .join(", ");
                if (controller.text != selectedTaxNames) {
                  controller.text = selectedTaxNames;
                }
                return TextField(
                  controller: controller,
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
                final isSelected = line.taxes.any((t) => t.id == tax.id);
                return CheckboxListTile(
                  value: isSelected,
                  title: Text(tax.name),
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (_) async {
                    final currentTaxIds = line.taxes.map((e) => e.id).toList();
                    final updatedList = List<int>.from(currentTaxIds);
                    if (updatedList.contains(tax.id)) {
                      updatedList.remove(tax.id);
                    } else {
                      updatedList.add(tax.id);
                    }
                    provider.editingOrderLineId = line.id;
                    await provider.updateLineTaxes(updatedList);
                  },
                );
              },
            ),
            SizedBox(height: height * 0.03),

            // --- TOTAL ---
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
                  CustomText(
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
                      provider.editingOrderLineId = lineId;
                      await provider.cancelEditingLine();
                    }
                    if (context.mounted) Navigator.pop(context);
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
                  onTap: () async {
                    // Show final saving loader
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
                      final currentTaxIds = line.taxes
                          .map((t) => t.id)
                          .toList();
                      final newQty =
                          int.tryParse(qtyController.text) ?? line.quantity;
                      final newPrice =
                          double.tryParse(priceController.text) ?? line.price;

                      provider.editingOrderLineId = line.id;

                      if (newQty != line.quantity) {
                        await provider.updateLineQty(newQty);
                      }
                      await provider.updateLinePrice(newPrice, currentTaxIds);
                    } finally {
                      if (context.mounted) {
                        hideLoadingDialog(context); // Hide overlay
                        Navigator.pop(context); // Close Dialog
                        Navigator.pop(
                          widget.parentContext,
                        ); // Close Bottom Sheet (optional)
                      }
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 26,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
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
