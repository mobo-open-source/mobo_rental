import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:mobo_rental/features/rental_orders/providers/create_rental_provider.dart';
import 'package:mobo_rental/Core/Widgets/common/paddings.dart';
import 'package:mobo_rental/Core/Widgets/common/textfrom.dart';
import 'package:provider/provider.dart';

Widget productShowing(BuildContext context) {
  // 1. Detect Dark Mode
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return Consumer<CreateRentalProvider>(
    builder: (context, provider, child) {
      final formatter = NumberFormat.compact(locale: "en_US");

      final fromattedGrandTotol = formatter.format(provider.grandTotal);
      return Column(
        children: [
          Container(
            decoration: const BoxDecoration(),
            child: Column(
              // single products 1
              children: List.generate(provider.selectedProducts.length, (
                index,
              ) {
                final line = provider.selectedProducts[index];
                final formatedPrice = formatter.format(line.lineTotal);

                return Container(
                  margin: EdgeInsets.all(pagePadding),
                  padding: EdgeInsets.all(pagePadding),
                  decoration: BoxDecoration(
                    // 2. Adaptive Card Background
                    color: isDark ? Colors.grey[850] : Colors.white,
                    // 3. Adaptive Border
                    border: Border.all(
                      color: isDark ? Colors.grey[800]! : Colors.grey.shade300,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: CustomText(
                              text: line.name,
                              size: 16,
                              fontweight: FontWeight.w600,
                              // 4. Adaptive Text Color
                              textcolor: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              provider.editingOrderLineId = line.id;
                              await provider.cancelEditingLine();
                            },
                            icon: HugeIcon(
                              icon: HugeIcons.strokeRoundedDelete02,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomText(
                                  text: 'Quantity',
                                  size: 12,
                                  // 5. Adaptive Label Color
                                  textcolor: isDark
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade600,
                                ),
                                const SizedBox(height: 8),

                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      // 6. Adaptive Quantity Border
                                      color: isDark
                                          ? Colors.grey[700]!
                                          : Colors.grey.shade300,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        onPressed: () async {
                                          final line =
                                              provider.selectedProducts[index];
                                          if (line.quantity > 1) {
                                            provider.editingOrderLineId =
                                                line.id;
                                            await provider.updateLineQty(
                                              line.quantity - 1,
                                            );
                                          }
                                        },
                                        // 7. Adaptive Icon Color
                                        icon: Icon(
                                          Icons.remove,
                                          size: 18,
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                        padding: const EdgeInsets.all(8),
                                        constraints: const BoxConstraints(),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                        ),
                                        child: CustomText(
                                          text: line.quantity.toString(),
                                          size: 16,
                                          textcolor: isDark
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () async {
                                          final line =
                                              provider.selectedProducts[index];
                                          provider.editingOrderLineId = line.id;
                                          await provider.updateLineQty(
                                            line.quantity + 1,
                                          );
                                        },

                                        icon: Icon(
                                          Icons.add,
                                          size: 18,
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                        padding: const EdgeInsets.all(8),
                                        constraints: const BoxConstraints(),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomText(
                                text: 'Total',
                                size: 12,
                                textcolor: isDark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600,
                              ),
                              const SizedBox(height: 20),
                              CustomText(
                                text: '\$ $formatedPrice',
                                size: 20,
                                fontweight: FontWeight.w600,
                                textcolor: Theme.of(context).primaryColor,
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),
                    ],
                  ),
                );
              }),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              // 8. Adaptive Summary Container Border
              border: Border.all(
                color: isDark
                    ? Colors.blue.withOpacity(0.3)
                    : Colors.blue.withAlpha(100),
              ),
              // 9. Adaptive Summary Container Background
              color: isDark
                  ? Colors.blue.withOpacity(0.1)
                  : Colors.lightBlueAccent.withAlpha(30),
            ),
            padding: const EdgeInsets.all(18),
            margin: const EdgeInsets.all(10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomText(
                      text: 'Subtotal:',
                      size: 18,
                      textcolor: isDark ? Colors.white70 : Colors.black87,
                    ),
                    CustomText(
                      text: '\$ ${formatter.format(provider.subtotal)}',
                      textcolor: isDark ? Colors.white : Colors.black,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomText(
                      text: 'Tax:',
                      size: 18,
                      textcolor: isDark ? Colors.white70 : Colors.black87,
                    ),
                    CustomText(
                      text: '\$ ${formatter.format(provider.totalTax)}',
                      textcolor: isDark ? Colors.white : Colors.black,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomText(
                      text: 'Total Amount:',
                      size: 20,
                      fontweight: FontWeight.w600,
                      textcolor: isDark ? Colors.white : Colors.black,
                    ),
                    CustomText(
                      text: '\$ $fromattedGrandTotol',
                      fontweight: FontWeight.w600,
                      size: 20,
                      textcolor: Colors.blue,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      );
    },
  );
}

class CustomerDataFeild extends StatelessWidget {
  final Widget child;
  const CustomerDataFeild({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 10, top: 5, bottom: 5, right: 10),
      decoration: BoxDecoration(
        color: Colors.grey.withAlpha(50),
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}
