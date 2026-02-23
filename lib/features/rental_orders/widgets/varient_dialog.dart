import 'package:flutter/material.dart';
import 'package:mobo_rental/features/rental_orders/models/product_model.dart'; // Import this
import 'package:mobo_rental/features/rental_orders/models/product_varient_model.dart';
import 'package:mobo_rental/features/rental_orders/providers/create_rental_provider.dart';
import 'package:mobo_rental/features/rental_orders/widgets/create_rental_order_widgets.dart';
import 'package:mobo_rental/features/rental_orders/widgets/product_conteiner.dart';
import 'package:provider/provider.dart';

class VariantDialog extends StatelessWidget {
  final String templateName;
  final BuildContext parentContext;

  const VariantDialog({
    super.key,
    required this.templateName,
    required this.parentContext,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFC63A5A),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Select Variant for $templateName',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ),
          Flexible(
            fit: FlexFit.loose,
            child: _VariantList(parentContext: parentContext),
          ),
        ],
      ),
    );
  }
}

class _VariantList extends StatelessWidget {
  final BuildContext parentContext;

  const _VariantList({required this.parentContext});

  @override
  Widget build(BuildContext context) {
    return Consumer<CreateRentalProvider>(
      builder: (context, provider, _) {
        if (provider.variantsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          itemCount: provider.variants.length,
          itemBuilder: (context, index) {
            final variant = provider.variants[index];
            return _VariantTile(variant: variant, parentContext: parentContext);
          },
        );
      },
    );
  }
}

class _VariantTile extends StatelessWidget {
  final ProductVariantModel variant;
  final BuildContext parentContext;

  const _VariantTile({required this.variant, required this.parentContext});

  @override
  Widget build(BuildContext context) {
    return ProductConteiner(
      title: variant.name,
      price: variant.price.toString(),
      qty: variant.stock,
      sku: variant.sku,
      ontap: () {
        Navigator.pop(context);

        final productModel = ProductModel(
          id: variant.id,
          name: variant.name,
          displayPrice: variant.price.toString(),
          qty: variant.stock,
          variantCount: 0,
        );

        openProductDialog(
          parentContext,
          productModel,
          specificVariantId: variant.id,
        );
      },
    );
  }
}
