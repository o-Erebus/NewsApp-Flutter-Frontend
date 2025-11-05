import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:Nexora/Providers/podcast_provider.dart';
import 'package:Nexora/Models/podcast_model.dart';

class FullPlayerBottomSheet extends StatelessWidget {
  final Podcast podcast;
  final PodcastProvider podcastProvider;

  const FullPlayerBottomSheet({
    required this.podcast,
    required this.podcastProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<PodcastProvider>(
      builder: (context, provider, _) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(20),
                children: [
                  // Drag indicator
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[700],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Podcast Cover
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CachedNetworkImage(
                      imageUrl: podcast.imageUrl,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[800],
                        child: const Center(child: Icon(Icons.music_note)),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[800],
                        child: const Center(child: Icon(Icons.music_note)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title and Channel
                  Text(
                    podcast.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    podcast.channelName,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[400]),
                  ),
                  const SizedBox(height: 16),

                  // Progress Bar
                  Column(
                    children: [
                      SliderTheme(
                        data: SliderThemeData(
                          trackHeight: 6,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 8,
                          ),
                        ),
                        child: Slider(
                          value: provider.totalDuration > 0
                              ? provider.currentPosition
                              : 0,
                          max: provider.totalDuration,
                          onChanged: (value) {
                            provider.seek(value);
                          },
                          activeColor: Colors.teal.shade400,
                          inactiveColor: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            provider.currentPositionFormatted,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(color: Colors.grey[400]),
                          ),
                          Text(
                            provider.totalDurationFormatted,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(color: Colors.grey[400]),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Control Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildControlButton(
                        context,
                        Icons.fast_rewind,
                        () => provider.skipBackward(),
                      ),
                      _buildControlButton(
                        context,
                        provider.isPlaying ? Icons.pause : Icons.play_arrow,
                        () => provider.togglePlayPause(),
                        isPrimary: true,
                      ),
                      _buildControlButton(
                        context,
                        Icons.fast_forward,
                        () => provider.skipForward(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Description
                  Text(
                    'About this episode',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    podcast.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[400],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Rating and Info
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard(
                          context,
                          '⭐ ${podcast.rating}',
                          'Rating',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInfoCard(
                          context,
                          '👥 ${(podcast.listenerCount / 1000000).toStringAsFixed(1)}M',
                          'Listeners',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildControlButton(
    BuildContext context,
    IconData icon,
    VoidCallback onPressed, {
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: isPrimary ? Colors.teal.shade400 : Colors.grey[800],
          shape: BoxShape.circle,
        ),
        padding: EdgeInsets.all(isPrimary ? 16 : 12),
        child: Icon(icon, color: Colors.white, size: isPrimary ? 32 : 24),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String value, String label) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }
}
