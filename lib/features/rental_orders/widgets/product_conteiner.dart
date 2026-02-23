import 'package:flutter/material.dart';

class ProductConteiner extends StatelessWidget {
  final String price;
  final String title;
  final dynamic qty;
  final String? sku;
  final String? category;
  final int? variants;
  final VoidCallback ontap;

  const ProductConteiner({
    super.key,
    required this.title,
    required this.price,
    required this.qty,
    required this.ontap,
    this.sku,
    this.category,
    this.variants,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Detect Dark Mode
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: ontap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        width: double.infinity,
        decoration: BoxDecoration(
          // 2. Adaptive Background Color
          color: isDark ? Colors.grey[850] : Colors.white,
          borderRadius: BorderRadius.circular(15),
          // 3. Adaptive Border Color
          border: Border.all(
            color: isDark ? Colors.grey[800]! : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, 4),
              blurRadius: 10,
              // 4. Subtler shadow for dark mode
              color: isDark
                  ? Colors.black.withOpacity(0.2)
                  : Colors.black.withOpacity(0.05),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                // 5. Adaptive Title Color
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildBadge(
                      text: 'SKU: ${sku ?? 'false'}',
                      // 6. Adaptive SKU Badge (Dark Grey vs Light Grey)
                      bgColor: isDark
                          ? Colors.grey[800]!
                          : Colors.grey.shade100,
                      textColor: isDark
                          ? Colors.grey[400]!
                          : Colors.grey.shade600,
                    ),
                    const SizedBox(width: 8), // Added spacing
                    Text(
                      ' $price',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    _buildBadge(
                      text: '${qty.toString()} in stock',
                      // 7. Adaptive Red Badge
                      // Dark mode uses a transparent red bg and lighter red text
                      bgColor: isDark
                          ? Colors.red.withOpacity(0.15)
                          : const Color(0xFFFFEBEE),
                      textColor: isDark
                          ? Colors.redAccent.shade100
                          : const Color(0xFFE57373),
                    ),
                    const SizedBox(width: 10),
                    if (variants != null && variants! > 1)
                      _buildBadge(
                        text: '$variants variants',
                        // 8. Adaptive Blue Badge
                        bgColor: isDark
                            ? Colors.blue.withOpacity(0.15)
                            : const Color(0xFFE3F2FD),
                        textColor: isDark
                            ? Colors.blueAccent.shade100
                            : const Color(0xFF2196F3),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge({
    required String text,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
