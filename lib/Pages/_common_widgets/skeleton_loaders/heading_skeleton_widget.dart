// lib/Pages/_common_widgets/skeleton_loaders/heading_skeleton_widget.dart
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class HeadingSkeletonWidget extends StatelessWidget {
  final EdgeInsetsGeometry padding;

  const HeadingSkeletonWidget({
    super.key,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SliverToBoxAdapter(
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(bottom: 6.0),
        padding: padding,
        child: Shimmer.fromColors(
          baseColor: theme.colorScheme.surfaceContainerHighest,
          highlightColor: theme.colorScheme.surfaceContainer,
          child: Container(
            height: 42, // Increased height to better match headlineMedium text
            width: 150, // Appropriate width for "Top Headlines"
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20.0),
            ),
          ),
        ),
      ),
    );
  }
}
