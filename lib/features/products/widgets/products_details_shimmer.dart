import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ProductSalesHistoryShimmer extends StatelessWidget {
  const ProductSalesHistoryShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(),
            const SizedBox(height: 16),
            _analyticsGrid(),
            const SizedBox(height: 24),
            _chartCard(),
            const SizedBox(height: 24),
            _recentList(),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle() {
    return Container(height: 24, width: 180, decoration: _box());
  }

  Widget _analyticsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: List.generate(4, (_) => _card(height: 80)),
    );
  }

  Widget _chartCard() {
    return _card(height: 260);
  }

  Widget _recentList() {
    return Column(
      children: List.generate(
        6,
        (_) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Expanded(child: _line(height: 14)),
              const SizedBox(width: 16),
              _line(width: 80, height: 14),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card({required double height}) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: _box(),
    );
  }

  Widget _line({double height = 12, double width = double.infinity}) {
    return Container(height: height, width: width, decoration: _box(radius: 8));
  }

  BoxDecoration _box({double radius = 16}) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius),
    );
  }
}
