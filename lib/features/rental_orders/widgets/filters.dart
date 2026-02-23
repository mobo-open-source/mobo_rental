import 'package:flutter/material.dart';
import 'package:mobo_rental/Core/Widgets/common/textfrom.dart';
import 'package:mobo_rental/features/rental_orders/providers/rental_order_provider.dart';
import 'package:provider/provider.dart';

Widget buildBottomButtons(BuildContext context) {
  final bool isDark = Theme.of(context).brightness == Brightness.dark;

  return Consumer<RentalOrderProvider>(
    builder: (context, provider, child) => Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF121212) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: OutlinedButton(
              onPressed: () {
                provider.clearFilters();
                provider.searchRentalOrders(context, searchQuery: null);
                Navigator.pop(context);
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                ),
              ),
              child: Text(
                "Clear All",
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {
                provider.applyFilters();
                provider.searchRentalOrders(context, searchQuery: null);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("Apply", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget statusFilterContainer(
  String label, {
  required bool isSelected,
  required VoidCallback ontap,
  required BuildContext context,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final theme = Theme.of(context);

  return InkWell(
    onTap: ontap,
    borderRadius: BorderRadius.circular(8),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected
            ? theme.primaryColor
            : (isDark
                  ? Colors.white.withOpacity(.08)
                  : theme.primaryColor.withOpacity(0.08)),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isSelected)
            const Icon(Icons.check, size: 16, color: Colors.black),
          if (isSelected) const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected
                  ? Colors.white
                  : (isDark ? Colors.white : Colors.black87),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget paginationWidget(BuildContext context, RentalOrderProvider provider) {
  if (provider.rentalOrderScreenList.isEmpty) {
    return const SizedBox();
  }

  final ThemeData theme = Theme.of(context);
  final bool isDark = theme.brightness == Brightness.dark;

  final Color disabledColor = isDark
      ? theme.colorScheme.onSurface.withAlpha(72)
      : theme.colorScheme.onSurface.withAlpha(72);

  return Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2B2B2B) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.10)
                : Colors.black.withOpacity(0.05),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.25)
                  : Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          '${provider.startIndex}-${provider.endIndex}/${provider.totalCount}',
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
      const SizedBox(width: 12),
      InkWell(
        onTap: provider.canGoPrevious
            ? () => provider.previousPage(context)
            : null,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(
            Icons.chevron_left,
            size: 20,
            color: provider.canGoPrevious
                ? theme.colorScheme.primary
                : disabledColor,
          ),
        ),
      ),
      const SizedBox(width: 3),
      InkWell(
        onTap: provider.canGoNext ? () => provider.nextPage(context) : null,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(
            Icons.chevron_right,
            size: 20,
            color: provider.canGoNext
                ? theme.colorScheme.primary
                : disabledColor,
          ),
        ),
      ),
    ],
  );
}
