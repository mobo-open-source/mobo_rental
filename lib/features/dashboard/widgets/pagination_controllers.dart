import 'package:flutter/material.dart';

class PaginationControlsDashboard extends StatelessWidget {
  final int startIndex;
  final int endIndex;
  final int totalCount;
  final bool canGoPrevious;
  final bool canGoNext;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final bool isLoading;

  const PaginationControlsDashboard({
    super.key,
    required this.startIndex,
    required this.endIndex,
    required this.totalCount,
    required this.canGoPrevious,
    required this.canGoNext,
    required this.onPrevious,
    required this.onNext,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (totalCount == 0 || isLoading) {
      return const SizedBox.shrink();
    }

    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    final Color disabledColor = isDark
        ? theme.colorScheme.onSurface.withAlpha(72)
        : theme.colorScheme.onSurface.withAlpha(72);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
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
              '$startIndex-$endIndex/$totalCount',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: canGoPrevious ? onPrevious : null,
            customBorder: const CircleBorder(),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.chevron_left,
                size: 24,
                color: canGoPrevious
                    ? theme.colorScheme.primary
                    : disabledColor,
              ),
            ),
          ),
          const SizedBox(width: 3),
          InkWell(
            onTap: canGoNext ? onNext : null,
            customBorder: const CircleBorder(),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.chevron_right,
                size: 24,
                color: canGoNext ? theme.colorScheme.primary : disabledColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
