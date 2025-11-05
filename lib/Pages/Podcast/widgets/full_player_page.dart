import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:Nexora/Providers/podcast_provider.dart';
import 'package:Nexora/Models/podcast_model.dart';
import 'package:Nexora/Pages/Podcast/widgets/seek_bar.dart';

class FullPlayerPage extends StatelessWidget {
  final Podcast podcast;

  const FullPlayerPage({required this.podcast, super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop();
        return false;
      },
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: Consumer<PodcastProvider>(
          builder: (context, provider, _) {
            return SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Header with close button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.all(10),
                              child: Icon(
                                Icons.keyboard_arrow_down,
                                color: colorScheme.onSurface,
                                size: 28,
                              ),
                            ),
                          ),
                          Text(
                            'Now Playing',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          // keep an empty sized box here so the title stays centered
                          const SizedBox(width: 48),
                        ],
                      ),
                      const SizedBox(height: 40),

                      // Podcast Cover
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: CachedNetworkImage(
                          imageUrl: podcast.imageUrl,
                          height: 300,
                          width: 300,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: colorScheme.surfaceContainerHigh,
                            child: Center(
                              child: Icon(
                                Icons.music_note,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: colorScheme.surfaceContainerHigh,
                            child: Center(
                              child: Icon(
                                Icons.music_note,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Title
                      Text(
                        podcast.title,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                      ),
                      const SizedBox(height: 8),

                      // Channel
                      Text(
                        podcast.channelName,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Progress Bar (shared seek bar component)
                      SeekBar(
                        current: provider.currentPosition,
                        total: provider.totalDuration,
                        onSeek: (value) async {
                          await provider.seek(value);
                        },
                      ),
                      const SizedBox(height: 40),

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
                      const SizedBox(height: 40),

                      // Description
                      Text(
                        'About this episode',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        podcast.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.6,
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildControlButton(
    BuildContext context,
    IconData icon,
    VoidCallback onPressed, {
    bool isPrimary = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: isPrimary
              ? colorScheme.primary
              : colorScheme.surfaceContainerHigh,
          shape: BoxShape.circle,
        ),
        padding: EdgeInsets.all(isPrimary ? 20 : 16),
        child: Icon(
          icon,
          color: isPrimary ? colorScheme.onPrimary : colorScheme.onSurface,
          size: isPrimary ? 40 : 28,
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String value, String label) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
