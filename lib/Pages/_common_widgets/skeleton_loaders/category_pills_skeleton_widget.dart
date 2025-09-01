// lib/Pages/_common_widgets/skeleton_loaders/category_pills_skeleton_widget.dart
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CategoryPillsSkeletonWidget extends StatelessWidget {
  const CategoryPillsSkeletonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SliverToBoxAdapter(
      child: Container(
        height: 40,
        margin: const EdgeInsets.only(bottom: 6.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Shimmer.fromColors(
          baseColor: theme.colorScheme.surfaceContainerHighest,
          highlightColor: theme.colorScheme.surfaceContainer,
          child: Container(
            height: 36, // Reduced height to better match the actual pills area
            width: double.infinity, // Full width container
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(
                20.0,
              ), // Same rounding as actual pills
            ),
          ),
        ),
      ),
    );
  }
}
