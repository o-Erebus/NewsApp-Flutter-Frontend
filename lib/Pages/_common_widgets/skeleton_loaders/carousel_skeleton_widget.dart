// lib/Pages/_common_widgets/skeleton_loaders/carousel_skeleton_widget.dart
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CarouselSkeletonWidget extends StatelessWidget {
  const CarouselSkeletonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SliverToBoxAdapter(
      child: Container(
        height: 300.0,
        padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 4.0),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 16.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Shimmer.fromColors(
            baseColor: theme.colorScheme.surfaceContainerHighest,
            highlightColor: theme.colorScheme.surfaceContainer,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Main image area
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                  ),
                ),
                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.transparent,
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      stops: const [0.0, 0.4],
                    ),
                  ),
                ),
                // Text area with gradient
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 300 * 0.25,
                  child: Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.8),
                          Colors.transparent,
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: 20,
                        width: 200,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
