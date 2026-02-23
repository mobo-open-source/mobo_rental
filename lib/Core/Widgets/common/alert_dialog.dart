import 'package:flutter/material.dart';

void loadingDialog(
  BuildContext context,
  String title,
  String subTitle,
  Widget icon,
) {
  // 1. Check Theme for Subtitle Text
  final isDark = Theme.of(context).brightness == Brightness.dark;

  dialogBox(
    context,
    title,
    icon,
    Text(
      subTitle,
      style: TextStyle(
        // Adaptive subtitle color
        color: isDark ? Colors.grey.shade400 : Colors.black54,
      ),
      textAlign: TextAlign.center,
    ),
  );
}

void hideLoadingDialog(BuildContext context) {
  if (Navigator.of(context, rootNavigator: true).canPop()) {
    Navigator.of(context, rootNavigator: true).pop();
  }
}

Future<dynamic> dialogBox(
  BuildContext context,
  String title,
  Widget icon,
  Widget child,
) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      final isDark = Theme.of(context).brightness == Brightness.dark;

      return Dialog(
        backgroundColor: isDark ? Colors.grey[850] : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withAlpha(isDark ? 50 : 20),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(12),
                child: icon,
              ),

              const SizedBox(height: 20),

              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  // Adaptive Title Color
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 10),

              child,
            ],
          ),
        ),
      );
    },
  );
}
