import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_colors.dart';

/// Shimmer skeleton placeholder for loading states
class ShimmerLoader extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerLoader({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? AppColors.darkShimmerBase : AppColors.shimmerBase,
      highlightColor: isDark ? AppColors.darkShimmerHighlight : AppColors.shimmerHighlight,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }

  /// Card-shaped shimmer placeholder
  static Widget card({double height = 120}) {
    return Builder(builder: (context) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return Shimmer.fromColors(
        baseColor: isDark ? AppColors.darkShimmerBase : AppColors.shimmerBase,
        highlightColor: isDark ? AppColors.darkShimmerHighlight : AppColors.shimmerHighlight,
        child: Container(
          height: height,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
    });
  }

  /// List shimmer with multiple lines
  static Widget list({int itemCount = 5}) {
    return Column(
      children: List.generate(
        itemCount,
        (i) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              ShimmerLoader(width: 48, height: 48, borderRadius: 12),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    ShimmerLoader(height: 14),
                    SizedBox(height: 8),
                    ShimmerLoader(width: 150, height: 10),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Dashboard skeleton shimmer
  static Widget dashboard() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerLoader(width: 120, height: 16),
                const SizedBox(height: 12),
                const ShimmerLoader(width: 250, height: 28),
                const SizedBox(height: 24),
                const ShimmerLoader(height: 54, borderRadius: 16),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: List.generate(
                4,
                (i) => const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: ShimmerLoader(width: 80, height: 36, borderRadius: 12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          ShimmerLoader.card(height: 160),
          ShimmerLoader.card(height: 160),
        ],
      ),
    );
  }
}
