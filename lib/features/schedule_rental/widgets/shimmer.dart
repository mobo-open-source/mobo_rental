import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SheduledRentalShimmer extends StatelessWidget {
  final bool isdark;

  const SheduledRentalShimmer({super.key, required this.isdark});

  @override
  Widget build(BuildContext context) {
    final Color baseColor = isdark ? Colors.grey[850]! : Colors.grey.shade300;
    final Color highlightColor = isdark
        ? Colors.grey[600]!
        : Colors.grey.shade100;
    final Color blockColor = isdark ? Colors.grey[800]! : Colors.white;

    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: isdark
              ? Colors.grey[850]
              : Theme.of(context).colorScheme.secondary,
          border: Border(
            bottom: BorderSide(
              color: isdark ? Colors.grey[800]! : Colors.grey.shade300,
            ),
          ),
        ),
        child: Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: ListView.builder(
            itemCount: 8,
            padding: const EdgeInsets.only(bottom: 20),
            itemBuilder: (context, index) {
              return Container(
                height: 70,
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: blockColor,
                  border: Border(
                    bottom: BorderSide(
                      color: isdark ? Colors.grey[700]! : Colors.grey.shade300,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 16,
                      margin: const EdgeInsets.only(right: 100),
                      decoration: BoxDecoration(
                        color: blockColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 100,
                      height: 12,
                      decoration: BoxDecoration(
                        color: blockColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
