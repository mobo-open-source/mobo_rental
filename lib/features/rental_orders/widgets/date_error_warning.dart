import 'package:flutter/material.dart';

void showSameDateWarningDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      final isDark = Theme.of(context).brightness == Brightness.dark;

      final backgroundColor = isDark ? Colors.grey[900] : Colors.white;
      final titleColor = isDark ? Colors.white : Colors.black87;
      final bodyColor = isDark ? Colors.white70 : Colors.black87;

      final primaryColor = Theme.of(context).colorScheme.primary;

      return Dialog(
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: primaryColor,
                    size: 26,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "Invalid Duration",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: titleColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              Text(
                'The Start Date cannot be the same as the Return Date. Please select a valid rental period.',
                style: TextStyle(fontSize: 14, color: bodyColor, height: 1.4),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Got it",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
