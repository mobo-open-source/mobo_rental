import 'package:flutter/material.dart';
import 'package:mobo_rental/Core/Widgets/common/textfrom.dart';
import 'package:shimmer/shimmer.dart';

Widget dashBordMainCard({
  required String title,
  required String amount,
  required String subtitle,
  required Widget icon,
  required Color bgColor,
  required VoidCallback ontap,
  required BuildContext ctx,
  required bool isdark,
  bool? isLoading,
}) {
  if (isLoading == true) {
    final Color baseColor = isdark ? Colors.grey[850]! : Colors.grey.shade300;
    final Color highlightColor = isdark
        ? Colors.grey[600]!
        : Colors.grey.shade100;
    final Color blockColor = isdark ? Colors.grey[800]! : Colors.white;

    return InkWell(
      onTap: ontap,
      child: Container(
        decoration: BoxDecoration(
          color: isdark
              ? Colors.grey[850]
              : Theme.of(ctx).colorScheme.secondary,
          borderRadius: BorderRadius.circular(18),
          boxShadow: isdark
              ? []
              : [
                  BoxShadow(
                    color: Colors.grey.shade200,

                    blurRadius: 3,
                    spreadRadius: 3,
                  ),
                ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 18, width: 100, color: blockColor),
                const SizedBox(height: 8),
                Container(height: 14, width: 120, color: blockColor),
                const SizedBox(height: 4),
                Container(height: 9, width: 150, color: blockColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  return InkWell(
    onTap: ontap,
    child: Container(
      decoration: BoxDecoration(
        color: isdark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: isdark
            ? []
            : [
                BoxShadow(
                  color: Colors.grey.shade200,
                  offset: Offset(1, 2),
                  blurRadius: 5,
                  spreadRadius: 3,
                ),
              ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomText(
                        text: amount,
                        size: 18,
                        fontweight: FontWeight.w600,
                        textcolor: isdark ? Colors.white : Colors.black,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: bgColor.withAlpha(isdark ? 80 : 50),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: icon,
                      ),
                    ],
                  ),
                  CustomText(
                    text: title,
                    size: 14,
                    textcolor: isdark
                        ? Colors.grey[400]!
                        : Colors.black.withAlpha(190),
                    fontweight: FontWeight.w500,
                  ),
                  CustomText(
                    text: subtitle,
                    size: 9,
                    textcolor: isdark ? Colors.grey[500]! : Colors.black54,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
