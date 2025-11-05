import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:Nexora/Providers/podcast_provider.dart';
import 'trending_podcast_card.dart';

class TrendingPodcastsSection extends StatelessWidget {
  const TrendingPodcastsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Consumer<PodcastProvider>(
      builder: (context, podcastProvider, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          Icons.trending_up,
                          color: colorScheme.onPrimary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Trending',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'See All',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Trending Podcasts List
            if (podcastProvider.isFetchingTrending)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: _buildTrendingShimmer(colorScheme),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                // Show only up to the first 4 trending podcasts
                itemCount: podcastProvider.trendingPodcasts.length > 4
                    ? 4
                    : podcastProvider.trendingPodcasts.length,
                itemBuilder: (context, index) {
                  final podcast = podcastProvider.trendingPodcasts[index];
                  return TrendingPodcastCard(
                    podcast: podcast,
                    index: index + 1,
                  );
                },
              ),
          ],
        );
      },
    );
  }

  Widget _buildTrendingShimmer(ColorScheme colorScheme) {
    return Column(
      children: List.generate(
        4,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Shimmer.fromColors(
            baseColor: colorScheme.surfaceContainerHigh,
            highlightColor: colorScheme.surface,
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
